# Overview

This is a repository used for setting up a development version of typo3.org website.

For the first installation, consider one good hour to walk through all the steps. The time will depend on the speed of your network along to the the performance of your machine. There will about 1 GB to download which includes a virtual machine and the typo3.org image.

# Quick set up guide

Refer to the troubleshooting section below if any problem pops up during installation.

## 1. Enable virtualisation of your processor

Go to the BIOS and and enable the virtualisation features of your CPU.
The feature is usually called "VT -x" (Intel) or "AMD -v‎" (AMD).

## 2. Install VirtualBox

Follow this download link to install VirtualBox on your system <https://www.virtualbox.org/wiki/Downloads>.

## 3. Install Vagrant

Go to <https://www.vagrantup.com/downloads.html>, download and install the package for your OS.

If you have any issues with the latest version, try the prior minor release.

Also install the [vagrant-omnibus](https://github.com/chef/vagrant-omnibus) plugin:

	vagrant plugin install vagrant-omnibus

### alternative on Linux (Debian-like)

	apt-get install rubygems
	gem install vagrant --no-rdoc --no-ri

## 4. Download Cookbooks
	git clone git://git.typo3.org/Teams/Server/Vagrant/Typo3Org.git
	cd Typo3Org

## 5. Fire-up Vagrant

	vagrant up

## 6. Wait

Get a coffee. Or take a walk. Whatever. Vagrant might take some time to download and install everything.

## 7. Edit your /etc/hosts

Add the following lines to your /etc/hosts (C:/Windows/system32/drivers/etc/hosts for Windows users)

	192.168.156.122 typo3.dev t3org.dev
	192.168.156.123 t3o-solr.dev

## 8. Visit your website

Point your browser to <http://t3org.dev>.

## 9. Have fun

# Common tasks

## Backend login

The credentials for backend login are `admin` with password `typo3`.

## SSH connection to web server

Type ``vagrant ssh t3o-web`` in the Typo3Org folder and you are logged in without being asked for a password.

If you connect to the machine using ``ssh t3org.dev`` or any other program use the name ``vagrant`` and the password ``vagrant``.

The document root of the virtual machine is mounted to the ``/var/www/vhosts/t3org.dev/www`` folder inside the directory `Typo3Org`. 

## Modfying files

There are basically three methods to modify files on the vagrant box. Choose the one your workflow works best with.

### a) changing on the server with ssh/sftp

As described in the last chapter you can connect to vagrant via SSH or SFTP to change files directly on the VM.

### b) shared folder

Vagrant creates a shared folder for you. It is placed in the subfolder "web" on your local machine right inside
your vagrant folder (that's where the Vagrantfile is). Whenever you change a file there it is automatically changed on the VM and vice versa.

Unfortunately this might not work on a Windows Host as it does not support symlinks.

Be aware that when reinstalling the VM (see below) this shared folder is deleted. Make sure to make backups outside the folder if you need this.

### c) copying files via SSH

If you use an IDE like PHPStorm it can take care of copying files from the VM and back. 

There is a tutorial on how to this on jetbrains: <http://www.jetbrains.com/phpstorm/webhelp/working-with-web-servers-copying-files.html>

## frontend user login

In case you need a Frontend User, you can easily create one over the backend.
Create a record on PID 11 and assign the user to `User group (activated)`.

# Troubleshooting

## Uncaught exception 't3lib_cache_Exception' with message 'No table to write data to has been set using the setting "cacheTable"'

Still not sure why this happens, but it seems to be a bug in PHP that is not fixed in Squeeze.
Update to a newer PHP version:

Become root with `sudo -s`.

Edit `/etc/apt/sources.list` and add the following line:

    deb http://packages.dotdeb.org squeeze all

Execute

    wget http://www.dotdeb.org/dotdeb.gpg
    apt-key add dotdeb.gpg
    apt-get update && apt-get upgrade

When asked, keep your local version (this is default).

## Vagrant stuck (Network issue)
It happens sometimes Vagrant can not finish the setup and remains stuck most likely because of networking issues. An easy workaround is to login into the Box using the GUI window (vagrant / vagrant as username / password) and to reboot the Box with "sudo reboot".

- Run vagrant using the following line:

	config.vm.boot_mode = :gui

- Next, login using "vagrant" / "vagrant"

- Now run "sudo -s" and try to fix the problem manually:

	sudo /etc/init.d/networking restart

If that helps, you might try adding the following line to /etc/rc.local (right before "exit 0"):

	sh /etc/init.d/networking restart

(Source: <https://github.com/mitchellh/vagrant/issues/391>)

## Mounting shared folders after VirtualBox Guest Additions upgrade fails

If the VM upgrades the VirtualBox Guest Additions automatically and the kernel modules are rebuilt, a `vagrant up` might fail with the following error:

	[t3o-web] Mounting shared folders...
	[t3o-web] -- v-root: /vagrant
	The following SSH command responded with a non-zero exit status.
	Vagrant assumes that this means the command failed!

	mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` v-root /vagrant

To resolve that error, just do a `vagrant reload`, which will cause the VM to reboot and do the deployment during the successful bootup.

Note: If the `vagrant up` fails for setting up the first VM `t3o-web`, the second VM `t3o-solr` isn't created at all. To do so, type `vagrant up t3o-solr` (which will then very likely also fail after rebuilding the kernel modules, so just issue `vagrant reload` once again). 

## Debian security updates throws a 404
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

	vagrant ssh t3o-web

Execute manual update

	sudo apt-get update

Exit the ssh connection

	exit

And reload your VM

	vagrant reload

Now, the updates can be applied and the chef magic will start.

# Advanced Topics

## Suspending VMs

You can suspend your VM using the command ``vagrant suspend``. This is the recommended way of
stopping your dev environment cleanly.

## Configure Vagrant file

To adjust configuration open ``Vagrantfile`` file and change settings according to your needs.

	# Activate the GUI or run in headless mode
	config.vm.boot_mode = :gui

	# Turn on verbose Chef logging if necessary
	chef.log_level      = :debug

## Update the site to the latest version

Run the following command to download and extract the site incl. database again:
REINSTALL=true vagrant provision t3o-web

## Debugging email

t3o-web comes with a local mail server that you can access in your browser.
Mails from the TYPO3 installation will be automatically send there and will **never** leave your computer.

Go to <http://t3org.dev:1080/> to see all received mails.

If you need any other application to sent mails there use the SMTP service on port 1025.

### Tips & Tricks

  * Typing `?` shows you the inline help
  * Typing `D` and then enter `~s .*` marks all mails for deletion.
    If you now type `$` and confirm it your inbox should be clean again.
    You can also enter `~d>1d` to mark all mails older than one day to be deleted.

## Remote debugging with xdebug

t3o-web is capable of running xdebug, but it this feature is turned off by default for performance reasons.
To enable it, modify the Vagrantfile and set `features[:xdebug]` to `true`.

By default xdebug is configured to connect to PhpStorm port 9000 on the VirtualBox Host. But you can also change
that in the Vagrantfile if you use some other IDE or port.

You can trigger xdebug in the browser with a browser cookie: <http://www.jetbrains.com/phpstorm/marklets/>.
You can trigger xdebug in the CLI through environment variables like this:

    XDEBUG_CONFIG="idekey=PHPSTORM remote_port=9000" SERVER_NAME=t3org.dev SERVER_PORT=80 php commandToDebug.php

The `SERVER_*` variables are only needed by PhpStorm to allow proper mapping and might be left out in other IDEs.

## RabbitMQ

RabbitMQ comes with an administration interface that you will find on <http://t3org.dev:15672>.
Log in using the user "admin" and the password "typo3".
