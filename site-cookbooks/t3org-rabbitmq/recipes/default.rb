include_recipe "rabbitmq"

include_recipe "rabbitmq::plugin_management"
include_recipe "rabbitmq::user_management"
include_recipe "rabbitmq::mgmt_console"

rabbitmqadmin_bin = '/usr/local/bin/rabbitmqadmin'

remote_file rabbitmqadmin_bin do
  # this file is hosted by the rabbitmq::mgmt_console that was just installed
  source "http://localhost:15672/cli/rabbitmqadmin"
  mode 0744
  action :create
end

# binary call
rabbitmqadmin = "#{rabbitmqadmin_bin} -u #{node['rabbitmq']['enabled_users'][0]['name']} -p #{node['rabbitmq']['enabled_users'][0]['password']} -V #{node['rabbitmq']['virtualhosts'][0]}"


# basic idea at the moment is:
# The application (t3org.dev) only writes to exchanges and reads from queues

# create all exchanges and connect them to queues that no one will ever read ;)
node['t3org-rabbitmq']['outgoing_exchanges'].each do |exchange|
  execute "create exchange #{exchange['name']}" do
    command "#{rabbitmqadmin} declare exchange name=#{exchange['name']} type=fanout auto_delete=false durable=true"
  end

  exchange['queues'].each do |queue_name|
    execute "create queue #{queue_name}" do
      command "#{rabbitmqadmin} declare queue name=#{queue_name} auto_delete=false durable=true"
    end

    execute "bind #{exchange['name']} to #{queue_name}" do
      command "#{rabbitmqadmin} declare binding source=#{exchange['name']} destination=#{queue_name}"
      end
  end
end

# crate the queues that the application (t3org.dev) will be reading from
node['t3org-rabbitmq']['incoming_queues'].each do |queue_name|
  execute "create queue #{queue_name}" do
    command "#{rabbitmqadmin} declare queue name=#{queue_name} auto_delete=false durable=true"
  end
end