#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
__DIR__="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# You should configure the constant listed below.
#
# VM_NAME:
#    arbitrary name for the VM.
#
# VM_TYPE:
#    possible values for VM_TYPE can be found on the link below.
#    https://www.virtualbox.org/browser/vbox/trunk/src/VBox/Main/src-all/Global.cpp
#
# VM_ISO_NAME:
#    basename of the ISO file.

readonly VM_NAME='ubuntu-minimal-18.04'
readonly VM_TYPE='Ubuntu_64'
readonly VM_ISO_NAME="ubuntu-minimal-18.04.iso"

# Default locations for elements:
#   - VM_ISO_FOLDER: directory used to store the ISO files.
#   - VM_FOLDER: directory used to store the VMs.
#   - VM_VDI_FOLDER: directory used to store the Virtual Disk Images.

readonly VM_ISO_FOLDER="${__DIR__}/iso"
readonly VM_FOLDER="${__DIR__}/VMs"
readonly VM_VDI_FOLDER="${__DIR__}/vdi"

# ------------------------------------------------------
# Constants
# ------------------------------------------------------

readonly VM_ISO_PATH="${VM_ISO_FOLDER}/${VM_ISO_NAME}"
readonly VM_VDI_PATH="${VM_VDI_FOLDER}/${VM_NAME}.vdi"
readonly VBOX_VERSION=$(VBoxManage --version)
readonly VBOX_MAJOR_VERSION=$(VBoxManage --version | sed 's/^\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/')
readonly VBOX_PACK_VERSION=$(VBoxManage --version | sed 's/^\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)r\(.*\)$/\1-\2/')
readonly VBOX_EXT_PACK=$(VBoxManage list extpacks | head -n 1 | sed 's/^Extension Packs: \([0-9][0-9]*\)$/\1/')
readonly VBOX_DOWNLOAD_URL="https://download.virtualbox.org/virtualbox/${VBOX_MAJOR_VERSION}"

# ------------------------------------------------------
# Preparation
# ------------------------------------------------------

cd "${VM_FOLDER}" && rm -rf * && cd - && echo "VM folder deleted"
rm -f "${VM_VDI_PATH}" && echo "VDI deleted"

function error() {
    echo "An error occurred!"
    exit 1
}

readonly MACHINES_PATH=$(VBoxManage list systemproperties | grep "Default machine folder:" | sed 's/^Default machine folder:\s*//')
if [ ! "${MACHINES_PATH}" = "${VM_FOLDER}" ]; then
    VBoxManage setproperty machinefolder "${VM_FOLDER}" || error
fi

# ------------------------------------------------------
# VM creation
# ------------------------------------------------------

VBoxManage createmedium disk --filename "${VM_VDI_PATH}" \
                             --size 32768 || error

VBoxManage createvm --name "${VM_NAME}" \
                    --ostype "${VM_TYPE}" \
                    --register || error

VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" \
                                   --add sata \
                                   --controller IntelAHCI || error

VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" \
                                      --port 0 \
                                      --device 0 \
                                      --type hdd \
                                      --medium "${VM_VDI_PATH}" || error

VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" \
                                   --add ide || error

VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" \
                                      --port 0 \
                                      --device 0 \
                                      --type dvddrive \
                                      --medium "${VM_ISO_PATH}" || error

VBoxManage modifyvm "${VM_NAME}" --audio none || error

VBoxManage modifyvm "${VM_NAME}" --ioapic on || error

VBoxManage modifyvm "${VM_NAME}" --vrde on || error

VBoxManage modifyvm "${VM_NAME}" --boot1 dvd \
                                 --boot2 disk \
                                 --boot3 none \
                                 --boot4 none || error

VBoxManage modifyvm "${VM_NAME}" --memory 2048 \
                                 --vram 128 || error

VBoxManage modifyvm "${VM_NAME}" --natpf1 "guestssh,tcp,,2222,,22" || error

VBoxManage modifyvm "${VM_NAME}" --natpf2 "guesthttp,tcp,,8080,,80" || error

echo "" && echo "SUCCESS !!!" && echo ""


if [ ${VBOX_EXT_PACK} -eq 0 ]; then
    echo
    echo "--------------------------------------------------"
    echo "WARNING! The extension packs are not installed!"
    echo "RDP connexion will not work!"
    echo "--------------------------------------------------"
    echo
    echo "You can download the extension packs on the link:"
    echo
    echo "${VBOX_DOWNLOAD_URL}" 
    echo "${VBOX_DOWNLOAD_URL}/Oracle_VM_VirtualBox_Extension_Pack-${VBOX_PACK_VERSION}.vbox-extpack" 
    echo
    echo "Install the extension packs:"
    echo
    echo "VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-${VBOX_PACK_VERSION}.vbox-extpack"
    echo
fi

echo "Link to the Guest Additions:"
echo
echo "${VBOX_DOWNLOAD_URL}"
echo "${VBOX_DOWNLOAD_URL}/VBoxGuestAdditions_${VBOX_MAJOR_VERSION}.iso" 
echo
echo "VM startup:"
echo
echo "VBoxHeadless --startvm \"${VM_NAME}\" --vrde on"
echo
echo "Get information about the virtual box:"
echo
echo "VBoxManage showvminfo \"${VM_NAME}\""
echo