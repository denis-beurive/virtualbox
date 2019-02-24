#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
export __DIR__="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

. "${__DIR__}/lib/report.sh"
. "${__DIR__}/lib/types.sh"

function get_default_machine_folder() {
  echo $(VBoxManage list systemproperties | grep "Default machine folder:" | sed 's/^Default machine folder:\s*//')
}

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

# Set network configration

. "${__DIR__}/net-env.sh"

# Specific locations for elements:
#   - VM_ISO_FOLDER: directory used to store the ISO files.
#   - VM_FOLDER: directory used to store the VMs.
#   - VM_VDI_FOLDER: directory used to store the Virtual Disk Images.
# Note: these parameters are ignored if the value of USE_DEFAULT_LOCATIONS is set to 0.

. "${__DIR__}/sys-env.sh"

# ------------------------------------------------------
# Constants
# ------------------------------------------------------

readonly VM_ISO_PATH="${VM_ISO_FOLDER}/${VM_ISO_NAME}"
readonly VM_VDI_PATH="${VM_VDI_FOLDER}/${VM_NAME}.vdi"

readonly VBOX_VERSION=$(VBoxManage --version)
readonly VBOX_MAJOR_VERSION=$(echo "${VBOX_VERSION}" | sed 's/^\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/')
readonly VBOX_PACK_VERSION=$(echo "${VBOX_VERSION}" | sed 's/^\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)r\(.*\)$/\1-\2/')
readonly VBOX_EXT_PACK=$(VBoxManage list extpacks | head -n 1 | sed 's/^Extension Packs: \([0-9][0-9]*\)$/\1/')
readonly VBOX_DOWNLOAD_URL="https://download.virtualbox.org/virtualbox/${VBOX_MAJOR_VERSION}"

if [ $(isInteger "${VBOX_EXT_PACK}") -eq 0 ]; then error "Cannot determine whether the extension packs are installed or not!"; fi
if [ $(isVersionNumber "${VBOX_MAJOR_VERSION}") -eq 0 ]; then error "Cannot determine VirtualBox major version number!"; fi

echo
echo "------------------------------------------------------------"
echo "Version:            ${VBOX_VERSION}"
echo "Major version:      ${VBOX_MAJOR_VERSION}"
echo "Ext pack URL tag:   ${VBOX_PACK_VERSION}"
echo "Ext pack installed: ${VBOX_EXT_PACK}"
echo "------------------------------------------------------------"
echo
echo "VM folder:  ${VM_FOLDER}"
echo "ISO folder: ${VM_ISO_FOLDER}"
echo "VDI folder: ${VM_VDI_FOLDER}"
echo
echo "FTP port:   ${PORT_FTP}"
echo "HTTP port:  ${PORT_HTTP}"
echo "SSH port:   ${PORT_SSH}"
echo "MySql port: ${PORT_MYSQL}"
echo

while true; do
    read -p "Do you wish to continue?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# ------------------------------------------------------
# Preparation
# ------------------------------------------------------

if [ -d "${VM_FOLDER}/${VM_NAME}" ]; then
  cd "${VM_FOLDER}/${VM_NAME}" && rm -rf * && cd - && echo "VM folder deleted"
fi

if [ -f "${VM_VDI_PATH}" ]; then
  rm -f "${VM_VDI_PATH}" && echo "VDI deleted"
fi

sleep 2

readonly MACHINES_PATH=$(get_default_machine_folder)
if [ ! "${MACHINES_PATH}" = "${VM_FOLDER}" ]; then
    VBoxManage setproperty machinefolder "${VM_FOLDER}" || error "Cannot set the path to the machines directory!"
fi

# ------------------------------------------------------
# VM creation
# ------------------------------------------------------

VBoxManage createmedium disk --filename "${VM_VDI_PATH}" \
                             --size 32768 || error "Cannot create the medium"

VBoxManage createvm --name "${VM_NAME}" \
                    --ostype "${VM_TYPE}" \
                    --register || error "Cannot create the VM"

VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" \
                                   --add sata \
                                   --controller IntelAHCI || error "Cannot add the SATA storage controller (for the hard drive)"

VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" \
                                      --port 0 \
                                      --device 0 \
                                      --type hdd \
                                      --medium "${VM_VDI_PATH}" || error "Cannot attach the hard drive"

VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" \
                                   --add ide || error "Cannot add the IDE storage controller (for the DVD)"

VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" \
                                      --port 0 \
                                      --device 0 \
                                      --type dvddrive \
                                      --medium "${VM_ISO_PATH}" || error "Cannot attach the DVD"

VBoxManage modifyvm "${VM_NAME}" --audio none || error "Cannot disable the audio"

VBoxManage modifyvm "${VM_NAME}" --ioapic on || error "Cannot enable IO APIC"

VBoxManage modifyvm "${VM_NAME}" --vrde on || error "Cannot enable VRDE (for remote desktop connexion)"

VBoxManage modifyvm "${VM_NAME}" --boot1 dvd \
                                 --boot2 disk \
                                 --boot3 none \
                                 --boot4 none || error "Cannot set the boot order"

VBoxManage modifyvm "${VM_NAME}" --memory 2048 \
                                 --vram 128 || error "Cannot set the RAM quantity"

VBoxManage modifyvm "${VM_NAME}" --natpf1 "guestssh,tcp,,${PORT_SSH},,22" || error "Can not configure NAT for SSH"

VBoxManage modifyvm "${VM_NAME}" --natpf2 "guesthttp,tcp,,${PORT_HTTP},,80" || error "Can not configure NAT for HTTP"

VBoxManage modifyvm "${VM_NAME}" --natpf2 "guestmysql,tcp,,${PORT_MYSQL},,3306" || error "Can not configure NAT for MySql"

VBoxManage modifyvm "${VM_NAME}" --natpf2 "guestftp,tcp,,${PORT_FTP},,21" || error "Can not configure NAT for FTP"

echo "" && echo "SUCCESS !!!" && echo ""

if [ ${VBOX_EXT_PACK} -eq 0 ]; then
    echo
    echo "------------------------------------------------------------"
    echo "WARNING! The extension packs are not installed!"
    echo "RDP connexion will not work!"
    echo "------------------------------------------------------------"
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

echo
echo
echo "Link to the Guest Additions (to be installed on the gest):"
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
echo "Stop the VM:"
echo 
echo "VBoxManage controlvm \"${VM_NAME}\" poweroff"
echo 
echo "Remove the CDROM"
echo
echo "VBoxManage storageattach \"${VM_NAME}\" \\"
echo "    --storagectl \"IDE Controller\" \\"
echo "    --port 0 \\"
echo "    --device 0 \\"
echo "    --medium emptydrive"
echo