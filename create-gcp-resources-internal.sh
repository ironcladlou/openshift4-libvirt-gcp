#!/bin/bash

# this is meant to run in openshift-gce-devel project
# network/subnet is set as "somaltest"

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
export NETWORK=somaltest

# Images are maintained by sally.omalley108@gmail.com
# see IMAGES.md for more information
echo_bright "Creating instance ${INSTANCE} in project ${PROJECT}"
gcloud compute instances create "${INSTANCE}" \
  --image-family okd4-somal \
  --zone "${ZONE}" \
  --min-cpu-platform "Intel Haswell" \
  --machine-type n1-standard-16 \
  --boot-disk-type pd-ssd --boot-disk-size 128GB \
  --network "${NETWORK}" \
  --subnet "${NETWORK}"

echo "${bold}All resources successfully created${reset}"
echo "${bold}Use this command to ssh into the VM:${reset}"
echo_bright "gcloud beta compute ssh --zone ${ZONE} ${INSTANCE} --project ${PROJECT}"
echo ""
echo "${bold}To clean up all resources from this script, run:${reset}"
echo_bright "INSTANCE=${INSTANCE} ./teardown-gcp.sh"
