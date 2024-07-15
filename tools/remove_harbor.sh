#!/bin/bash

echo "remove harbor start >>>"
ansible -i ../hosts harbor   -m shell -a 'cd {{ HARBOR_PATH }}/barbor && docker-compose down -v' || exit 1
#ansible -i ../hosts harbor   -m systemd -a 'name=docker state=stopped enabled=no'

ansible -i ../hosts harbor   -m shell -a 'rm -rf /var/log/harbor' || exit 1
ansible -i ../hosts harbor   -m shell -a 'rm -rf {{ HARBOR_PATH }}/barbor' || exit 1
echo "remove harbor all OK <<<"