#/bin/bash

NAME="$1"
if [ -z "$NAME" ]; then
  echo "usage: create-cluster.sh <name>"
  exit 1
fi

CLUSTER_DIR="$HOME/clusters/${NAME}"
if [ -d "$CLUSTER_DIR" ]; then
  echo "WARNING: cluster ${NAME} already exists at ${CLUSTER_DIR}"
fi

export PATH="$PATH:$PWD/bin"

export OPENSHIFT_INSTALL_BASE_DOMAIN=openshift.testing
export OPENSHIFT_INSTALL_CLUSTER_NAME=$NAME
export OPENSHIFT_INSTALL_EMAIL_ADDRESS=user@example.com
export OPENSHIFT_INSTALL_PASSWORD=user@example.com
export OPENSHIFT_INSTALL_PLATFORM=libvirt
export OPENSHIFT_INSTALL_SSH_PUB_KEY_PATH=$HOME/.ssh/id_rsa.pub
export OPENSHIFT_INSTALL_PULL_SECRET_PATH=$HOME/.openshift-pull-secret.json
export OPENSHIFT_INSTALL_LIBVIRT_URI="qemu+tcp://192.168.122.1/system"
export OPENSHIFT_INSTALL_LIBVIRT_IMAGE="file://$HOME/rhcos-qemu.qcow2"
openshift-install create cluster --log-level=debug --dir="$CLUSTER_DIR" 2>&1 | tee /tmp/installer.log
