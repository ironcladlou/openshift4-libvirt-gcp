# OKD 4 libvirt on GCP

## Create an [OKD 4](https://www.okd.io) cluster in a single GCP instance.    

**NOTE**      
This branch is meant for use outside of internal RH GCE environment.  If you are currently a member of    
`openshift-gce-devel` project, switch to [rhel8 branch](https://github.com/ironcladlou/openshift4-libvirt-gcp/tree/rhel8) and follow README there.


### Prerequisites

Images are built and maintained in `okd4-280016` GCE project.  If you have access to `okd4-280016` GCE project,
all you need to get started is the [gcloud CLI tool](https://cloud.google.com/sdk/docs/downloads-yum)
For developers not in `okd4-280016` project, see [here](https://github.com/ironcladlou/openshift4-libvirt-gcp/blob/centos8-okd4/IMAGES.md)
for information on images, and substitute `your-gce-project` for `okd4-280016` in all scripts. 

### Create GCP instance

First, create network and firewall rules in GCP and then the GCP instance.
```
Note: this script uses scp to copy pull-secret to gcp instance.  Alternative is to
add pull-secret to metadata when creating the instance.  However, metadata is printed
in the gcp console.  This is why this setup uses scp instead. 
```
You can either run the commands from `create-gcp-resources.sh` individually or run the script like so:

```shell
$ export INSTANCE=mytest
$ export GCP_USER=<whatever name you login as to gcp instance>, used to scp pull-secret to $HOME/pull-secret in gcp instance
$ export PULL_SECRET=/path/to/pull-secret-one-liner.json
$ ./create-gcp-resources.sh
```

### Create nested libvirt cluster - 3 masters, 2 workers

Connect to the instance using SSH and create a cluster named `$CLUSTER_NAME` using latest okd4 payload.    

[okd.io](https://www.okd.io/) current release payload image: `quay.io/openshift/okd:4.4.0-0.okd-2020-05-23-055148-beta5`      
To override this image, `export OKD_RELEASE_IMAGE=<a release image you have access to>`.  The libvirt-installer will then be
extracted from OKD_RELEASE_IMAGE.

Install directory will be populated at `$HOME/clusters/$CLUSTER_NAME`

```shell
$ gcloud beta compute ssh --zone "us-east1-c" $INSTANCE --project "okd4-280016"
$ create-cluster $CLUSTER_NAME
```

### Tear Down Cluster

You can tear down and relaunch easily within your gcp instance like so:
```shell
$ gcloud beta compute ssh --zone "us-east1-c" $INSTANCE --project "okd4-280016"
$ openshift-install destroy cluster --dir ~/clusters/$ClUSTER_NAME && rm -rf ~/clusters/$CLUSTER_NAME
```

### Tear Down and Clean Up GCP.

Clean up your GCP resources when you are done with your development cluster.
Check out `teardown-gcp.sh` for individual commands or run the script like so:
```shell
$ INSTANCE=<your gcp instance name> ./teardown-gcp.sh
```

Interact with your cluster with `oc` while connected via ssh to your gcp instance. 

## Advanced usage

It's possible to ignore all the defaults and helpers and simply use the image as a stable base for libvirt installer development.
You can use `openshift-install` binary without the `create-cluster` if you prefer. 
To do this, you'll need to do the following:
```
$ oc adm release extract --command openshift-baremetal-install <an okd release you have access to>
$ sudo mv openshift-baremetal-install /usr/local/bin/openshift-install
$ openshift-install create-cluster --dir your-install-dir-with-your-install-config.yaml
```
