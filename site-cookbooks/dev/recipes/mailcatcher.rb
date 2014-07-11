# exim4 and mutt where used previously for mail catching, but are not needed anymore
%w{sendmail postfix exim4 mutt}.each do |name|
  package name do
    action :remove
  end
end

package 'dpkg' # start-stop-daemon
package 'ruby1.9.1'
package 'libsqlite3-dev' # building mailcatcher gem

gem_package 'mailcatcher' do
  version node['dev']['mailcatcher']['version']
  notifies :restart, 'service[mailcatcher]', :delayed
end

template '/etc/init.d/mailcatcher' do
  source 'mailcatcher/initd.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  notifies :restart, 'service[mailcatcher]', :delayed
end

service 'mailcatcher' do
  supports :restart => true, :reload => false, :status => false
  action [:enable, :start]
end

