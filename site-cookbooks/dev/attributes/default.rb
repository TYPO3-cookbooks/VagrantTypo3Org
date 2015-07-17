default[:dev][:xdebug][:remote][:enable] = false

# seems to be a fixed IP to the VirtualBox Host
default[:dev][:xdebug][:remote][:host] = '10.0.2.2'
default[:dev][:xdebug][:remote][:port] = 9000
default[:dev][:xdebug][:remote][:idekey] = 'PHPSTORM'

default['dev']['mailcatcher']['version'] = '0.5.12'
default['dev']['mailcatcher']['listen_ip'] = '0.0.0.0'

# setting needed for composer
include_attribute 'php'
normal['php']['directives']['suhosin.executor.include.whitelist'] = 'phar'
normal['php']['directives']['sendmail_path'] = node['mailhog']['binary']['path'] + ' sendmail'
