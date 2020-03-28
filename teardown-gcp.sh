#!/bin/bash
set -e
set -u
set -o pipefail

echo "Cleaning up GCP"
if [[ -z "$INSTANCE" ]]; then
     echo "\$INSTANCE must be provided"
fi
echo "This script will remove all $INSTANCE GCP resources"
echo "Do you want to continue (Y/n)?"
read x
if [ "$x" != "Y" ]; then
    exit 0
fi
set -x
gcloud compute instances delete "${INSTANCE}" --quiet
gcloud compute firewall-rules delete "${INSTANCE}" --quiet
gcloud compute networks subnets delete "${INSTANCE}" --quiet
gcloud compute networks delete "${INSTANCE}" --quiet
