#
# Cookbook Name:: wal_e
# Recipe:: default

# Chef::Log.info "Enable wal-e for postgres"
wal_e = node["wal_e"]
wal_e_env = "/etc/wal-e.d/env"
if 'debian' == node['platform_family']
  postgres_install_path = node['postgresql']['config']['data_directory']
else
  postgres_install_path = node['postgresql']['dir']
end
backup_push_command = "/usr/bin/envdir #{wal_e_env} /usr/local/bin/wal-e backup-push #{postgres_install_path}"

# Chef::Log.info "update postgresql configuration for wal_archiving"
node.set['postgresql']['config']["wal_level"] = "archive"
node.set['postgresql']['config']["archive_mode"] = "on"
node.set['postgresql']['config']["archive_command"] = "envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-push %p"
node.set['postgresql']['config']["archive_timeout"] = 60

# Chef::Log.info "install dependencies python, pip, etc..."
include_recipe "git"
include_recipe "python"
package "daemontools"
package "lzop"
package "pv"
package "libevent-dev"

# Chef::Log.info "install wal-e via pip"
python_pip "git+git://github.com/wal-e/wal-e.git#egg=wal-e" do
  action :install
end

# Chef::Log.info "configure wal-e s3 envdir"
directory "/etc/wal-e.d" do
  owner "root"
  group "postgres"
  mode 0750
  action :create
end

directory wal_e_env do
  owner "root"
  group "postgres"
  mode 0750
  action :create
end

# AWS_SECRET_ACCESS_KEY
file "#{wal_e_env}/AWS_SECRET_ACCESS_KEY" do
  owner "root"
  group "postgres"
  mode 0750
  action :create
  content wal_e['aws_secret_access_key']
end

# AWS_ACCESS_KEY_ID
file "#{wal_e_env}/AWS_ACCESS_KEY_ID" do
  owner "root"
  group "postgres"
  mode 0750
  action :create
  content wal_e['aws_access_key_id']
end

# WALE_S3_PREFIX
file "#{wal_e_env}/WALE_S3_PREFIX" do
  owner "root"
  group "postgres"
  mode 0750
  action :create
  content wal_e['wale_s3_prefix'] # "s3://your-lower-case-bucket-name/server-x/wal-e/"
end

# Chef::Log.info "setup cron job to do create snap shots"
cron "wal-e" do
  minute "00"
  hour "2"
  # 0 2 * * * (Daily 2:00am)
  user "postgres"
  command backup_push_command
end

if wal_e["create_initial_backup"]
  # Chef::Log.info "run the initial snap shot during the provision"
  execute "wal-e initial backup-push" do
    user "postgres"
    group "postgres"
    command backup_push_command
    only_if { ::Dir.glob("#{postgres_install_path}/pg_xlog/*.backup").empty? }
  end
end
