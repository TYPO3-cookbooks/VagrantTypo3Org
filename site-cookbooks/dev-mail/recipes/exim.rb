
# just make sure sendmail and postfix are not installed
%w{sendmail postfix}.each do |name|
  package name do
    action :remove
  end
end

# install Exim
package "exim4"

service "exim4" do
  supports :restart => true, :reload => true
  action :enable
end


template "/etc/exim4/update-exim4.conf.conf" do
  source "update-exim4.conf.conf"
  owner "root"
  group "root"
  mode "0644"
end

# this is about the equivalent to "dpkg-reconfigure exim4", but automated
execute "/usr/sbin/update-exim4.conf"

# configure a catchall route
template "/etc/exim4/conf.d/router/175_exim4-config_catchall" do
  source "175_exim4-config_catchall"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[exim4]"
end