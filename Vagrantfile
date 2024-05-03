# -*- mode: ruby -*-
# vi: set ft=ruby :

num_controlplanes = 1
num_workers = 2

ip_address_prefix = "192.168.56."
controlplane_ip_address_start = 20
worker_ip_address_start = 30

controlplane_loadbalancer_ip_address = ip_address_prefix + "10"
controlplane_ip_addresses = Array.new(num_controlplanes) { |i| ip_address_prefix + (controlplane_ip_address_start + i).to_s }
worker_ip_addresses = Array.new(num_workers) { |i| ip_address_prefix + (worker_ip_address_start + i).to_s }
high_availability_enabled = num_controlplanes > 1

Vagrant.configure("2") do |config|

    config.vm.box = "bento/ubuntu-24.04"

    if high_availability_enabled
        config.vm.define "controlplane_loadbalancer" do |loadbalancer|
            loadbalancer.vm.hostname = "controlplane-loadbalancer"
            loadbalancer.vm.network "private_network", ip: controlplane_loadbalancer_ip_address
            loadbalancer.vm.provision "shell", path: "script/init-loadbalancer-node.sh"
            loadbalancer.vm.provision "shell", path: "script/configure-loadbalancer.sh", args: controlplane_ip_addresses
        end
    end

    (0..(num_controlplanes - 1)).each do |i|
        config.vm.define "controlplane_#{i}" do |controlplane|
            controlplane_ip_address = controlplane_ip_addresses[i]
            controlplane.vm.hostname = "controlplane-#{i}"
            controlplane.vm.network "private_network", ip: controlplane_ip_address
            controlplane.vm.provision "shell", path: "script/init-cluster-node.sh"
            if high_availability_enabled
                if i == 0
                    # Install and configure first controlplane.
                    controlplane.vm.provision "shell", path: "script/install-first-controlplane-in-ha-mode.sh", args: [controlplane_ip_address, controlplane_loadbalancer_ip_address]
                else
                    # Join further controlplanes to existing cluster.
                    controlplane.vm.provision "shell", path: "sync/kubeadm-join-controlplane.sh"
                end
            else
                controlplane.vm.provision "shell", path: "script/install-first-controlplane.sh", args: controlplane_ip_address
            end
        end
    end

    (0..(num_workers - 1)).each do |i|
        config.vm.define "worker_#{i}" do |worker|
            worker.vm.hostname = "worker-#{i}"
            worker.vm.network "private_network", ip: worker_ip_addresses[i]
            worker.vm.provision "shell", path: "script/init-cluster-node.sh"
            worker.vm.provision "shell", path: "sync/kubeadm-join-worker.sh"
        end
    end
end
