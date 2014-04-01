# -*- mode: ruby -*-
# vi: set ft=ruby :

features = {
    # enable if provisioning fails
    :chef_verbose => false,
    # boot VirtualBox with GUI - usually just an annoying window, but helpful if you can't connect via SSH
    :gui => false,
    # run a SOLR server
    :solr => true,
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

Vagrant::Config.run do |global_config|
  vms.each_pair do |name, options|
    global_config.vm.define name do |config|
      ipaddress = options[:ipaddress]

      config.ssh.max_tries = 100

      config.vm.box = "squeeze"
      config.vm.box_url = "http://st-g.de/fileadmin/downloads/2012-10/squeeze.box"
      config.vm.boot_mode = features[:gui] ? :gui : :headless
      config.vm.network :hostonly, ipaddress
      config.vm.host_name = name

      if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.2')
        share_folder_options = {:create => true, :nfs => false, :mount_options => ['dmode=777','fmode=777']}
      else
        share_folder_options = {:create => true, :nfs => false, :extra => 'dmode=777,fmode=777'}
      end
      if name == "t3o-web"
        if (RUBY_PLATFORM =~ /mingw32/).nil?
          # May only run on non-Windows systems (symlinks won't work otherwise)
          config.vm.share_folder "package", "/var/cache/t3org.dev", "./tmp/package", share_folder_options
          config.vm.share_folder "web", "/var/www/vhosts/t3org.dev", "./web", share_folder_options
        end
      end

      config.vm.share_folder "apt-cache", "/var/cache/apt/archives", "./tmp/apt", {:create => true}

      # set auto_update to false, if do NOT want to check the correct additions
      # version when booting this machine
      #config.vbguest.auto_update = false

      config.vm.provision :chef_solo do |chef|
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
        chef.log_level      = features[:chef_verbose] ? :debug : :warn

        # List the recipies you are going to work on/need.
        run_list = []
        run_list << "role[debian]"
        run_list << "role[base]"
        run_list << "role[vagrant]"
        run_list << ENV['CHEF_RUN_LIST'].split(",") if ENV.has_key?('CHEF_RUN_LIST')
        chef.run_list = [run_list, options[:run_list].split(",")].flatten

      end

      config.vm.customize [
        "modifyvm", :id,
        "--name", name,
        "--memory", options[:memory] || "1024",
        "--cpus", options[:cpus] || "1"
      ]
      config.vm.customize [
        "setextradata", :id,
        "VBoxInternal2/SharedFoldersEnableSymlinksCreate/package", "1"
      ]
      config.vm.customize [
        "setextradata", :id,
        "VBoxInternal2/SharedFoldersEnableSymlinksCreate/web", "1"
      ]
    end
  end
end
