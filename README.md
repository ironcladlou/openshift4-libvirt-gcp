# OpenShift 4.0 libvirt on GCP

Create an [OpenShift 4.0](https://github.com/openshift/installer) cluster in a single GCP instance.

## Create a cluster

**If the images are built and available in your project/zone, all you need to get started is the `gcloud` CLI tool.**

First, launch an instance.

```shell
$ gcloud compute instances create $INSTANCE \
  --image-family openshift4-libvirt \
  --zone us-east1-c \
  --min-cpu-platform "Intel Haswell" \
  --machine-type n1-standard-8 \
  --boot-disk-type pd-ssd --boot-disk-size 256GB \
  --metadata-from-file openshift-pull-secret=openshift-pull-secret.json
```

Connect to the instance using SSH and create a cluster named `nested`.

```shell
$ create-cluster nested
```

Interact with your cluster with `oc`.

### Updating the installer

Tools can be updated right from the instance itself.

Update the OpenShift installer from `master` using:

```shell
$ update-installer [repo-owner] [branch]
```

Update the OpenShift installer from `https://github.com/repo-owner/installer.git` `branch` using:

```shell
$ update-installer repo-owner branch
```

Update the RHCOS image using:

```shell
$ update-rhcos-image
```

## Images

Images are built with [Packer](https://www.packer.io). Override variables as necessary.

### Source image

The source image is `centos-7` with [nested virtualization enabled](https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances#restrictions).

```shell
$ packer build openshift4-libvirt-source.json
```

### Provisioned image

The provisioned image implements all the [OpenShift libvirt HOWTO](https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md) requirements.

```shell
$ packer build openshift4-libvirt.json
```

## Advanced usage

It's possible to ignore all the defaults and helpers and simply use the image as a stable base for libvirt installer development.
