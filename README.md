# OKD 4 libvirt on GCP

## Create an [OKD 4](https://www.okd.io) cluster in a single GCP instance.    

### Prerequisites

Images are built and maintained in project `okd4-280016` GCE project, and made available to the public.
All you need to get started is the [gcloud CLI tool](https://cloud.google.com/sdk/docs/downloads-yum)
If you want to build your own images, see [here](https://github.com/ironcladlou/openshift4-libvirt-gcp/blob/centos8-okd4/IMAGES.md),
and substitute `your-gce-project` for `okd4-280016` in all scripts. 

### Create GCP instance

First, create network and firewall rules in GCP and then the GCP instance.
You can either run the commands from `create-gcp-resources.sh` individually or run the script like so:

```shell
$ export INSTANCE=mytest
$ ./create-gcp-resources.sh
```

### Create nested libvirt cluster - 3 masters, 2 workers

Connect to the instance using SSH and create a cluster named `$CLUSTER_NAME` using latest okd4 payload.    

[okd.io](https://www.okd.io/) current release payload image: `quay.io/openshift/okd:4.4.0-0.okd-2020-05-23-055148-beta5`      
To override this image, `export OKD_RELEASE_IMAGE=<a release image you have access to>`.  The libvirt-installer will then be
extracted from OKD_RELEASE_IMAGE.

Install directory will be populated at `$HOME/clusters/$CLUSTER_NAME`

```shell
$ gcloud beta compute ssh --zone "us-east1-c" $INSTANCE --project "your-project"
$ create-cluster $CLUSTER_NAME
```

### Tear Down Cluster

You can tear down and relaunch easily within your gcp instance like so:
```shell
$ gcloud beta compute ssh --zone "us-east1-c" $INSTANCE --project "your-project"
$ openshift-install destroy cluster --dir ~/clusters/$ClUSTER_NAME && rm -rf ~/clusters/$CLUSTER_NAME
```

### Tear Down and Clean Up GCP.

Clean up your GCP resources when you are done with your development cluster.
The instance created by the script is centos8-based, n1-standard-16, 128GB.
If you don't tear it down it will cost you (or your project administrator) a lot of money.
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
