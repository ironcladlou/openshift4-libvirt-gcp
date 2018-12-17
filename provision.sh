#!/bin/bash
set -e
set -u
set -o pipefail

# Install tools
sudo mv /tmp/tools/* /usr/local/bin

# :-)
sudo setenforce 0
sudo sed -i -z 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Enable the latest libvirt packages
sudo bash -c 'cat > /etc/yum.repos.d/sig-virt.repo' << EOF
[sig-virt-libvirt-latest]
name=SIG-Virt libvirt packages for CentOS 7 x86_64
baseurl=http://mirror.centos.org/centos-7/7/virt/x86_64/libvirt-latest
enabled=1
EOF

# Enable the latest QEMU packages
sudo bash -c 'cat > /etc/yum.repos.d/sig-virt-kvm-common.repo' << EOF
[sig-virt-kvm-common]
name=SIG-Virt libvirt packages for CentOS 7 x86_64
baseurl=http://mirror.centos.org/centos-7/7/virt/x86_64/kvm-common
enabled=1
EOF

# Enable the latest Go packages
sudo rpm --import https://mirror.go-repo.io/centos/RPM-GPG-KEY-GO-REPO
curl -s https://mirror.go-repo.io/centos/go-repo.repo | sudo tee /etc/yum.repos.d/go-repo.repo

# TODO: find the GPG key for SIG-Virt stuff
sudo yum install -y --nogpg libvirt libvirt-devel libvirt-client git golang libvirt-daemon-kvm qemu-kvm bind-utils jq

# Enable IP forwarding
# https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md#enable-ip-forwarding
sudo sysctl net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sudo sysctl -p /etc/sysctl.d/99-ipforward.conf

# Enable non-root access to libvirt stuff
# https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md#make-sure-you-have-permissions-for-qemusystem
sudo bash -c 'cat > /etc/polkit-1/rules.d/80-libvirt.rules' << EOF
polkit.addRule(function(action, subject) {
  if (action.id == "org.libvirt.unix.manage" subject.isInGroup("google-sudoers")) {
      return polkit.Result.YES;
  }
});
EOF

# Configure libvirt to accept TCP connections
# https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md#configure-libvirt-to-accept-tcp-connections
sudo bash -c 'cat >> /etc/libvirt/libvirtd.conf' << EOF
listen_tls = 0
listen_tcp = 1
auth_tcp="none"
tcp_port = "16509"
EOF
sudo bash -c 'cat >> /etc/sysconfig/libvirtd' << EOF
LIBVIRTD_ARGS="--listen"
EOF
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
sudo iptables -I INPUT -p tcp -s 192.168.122.0/24 -d 192.168.122.1 --dport 16509 -j ACCEPT -m comment --comment "Allow insecure libvirt clients"
sudo firewall-cmd --zone=trusted --add-source=192.168.126.0/24
sudo firewall-cmd --zone=trusted --add-port=16509/tcp

# Enable NetworkManager DNS overlay
# https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md#set-up-networkmanager-dns-overlay
sudo sed -i -z 's/\[main\]\n/\[main\]\ndns=dnsmasq\n/' /etc/NetworkManager/NetworkManager.conf
echo server=/openshift.testing/192.168.126.1 | sudo tee /etc/NetworkManager/dnsmasq.d/openshift.conf
sudo systemctl restart NetworkManager

# Configure the default libvirt storage pool
# https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md#configure-default-libvirt-storage-pool
sudo virsh pool-define /dev/stdin <<EOF
<pool type='dir'>
  <name>default</name>
  <target>
    <path>/var/lib/libvirt/images</path>
  </target>
</pool>
EOF
sudo virsh pool-start default
sudo virsh pool-autostart default

# Install a default RHCOS image
update-rhcos-image

echo "Installing oc client"
cd $HOME
curl -OL https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar -zxf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
sudo mv $HOME/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/local/bin

echo "Installing kubectl binary"
sudo ln -s /usr/local/bin/oc /usr/local/bin/kubectl

# Install a default installer
update-installer

sudo bash -c 'cat >> /etc/bashrc' << EOF
export KUBECONFIG=\$HOME/clusters/nested/auth/kubeconfig
EOF
