#
# Cookbook Name:: wal_e
# Recipe:: wal_e::common

# Chef::Log.info "Enable wal-e for postgres"
wal_e_config = node["wal_e"]
wal_e_env = wal_e_config["d_env_path"]
git_reference = wal_e_config["wale_git_install_reference"]

# Chef::Log.info "install dependencies python, pip, etc..."
include_recipe "git"
include_recipe "python"
package "daemontools"
package "lzop"
package "pv"
package "libevent-dev"

# ===========================================
install_wale_src_path = "/installs/wal-e-src"
install_wale_marker_path = "/installs/wal-e-marker"
needs_wal_e_install = !::File.exists?(install_wale_marker_path) || ::IO.read(install_wale_marker_path) != git_reference

directory "/installs" do
  action :create
end

git install_wale_src_path do
  repository "https://github.com/wal-e/wal-e.git"
  revision git_reference
  only_if { !::File.exists?(install_wale_marker_path) || ::IO.read(install_wale_marker_path) != git_reference }
end

wal_e_setup_command = if wal_e_config["install_style"] == "pip"
  # https://github.com/wal-e/wal-e/issues/143
  execute "pip install --upgrade six" do
    only_if { needs_wal_e_install }
  end

  "pip install -e git+https://github.com/wal-e/wal-e.git@#{git_reference}#egg=wal-e"
else
  "python setup.py install"
end

execute wal_e_setup_command do
  cwd install_wale_src_path
  only_if { needs_wal_e_install }
end

file install_wale_marker_path do
  content git_reference
end


# ===========================================
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
