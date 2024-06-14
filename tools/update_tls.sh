#!/bin/bash

root_dir=$(pwd |sed 's#tools##')
etcd_cert_dir=$root_dir/roles/etcd/files/etcd_cert
apiserver_ecert_dir=$root_dir/roles/master/files/etcd_cert
apiserver_kcert_dir=$root_dir/roles/master/files/k8s_cert
node_cert_dir=$root_dir/roles/node/files/k8s_cert

echo "update tls start >>>"
#mv bck
ansible -i ../hosts localhost -m shell   -a "mv $root_dir/ssl $root_dir/ssl-`date "+%Y-%m-%d~%H:%M:%S"`" || exit 1
ansible -i ../hosts localhost -m shell   -a "rm -rf $apiserver_ecert_dir $etcd_cert_dir $apiserver_kcert_dir $node_cert_dir" || exit 1
echo "mv directory OK >>>"

#update tls
ansible-playbook -i ../hosts ../update.yml -uroot -t tls || exit 1
echo "play tls OK >>>"

#etcd restarted
ansible -i ../hosts etcd   -m shell   -a 'rm -rf {{ etcd_work_dir }}/ssl/*.pem' || exit 1
ansible-playbook -i ../hosts ../update.yml -uroot -t etcd_ssl_dist || exit 1
ansible -i ../hosts etcd   -m systemd -a "name=etcd state=restarted" || exit 1
echo "restart etcd OK >>>"

#kube restarted
ansible -i ../hosts master   -m shell   -a 'rm -rf {{ k8s_work_dir }}/ssl/*.pem' || exit 1
ansible -i ../hosts master   -m shell   -a 'rm -rf {{ k8s_work_dir }}/ssl/etcd/*.pem' || exit 1
ansible-playbook -i ../hosts ../update.yml -uroot -t master_k8s_dist,master_etcd_dist,node_k8s_dist  || exit 1
ansible -i ../hosts master   -m systemd -a "name=kube-apiserver state=restarted" || exit 1
ansible -i ../hosts master   -m systemd -a "name=kube-controller-manager state=restarted" || exit 1
ansible -i ../hosts master   -m systemd -a "name=kube-scheduler state=restarted" || exit 1
sleep 5
ansible -i ../hosts k8s      -m systemd -a "name=kubelet state=restarted" || exit 1
ansible -i ../hosts k8s      -m systemd -a "name=kube-proxy state=restarted" || exit 1
echo "restart kube OK >>>"

#containerd restarted
ansible -i ../hosts k8s      -m systemd -a "name=containerd state=restarted" || exit 1
echo "restart containerd OK >>>"

ansible-playbook -i ../hosts ../update.yml -uroot -t addons || exit 1
echo "update tls OK <<<"