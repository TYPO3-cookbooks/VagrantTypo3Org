#see https://github.com/TYPO3-cookbooks/site-mqtypo3org/blob/master/attributes/default.rb

normal['rabbitmq']['version'] = "3.2.2"
normal['rabbitmq']['package'] = "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node[:rabbitmq][:version]}/rabbitmq-server_#{node[:rabbitmq][:version]}-1_all.deb"

# make sure that there's no guest account!
normal['rabbitmq']['enabled_users'] = [
	{
		'name' => 'admin',
		'password' => 'typo3',
		'tag' => 'administrator',
		'rights' => [
			{
				'vhost' => 'vagrant',
				'conf'  => '.*',
				'write' => '.*',
				'read'  => '.*',
			},
		],
	},
]
normal['rabbitmq']['disabled_users'] = ["guest"]

normal['rabbitmq']['virtualhosts'] = ["vagrant"]

normal['rabbitmq']['ssl'] = false

# array of all the exchanges the application (t3org.dev) wants to write to.
#
# technically this declaration is not needed and there is no application
# reading from here, but I expect it to be very helpful for everyone new
# to RabbitMQ, because they can see what's going on.
default['t3org-rabbitmq']['outgoing_exchanges'] = [
    {
        'name' => 'org.typo3.spam.user',
        'queues' => %w(org.typo3.spam.user.test org.typo3.spam.user.www org.typo3.spam.user.forge)
    },
    {
        'name' => 'org.typo3.ter.version.upload',
        'queues' => %w(org.typo3.ter.version.upload.test org.typo3.ter.version.upload.docs)
    },
    {
        'name' => 'org.typo3.ter.key.register',
        'queues' => %w(org.typo3.ter.key.register.test)
    },
    {
        'name' => 'org.typo3.ter.key.delete',
        'queues' => %w(org.typo3.ter.key.delete.test)
    },
    {
        'name' => 'org.typo3.user.register',
        'queues' => %w(org.typo3.user.register.test)
    },
]

# array of all the queues the application (t3org.dev) wants to read from
#
# technically this declaration is not needed and there is no application
# reading from here, but this makes it easier to test if messages are read.
default['t3org-rabbitmq']['incoming_queues'] = %w{
  org.typo3.spam.user.www
}
