#!/bin/bash

bold=$(tput bold)
bright=$(tput setaf 14)
reset=$(tput sgr0)

echo_bright() {
    echo "${bold}${bright}$1${reset}"
}

echo "${bold}Creating GCP resources${reset}"
if [[ -z "$ID" ]]; then
    echo the following environment variables must be provided:
    echo "\$ID to name gcp network and subnet"
    exit 1
fi
set -euo pipefail

export ZONE=$(gcloud config get-value compute/zone)
export PROJECT=$(gcloud config get-value project)
echo_bright "Creating network ${ID}"
gcloud compute networks create "${ID}" \
  --subnet-mode=custom \
  --bgp-routing-mode=regional

echo_bright "Creating subnet for network ${ID}"
gcloud compute networks subnets create "${ID}" \
  --network "${ID}" \
  --range=10.0.0.0/9

echo_bright "Creating firewall rules for network ${ID}"
gcloud compute firewall-rules create "${ID}" \
  --network "${ID}" \
  --allow tcp:22,icmp

echo "${bold}Network and subnet successfully created${reset}"
