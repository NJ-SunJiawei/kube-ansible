#!/bin/bash

echo "add helm start >>>"
ansible-playbook -i ../hosts ../01_install.yml -uroot -t helm || exit 1
echo "add helm OK <<<"
