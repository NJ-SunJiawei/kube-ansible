#!/bin/bash

echo "remove helm start >>>"
ansible -i ../hosts helm   -m shell -a 'docker stop nginx-helm-charts' || exit 1
ansible -i ../hosts helm   -m shell -a 'docker rm nginx-helm-charts' || exit 1
#ansible -i ../hosts helm   -m systemd -a 'name=docker state=stopped enabled=no'

ansible -i ../hosts helm   -m shell -a 'rm -rf {{ HELM_PATH }}' || exit 1
ansible -i ../hosts helm   -m shell -a 'rm -rf /usr/bin/helm' || exit 1
echo "remove helm all OK <<<"