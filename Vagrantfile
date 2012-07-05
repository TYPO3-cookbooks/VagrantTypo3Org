# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.ssh.max_tries = 100

  config.vm.box = "debian-6-amd64"
  config.vm.box_url = "http://dl.dropbox.com/u/1467717/VirtualBoxes/debian-6-amd64.box"
  config.vm.boot_mode = :gui
  #config.vm.network :hostonly, "192.168.156.122"
  config.vm.host_name = 'typo3.dev t3org.dev'

  # set auto_update to false, if do NOT want to check the correct additions
  # version when booting this machine
  #config.vbguest.auto_update = false

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path  = ["cookbooks", "site-cookbooks"]
    chef.roles_path      = ["roles"]
    chef.data_bags_path  = ["data_bags"]

    # Turn on verbose Chef logging if necessary
    #chef.log_level      = :debug

    # List the recipies you are going to work on/need.
    chef.add_role     "debian"
    chef.add_role     "base"
    chef.add_role     "vagrant"
    chef.add_role     "typo3"
    chef.add_role     "t3org"
  end

  config.vm.customize [
    "modifyvm", :id,
    "--name", "typo3.dev",
    "--memory", "512"
  ]
end
