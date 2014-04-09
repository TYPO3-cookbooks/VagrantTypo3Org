
%w{php5-xdebug}.each do |name|
  package name do
    # remove package if not needed for better performance
    action(node[:dev][:xdebug][:remote][:enable] ? :install : :remove)
  end
end

template "/etc/php5/conf.d/xdebug.ini" do
  source "xdebug/xdebug.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[apache2]"
end