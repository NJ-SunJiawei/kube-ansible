#!/bin/bash

echo "remove kubernetes start >>>"
#remove master
ansible-playbook -i ../hosts ../01_install.yml -uroot -t addons_delete
ansible -i ../hosts master -m systemd -a 'name=kube-apiserver state=stopped enabled=no' || exit 1
ansible -i ../hosts master -m systemd -a 'name=kube-controller-manager state=stopped enabled=no' || exit 1
ansible -i ../hosts master -m systemd -a 'name=kube-scheduler state=stopped enabled=no' || exit 1
ansible -i ../hosts master -m shell   -a 'rm -rf /root/.kube/config' || exit 1
ansible -i ../hosts master -m shell   -a 'rm -rf /usr/lib/systemd/system/{kube-apiserver,kube-controller-manager,kube-scheduler}.service' || exit 1
echo "remove kubernetes master OK <<<"

#remove etced
ansible -i ../hosts etcd   -m systemd -a 'name=etcd state=stopped enabled=no' || exit 1
ansible -i ../hosts etcd   -m shell   -a 'rm -rf {{ etcd_work_dir }}' || exit 1
ansible -i ../hosts etcd   -m shell   -a 'rm -rf /usr/lib/systemd/system/etcd.service' || exit 1
echo "remove kubernetes etced OK <<<"

#remove worker
ansible -i ../hosts k8s    -m systemd -a 'name=kubelet state=stopped enabled=no' || exit 1
ansible -i ../hosts k8s    -m systemd -a 'name=kube-proxy state=stopped enabled=no' || exit 1
#ansible -i ../hosts k8s    -m yum     -a 'name=crictl state=absent' || exit 1
ansible -i ../hosts k8s    -m shell   -a 'rm -rf /usr/lib/systemd/system/{kubelet,kube-proxy}.service' || exit 1
echo "remove kubernetes worker OK <<<"

#stop containerd
ansible -i ../hosts k8s    -m shell   -a 'ctr -n=k8s.io c rm $(ctr -n=k8s.io c ls -q) || echo true'
ansible -i ../hosts k8s    -m shell   -a 'ctr -n=k8s.io i rm $(ctr -n=k8s.io i ls -q) || echo true'
ansible -i ../hosts k8s    -m systemd -a 'name=containerd state=stopped enabled=no' || exit 1
#ansible -i ../hosts k8s   -m shell   -a 'rm -rf /etc/cni' || exit 1
#ansible -i ../hosts k8s   -m shell   -a 'rm -rf /etc/systemd/system/containerd.service' || exit 1
echo "stop kubernetes containerd OK <<<"

#stop docker
ansible -i ../hosts harbor   -m systemd -a 'name=docker state=stopped enabled=no'
ansible -i ../hosts helm     -m systemd -a 'name=docker state=stopped enabled=no'
ansible -i ../hosts harbor   -m shell   -a 'rm -rf /usr/local/bin/docker-compose'
ansible -i ../hosts helm     -m shell   -a 'rm -rf /usr/local/bin/docker-compose'
echo "stop harbor/helm docker OK <<<"

#remove others
ansible -i ../hosts k8s    -m shell   -a 'rm -rf /opt/etcd' || exit 1
ansible -i ../hosts k8s    -m shell   -a 'rm -rf /opt/kubernetes /usr/bin/kubelet' || exit 1
ansible -i ../hosts k8s    -m shell   -a 'rm -rf /opt/cni /var/lib/cni /var/lib/calico ' || exit 1

echo "remove kubernetes all OK <<<"
