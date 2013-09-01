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

Go to <http://downloads.vagrantup.com/tags/v1.0.7>, download and install the package for your OS.

Note: At the time of writing version 1.1 and up won't work.

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

# Troubleshooting

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

t3o-web comes with a local mail server that keeps all mails sent via the sendmail command.
To access all mails login via ssh to t3o-web

    vagrant ssh t3o-web

and start a small console email reader

    mutt

### Tips & Tricks

  * Typing `?` shows you the inline help
  * Typing `D` and then enter `~s .*` marks all mails for deletion.
    If you now type `$` and confirm it your inbox should be clean again.
    You can also enter `~d>1d` to mark all mails older than one day to be deleted.

