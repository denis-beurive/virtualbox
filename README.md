# Introduction

This repository contains a script that can be used to build a VirtualBox virtual machine.

# Prerequisites

Check the version of VirtualBox that you are using.
It must be greater or equal to `5.2.0`.

    VBoxManage --version
  
Make sure that you've installed the extension pack:

    VBoxManage list extpacks

If the extension pack is not installed, then you cannot open a remote desktop connexion to the guest. This makes the installation process impossible.

To install the extension pack:

* Download the file that contains the extension pack. You find it on [this link](https://download.virtualbox.org/virtualbox). Click on the link that represents the major version of VirtualBox that you are using. For example, if you are using version `5.2.26r128414`, then click on `5.2.26`. Then download the file named `Oracle_VM_VirtualBox_Extension_Pack-<the exact version of virtualbox>.vbox-extpack`.
* Run the command below:

    VBoxManage extpack install --replace "Oracle_VM_VirtualBox_Extension_Pack-<the exact version of virtualbox>.vbox-extpack"

For example:

    VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-5.2.26-128414.vbox-extpack

# Configuration

Edit the file `build.sh` and set the values of the variables listed below:

* **VM_NAME**: the (arbitrary) name of the VM.
* **VM_TYPE**: the OS type.
* **VM_ISO_NAME**: the basename of the file that contains the ISO file. By default the ISO file must be stored under the directory `iso`. This can be changed however (see the variable **VM_ISO_FOLDER**).

> Possible values for VM_TYPE can be found on [this link](https://www.virtualbox.org/browser/vbox/trunk/src/VBox/Main/src-all/Global.cpp).

