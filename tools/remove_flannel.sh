#!/bin/bash

echo "remove flannel start >>>"
ansible-playbook -i ../hosts ../01_install.yml -uroot -t addons_delete_flannel || exit 1
echo "add flannel yaml <<<"

ansible -i ../hosts k8s  -m shell   -a 'rm -rf /etc/cni/net.d' || exit 1
echo "add flannel OK <<<"