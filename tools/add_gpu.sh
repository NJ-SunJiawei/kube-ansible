#!/bin/bash

echo "add gpu start >>>"
ansible-playbook -i ../hosts ../04_add-gpu.yml -uroot
echo "add gpu OK <<<"
