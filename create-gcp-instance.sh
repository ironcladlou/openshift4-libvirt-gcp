#!/bin/bash

# This script is meant to run in openshift-gce-devel project
# If not in openshift-gce-devel, the network and subnet will need to be created.
# For network, subnet creation see create-network-and-subnet.sh

bold=$(tput bold)
bright=$(tput setaf 14)
reset=$(tput sgr0)

echo_bright() {
    echo "${bold}${bright}$1${reset}"
}

echo "${bold}Creating GCP resources${reset}"
if [[ -z "$INSTANCE" ]] || [[ -z "$PULL_SECRET" ]] || [[ -z "$GCP_USER" ]]; then
    echo the following environment variables must be provided:
    echo "\$INSTANCE to name gcp resources"
    echo "\$PULL_SECRET path to your pull-secret"
    echo "\$GCP_USER your gcp username to scp pull-secret to gcp instance"
    exit 1
fi
set -euo pipefail

export ZONE=$(gcloud config get-value compute/zone)
export PROJECT=$(gcloud config get-value project)
# This network is in openshift-gce-devel project
export NETWORK=ocp4-libvirt-dev

echo_bright "Creating instance ${INSTANCE} in project ${PROJECT}"
gcloud compute instances create "${INSTANCE}" \
  --image-family openshift4-libvirt \
  --zone us-east1-c \
  --min-cpu-platform "Intel Haswell" \
  --machine-type n1-standard-16 \
  --boot-disk-type pd-ssd --boot-disk-size 256GB \
  --network "${NETWORK}" \
  --subnet "${NETWORK}"

echo_bright "Using scp to copy pull-secret to /home/${GCP_USER}/pull-secret in instance ${INSTANCE}"
timeout 45s bash -ce 'until \
    gcloud compute --project "${PROJECT}" scp \
      --quiet \
      --zone "${ZONE}" \
      -- "${PULL_SECRET}" "${GCP_USER}"@"${INSTANCE}":"${HOME}"/pull-secret; do sleep 5; done'

echo "${bold}All resources successfully created${reset}"
echo "${bold}Use this command to ssh into the VM:${reset}"
echo_bright "gcloud beta compute ssh --zone ${ZONE} ${INSTANCE} --project ${PROJECT}"
echo ""
echo "${bold}To delete the instance, run:${reset}"
echo_bright "gcloud compute instances delete ${INSTANCE}"
