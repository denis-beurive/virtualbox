#!/bin/bash

function error {
    echo
    echo "An error occurred!"
    if [ $# -gt 0 ]; then
        echo $1
    fi
    echo
    exit 1
}