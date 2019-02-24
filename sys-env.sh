# Specific locations for elements:
#   - VM_ISO_FOLDER: directory used to store the ISO files.
#   - VM_FOLDER: directory used to store the VMs.
#   - VM_VDI_FOLDER: directory used to store the Virtual Disk Images.
# Note: these parameters are ignored if the value of USE_DEFAULT_LOCATIONS is set to 0.


readonly VM_FOLDER="$(get_default_machine_folder)"
readonly VM_ISO_FOLDER="${__DIR__}/iso"
readonly VM_VDI_FOLDER="${__DIR__}/vdi"
