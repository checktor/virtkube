# virtkube

virtkube implements a local Kubernetes cluster running on multiple virtual machines provisioned
by [Vagrant](https://www.vagrantup.com/). It uses [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
to set up the cluster from scratch based on minimal Ubuntu images for each node. In comparison
to [minikube](https://minikube.sigs.k8s.io/docs/), this tool does not provision a single-node cluster. The smallest
possible infrastructure consists of one controlplane and one worker node. This is intentional because virtkube's primary
goal is to provide a development cluster as close as possible to a productive Kubernetes deployment.

## Prerequisites

### Vagrant

Vagrant can be installed on macOS, Linux, and Windows. Follow
HashiCorp's [installation manual](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant) for your
desired operating system.

### Virtualization tool like VirtualBox

Vagrant works with multiple virtualization tools. This project is tested with [VirtualBox](https://www.virtualbox.org/).
Consult the [official documentation](https://www.virtualbox.org/wiki/Downloads) for further information on the
installation procedure.

## Cluster management

### Create cluster

```shell
vagrant up
```

### Configure kubectl to work with cluster

Use 'kubeconfig' file in [sync](sync) folder for kubectl authentication.

```shell
kubectl --kubeconfig sync/kubeconfig get pods -A
```

### Connect to cluster VMs

Use `vagrant ssh <VM name>` to access a specific cluster VM, e.g. `vagrant ssh worker_0` to connect to first worker
node.

### Remove cluster

```shell
vagrant destroy
```

## Cluster testing

Run scripts in [test](test) folder, e.g. `./test/test-deployment.sh` to test deployment creation.

## Cluster configuration

See variables in [Vagrantfile](Vagrantfile) for configuration details.

## Further tools

The following dependencies are used to provision the cluster:

* Container runtime: [containerd](https://github.com/containerd/containerd)
* CNI plugin: [flannel](https://github.com/flannel-io/flannel)
