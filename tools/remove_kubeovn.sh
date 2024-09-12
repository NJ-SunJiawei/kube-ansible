#!/bin/bash

echo "remove ovn start >>>"
ansible-playbook -i ../hosts ../01_install.yml -uroot -t addons_delete_ovn || exit 1
echo "add ovn yaml <<<"

ansible -i ../hosts k8s  -m shell   -a 'rm -rf /var/run/openvswitch'
ansible -i ../hosts k8s  -m shell   -a 'rm -rf /var/run/ovn'
ansible -i ../hosts k8s  -m shell   -a 'rm -rf /etc/origin/openvswitch'
ansible -i ../hosts k8s  -m shell   -a 'rm -rf /etc/origin/ovn'
ansible -i ../hosts k8s  -m shell   -a 'rm -rf /etc/cni/net.d/00-kube-ovn.conflist'
ansible -i ../hosts k8s  -m shell   -a 'rm -rf /etc/cni/net.d/01-kube-ovn.conflist'
ansible -i ../hosts k8s  -m shell   -a 'rm -rf /etc/cni/net.d/05-cilium.conflist'
ansible -i ../hosts k8s  -m shell   -a 'rm -rf /var/log/openvswitch'
ansible -i ../hosts k8s  -m shell   -a 'rm -rf /var/log/ovn'
ansible -i ../hosts k8s  -m shell   -a 'rm -rf /var/log/kube-ovn'
echo "add ovn OK <<<"
