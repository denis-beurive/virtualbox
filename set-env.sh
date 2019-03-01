#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
export __DIR__="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

. "${__DIR__}/lib/report.sh"

_VBoxManage='/usr/bin/VBoxManage'
_VBoxHeadless='/usr/bin/VBoxHeadless'

# Print the help.

function vmhelp {
    echo 'vmstart [<name of the VM>]'
    echo 'vmstop  [<name of the VM>]'
}

# Start a VM
# @param [#1]: The name of the VM to start.
#              If this parameter is not specified, then the function assumes that the name of the
#              VM is identified by the environment variable VM_NAME.

function vmstart {

    if [ $# -gt 1 ]; then
        echo "vmstart: too many arguments!"
        return
    fi

    local VM=""
    if [ $# -eq 0 ]; then
        if [ -z "${VM_NAME}" ]; then
            echo "vmstart: when called without argument, the environment variable VM_NAME must be defined!"
            return
        else 
            VM="${VM_NAME}"
        fi
    else
        VM="${1}"
    fi

    "${_VBoxHeadless}" --startvm "${VM}" &

    echo
    if [ $? -eq 0 ]; then
        echo "SUCCESS"
    else
        echo "FAILURE"
    fi
}

# Stop a VM
# @param [#1]: The name of the VM to stop.
#              If this parameter is not specified, then the function assumes that the name of the
#              VM is identified by the environment variable VM_NAME.

function vmstop {

    if [ $# -gt 1 ]; then
        error "vmstop: too many arguments!"
    fi

    local VM=""
    if [ $# -eq 0 ]; then
        if [ -z "${VM_NAME}" ]; then
            echo "vmstop: when called without argument, the environment variable VM_NAME must be defined!"
            return
        else 
            VM="${VM_NAME}"
        fi
    else
        VM="${1}"
    fi

    "${_VBoxManage}" controlvm "${VM}" poweroff &

    echo
    if [ $? -eq 0 ]; then
        echo "SUCCESS"
    else
        echo "FAILURE"
    fi
}
