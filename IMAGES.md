# OpenShift 4.0 libvirt on GCP Images

Currently, images are maintained and pushed to `openshift-gce-devel` project for all OpenShift developers to use.   
If you have access to OpenShift GCE account, you should not build images.  For access see [onboarding docs](https://mojo.redhat.com/docs/DOC-1081313)
For all others, you'll need to create these images in your GCE project and update all scripts accordingly.

## Images

Images are built with [Packer](https://www.packer.io). Override variables as necessary.

### Source image

The source image is `rhel9` with [nested virtualization enabled](https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances#restrictions).

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
