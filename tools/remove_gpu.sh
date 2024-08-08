#!/bin/bash

echo "remove gpu start >>>"
ansible-playbook -i ../hosts ../04_add-gpu.yml -uroot -t addons_delete
echo "remove gpu all OK <<<"