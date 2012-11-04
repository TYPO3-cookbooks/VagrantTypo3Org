# -*- mode: ruby -*-
# vi: set ft=ruby :

vms = {
  "t3o-web" => {
    :hostname  => "typo3.dev t3org.dev",
    :ipaddress => "192.168.156.122",
    :run_list => "role[typo3],role[t3org]"
  },
  "t3o-solr" => {
    :hostname  => "t3o-solr.dev",
    :ipaddress => "192.168.156.123",
    :run_list => "role[solr]"
  }
}

Vagrant::Config.run do |global_config|
  vms.each_pair do |name, options|
    global_config.vm.define name do |config|
      ipaddress = options[:ipaddress]

      config.ssh.max_tries = 100

      config.vm.box = "squeeze"
      config.vm.box_url = "http://st-g.de/fileadmin/downloads/2012-10/squeeze.box"
      config.vm.boot_mode = :gui
      config.vm.network :hostonly, ipaddress
      config.vm.host_name = name

#      if name == "t3o-web"
#        config.vm.share_folder "web", "/var/www/vhosts/t3org.dev", "./web", {:create => true, :nfs => false}
#      end

      # set auto_update to false, if do NOT want to check the correct additions
      # version when booting this machine
      #config.vbguest.auto_update = false

      config.vm.provision :chef_solo do |chef|
        chef.cookbooks_path  = ["cookbooks", "site-cookbooks"]
        chef.roles_path      = ["roles"]
        chef.data_bags_path  = ["data_bags"]

        # Turn on verbose Chef logging if necessary
        chef.log_level      = :debug

        # List the recipies you are going to work on/need.
        chef.add_role     "debian"
        chef.add_role     "base"
        chef.add_role     "vagrant"
        chef.add_role     "typo3"
        chef.add_role     "t3org"

        run_list = []
        run_list << "role[debian]"
        run_list << "role[base]"
        run_list << "role[vagrant]"
        run_list << ENV['CHEF_RUN_LIST'].split(",") if ENV.has_key?('CHEF_RUN_LIST')
        chef.run_list = [options[:run_list].split(","), run_list].flatten

      end

      config.vm.customize [
        "modifyvm", :id,
        "--name", name,
        "--memory", "1024"
      ]
      config.vm.customize [
        "setextradata", :id,
        "VBoxInternal2/SharedFoldersEnableSymlinksCreate/web", "1"
      ]
    end
  end
end
