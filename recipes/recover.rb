#
# Cookbook Name:: wal_e
# Recipe:: recover

# install wal-e common functions
include_recipe "wal_e::common"

wal_e_config = node["wal_e"]
recover_config = wal_e_config["recover"]

pg_data_path = if 'debian' == node['platform_family']
  node['postgresql']['config']['data_directory']
else
  node['postgresql']['dir']
end

# STOP postgres service
service "postgresql" do
  action :stop
end

# delete data directories
delete_directories = %w(
  base
  pg_clog
  pg_multixact
  pg_notify
  pg_serial
  pg_stat_tmp
  pg_subtrans
  pg_tblspc
  pg_twophase
  pg_xlog
)

delete_directories.each do |directory_name|
  directory "#{pg_data_path}/#{directory_name}" do
    owner 'postgres'
    group 'postgres'
    recursive true
    action :delete
  end
end

# backup_fetch_command = "envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-fetch #{pg_data_path} LATEST"
backup_fetch_command = "#{wal_e_config['exe']} backup-fetch #{pg_data_path} LATEST"

Chef::Log.info "fetch latest backup from s3 for recover server"
execute "wal-e fetch latest backup" do
  user "postgres"
  group "postgres"
  command backup_fetch_command
end

# restore_command = "envdir #{wal_e_env} /usr/local/bin/wal-e wal-fetch \"%f\" \"%p\""
restore_command = "#{wal_e_config['exe']} wal-fetch \"%f\" \"%p\""
recovery_target_timeline = recover_config["recovery_target_timeline"]
recovery_target_time = recover_config["recovery_target_time"]

template "#{pg_data_path}/recovery.conf" do
  source "recovery.conf.recover.erb"
  mode 0700
  owner "postgres"
  group "postgres"
  variables({
    :restore_command => restore_command,
    :recovery_target_timeline => recovery_target_timeline,
    :recovery_target_time => recovery_target_time
  })
end

service "postgresql" do
  action :restart
end

# TODO: manual steps are now needed ?
# ssh onto box and tail postgres log
# > sudo su - postgres
# > tail -f /var/log/postgresql/postgresql-9.1-main.log
# once server is online verify data is present
# > psql -c "\l"
# > psql app1 -c "select * from sample_data_1;"

# if all is good
# update configuration making this box the new master
# new WAL files will NOT be pushed to S3 until this box is reconfigured


