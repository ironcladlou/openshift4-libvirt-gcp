#!/bin/bash
set -e
set -u
set -o pipefail
set -x

# Install tools
sudo mv /tmp/tools/* /usr/local/bin

# Remove the dnf-automatic package
sudo dnf remove -y dnf-automatic

sudo dnf install -y libvirt libvirt-devel libvirt-client git libvirt-daemon-kvm bind-utils jq gcc-c++ golang

# Install yq to manipulate manifest file created by installer.
if [[ ! -e /usr/local/bin/yq ]]; then
    curl -L https://github.com/mikefarah/yq/releases/download/2.2.1/yq_linux_amd64 -o yq
    chmod +x yq
    sudo mv yq /usr/local/bin/yq
fi

# Enable IP forwarding
# https://github.com/openshift/installer/tree/master/docs/dev/libvirt#enable-ip-forwarding
sudo sysctl net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sudo sysctl -p /etc/sysctl.d/99-ipforward.conf

# Configure libvirt to accept TCP connections
# https://github.com/openshift/installer/tree/master/docs/dev/libvirt#configure-libvirt-to-accept-tcp-connections
sudo bash -c 'cat >> /etc/libvirt/libvirtd.conf' << EOF
auth_tcp="none"
EOF

sudo systemctl enable libvirtd-tcp.socket
sudo systemctl start libvirtd-tcp.socket

sudo bash -c 'cat >> /etc/modprobe.d/kvm.conf' << EOF
options kvm_intel nested=1
EOF
# Ensure nesting is enabled in the kernel
# TODO: verify this is still necessary
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
sudo systemctl restart libvirtd
# Set up iptables and firewalld
# TODO: discover the ports
sudo firewall-cmd --permanent --add-rich-rule "rule service name="libvirt" reject"
sudo firewall-cmd --permanent --zone=libvirt --add-service=libvirt
sudo firewall-cmd --zone=libvirt --add-service=libvirt --permanent

# Enable NetworkManager DNS overlay
# https://github.com/openshift/installer/tree/master/docs/dev/libvirt#set-up-networkmanager-dns-overlay
echo -e "[main]\ndns=dnsmasq" | sudo tee /etc/NetworkManager/conf.d/openshift.conf
echo server=/openshift.testing/192.168.126.1 | sudo tee /etc/NetworkManager/dnsmasq.d/openshift.conf
# Create new domain for ingress to make sure it able to resolve auth route URL
echo address=/.apps.openshift.testing/192.168.126.51 | sudo tee -a /etc/NetworkManager/dnsmasq.d/openshift.conf
sudo systemctl restart NetworkManager

echo "Installing oc client"
cd $HOME
curl -OL https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
tar -zxf oc.tar.gz
rm -fr oc.tar.gz
sudo mv $HOME/oc /usr/local/bin
sudo ln -s /usr/local/bin/oc /usr/local/bin/kubectl

sudo bash -c 'cat >> /etc/bashrc' << EOF
export KUBECONFIG=\$HOME/clusters/nested/auth/kubeconfig
export PATH=$PATH:/usr/local/go/bin
EOF
