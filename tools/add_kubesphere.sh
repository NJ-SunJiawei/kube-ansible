#!/bin/bash

echo "add kubesphere start >>>"
ansible-playbook -i ../hosts ../01_install.yml -uroot -t addons_prometheus
echo "add kubesphere OK <<<"
