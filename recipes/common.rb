#
# Cookbook Name:: wal_e
# Recipe:: wal_e::common

# Chef::Log.info "Enable wal-e for postgres"
wal_e_config = node["wal_e"]
wal_e_env = wal_e_config["d_env_path"]

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
  content wal_e_config['aws_secret_access_key']
end

# AWS_ACCESS_KEY_ID
file "#{wal_e_env}/AWS_ACCESS_KEY_ID" do
  owner "root"
  group "postgres"
  mode 0750
  action :create
  content wal_e_config['aws_access_key_id']
end

# WALE_S3_PREFIX
file "#{wal_e_env}/WALE_S3_PREFIX" do
  owner "root"
  group "postgres"
  mode 0750
  action :create
  content wal_e_config['wale_s3_prefix'] # "s3://your-lower-case-bucket-name/server-x/wal-e/"
end
