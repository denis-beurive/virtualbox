# Return the path to the directory used by Virtual Box to keep VMs.
# Return The path to the directory used by Virtual Box to keep VMs.

function get_default_machine_folder {
  echo $(VBoxManage list systemproperties | grep "Default machine folder:" | sed 's/^Default machine folder:\s*//')
}

# Test whether a VM exists or not.
# #1 Name of the VM
# Return "yes|no".
#        If the VM already exists, then the function returns the value "yes".
#        Otherwise, it returns the value "no".

function vm_exists {
  if [ $# -ne 1 ]; then
     echo "[vm_exists] Argument missing: the name of the VM to look for!"
     exit 1
  fi

  local found="no"
  for name in $(VBoxManage list vms | egrep -v "^\"<inaccessible>\"" | sed 's/" .*$//; s/^"//'); do
    if [ "${name}" = "${1}" ]; then
      found="yes"
    fi  
  done
  echo "${found}"
}

# Get the exact version of Virtual Box, installed on the host.
# Return The exact version of Virtual Box, installed on the host.

function get_version {
    echo "$(VBoxManage --version)"
}

# Get the major version of Virtual Box, installed on the host.
# Return The major version of Virtual Box, installed on the host.

function get_major_version {
    echo "$(VBoxManage --version | sed 's/^\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/')"
}

# Get the version of the extension pack to install on the host.
# The extension pack activates the RDP connexion.
# Return The version of the extension pack to install on the host.

function get_pack_version {
    echo "$(VBoxManage --version | sed 's/^\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)r\(.*\)$/\1-\2/')"
}

# Return the number of extension packs installed on the host.
# Return The number of extension packs installed on the host.

function get_extensions_count {
    echo "$(VBoxManage list extpacks | head -n 1 | sed 's/^Extension Packs: \([0-9][0-9]*\)$/\1/')"
}

# Return the URL where all the Virtual Box components can be downloaded.
# Return The URL where all the Virtual Box components can be downloaded.

function get_download_url {
    local major_version=$(get_major_version)
    echo "https://download.virtualbox.org/virtualbox/${major_version}"
}
