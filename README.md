# Introduction

This repository contains a script (`build.sh`) that can be used to build a VirtualBox virtual machine.

Please note that:

* This script will configure [port forwarding with NAT](https://www.virtualbox.org/manual/ch06.html#natforward) between the host and the guest. Four port forwarding rules are configured:
  * One rule for SSH.
  * One rule for FTP.
  * One rule for HTTP.
  * One rule for MySql.

# Prerequisites

Check the version of VirtualBox that you are using.
It must be greater or equal to `5.2.0`.

    VBoxManage --version
  
Make sure that you've installed the extension pack:

    VBoxManage list extpacks

If the extension pack is not installed, then you cannot open a remote desktop connexion to the guest. This makes the installation process impossible.

To install the extension pack:

* Download the file that contains the extension pack. You find it on [this link](https://download.virtualbox.org/virtualbox). Click on the link that represents the major version of VirtualBox that you are using. For example, if you are using version `5.2.26r128414`, then click on `5.2.26`. Then download the file named `Oracle_VM_VirtualBox_Extension_Pack-<the exact version of virtualbox>.vbox-extpack`.
* Run this command: `VBoxManage extpack install --replace "Oracle_VM_VirtualBox_Extension_Pack-<the exact version of virtualbox>.vbox-extpack"`

For example:

    VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-5.2.26-128414.vbox-extpack

# Configuration

The names of the configuration listed below depends on the environment variable `VBOX_ENV`.

If the environment variable `VBOX_ENV` is **NOT** set, then the script `build.sh`  will load the configuration files listed below:

* `vm-env.sh`
* `net-env.sh`
* `sys-env.sh`

Otherwise, the script `build.sh`  will load the configuration files listed below:

* `vm-env-${VBOX_ENV}.sh`
* `net-env-${VBOX_ENV}.sh`
* `sys-env-${VBOX_ENV}.sh`

> The variable `VBOX_ENV` allows you to create several sets of configuration files (for different environments).

## vm-env.sh: elements used to build the VM

Edit the file `vm-env.sh` and set the values of the variables listed below:

* **VM_NAME**: the (arbitrary) name of the VM.
* **VM_TYPE**: the OS type.
* **VM_ISO_NAME**: the basename of the file that contains the ISO file. By default the ISO file must be stored under the directory `iso`. This can be changed however (see the variable **VM_ISO_FOLDER**).

> Possible values for VM_TYPE can be found on [this link](https://www.virtualbox.org/browser/vbox/trunk/src/VBox/Main/src-all/Global.cpp).

## net-env.sh: set the port numbers

Edit the file `net-env.sh` and set the values of the variables listed below:

* **PORT_FTP**: FTP port as seen from the host.
* **PORT_SSH**: SSH port as seen from the host.
* **PORT_HTTP**: HTTP port as seen from the host.
* **PORT_MYSQL**: MYSQL port as seen from the host.

## sys-env.sh

If you want to put the ISO file, the VDI file and the VMs in specific locations, then edit the file `sys-env.sh`.

* **VM_FOLDER**: path to the directory where Virtual Box will store the VMs.
* **VM_ISO_FOLDER**: path to the directory where you put the ISO file.
* **VM_VDI_FOLDER**: path to the directory where you want to put the VDI files.

# Generic notes

## Path to Virtual Boc configurations and LOGs

    $HOME/.config/VirtualBox/

## Path to VMs

    VBoxManage list systemproperties | grep "Default machine folder:" | sed 's/^Default machine folder:\s*//'

## Start the VM

    VBoxHeadless --startvm "ubuntu-minimal-18.04" --vrde on

## Stop the VM

    VBoxManage controlvm "ubuntu-minimal-18.04" poweroff

> You must stop the VM at the end of the installation process. Do not restart the VM from the installation menu. You need to eject the installation DVD before restarting the VM. And you cannot eject the DVD while the VM is running.

## List all VMs

List all available VMs:

    VBoxManage list vms

List all inaccessible VMs:

    VBoxManage list vms | egrep "^\"<inaccessible>\"" | sed 's/^.*{//; s/}$//'

List all accessible VMs:

    VBoxManage list vms | egrep -v "^\"<inaccessible>\"" | sed 's/^.*{//; s/}$//'

    # or:

    VBoxManage list vms | egrep -v "^\"<inaccessible>\"" | sed 's/" .*$//; s/^"//'

List all running VMs:

    VBoxManage list runningvms

## Delete a VM

    VBoxManage unregistervm <uuid|vmname> [--delete]

Delete all inaccessible VMs:

    for id in $(VBoxManage list vms | egrep "^\"<inaccessible>\"" |  sed 's/^.*{//; s/}$//'); do
        echo "removing ${id}"
        VBoxManage unregistervm "${id}" --delete 2> /dev/null
    done
    if [ $(VBoxManage list vms | egrep "^\"<inaccessible>\"" |  sed 's/^.*{//; s/}$//' | wc -l) -eq 0 ]; then
        echo "SUCCESS"
    else
        echo "ERROR"
    fi

## Show the VirtualBox configuration for a VM

    VBoxManage showvminfo <name of the VM>

    Or (useful if you write scripts):

    VBoxManage showvminfo <name of the VM> --machinereadable

> This information describes the "static" configuration of a VM.

## Show guest properties

List the available properties:

    VBoxManage guestproperty enumerate <name of the VM>

Get a specific property, identified by its ID:

    VBoxManage guestproperty get <name of the VM> <property ID>

> This information describes the "current" state of a guest. It depends on whether the guest is running or not.

For example:

    $ VBoxManage guestproperty enumerate py
    Name: /VirtualBox/GuestInfo/OS/Product, value: Linux, timestamp: 1551948596559842000, flags: 
    Name: /VirtualBox/GuestInfo/Net/0/V4/IP, value: 10.0.2.15, timestamp: 1551948596570365000, flags: 
    Name: /VirtualBox/GuestInfo/Net/0/MAC, value: 080027E4FEC3, timestamp: 1551948596571229000, flags: 
    Name: /VirtualBox/GuestInfo/OS/ServicePack, value: , timestamp: 1551948596561376000, flags: 
    Name: /VirtualBox/HostInfo/VBoxVerExt, value: 5.2.26, timestamp: 1551948566576963000, flags: TRANSIENT, RDONLYGUEST
    Name: /VirtualBox/GuestInfo/Net/0/V4/Netmask, value: 255.255.255.0, timestamp: 1551948596570679000, flags: 
    Name: /VirtualBox/GuestInfo/OS/Version, value: #1 SMP Debian 4.9.144-3.1 (2019-02-19), timestamp: 1551948596560978000, flags: 
    Name: /VirtualBox/GuestAdd/VersionExt, value: 5.2.26, timestamp: 1551948596561769000, flags: 
    Name: /VirtualBox/GuestAdd/Revision, value: 128414, timestamp: 1551948596562767000, flags: 
    Name: /VirtualBox/HostGuest/SysprepExec, value: , timestamp: 1551948566576613000, flags: TRANSIENT, RDONLYGUEST
    Name: /VirtualBox/GuestInfo/OS/LoggedInUsers, value: 1, timestamp: 1551948596566065000, flags: TRANSIENT, TRANSRESET
    Name: /VirtualBox/GuestInfo/Net/0/Status, value: Up, timestamp: 1551948596571334000, flags: 
    Name: /VirtualBox/GuestInfo/Net/0/Name, value: enp0s3, timestamp: 1551948596571436000, flags: 
    Name: /VirtualBox/HostGuest/SysprepArgs, value: , timestamp: 1551948566576660000, flags: TRANSIENT, RDONLYGUEST
    Name: /VirtualBox/GuestAdd/Version, value: 5.2.26, timestamp: 1551948596561638000, flags: 
    Name: /VirtualBox/HostInfo/VBoxRev, value: 128414, timestamp: 1551948566576996000, flags: TRANSIENT, RDONLYGUEST
    Name: /VirtualBox/GuestInfo/Net/0/V4/Broadcast, value: 10.0.2.255, timestamp: 1551948596570519000, flags: 
    Name: /VirtualBox/HostInfo/VBoxVer, value: 5.2.26, timestamp: 1551948566576928000, flags: TRANSIENT, RDONLYGUEST
    Name: /VirtualBox/GuestInfo/OS/LoggedInUsersList, value: dev, timestamp: 1551948596565490000, flags: TRANSIENT, TRANSRESET
    Name: /VirtualBox/GuestInfo/Net/Count, value: 1, timestamp: 1551948856691493000, flags: 
    Name: /VirtualBox/GuestInfo/OS/Release, value: 4.9.0-8-amd64, timestamp: 1551948596560585000, flags: 
    Name: /VirtualBox/GuestInfo/OS/NoLoggedInUsers, value: false, timestamp: 1551948596568255000, flags: TRANSIENT, TRANSRESET

If the guest is running, then it has an IP address:

    $ VBoxManage guestproperty get py /VirtualBox/GuestInfo/Net/0/V4/IP
    Value: 10.0.2.15

If the guest is not running:

    $ VBoxManage guestproperty get py /VirtualBox/GuestInfo/Net/0/V4/IP
    No value set!

## List all port forwarding rules for a given VM

A port forwarding rule is defined by:

* a **virtual network adapter**.
* a name (the name of the rule, __relatively to the virtual network adapter__).

> See [NAT Networking Settings (8.8.2.1)](https://www.virtualbox.org/manual/ch08.html):
> 
> With all these settings, the decimal number directly following the option name, 1-N in the list below, specifies the **virtual network adapter** whose settings should be changed.

The command below shows the virtual network adapters and the names of rules, and much more data.

    VBoxManage showvminfo ${VM_NAME} | egrep '^NIC [1-8] Rule'

To print only the network adapters and the names of rules, you can execute the command listed in the rest of this section.

The command below prints all the couples `(<virtual network adapter>, <name of rule>)` for a given virtual machine identified by its name.

    $ VBoxManage showvminfo ${VM_NAME} | egrep '^NIC [1-8] Rule' | sed 's/^NIC //; s/Rule([0-9]*)://; s/,.*//'
    1    name = guestftp
    1    name = guesthttp
    1    name = guestmysql
    1    name = guestssh

> `VM_NAME`: the name of the virtual box.

* **`1`**: the **virtual network adapter**
* **`guestftp`**: the name of a rule (defined within the virtual network adapter number 1).

## Delete a port forwarding rule

First, list all the couples `(<virtual network adapter>, <name of rule>)` for a given virtual machine identified by its name.

    $ VBoxManage showvminfo ${VM_NAME} | egrep '^NIC [1-8] Rule' | sed 's/^NIC //; s/Rule([0-9]*)://; s/,.*//'
    1    name = guestftp
    1    name = guesthttp
    1    name = guestmysql
    1    name = guestssh

> `VM_NAME`: the name of the virtual box.

To delete the rule "`guesthttp`" (_that is defined within the virtual network adapter number 1_):

    VBoxManage modifyvm ${VM_NAME} --natpf1 delete guesthttp

More generally:

    VBoxManage modifyvm ${VM_NAME} --natpf<N> delete <name>

## Eject the DVD

Eject the DVD after the installation: [https://techotom.wordpress.com/2012/09/22/ejecting-an-iso-from-a-virtualbox-vm-using-vboxmanage/](https://techotom.wordpress.com/2012/09/22/ejecting-an-iso-from-a-virtualbox-vm-using-vboxmanage/)

Example:

The DVD has been created using the command line below:

    VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" \
                                          --port 0 \
                                          --device 0 \
                                          --type dvddrive \
                                          --medium "${VM_ISO_PATH}"

You can see that:

* `port=0`
* `device=0`

We just attach an empty medium to the DVD:

    VBoxManage storageattach "ubuntu-minimal-18.04" \
    --storagectl "IDE Controller" \
    --port 0 \
    --device 0 \
    --medium emptydrive

> This command must be executed while the VM is halted.

You can also execute the command below:

    VBoxManage closemedium dvd "ubuntu-minimal-18.04"

## Take a snapshot

    VBoxManage snapshot "ubuntu-minimal-18.04" \
        take "fresh-install" \
        --description "This is a fresh installation"

## Install the guest addition

On the guest:

    wget https://download.virtualbox.org/virtualbox/5.2.26/VBoxGuestAdditions_5.2.26.iso

Install the tools required to build the guest addition:

As `root`:

    apt-get install gcc
    apt-get install perl
    apt-get install build-essential
    apt-get install "linux-headers-$(uname -r)"

Then mount the ISO file and run the installation script:

    mkdir iso
    mount -o loop VBoxGuestAdditions_5.2.26.iso ./iso
    cd iso
    ./VBoxLinuxAdditions.run

> This action may take a while.

Then reboot the guest:

    sudo reboot

Once the guest addition is installed, we can configure the guest to use it.

## Set a shared folder

* We want the guest user "denis" to be allowed to access the shared folder.
* On the guest, We want the shared folder to be `/home/denis/projects`.
* On the host, the shared folder will be `/home/denis/Documents/Python/shared`.

First, make sure that the _guest addition_ is installed (on the guest).

Halt the guest (executed on the guest):

    sudo halt

On the host, stop the VM:

    VBoxManage controlvm "ubuntu-minimal-18.04" poweroff

Configure the shared folder:
   
    VBoxManage sharedfolder add "ubuntu-minimal-18.04" \
               --name shared1 \
               --hostpath /home/denis/Documents/Python/shared

> Make sure that the directory specified by the option `--hostpath` exists (on the host)!

> I you need to remove the shared folder, execute the following command: `VBoxManage sharedfolder remove "ubuntu-minimal-18.04" --name shared1`

> The name "shared1" is chosen arbitrarily.

Please note that we don't specify the path to the guest where the folder will be accessible from. This configuration is done on the guest. See below.

Start the VM:

    VBoxHeadless --startvm "ubuntu-minimal-18.04" --vrde on

On the guest, we will configure the system so it will mount the shared folder (`/home/denis/Documents/Python/shared`) to a given directory at boot time.

Get the UID and the GID of the user "denis":

    denis@python-dev:~$ echo "denis UID:" $(id -u) && echo "denis GID:" $(id -g)
    denis UID: 1000
    denis GID: 1000

Make sure that the directory `/home/denis/projects` exists on the guest:

    mkdir -p /home/denis/projects

Edit the file `/etc/fstab` as `root` and add the line below:

    shared1    /home/denis/projects    vboxsf    defaults,uid=1000,gid=1000,umask=0077    0    0

> see [this document](http://debian-facile.org/doc:systeme:fstab) for details.

Make sure that the kernel module `vboxfs` exists on the guest (it should):

    $ find /lib/modules/$(uname -r) -type f -name '*.ko' | grep vboxsf
    /lib/modules/4.15.0-45-generic/misc/vboxsf.ko
    /lib/modules/4.15.0-45-generic/kernel/ubuntu/vbox/vboxsf/vboxsf.ko

On the host, make sure that the VM is well configured:

    VBoxManage showvminfo "ubuntu-minimal-18.04" | grep shared1
    Name: 'shared1', Host path: '/home/denis/Documents/Python/shared' (machine mapping), writable

> If, for some reason, you forgot to configure a shared folder on the VM, then the guest will not be able to boot correctly. The system will run in emergency mode, and you won't be able to connect through SSH. In this case, the only way to access the guest is to use a remote desktop connexion.

Now reboot the guest.

    sudo reboot

Make sure that the sharing works as expected.

On the host:

    touch /home/denis/Documents/Python/shared/test.txt

On the guest:

    if [ -e /home/denis/projects/test.txt ]; then echo "OK"; else echo "FAILED"; fi

> Please note that, for some OS, you may need to explicitly add the kernel module `vboxfs` to the list of modules loaded at boot time. You do that by adding the line "`vboxfs`" to the end of the file `/etc/modules`. However, on Ubuntu 18.04, this is not necessary.

# Notes for Ubuntu 18.04 minimal

## SSH configuration

### Basic (login/password) authentication

No SSH server is installed by default. To install it, run the command below:

    sudo apt-get install openssh-server

You can then open an SSH connexion from the host to the guest:

    ssh denis@localhost -p 2222 -o IdentitiesOnly=yes 

> This command assumes that you've created a user named "denis". We specify the port number 2222 since that's the configuration we've applied on the VM.

### Public/Private Key authentication

Then, you need to configure key authentication.

On the host, generate a set of keys:

    denis@lab ~/Documents/github/vbox/ssh $ ssh-keygen -t rsa
    Generating public/private rsa key pair.
    Enter file in which to save the key (/home/denis/.ssh/id_rsa): ./vm_python
    ...

On the host:

    cp vm_python ~/.ssh

Copy the public key on the guest. You can use scp to do that.

> You can transfer the public key from the host to the guest through HTTP. To do that, you can set up a minimal HTTP server on the host (using Busybox, for example). And, assuming that the name of the file that contains the public key is "`vm_python.pub`", you can issue the following command from the guest: `wget http:<IP>:<port>/vm_python.pub`. 

Then, on the guest:

    cd ~
    mkdir .ssh
    chmod 0700 .ssh
    cp vm_python.pub .ssh/
    cd .ssh
    chmod 0644 vm_python.pub
    cat vm_python.pub > authorized_keys2
    chmod 0644 authorized_keys2

Then, from the host, you can open an SSH connexion to the guest without the need to provide a password:

    ssh -p 2222 -o IdentitiesOnly=yes -i ~/.ssh/vm-python denis@localhost


