# OpenShift 4.0 libvirt on GCP

Create an [OpenShift 4.0](https://github.com/openshift/installer) cluster in a single GCP instance.

## Create a cluster

**If the images are built and available in your project/zone, all you need to get started is the `gcloud` CLI tool.**

First, create network and firewall rules.

```shell
$ gcloud compute networks create "${INSTANCE}" \
  --subnet-mode=custom \
  --bgp-routing-mode=regional

$ gcloud compute networks subnets create "${INSTANCE}" \
  --network "${INSTANCE}" \
  --range=10.0.0.0/9

$ gcloud compute firewall-rules create "${INSTANCE}" \
  --network "${INSTANCE}" \
  --allow tcp:22,icmp
```

Then, create the instance.

```shell
$ gcloud compute instances create "${INSTANCE}" \
  --image-family openshift4-libvirt \
  --zone us-east1-c \
  --min-cpu-platform "Intel Haswell" \
  --machine-type n1-standard-16 \
  --boot-disk-type pd-ssd --boot-disk-size 256GB \
  --network "${INSTANCE}" \
  --subnet "${INSTANCE}" \
  --metadata-from-file openshift-pull-secret=openshift-pull-secret.json
```

Connect to the instance using SSH and create a cluster named `nested`.

```shell
$ create-cluster nested
```

*IMPORTANT* Tear down and clean up GCP.

```shell
$ gcloud compute instances delete "${INSTANCE}"
$ gcloud compute firewall-rules delete "${INSTANCE}"
$ gcloud compute networks subnets delete "${INSTANCE}"
$ gcloud compute networks delete "${INSTANCE}"
```

Interact with your cluster with `oc`.

### Updating the installer

Tools can be updated right from the instance itself.

Update the OpenShift installer from `https://github.com/openshift/installer.git` `master` using:

```shell
$ update-installer
```

Update the OpenShift installer from `https://github.com/repo-owner/installer.git` `branch` using:

```shell
$ update-installer repo-owner branch
```

## Images

Images are built with [Packer](https://www.packer.io). Override variables as necessary.

### Source image

The source image is `rhel8` with [nested virtualization enabled](https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances#restrictions).

```shell
$ packer build openshift4-libvirt-source.json
```

To override any default variable value, for example, Google Project ID:

```shell
$ packer build -var 'project=your-google-project-id' openshift4-libvirt-source.json
```

### Provisioned image

The provisioned image implements all the [OpenShift libvirt HOWTO](https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md) requirements.

```shell
$ packer build openshift4-libvirt.json
```
To override any default variable value, for example, Google Project ID:

```shell
$ packer build -var 'project=your-google-project-id' openshift4-libvirt.json
```

## Advanced usage

It's possible to ignore all the defaults and helpers and simply use the image as a stable base for libvirt installer development.
