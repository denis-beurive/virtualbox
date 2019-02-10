# Introduction

This repository contains a script that can be used to build a VirtualBox virtual machine.

This script will configure [port forwarding with NAT](https://www.virtualbox.org/manual/ch06.html#natforward) between the host and the guest.
 
* The TCP traffic to a _host interface_, on port 2222 will be forwarded to the guest on port 22 (this is SSH).
* The TCP traffic to a _host interface_, on port 8080 will be forwarded to the guest on port 80 (this is HTTP).

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

Edit the file `build.sh` and set the values of the variables listed below:

* **VM_NAME**: the (arbitrary) name of the VM.
* **VM_TYPE**: the OS type.
* **VM_ISO_NAME**: the basename of the file that contains the ISO file. By default the ISO file must be stored under the directory `iso`. This can be changed however (see the variable **VM_ISO_FOLDER**).

> Possible values for VM_TYPE can be found on [this link](https://www.virtualbox.org/browser/vbox/trunk/src/VBox/Main/src-all/Global.cpp).

# Generic notes

## Stop the VM

    VBoxManage controlvm "ubuntu-minimal-18.04" poweroff

> You must stop the VM at the end of the installation process. Do not restart the VM from the installation menu. You need to eject the installation DVD before restarting the VM. And you cannot eject the DVD while the VM is running.

## Eject the DVD

Eject the DVD after the installation: [https://techotom.wordpress.com/2012/09/22/ejecting-an-iso-from-a-virtualbox-vm-using-vboxmanage/](https://techotom.wordpress.com/2012/09/22/ejecting-an-iso-from-a-virtualbox-vm-using-vboxmanage/)

Example:

The DVD has been create using the command line:

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

# Notes for Ubuntu 18.04 minimal

## SSH configuration

### Basic (login/password) authentication

No SSH server is installed by default. To install it, run the command below:

    sudo apt-get install openssh-server

You can then open an SSH connexion from the host to the guest:

    ssh denis@localhost -p 2222 -o IdentitiesOnly=yes 

> This command assumes that you've created a user named "denis". We specify the port number 2222 since that's the configuration we've applied on the VM.

### Public/Provate Key authentication

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


