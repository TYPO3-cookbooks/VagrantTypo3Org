#
# Cookbook Name:: application
# Recipe:: typo3
#
# Copyright 2012, Christian Trabold, dkd Internet Service GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

app = node.run_state[:current_app]

#Chef::Log.warn "Hello TYPO3 application! Please work me out!"

###
# You really most likely don't want to run this recipe from here - let the
# default application recipe work it's mojo for you.
###

# We need PHP
include_recipe "php"

## First, install any application specific packages
if app['packages']
  app['packages'].each do |pkg,ver|
    package pkg do
      action :install
      version ver if ver && ver.length > 0
    end
  end
end

## Next, install any application specific gems
if app['pears']
  app['pears'].each do |pear,ver|
#    execute "pyrus install #{pear}"
  end
end

#######################################
# Created database for application
#######################################

app['databases'].each do |key, stage|
  # Create database
  database_name = stage['database']

  # externalize conection info in a ruby hash
  connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

  mysql_database database_name do
    connection connection_info
    action :create
  end

  mysql_database_user stage['username'] do
    connection connection_info
    password stage['password']
    database_name stage['database']
    host stage['host']
    privileges [:select,:update,:insert,:create,:alter,:drop,:delete]
    action :grant
  end

  # TODO ct 2012-04-15 Use a LWRP for this!
  #execute "mysql -uroot -p#{node['mysql']['server_root_password']} typo3_test < #{stage['document_root']}/typo3conf/ext/introduction/Resources/Private/Subpackages/Introduction/Database/introduction.sql"
  #execute "mysql -uroot -p#{node['mysql']['server_root_password']} typo3_test < #{stage['document_root']}/typo3temp/user-fixtures.sql"
end

#######################################
# Create webroot directory
#######################################
app["stages"].each do |key, stage|
  directory "#{stage['document_root']}" do
    owner app['owner']
    group app['group']
    mode "0770"
    recursive true
    action :create
  end

  # Create vhost config and reload webserver
  Chef::Log.info "Creating web_app for TYPO3 project"
  web_app stage['server_name'] do
    cookbook "typo3"
    template "web_app.conf.erb"
    docroot "#{stage['document_root']}/"
    server_name stage['server_name']
    server_aliases stage['server_aliases']
  end
end
