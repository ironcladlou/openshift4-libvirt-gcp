#!/bin/bash

echo "Creating GCP resources"
if [[ -z "$INSTANCE" ]] || [[ -z "$PULL_SECRET" ]] || [[ -z "$GCP_USER" ]]; then
    echo the following environment variables must be provided:
    echo "\$INSTANCE to name gcp resources"
    echo "\$PULL_SECRET path to your pull-secret"
    echo "\$GCP_USER your gcp username to scp pull-secret to gcp instance"
    exit 1
fi
if [[ -z "$PULL_SECRET" ]]; then
    echo "\$PULL_SECRET path must be provided"
    exit 1
fi
if [[ -z "$GCP_USER" ]]; then
    echo "\$GCP_USER your gcp username must be provided, to scp pull-secret to gcp instance"
    exit 1
fi
set -euo pipefail
set -x
gcloud compute networks create "${INSTANCE}" \
  --subnet-mode=custom \
  --bgp-routing-mode=regional

gcloud compute networks subnets create "${INSTANCE}" \
  --network "${INSTANCE}" \
  --range=10.0.0.0/9

gcloud compute firewall-rules create "${INSTANCE}" \
  --network "${INSTANCE}" \
  --allow tcp:22,icmp


gcloud compute instances create "${INSTANCE}" \
  --image-family openshift4-libvirt \
  --zone us-east1-c \
  --min-cpu-platform "Intel Haswell" \
  --machine-type n1-standard-16 \
  --boot-disk-type pd-ssd --boot-disk-size 256GB \
  --network "${INSTANCE}" \
  --subnet "${INSTANCE}"

ZONE=$(gcloud config get-value compute/zone)
PROJECT=$(gcloud config get-value project)
gcloud compute --project "${PROJECT}" scp \
  --quiet \
  --zone "${ZONE}" \
  -- "${PULL_SECRET}" "${GCP_USER}"@"${INSTANCE}":"${HOME}"/pull-secret
