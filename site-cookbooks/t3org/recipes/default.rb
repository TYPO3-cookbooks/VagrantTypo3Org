#
# Cookbook Name:: typo3
# Recipe:: default
#
# Copyright 2012, Fabien Udriot
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


#######################################
# Variables
#######################################
t3o_package = "t3o-vagrant"
t3o_package_compressed = "t3o-vagrant-big-file-being-downloaded.tar.gz"
t3o_package_url = "http://www.dev.t3o.typo3.org/t3o-vagrant.tar.gz"
storing_directory = "/var/cache/t3org.dev"
home_directory = "/var/www/vhosts/t3org.dev"

#######################################
# Install some more dependencies
#######################################
include_recipe "apache2::mod_php5"

template "/etc/php5/apache2/php.ini" do
  source "php.erb"
  owner "root"
  group "root"
  notifies :restart, 'service[apache2]'
end

#######################################
# Install restore script
#######################################
template "#{storing_directory}/restore_backup.sh" do
  source "restore_backup.erb"
  owner "root"
  group "root"
  mode "0755"
end

directory storing_directory do
	action :create
	recursive true
end

directory home_directory do
	action :create
	recursive true
end

#######################################
# Download typo3 pacakge
#######################################
remote_file "#{storing_directory}/#{t3o_package_compressed}" do

  # Doesn't display the message as expected ;(
  #Chef::Log.info "Downloading typo3.org package (over 600 Mb)..."
  source "#{t3o_package_url}"
  mode "0644"
  action :create_if_missing
end

#######################################
# Extract typo3 package
#######################################
bash "extract_typo3_package_can_take_some_time" do
  not_if {::File.exists? "#{storing_directory}/#{t3o_package}"}
  user "root"
  cwd "#{storing_directory}"
  code <<-EOF

    echo "Extract archive..."
    tar -zxf #{t3o_package_compressed}
    chown -R root:root #{t3o_package}
  EOF
end

#######################################
# Deploy typo3 package
#######################################
bash "deploy_typo3_package_can_take_some_time" do
  not_if {::File.exists? "#{home_directory}/www/typo3/"}
  user "root"
  code <<-EOF

    echo "Reset file system..."
    rm -rf #{home_directory}
    mkdir -p #{home_directory}

    echo "Running restore backup script which will take some time..."
    #{storing_directory}/restore_backup.sh -u root -p root -h localhost -d t3orgdev -r #{home_directory} -s #{storing_directory}/#{t3o_package} -f

    mv #{home_directory}/htdocs #{home_directory}/www

    # Set permissions to maximal since in development
    chown -R www-data:www-data #{home_directory}/www
    chmod -R 777 #{home_directory}/www

    # Create ENABLE_INSTALL_TOOL
    touch #{home_directory}/www/typo3conf/ENABLE_INSTALL_TOOL

    # Todo edit
    # sed '5f4dcc3b5aa765d61d8327deb882cf99';  by 5f4dcc3b5aa765d61d8327deb882cf99

    # Debug
    #exit 1
  EOF
  notifies :restart, "service[apache2]"
  notifies :run, "execute[solr-updateConnections]"
end

execute "solr-updateConnections" do
  # This might fail but is not critical for the provisioning
  command "php #{home_directory}/www/typo3/cli_dispatch.phpsh solr updateConnections || true"
  user "www-data"
  group "www-data"
  action :nothing
end
