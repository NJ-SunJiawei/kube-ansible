#!/bin/bash

echo "add harbor start >>>"
ansible-playbook -i ../hosts ../03_add-harbor.yml -uroot -t harbor

ansible-playbook -i ../hosts ../03_add-harbor.yml -uroot -t harbor_login || exit 1
echo "add harbor OK <<<"
