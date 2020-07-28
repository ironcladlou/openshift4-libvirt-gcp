#!/bin/bash

bold=$(tput bold)
bright=$(tput setaf 14)
reset=$(tput sgr0)

echo_bright() {
    echo "${bold}${bright}$1${reset}"
}

echo "${bold}Creating GCP resources${reset}"
if [[ -z "$INSTANCE" ]]; then
    echo the following environment variable must be provided:
    echo "\$INSTANCE to name gcp resources"
    exit 1
fi
set -euo pipefail

export ZONE=$(gcloud config get-value compute/zone)
export PROJECT=$(gcloud config get-value project)
echo_bright "Creating network ${INSTANCE}"
gcloud compute networks create "${INSTANCE}" \
  --subnet-mode=custom \
  --bgp-routing-mode=regional

echo_bright "Creating subnet for network ${INSTANCE}"
gcloud compute networks subnets create "${INSTANCE}" \
  --network "${INSTANCE}" \
  --range=10.0.0.0/9

echo_bright "Creating firewall rules for network ${INSTANCE}"
gcloud compute firewall-rules create "${INSTANCE}" \
  --network "${INSTANCE}" \
  --allow tcp:22,icmp

# Images are maintained by sally.omalley108@gmail.com
# image okd-4-5-0-0-okd-2020-06-29-110348-beta6 built june 29, 2020
# see IMAGES.md for more information
echo_bright "Creating instance ${INSTANCE} in project ${PROJECT}"
gcloud compute instances create "${INSTANCE}" \
  --image okd-4-5-0-0-okd-2020-06-29-110348-beta6 \
  --image-project okd4-280016 \
  --zone "${ZONE}" \
  --min-cpu-platform "Intel Haswell" \
  --machine-type n1-standard-4 \
  --boot-disk-type pd-ssd --boot-disk-size 128GB \
  --network "${INSTANCE}" \
  --subnet "${INSTANCE}"

echo "${bold}All resources successfully created${reset}"
echo "${bold}Use this command to ssh into the VM:${reset}"
echo_bright "gcloud beta compute ssh --zone ${ZONE} ${INSTANCE} --project ${PROJECT}"
echo ""
echo "${bold}To clean up all resources from this script, run:${reset}"
echo_bright "INSTANCE=${INSTANCE} ./teardown-gcp.sh"
