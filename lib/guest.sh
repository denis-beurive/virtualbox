
# Test whither a guest gets assigned IPs or not.
# #1 Name of the VM
# Return If the gust has assigned IPs, then the function returns the value "yes".
#        Otherwise, it returns the value "no".

function guest_has_ips {

    if [ $# -ne 1 ]; then
        echo "[has_ips] Argument missing: the name of the VM to look for!"
        exit 1
    fi

    local r=$(VBoxManage guestproperty enumerate "${1}" | egrep '^Name: /VirtualBox/GuestInfo/Net/[0-9]+/V[0-9]/IP')
    if [ -z "${r}" ]; then
        echo 'no'
    else
        echo 'yes'
    fi
}


# Print all the IP addresses assigned to a given guest.
# #1 Name of the VM
# Returm The list of IP addresses assigned to the given guest.

function guest_get_ips {

    if [ $# -ne 1 ]; then
        echo "[get_guest_ip] Argument missing: the name of the VM to look for!"
        exit 1
    fi

    if [ "$(guest_has_ips "${1}")" = "no" ]; then
        echo ''
    else
        local ids=$(VBoxManage guestproperty enumerate "${1}" | egrep '^Name: /VirtualBox/GuestInfo/Net/[0-9]+/V[0-9]/IP' | sed 's/^Name: //; s/, value:.*//')

        for id in "${ids}"; do
            VBoxManage guestproperty get "${1}" "${id}" | sed 's/^Value: //'
        done
    fi
}


