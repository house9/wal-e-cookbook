#
# Cookbook Name:: wal_e
# Recipe:: master

# install wal-e
include_recipe "wal_e::common"

wal_e_config = node["wal_e"]

# set up master db config and initial backup
pg_data_path = if 'debian' == node['platform_family']
  node['postgresql']['config']['data_directory']
else
  node['postgresql']['dir']
end

backup_push_command = "#{wal_e_config['exe']} backup-push #{pg_data_path}"

Chef::Log.info "update postgresql configuration for wal_archiving"
node.set['postgresql']['config']["wal_level"] = "archive"
node.set['postgresql']['config']["archive_mode"] = "on"
node.set['postgresql']['config']["archive_command"] = "#{wal_e_config['exe']} wal-push %p"
node.set['postgresql']['config']["archive_timeout"] = 60

service 'postgresql' do
  action :restart
end

Chef::Log.info "setup cron job to do create snap shots"
cron "wal-e" do
  minute "00"
  hour "2"
  # 0 2 * * * (Daily 2:00am)
  user "postgres"
  command backup_push_command
end

Chef::Log.info "run the initial snap shot during the provision"
execute "wal-e initial backup-push" do
  user "postgres"
  group "postgres"
  command backup_push_command
  only_if { ::Dir.glob("#{pg_data_path}/pg_xlog/*.backup").empty? }
end
