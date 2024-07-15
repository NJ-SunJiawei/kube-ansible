#!/bin/bash

echo "add helm start >>>"
ansible-playbook -i ../hosts ../04_add-helm.yml -uroot -t helm || exit 1
echo "add helm OK <<<"
