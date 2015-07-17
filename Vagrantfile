# -*- mode: ruby -*-
# vi: set ft=ruby :
#
VAGRANTFILE_API_VERSION = '2'

features = {
    # enable if provisioning fails
    :chef_verbose => false,
    # boot VirtualBox with GUI - usually just an annoying window, but helpful if you can't connect via SSH
    :gui => false,
    # run a SOLR server
    :solr => true,
    # enable Rabbit MQ
    :rabbit_mq => true,
    # if enabled, set the "t3org.dev" hostname to 192.168.156.124 in your local /etc/hosts
    :varnish => false,
    # is configured for PHPSTORM on port 9000 by default - check below to change the settings
    :xdebug => false,
}


# if you don't want to develop on the TER FE or Solr search itself, feel free to comment out the t3o-solr part
vms = {
  "t3o-web" => {
    :hostname  => "t3org.dev",
    :ipaddress => "192.168.156.122",
    :run_list => "role[typo3],role[t3org]",
    :cpus => "2",
    :memory => "1024"
  },
}

if features[:rabbit_mq]
  vms["t3o-web"][:run_list] += ',role[t3org-rabbitmq]'
end

if features[:solr]
  vms["t3o-solr"] = {
    :hostname  => "t3o-solr.dev",
    :ipaddress => "192.168.156.123",
    :run_list => "role[solr]",
    :cpus => "1",
    :memory => "1024"
  }
end

if features[:varnish]
    vms["t3o-proxy"] = {
        :hostname  => "t3-proxy.dev",
        :ipaddress => "192.168.156.124",
        :run_list => "role[t3org-proxy]",
        :cpus => "1",
        :memory => "512"
    }
end

if defined?(::VagrantPlugins::LibrarianChef)
	# it will just use its own cookbooks and not the one we added in this repo
	raise 'The vagrant plugin "vagrant-librarian-chef" is known to cause issues during provision. Please uninstall it by running "vagrant plugin uninstall vagrant-librarian-chef".'
end

Vagrant.configure('2') do |global_config|
  # This is the version used previously… installed here via
  # vagrant-omnibus from https://github.com/chef/vagrant-omnibus
  # This is a required plugin!
  # TODO: Write a check like LibrarianChef above to warn if plugin is
  # missing…
  global_config.omnibus.chef_version = '10.16.2'

  vms.each_pair do |name, options|
    global_config.vm.define name do |config|
      ipaddress = options[:ipaddress]

      config.vm.box = 'typo3/squeeze'
      config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-6.0.10_chef-provisionerless.box'
      config.vm.network 'private_network', ip: ipaddress
      config.vm.host_name = name

      if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.2')
        share_folder_options = {:create => true, :nfs => false, :mount_options => ['dmode=777','fmode=777']}
      else
        share_folder_options = {:create => true, :nfs => false, :extra => 'dmode=777,fmode=777'}
      end

      if name == "t3o-web"
        if (RUBY_PLATFORM =~ /mingw32/).nil?
          # TODO: Probably needs checks… cannot test mingw32 stuff…
          # May only run on non-Windows systems (symlinks won't work otherwise)
          #config.vm.share_folder "package", "/var/cache/t3org.dev", "./tmp/package", share_folder_options
          #config.vm.share_folder "web", "/var/www/vhosts/t3org.dev", "./web", share_folder_options
        end
      end

      config.vm.provision 'chef_solo' do |chef|
        chef.cookbooks_path  = ["cookbooks", "site-cookbooks"]
        chef.roles_path      = ["roles"]
        chef.data_bags_path  = ["data_bags"]

        chef.json = {}

        unless ENV['REINSTALL'].nil?
            chef.json.merge! ({
                :t3org => {
                    :forceInstall => true,
                }
            })
        end

        # uncomment to enable xdebug
        if features[:xdebug]
            chef.json.merge! ({
                :dev => {
                    :xdebug => {
                        :remote => {
                             :enable => true,
                             :host => '10.0.2.2',
                             :port => 9000,
                             :idekey => 'PHPSTORM',
                        }
                    }
                }
            })
        end

        # Turn on verbose Chef logging if necessary
        chef.log_level      = features[:chef_verbose] ? :debug : :info

        # List the recipies you are going to work on/need.
        run_list = []
        run_list << "role[debian]"
        run_list << "role[base]"
        run_list << "role[vagrant]"
        run_list << ENV['CHEF_RUN_LIST'].split(",") if ENV.has_key?('CHEF_RUN_LIST')
        chef.run_list = [run_list, options[:run_list].split(",")].flatten
      end

      config.vm.provider 'virtualbox' do |v, override|
        v.name = name
        v.memory = options[:memory] || "1024"
        v.cpus = 1
        v.gui = features[:gui]
        v.customize [
          "setextradata", :id,
          "VBoxInternal2/SharedFoldersEnableSymlinksCreate/package", "1"
        ]
        v.customize [
          "setextradata", :id,
          "VBoxInternal2/SharedFoldersEnableSymlinksCreate/web", "1"
        ]
      end

      config.vm.provider 'vmware_fusion' do |v, override|
        v.vmx['memsize'] = options[:memory] || "1024"
        v.vmx['numvcpus'] = 1
        v.gui = features[:gui]
        override.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_debian-6.0.10_chef-provisionerless.box'
      end
    end
  end
end
