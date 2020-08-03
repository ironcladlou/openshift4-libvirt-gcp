# OKD 4.0 libvirt on GCP Images

Currently, images are maintained and pushed to `okd4-280016` project for all OpenShift developers to use.   
If you have access to okd4 GCE account, you should not build images.
For all others, you'll need to create these images in your GCE project and update all scripts accordingly.

## Images

Images are built with [Packer](https://www.packer.io). Override variables as necessary.

### Source image

The source image is `centos8` with [nested virtualization enabled](https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances#restrictions).

```shell
$ packer build okd4-somal-source.json
```

To override any default variable value, for example, Google Project ID:

```shell
$ packer build -var 'project=your-google-project-id' okd4-libvirt-source.json
```

### Provisioned image

The provisioned image implements all the [OpenShift libvirt HOWTO](https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md) requirements.

```shell
$ packer build okd4-somal.json
```
To override any default variable value, for example, Google Project ID:

```shell
$ packer build -var 'project=your-google-project-id' okd4-libvirt.json
```
