#!/bin/bash

bold=$(tput bold)
bright=$(tput setaf 14)
reset=$(tput sgr0)

echo_bright() {
    echo "${bold}${bright}$1${reset}"
}

echo_bright "Cleaning up GCP"
if [[ -z "$INSTANCE" ]]; then
     echo "\$INSTANCE must be provided"
fi
echo "This script will remove ${bright}${bold}$INSTANCE${reset} GCP instance."
echo "${bold}Do you want to continue (Y/n)?${reset}"
read x
if [ "$x" != "Y" ]; then
    exit 0
fi
set -x
gcloud compute instances delete "${INSTANCE}" --quiet
