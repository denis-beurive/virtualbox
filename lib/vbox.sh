function get_default_machine_folder {
  echo $(VBoxManage list systemproperties | grep "Default machine folder:" | sed 's/^Default machine folder:\s*//')
}

function vm_exists {
  if [ $# -ne 1 ]; then
     echo "[vm_exists] Argument missing: the name of the VM to look for!"
     exit 1
  fi

  found="no"
  for name in $(VBoxManage list vms | egrep -v "^\"<inaccessible>\"" | sed 's/" .*$//; s/^"//'); do
    if [ "${name}" = "${1}" ]; then
      found="yes"
    fi  
  done
  echo "${found}"
}
