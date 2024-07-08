#!/bin/bash

echo "add node start >>>"
ansible-playbook -i ../hosts ../02_add_node.yml -uroot|| exit 1
echo "add node OK <<<"
