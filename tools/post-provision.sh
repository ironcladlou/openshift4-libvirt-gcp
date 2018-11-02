#!/bin/bash
set -e
set -o pipefail

# Install pull secret
PULL_SECRET=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/openshift-pull-secret -H "Metadata-Flavor: Google")
echo $PULL_SECRET > $HOME/.openshift-pull-secret.json

# Set up a basic profile
cat <<EOF >> $HOME/.bash_profile
export KUBECONFIG=\$HOME/clusters/nested/auth/kubeconfig
export PATH=\$PATH:\$HOME/go/src/github.com/openshift/installer/bin
EOF

# Generate a default SSH key for VM access
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md#install-the-terraform-provider
# https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md#cache-terrafrom-plugins-optional-but-makes-subsequent-runs-a-bit-faster
echo "Installing terraform-provider-libvirt"
cat <<EOF > $HOME/.terraformrc
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
EOF
GOBIN=~/.terraform.d/plugins go get -u github.com/dmacvicar/terraform-provider-libvirt

# TODO: Pull this from a public place
echo "Downloading RHCOS image"
gsutil cp gs://rhcos/rhcos-qemu.qcow2.gz $HOME
cd $HOME
gunzip $HOME/rhcos-qemu.qcow2.gz

echo "Installing oc client"
cd $HOME
curl -OL https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar -zxf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
sudo mv $HOME/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/local/bin

# Build the installer
echo "Building installer"
git clone https://github.com/openshift/installer.git $HOME/go/src/github.com/openshift/installer
cd $HOME/go/src/github.com/openshift/installer
hack/get-terraform.sh
TAGS=libvirt_destroy hack/build.sh
