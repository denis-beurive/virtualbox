function prompt_continue {

    local question=''
    if [ $# -gt 0 ]; then
        question="${1}"
    else 
        question="Do you wish to continue? (Y/N) "
    fi

    while true; do
        read -p "${question}" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer Y or N. ";;
        esac
    done
}

