#
# Cookbook Name:: typo3
# Recipe:: web
#
# Copyright 2012, Christian Trabold, Sebastiaan van Parijs
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

# This recipe configures the webserver

# Create webroot directory
directory "#{node['typo3']['web']['document_root']}" do
  owner node['typo3']['web']['owner']
  group node['typo3']['web']['group']
  mode "0770"
  recursive true
  action :create
end


# Link TYPO3 sources
%w{
  t3lib
  tests
  typo3
  index.php
}.each do |folder|
  link "#{node['typo3']['web']['document_root']}/#{folder}" do
    to "#{node['typo3']['dir']}/#{folder}"
    owner node['typo3']['web']['owner']
    group node['typo3']['web']['group']
  end
end


# Link TYPO3 assets
%w{
  .htaccess
  clear.gif
}.each do |folder|
  link "#{node['typo3']['web']['document_root']}/#{folder}" do
    to "#{node['typo3']['introduction']['dir']}/#{folder}"
    owner node['typo3']['web']['owner']
    group node['typo3']['web']['group']
  end
end


# Link TYPO3 tests
link "#{node['typo3']['web']['document_root']}/typo3_src" do
  to "#{node['typo3']['dir']}/tests"
  owner node['typo3']['web']['owner']
  group node['typo3']['web']['group']
end

# Create real folders - no symlinks, to avoid permission errors
%w{
  fileadmin
  typo3conf
  typo3conf/ext
  typo3conf/l10n
  typo3temp
  uploads
}.each do |folder|
  directory "#{node['typo3']['web']['document_root']}/#{folder}" do
    owner node['typo3']['web']['owner']
    group node['typo3']['web']['group']
    mode 0774
    recursive true
  end
end

# Shouldn't matter if this action repeats itself
execute "Copy introduction package to Extension folder" do
  command "cp -r #{node['typo3']['introduction']['dir']}/typo3conf/ext/introduction  #{node['typo3']['web']['document_root']}/typo3conf/ext"
end

# Create localconf.php
template "#{node['typo3']['web']['document_root']}/typo3conf/localconf.php" do
  owner node['typo3']['web']['owner']
  group node['typo3']['web']['group']
  mode 0755
  variables(
    :db_name     => "typo3_test",
    :db_user     => "typo3",
    :db_password => "typo3",
    :db_host     => "127.0.0.1"
  )
end

# Always enable install tool for easier access
file "#{node['typo3']['web']['document_root']}/typo3conf/ENABLE_INSTALL_TOOL" do
  owner node['typo3']['web']['owner']
  group node['typo3']['web']['group']
  mode 0755
  action :touch
end


# Create fixtures
template "#{node['typo3']['web']['document_root']}/typo3temp/user-fixtures.sql" do
  owner node['typo3']['web']['owner']
  group node['typo3']['web']['group']
  mode 0755
end

# TODO ct 2012-04-14 Fix permissions
directory "#{node['typo3']['web']['document_root']}" do
  owner node['typo3']['web']['owner']
  group node['typo3']['web']['group']
  mode 0755
  recursive true
end


# Create database
database_name = "typo3_test"
# externalize conection info in a ruby hash
connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

mysql_database database_name do
  connection connection_info
  action :create
end

mysql_database_user "typo3" do
  connection connection_info
  password "typo3"
  database_name "typo3_test"
  host "localhost"
  privileges [:select,:update,:insert,:create,:alter,:drop,:delete]
  action :grant
end

execute "mysql -uroot -p#{node['mysql']['server_root_password']} typo3_test < #{node['typo3']['web']['document_root']}/typo3conf/ext/introduction/Resources/Private/Subpackages/Introduction/Database/introduction.sql"
execute "mysql -uroot -p#{node['mysql']['server_root_password']} typo3_test < #{node['typo3']['web']['document_root']}/typo3temp/user-fixtures.sql"


# Create vhost config and reload webserver
Chef::Log.info "Creating web_app for TYPO3 project"
web_app node['typo3']['web']['server_name'] do
  cookbook "typo3"
  template "web_app.conf.erb"
  docroot "#{node['typo3']['web']['document_root']}/"
  server_name node['typo3']['web']['server_name']
  server_aliases node['typo3']['web']['server_aliases']
end