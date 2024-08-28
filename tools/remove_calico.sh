#!/bin/bash

echo "remove calico start >>>"
ansible-playbook -i ../hosts ../01_install.yml -uroot -t addons_delete_calico || exit 1
echo "add calico yaml <<<"

ansible -i ../hosts k8s  -m shell   -a 'rm -rf /etc/calico' || exit 1
ansible -i ../hosts k8s  -m shell   -a 'rm -rf /etc/cni/net.d' || exit 1
echo "add calico OK <<<"
