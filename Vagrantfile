# -*- mode: ruby -*-
# vi: set ft=ruby :

ip_address_prefix = "192.168.56."
num_workers = 2

Vagrant.configure("2") do |config|

    config.vm.box = "bento/ubuntu-22.04"

    config.vm.define "controlplane_0" do |controlplane|
        controlplane_ip_address = ip_address_prefix + "10"
        controlplane.vm.hostname = "controlplane-0"
        controlplane.vm.network "private_network", ip: controlplane_ip_address
        controlplane.vm.provision "shell", path: "script/init-node.sh"
        controlplane.vm.provision "shell", path: "script/install-first-controlplane.sh", args: controlplane_ip_address
    end

    (0..(num_workers - 1)).each do |i|
        config.vm.define "worker_#{i}" do |worker|
            worker.vm.hostname = "worker-#{i}"
            worker.vm.network "private_network", ip: ip_address_prefix + "#{20 + i}"
            worker.vm.provision "shell", path: "script/init-node.sh"
            worker.vm.provision "shell", path: "sync/kubeadm-join.sh"
        end
    end

end
