#!/bin/bash

echo "add prometheus start >>>"
ansible-playbook -i ../hosts ../01_install.yml -uroot -t addons_prometheus
echo "add prometheus OK <<<"
