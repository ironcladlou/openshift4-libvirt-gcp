# OKD 4.0 libvirt on GCP Images

Currently, images are maintained and pushed to `okd4-280016` project and are public.
For all OpenShift developers to use, image is pushed to openshift-gce-devel project.   
You should not have to build images, but you can using packer and following below.

## Images

Images are built with [Packer](https://www.packer.io). Override variables as necessary.

### Source image

The source image is `rhel8` with [nested virtualization enabled](https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances#restrictions).

```shell
$ packer build okd4-libvirt-source.json
```

To override any default variable value, for example, Google Project ID:

```shell
$ packer build -var 'project=your-google-project-id' okd4-libvirt-source.json
```

### Provisioned image

The provisioned image implements all the [OpenShift libvirt HOWTO](https://github.com/openshift/installer/blob/master/docs/dev/libvirt-howto.md) requirements.

```shell
$ packer build okd4-libvirt.json
```
To override any default variable value, for example, Google Project ID:

```shell
$ packer build -var 'project=your-google-project-id' okd4-libvirt.json
```
