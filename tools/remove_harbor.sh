#!/bin/bash

echo "remove harbor start >>>"
ansible -i ../hosts harbor   -m shell -a 'docker-compose -f {{ HARBOR_PATH }}/harbor/docker-compose.yml down -v' -uroot || exit 1
#ansible -i ../hosts harbor   -m systemd -a 'name=docker state=stopped enabled=no' -uroot

ansible -i ../hosts harbor   -m shell -a 'rm -rf /var/log/harbor' -uroot || exit 1
ansible -i ../hosts harbor   -m shell -a 'rm -rf {{ HARBOR_PATH }}/harbor' -uroot || exit 1
ansible -i ../hosts harbor   -m shell -a 'rm -rf {{ HARBOR_PATH }}/database' -uroot || exit 1
ansible -i ../hosts harbor   -m shell -a 'rm -rf {{ HARBOR_PATH }}/registry' -uroot || exit 1
echo "remove harbor all OK <<<"