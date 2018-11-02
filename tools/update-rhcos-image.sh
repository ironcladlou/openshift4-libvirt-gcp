#!/bin/bash

build=$(curl -s https://releases-rhcos.svc.ci.openshift.org/storage/releases/maipo/builds.json | jq -r '.builds[0]')
image=$(curl -s https://releases-rhcos.svc.ci.openshift.org/storage/releases/maipo/$build/meta.json | jq -r '.images["qemu"].path')
url="https://releases-rhcos.svc.ci.openshift.org/storage/releases/maipo/$build/$image"
output="$HOME/redhat-coreos-maipo-latest-qemu.qcow2"

echo "Downloading rhcos $build to $output"
curl --compressed -L -o $HOME/redhat-coreos-maipo-latest-qemu.qcow2 $url
