# Overview

This is a repository used for setting up a development version of typo3.org website.

For the first installation, consider one good hour to walk through all the steps. The time will depend on the speed of your network along to the the performance of your machine. There will about 1 GB to download which includes a virtual machine and the typo3.org image.

# Quick set up guide

The first commands will check if the needed software is installed.

	# Test if your system contains all the necessary software.
	vagrant help        -> Refer to "Vagrant" and "Virtualbox" chapter if command missing
	bundle help         -> Refer to "Gems" chapter if command missing
	chef-solo --help    -> Refer to "Chef" chapter if command missing

	# Add a new image that will be stored into ~/.vagrant.d/boxes/
	vagrant box add squeeze https://dl.dropbox.com/u/1467717/VirtualBoxes/squeeze.box

	# Download Recipe
	git clone git://github.com/fudriot/chef-t3org.git
	cd chef-t3org

	# Install Gem dependencies
	bundle install

	# Fire up installation
	# Refer to the troubleshooting below if anything goes wrong.
	vagrant up

	# Enter virtual machine by using vagrant itself.
	# The default username / password is vagrant / vagrant
	vagrant ssh

	# Test the website
	curl t3org.dev

	# Sugestion to access the virtual machine from "outside"
	open Vagrantfile
	# -> comment out "config.vm.network" line
	vagrant reload

	# Files system is at:
	cd /var/www/vhost/t3org.dev

Refer to the troubleshooting section below if any problem pops up during installation.

The credentials for backend login are `admin` with password `typo3`.

# Installation of the software

## Chef

To get started you need a environment as described here:

  <http://wiki.opscode.com/display/chef/Workstation+Setup>

You'll especially need

- git
- gcc compilers and headers (eg. XCode / build-essential)

To install Chef on your system, type:

	# Run as sudo if permission issue
	gem update --system
	gem install chef

## Vagrant

Vagrant can be downloaded and installed from the website [vagrantup.com](http://vagrantup.com/)

	# Run as sudo if permission issue
	gem update --system
	gem install vagrant

## VirtualBox

Follow this download link to install VirtualBox on your system <https://www.virtualbox.org/wiki/Downloads>.

## Gems

Bundler manages an application's dependencies through its entire life across many machines systematically and repeatably.

	# Run as sudo if permission issue
	gem update --system
	gem install bundler --no-ri --no-rdoc

# Configure Vagrant file

To adjust configuration open ``Vagrantfile`` file and change settings according to your needs.

	# Define IP of the virtual machine to access it from the host
	config.vm.network :hostonly, "192.168.156.122"

	# Activate the GUI or run in headless mode
	config.vm.boot_mode = :gui

	# Turn on verbose Chef logging if necessary
	chef.log_level      = :debug

## Troubleshooting

### Vagrant stuck (Network issue)
It happens sometimes Vagrant can not finish the setup and remains stuck most likely because of networking issues. An easy workaround is to login into the Box using the GUI window (vagrant / vagrant as username / password) and to reboot the Box with "sudo reboot".

- Run vagrant using the following line:

	config.vm.boot_mode = :gui

- Next, login using "vagrant" / "vagrant"

- Now run "sudo -s" and try to fix the problem manually:

	sudo /etc/init.d/networking restart

If that helps, you might try adding the following line to /etc/rc.local (right before "exit 0"):

	sh /etc/init.d/networking restart

(Source: <https://github.com/mitchellh/vagrant/issues/391>)

### Mounting shared folders after VirtualBox Guest Additions upgrade fails

If the VM upgrades the VirtualBox Guest Additions automatically and the kernel modules are rebuilt, a `vagrant up` might fail with the following error:

	[t3o-web] Mounting shared folders...
	[t3o-web] -- v-root: /vagrant
	The following SSH command responded with a non-zero exit status.
	Vagrant assumes that this means the command failed!

	mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` v-root /vagrant

To resolve that error, just do a `vagrant reload`, which will cause the VM to reboot and do the deployment during the successful bootup.

Note: If the `vagrant up` fails for setting up the first VM `t3o-web`, the second VM `t3o-solr` isn't created at all. To do so, type `vagrant up t3o-solr` (which will then very likely also fail after rebuilding the kernel modules, so just issue `vagrant reload` once again). 

### Debian security updates throws a 404
At your first "vagrant up", vagrant tries to apply all the chef recipes.
During this process, it could be that there are some security updates for the Debian box.
If the security updates throw a 404 like

	Get:1 http://http.us.debian.org/debian/ squeeze/main patch amd64 2.6-2 [120 kB]
	Err http://security.debian.org/ squeeze/updates/main linux-headers-2.6.32-5-amd64 amd64 2.6.32-41squeeze2  404  Not Found [IP: 212.211.132.32 80]
	Failed to fetch http://security.debian.org/pool/updates/main/l/linux-2.6/linux-headers-2.6.32-5-common_2.6.32-41squeeze2_amd64.deb  404  Not Found [IP: 212.211.132.32 80]
	Failed to fetch http://security.debian.org/pool/updates/main/l/linux-2.6/linux-headers-2.6.32-5-amd64_2.6.32-41squeeze2_amd64.deb  404  Not Found [IP: 212.211.132.32 80]

You have to do some manual stuff, to finish the process.
Just run the following commands:

Login in via ssh to your VM (assuming the VM is launched)

	vagrant ssh

Execute manual update

	sudo apt-get update

Exit the ssh connection

	exit

And reload your VM

	vagrant reload

Now, the updates can be applied and the chef magic will start.
