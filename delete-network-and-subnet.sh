#!/bin/bash

bold=$(tput bold)
bright=$(tput setaf 14)
reset=$(tput sgr0)

echo_bright() {
    echo "${bold}${bright}$1${reset}"
}

echo "${bold}Deleting GCP resources${reset}"
if [[ -z "$ID" ]]; then
    echo the following environment variables must be provided:
    echo "\$ID to name gcp network and subnet"
    exit 1
fi
set -euo pipefail

export ZONE=$(gcloud config get-value compute/zone)
export PROJECT=$(gcloud config get-value project)
echo_bright "Deleting firewall rules for network ${ID}"
gcloud compute firewall-rules delete "${ID}" --quiet || true

echo_bright "Deleting subnet for network ${ID}"
gcloud compute networks subnets delete "${ID}" --quiet || true

echo_bright "Deleting network ${ID}"
gcloud compute networks delete "${ID}" --quiet || true



echo "${bold}Network and subnet successfully deleted${reset}"
