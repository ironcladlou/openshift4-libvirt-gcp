# OpenShift 4.0 libvirt on GCP

Create an [OpenShift 4.X](https://github.com/openshift/installer) cluster in a single GCP instance.

### Prerequisites

Images are built and maintained in openshift-gce-devel GCE project.  If you are an OpenShift developer and have access to openshift-gce-devel GCE project,
all you need to get started is the [gcloud CLI tool](https://cloud.google.com/sdk/docs/downloads-yum)    
For developers not in OpenShift organization, see [here](https://github.com/ironcladlou/openshift4-libvirt-gcp/blob/rhel8/IMAGES.md)
for information on images, and substitute `your-gce-project` for `openshift-gce-devel` in all scripts. 

### Create GCP instance

First, create network and firewall rules in GCP and then the GCP instance.
```
Note: this script uses scp to copy pull-secret to gcp instance.  Alternative is to
add pull-secret to metadata when creating the instance.  However, metadata is printed
in the gcp console.  This is why this setup uses scp instead. 
```
Check out `create-gcp-resources.sh` for individual commands or run the script like so:

```shell
$ export INSTANCE=mytest
$ export GCP_USER=<your gcp username>, used to scp pull-secret to $HOME/pull-secret in gcp instance
$ export PULL_SECRET=/path/to/pull-secret-one-liner.json
$ ./create-gcp-resources.sh
```

### Find an available release payload image

You need to provide an OVERRIDE release payload that you have access to.
For public images see [ocp-dev-preview](https://mirror.openshift.com/pub/openshift-v4/clients/ocp-dev-preview/) and
[quay.io/ocp-dev-preview](https://quay.io/repository/openshift-release-dev/ocp-release?tab=tags) 
or for internal images see [CI release images](https://openshift-release.svc.ci.openshift.org/)     
example release images:
* quay.io/openshift-release-dev/ocp-release:4.4.0-rc.2-x86_64 (public)
* registry.svc.ci.openshift.org/ocp/release:4.5.0-0.ci-2020-03-16-194422 (internal)

### Create nested libvirt cluster - 3 masters, 2 workers

Connect to the instance using SSH and create a cluster named `$CLUSTER_NAME` using latest payload built from CI.
Install directory will be populated at `$HOME/clusters/$CLUSTER_NAME`

```shell
$ gcloud beta compute ssh --zone "us-east1-c" $INSTANCE --project "openshift-gce-devel"
$ OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=registry.svc.ci.openshift.org/ocp/release:whatever create-cluster $CLUSTER_NAME
```

### Tear Down Cluster

You can tear down and relaunch easily within your gcp instance like so:
```shell
$ gcloud beta compute ssh --zone "us-east1-c" $INSTANCE --project "openshift-gce-devel"
$ openshift-install destroy cluster --dir ~/clusters/$ClUSTER_NAME && rm -rf ~/clusters/$CLUSTER_NAME
```

### Tear Down and Clean Up GCP.

Clean up your GCP resources when you are done with your development cluster.
Check out `teardown-gcp.sh` for individual commands or run the script like so:
```shell
$ INSTANCE=<your gcp instance name> ./teardown-gcp.sh
```

Interact with your cluster with `oc` while connected via ssh to your gcp instance. 

### Updating the installer

Tools can be updated right from the instance itself.

Update the OpenShift installer from `https://github.com/openshift/installer.git` `master` using:

```shell
$ gcloud beta compute ssh --zone "us-east1-c" $INSTANCE --project "openshift-gce-devel"
$ update-installer
```

Update the OpenShift installer from `https://github.com/repo-owner/installer.git` `branch` using:

```shell
$ gcloud beta compute ssh --zone "us-east1-c" $INSTANCE --project "openshift-gce-devel"
$ update-installer repo-owner branch
```

## Advanced usage

It's possible to ignore all the defaults and helpers and simply use the image as a stable base for libvirt installer development.
You can use `openshift-install` binary without the `create-cluster` if you prefer. 
