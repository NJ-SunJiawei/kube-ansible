## RepackageImage_Installation

### 一、引言

#### 1、编写目的

本文为自定义制作open Euler 镜像的文档，所用操作系统为OpenEuler-22.03-LTS。

文档使用者：客户用户

#### 2、项目背景

为了响应国产化的号召，本项目(ARM无线云底座项目) 由中国移动研究院带领，采用国产ARM架构服务器日海飞信作为研究、开发载体，经过慎重考虑，选择操作系统为OpenEuler-22.03-LTS，Kubernetes版本为1.24.1等来进行项目开发。

#### 3、参考资料

参考资料条目示例如下：

openEuler官方资源站：https://docs.openeuler.org/zh/

openEuler官方ISO发布包：https://repo.openeuler.org/openEuler-22.03-LTS/ISO/

openEuler官方repo源列表：https://repo.openeuler.org/openEuler-22.03-LTS/

containerd官网地址：[https://containerd.io](https://www.baidu.com/link?url=e8wadZ_J8jqStbAsIhE_MCQiERIoc63xfq2EInuUkwK&wd=&eqid=d60a2924000488d90000000363296656)

containerd GitHub项目：https://github.com/containerd/containerd

kubernetes官网网站：[https://kubernetes.io](https://www.baidu.com/link?url=AyQgx9ztLEVgHl4R84b8wXJD7uLcfTzCewerKV8wmFq&wd=&eqid=cfda8c36000c8be000000003632965e1)

kubernetes GitHub项目：https://github.com/kubernetes/kubernetes

### 二、制作流程

#### 1、环境准备

centos7.6虚拟机、已安装好open Euler 22.03 ARM操作系统的主机、openEuler镜像openEuler-22.03-LTS-aarch64.iso

#### **2、制作镜像前准备工作**

**1）在centos7.6虚拟机上安装所需工具**

```shell
yum -y install rsync createrepo mkisofs

mount openEuler-22.03-LTS-aarch64.iso /mnt 

mkdir /ISO 

# 同步/mnt/cdrom/下的文件到/ISO/路径下，除了 Packages 和 repodata 文件夹 
rsync -a --exclude=Packages/ --exclude=repodata/ /mnt/ /ISO/ 

mkdir -p /ISO/{Packages,repodata,ks}
```

**2）查找拷贝所需的 rpm 包到/ISO/Packages 下**

拷贝当前系统已安装的软件包到/ISO/Packages 目录下（最好还是拷贝全量的原 Packages 下的安装包，或者是 yum 安装过后再生成 install.log 否则依赖包会不完整） 

a）在已安装好open Euler 22.03 ARM操作系统的主机上使用一下命令生成 install.log ，获取所安装rpm包的信息

```shell
rpm -qa >> /root/install.log 
```

b） 根据上一步生成的install.log拷贝需安装的rpm包

```shell
awk '{print $0}' /root/install.log |xargs -i cp /mnt/Packages/{}.rpm /ISO/Packages/ 
```

c）配置 yum 下载指定软件包如ansible、vim、tar、kernel-rt的所有依赖包

  例： 

```shell
yum install -y --downloadonly --downloaddir=/root/test/ ansible #ansible可替换为想下载软件的名字 

mv /root/test/* /ISO/Packages/
```

**3）制作ks.cfg文件**

可以使用已安装完系统的/root/anaconda-ks.cfg,改名为ks.cfg

vim /ISO/ks/ks.cfg 做如下修改(可根据自己的需求修改)

```shell
# Generated by pykickstart v3.34

#version=DEVEL

# Use graphical install

#**graphical #****图形界面方式安装**

**text   #文本模式安装**

 

%packages #需要安装的rpm包，需在normal.xml文件中定义

@^minimal-environment

@core

@yfqansible

@vim

@kernel-rt

%end

 

%pre    #系统安装前执行的脚本
#格式化服务器所有磁盘的脚本
function fdisk_disk() {
  array=(a b c d e f g h i j k l m n o p q r s t u v w x y z)
  disk_sum=`expr $(lsblk | grep disk|wc -l) - 1`
  for ((a=1; a<=$disk_sum; a++))
  do
    b=`expr $a - 1 `
    disk_name=sd${array[$b]}
    disk_part_count=$( fdisk -l | grep $disk_name  | wc -l )
    if [ ${disk_part_count} -eq 2 ];then
       echo d>/tmp/test1.txt
       echo w>>/tmp/test1.txt
       cat /tmp/test1.txt | fdisk /dev/$disk_name
    else
          for((i=1;i<${disk_part_count};i++))
            do
             echo 'd'
             echo $i
          done > /tmp/test.txt
          echo "w" >> /tmp/test.txt
          cat  /tmp/test.txt |  fdisk /dev/$disk_name
    fi
     rm -rf /tmp/test.txt
  done

}

fdisk_disk

%end

# Keyboard layouts

keyboard --xlayouts='us'

# System language

lang en_US.UTF-8

 

# Network information根据自己的需求配置，也可注释掉

#network --bootproto=dhcp --device=enp43s0f0 --onboot=off --ipv6=auto --no-activate

#network --bootproto=static --device=enp43s0f1 --gateway=172.30.201.254 --ip=172.30.201.209 --nameserver=211.136.17.107 --netmask=255.255.255.0 --ipv6=auto --activate

#network --bootproto=dhcp --device=enp43s0f2 --onboot=off --ipv6=auto

#network --bootproto=dhcp --device=enp43s0f3 --onboot=off --ipv6=auto

network --hostname=master

 

# Use hard drive installation media

harddrive --dir= --partition=LABEL=openEuler-22.03-LTS-aarch64 #-V参数一致

 

# Run the Setup Agent on first boot

firstboot --enable

# System services

services --enabled="chronyd"

 

# System bootloader configuration

bootloader --location=mbr --boot-drive=sda

 

ignoredisk --only-use=sda

#autopart

 

# Partition clearing information

#clearpart --none --initlabel

clearpart --all --initlabel

# Disk partitioning information

part /boot/efi --fstype="ext4" --size=1024 --ondisk=sda

part /boot --fstype="ext4" --size=2048 --ondisk=sda

part swap --fstype="swap" --size=20480 --ondisk=sda

part / --fstype="ext4" --grow --size=1 --ondisk=sda

# System timezone

timezone Asia/Shanghai --utc

 

# Reboot after installation

reboot

# Root password也可设置成明文,此密文为cmcc123*的密文,不加密：rootpw 123456 

rootpw --iscrypted $6$YofEo5G6ivuNKg40$6SOGAni1D7/KfQ.FRg7NfnmbYYIQrilzU/XzTXn9TIsN68yY3p3z38jaZh6HyXXZZs3mH8dVn7EognOTHa/l1/

 

%post –nochroot

#--nochroot 已安装的真实操作系统被挂载到内存虚拟操作系统中的/mnt/sysimage目录

cp /run/install/repo/k8s_files/* /mnt/sysimage/root

#安装系统时镜像内容挂载在/run/install,已安装的操作系统此时挂载在内存中的/mnt/sysimage下

%end

 

%post

#更改默认进入的内核选项

grub2-set-default 1
chmod o+x /root/setup.sh
chmod o+x /root/edit_kernel.sh
echo 'sh /root/edit_kernel.sh' >>/etc/rc.d/rc.local
chmod o+x /etc/rc.d/rc.local
echo 'sh -x  /root/setup.sh' >>/root/.bash_profile
%end

%addon com_redhat_kdump --disable --reserve-mb='128'

 

%end

 

%anaconda

pwpolicy root --minlen=8 --minquality=1 --strict --nochanges --notempty

pwpolicy user --minlen=8 --minquality=1 --strict --nochanges --emptyok

pwpolicy luks --minlen=8 --minquality=1 --strict --nochanges --notempty

%end
```

**4）** **修改配置grub.cfg**

```shell
cat /ISO/EFI/BOOT/grub.cfg
```

```shell
set default="0" #0为第一个menuentry，将第一个menuentry设为默认选项
function load_video {

 if [ x$feature_all_video_module = xy ]; then

  insmod all_video

 else

  insmod efi_gop

  insmod efi_uga

  insmod ieee1275_fb

  insmod vbe

  insmod vga

  insmod video_bochs

  insmod video_cirrus

 fi

}

 

load_video

set gfxpayload=keep

insmod gzio

insmod part_gpt

insmod ext2

 

set timeout=5 #5秒后自动进入默认选项

### END /etc/grub.d/00_header ###

 

search --no-floppy --set=root -l 'openEuler-22.03-LTS-aarch64'

 

### BEGIN /etc/grub.d/10_linux ###添加了ks文件的位置

menuentry 'Install openEuler 22.03-LTS' --class red --class gnu-linux --class gnu --class os {

 linux /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=openEuler-22.03-LTS-aarch64 inst.ks=hd:LABEL=openEuler-22.03-LTS-aarch64:/ks/ks.cfg ro inst.geoloc=0 console=tty0 smmu.bypassdev=0x1000:0x17 smmu.bypassdev=0x1000:0x15 video=efifb:off video=VGA-1:640x480-32@60me fpi_to_tail=off

 initrd /images/pxeboot/initrd.img

}

menuentry 'Test this media & install openEuler 22.03-LTS' --class red --class gnu-linux --class gnu --class os {

 linux /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=openEuler-22.03-LTS-aarch64 rd.live.check inst.geoloc=0 console=tty0 smmu.bypassdev=0x1000:0x17 smmu.bypassdev=0x1000:0x15 video=efifb:off video=VGA-1:640x480-32@60me fpi_to_tail=off

 initrd /images/pxeboot/initrd.img

}

submenu 'Troubleshooting -->' {

 menuentry 'Install openEuler 22.03-LTS in basic graphics mode' --class red --class gnu-linux --class gnu --class os {

    linux /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=openEuler-22.03-LTS-aarch64 nomodeset inst.geoloc=0 console=tty0 smmu.bypassdev=0x1000:0x17 smmu.bypassdev=0x1000:0x15 video=efifb:off video=VGA-1:640x480-32@60me fpi_to_tail=off

    initrd /images/pxeboot/initrd.img

 }

 menuentry 'Rescue the openEuler system' --class red --class gnu-linux --class gnu --class os {

    linux /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=openEuler-22.03-LTS-aarch64 rescue console=tty0 smmu.bypassdev=0x1000:0x17 smmu.bypassdev=0x1000:0x15 video=efifb:off video=VGA-1:640x480-32@60me fpi_to_tail=off

    initrd /images/pxeboot/initrd.img

 }

}
```

**5）将所需要的文件放入镜像中**

```shell
#在/ISO下创建一个空文件夹k8s_files
cd /ISO/k8s_files
将所需要的文件放入此目录中
ls -l 

-rw-------.  1 root root 127516160 Jul  8 10:30 api-server.tar
-rw-r--r--.  1 root root    189911 Jul  8 10:30 calico.yaml
-rw-------.  1 root root 136835584 Jul  8 10:30 cni.tar
-rw-r--r--.  1 root root       996 Jul 12 16:04 configMap2.yaml
-rw-------.  1 root root 117030400 Jul  8 10:30 controller-manager.tar
-rw-r--r--.  1 root root  73339392 Jul 13 10:35 coredns.tar
-rw-r--r--.  1 root root 109018042 Jul  8 10:33 cri-containerd-cni-1.6.6-linux-arm64.tar.gz
-rw-r--r--.  1 root root      1513 Sep 23 15:26 edit_kernel.sh
-rw-------.  1 root root 179822592 Jul  8 10:30 etcd.tar
-rw-------.  1 root root 184323584 Jul  8 10:30 fedora.tar
-rw-r--r--.  1 root root       120 Jul  8 10:33 k8s.conf
-rw-r--r--.  1 root root  23299584 Jul 13 13:49 kube-controller.tar
-rw-r--r--.  1 root root       518 Jul  8 10:33 macvlan-conf.yml
drwxr-xr-x. 13 root root      4096 Jul  8 10:33 multus-cni
-rw-r--r--.  1 root root 138012672 Jul  8 10:42 multus-cni-3.8.tar.gz
-rw-r--r--.  1 root root      6352 Jul  8 10:33 multus-daemonset.yml
-rw-r--r--.  1 root root       719 Jul 12 16:03 network-attachment-definition.yaml
-rw-------.  1 root root 116764160 Jul  8 10:30 node.tar
-rw-r--r--.  1 root root      7688 Sep 23 14:27 nonet-k8s-install-nosriov.yml
-rw-------.  1 root root    523776 Jul  8 10:30 pause.tar
-rw-------.  1 root root   9689600 Jul  8 10:30 pod2daemon-flexvol.tar
-rw-------.  1 root root 108511744 Jul  8 10:30 proxy.tar
drwxr-xr-x.  2 root root      4096 Jul  8 10:52 rpm-k8s
drwxr-xr-x.  2 root root        97 Jul 12 16:02 rpm-tools
-rw-r--r--.  1 root root       307 Jul  8 10:33 samplepod1.yaml
-rw-------.  1 root root  51363328 Jul  8 10:30 scheduler.tar
-rw-r--r--.  1 root root      1468 Sep 23 14:37 setup.sh
-rw-r--r--.  1 root root      1167 Jul  8 10:33 sriov-cni-daemonset.yaml
-rw-r--r--.  1 root root      1057 Jul  8 10:33 sriovdp-config.yml
-rw-r--r--.  1 root root      1917 Jul 12 16:09 sriovdp-daemonset.yaml
-rw-r--r--.  1 root root       876 Jul  8 10:33 sriov-net2.yml
-rw-------.  1 root root  22895104 Jul 13 14:10 sriov-network-device-plugin.tar
-rw-r--r--.  1 root root   9901056 Jul  8 10:33 sriov.tar
```

附：

```yaml
cat nonet-k8s-install-nosriov.yml

---
- hosts: master
  #vars_files:
   #- ./var.yml
  remote_user: root
  tasks:
  #安装gcc numactl bash-completion
  - name: install gcc git numactl bash-completion
    shell: rpm -ivh --replacepkgs --force --nodeps  /root/rpm-tools/*.rpm
    ignore_errors: true
  #解压containerd包
  - name: unzip cantainerd package
    shell: tar -zxf /root/cri-containerd-cni-1.6.6-linux-arm64.tar.gz -C /
    ignore_errors: true
  #创建containerd配置文件夹
  - name: mkdir -p /etc/containerd
    shell: mkdir -p /etc/containerd
  #生成containerd默认配置文件
  - name: make config file
    shell: containerd   config  default  > /etc/containerd/config.toml
  #启动containerd
  - name: start containerd 
    shell: systemctl start containerd
  #设置开机自启containerd
  - name: enable containerd 
    shell: systemctl enable containerd
  #禁用swap
  - name: disbled swap
    shell: swapoff -a
  #把禁用swap的命令加入到开机自启里
  - name: modify rc.local
    shell: echo 'swapoff -a' >>/etc/rc.d/rc.local
  #给rc.local文件加可执行权限
  - name: chmod rc.local
    shell: chmod a+x  /etc/rc.d/rc.local
  #在/etc/fstab禁用swap分区
  - name: edit /etc/fstab
    shell: sed -i 's/^[^#].*swap*/#&/g' /etc/fstab
  #禁用防火墙
  - name: stop firewalld
    shell: systemctl stop firewalld
  #禁止启动防火墙
  - name: disabled firewalld
    shell: systemctl disable firewalld
  #禁用selinux
  - name: disabled selinux
    shell: sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  #安装k8s组件
  - name: install components
    shell: rpm -ivh --replacepkgs --force --nodeps /root/rpm-k8s/*.rpm
    ignore_errors: true
  #- name: cd 
  #  shell: cd
  #开机自启kubelet
  - name: enable kubelet
    shell: systemctl enable kubelet
  #复制环境变量文件
  - name: copy k8s.conf
    shell: cp -f /root/k8s.conf /etc/sysctl.d/
  #加载br_netfilter模块
  - name: load br_netfilter
    shell: modprobe br_netfilter
  #生效环境变量
  - name: sysctl -p
    shell: sysctl -p /etc/sysctl.d/k8s.conf
  #修改hosts文件
  - name: edit /etc/hosts
    shell: echo {{master_ip}} master >>/etc/hosts
  #导入集群所需镜像
  - name: config images-kube-apiserver
    shell: ctr -n=k8s.io image import api-server.tar
  - name: kube-controller-manager
    shell: ctr -n=k8s.io image import controller-manager.tar   
  - name: kube-proxy
    shell: ctr -n=k8s.io image import proxy.tar        
  - name: pause
    shell: ctr -n=k8s.io image import pause.tar         
  - name: etcd
    shell: ctr -n=k8s.io image import etcd.tar         
  - name: coredns
    shell: ctr -n=k8s.io image import coredns.tar        
  - name: kube-scheduler
    shell: ctr -n=k8s.io image import scheduler.tar 
  - name: calico kube-controllers
    shell: ctr -n=k8s.io image import kube-controller.tar 
  - name: calico node
    shell: ctr -n=k8s.io image import node.tar
  - name: fedora
    shell: ctr -n=k8s.io image import fedora.tar
  - name: cni
    shell: ctr -n=k8s.io image import cni.tar.gz
  - name: pod2daemon-flexvol
    shell: ctr -n=k8s.io image import pod2daemon-flexvol.tar
  #修改containerd配置文件
  - name: edit /etc/containerd/config.toml  SystemdCgroup
    shell: sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
  #修改pause版本
  - name: edit /etc/containerd/config.toml  sandbox_image
    shell: sed -i 's/sandbox_image = \"k8s.gcr.io\/pause:3.6\"/sandbox_image = \"registry.aliyuncs.com\/google_containers\/pause:3.7\"/g' /etc/containerd/config.toml
  #重启containerd
  - name: restart containerd
    shell: systemctl restart containerd  
  #初始化k8s集群
  - name: init cluster
    shell: kubeadm init --apiserver-advertise-address={{master_ip}} --apiserver-bind-port=6443 --kubernetes-version=v1.24.1 --pod-network-cidr=10.233.0.0/16 --service-cidr=172.30.0.0/16 --image-repository=registry.aliyuncs.com/google_containers --ignore-preflight-errors=swap
  #添加kubectl命令
  - name: mkdir kube
    shell: mkdir -p $HOME/.kube
  - name: copy admin.conf
    shell: sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  - name: change owner group
    shell: sudo chown $(id -u):$(id -g) $HOME/.kube/config
  #去除污点
  - name: remove taint control-plane:NoSchedule
    shell: kubectl taint node master node-role.kubernetes.io/control-plane:NoSchedule-
  - name: remove taint master:NoSchedule
    shell: kubectl taint node master node-role.kubernetes.io/master:NoSchedule-
  #部署calico
  - name: install calico
    shell: kubectl apply -f calico.yaml
  - name: sleep 15
    shell: sleep 15
  #使tab键一次空两格
  - name: set tab key
    shell: echo 'set tabstop=2' >/root/.vimrc
  - name: source .vimrc
    shell: source /root/.vimrc
  - name: source bash_completion
    shell: source  /usr/share/bash-completion/bash_completion
  - name: source  <(kubectl  completion bash)
    shell: source  <(kubectl  completion bash)
  - name: add config > ~/.bashrc
    shell: echo " source  <(kubectl  completion bash)"  >>  ~/.bashrc
 # - name: install hugepage
 #  shell: kubectl apply -f hugepage.yaml
  - name: sleep 5
    shell: sleep 5
  #最佳绑核
  - name: edit 10-kubeadm.conf
    shell: sed -i 's/Environment=\"KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=\/etc\/kubernetes\/bootstrap-kubelet.conf --kubeconfig=\/etc\/kubernetes\/kubelet.conf\"/Environment=\"KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=\/etc\/kubernetes\/bootstrap-kubelet.conf --cpu-manager-policy=static --kube-reserved=cpu=1,memory=1000Mi --kubeconfig=\/etc\/kubernetes\/kubelet.conf\"/g' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
  #重启kubelet
  - name: restart kubelet
    shell: systemctl restart kubelet
  #reload 系统状态
  - name: reload
    shell: systemctl daemon-reload
  #rbac
  #创建测试用户user1
  - name: useradd user1
    shell: useradd user1
  #生成私钥
  - name: make user1.key
    shell: umask 077;openssl genrsa -out /etc/kubernetes/pki/user1.key 2048
  #生成证书
  - name: make user1.csr
    shell: openssl req -new -key /etc/kubernetes/pki/user1.key -out /etc/kubernetes/pki/user1.csr -subj  "/CN=user1/O=k8s"
  #签署证书
  - name: sign user1.csr
    shell: openssl x509 -req -in /etc/kubernetes/pki/user1.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /etc/kubernetes/pki/user1.crt -days 500
  #创建rbac集群
  - name: create cluster
    shell: kubectl config set-cluster k8s --server=https://{{master_ip}}:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true --kubeconfig=/etc/kubernetes/pki/user1.conf
  #初始化user1的配置
  - name: Create user configuration
    shell: kubectl config set-credentials user1 --client-certificate=/etc/kubernetes/pki/user1.crt --client-key=/etc/kubernetes/pki/user1.key --embed-certs=true --kubeconfig=/etc/kubernetes/pki/user1.conf
  - name: sleep 30
    shell: sleep 30
  #修改配置文件
  - name: rm multus-daemonset.yml
    shell: rm -rf /root/multus-cni/deployments/multus-daemonset.yml
  #拷贝更改后的文件
  - name: cp -f /root/multus-daemonset.yml /root/multus-cni/deployments/
    shell: cp -f /root/multus-daemonset.yml /root/multus-cni/deployments/
  #加载multus-cni-3.8镜像
  - name: load multus-cni-3.8.tar.gz
    shell: ctr -n=k8s.io image import multus-cni-3.8.tar.gz
  #部署multus
  - name: apply multus-daemonset.yml
    shell: kubectl apply -f /root/multus-cni/deployments/multus-daemonset.yml
  - name: sleep 30
    shell: sleep 30
  #部署 macvlan
  - name: macvlan-conf 
    shell: kubectl apply -f macvlan-conf.yml
```

```shell
cat setup.sh

#!/bin/bash
#---------------设置网卡信息---------------#
echo 'The name of the network card of this machine is as follows:'
nmcli | grep ^en | awk -F':' '{print $1}'
read -p "Please enter the network card name:"  ens
read -p "Please enter the IP address:"    ip
read -p "Please enter the subnet mask:"  mask
read -p "Please enter the gateway:"     gateway
read -p "Please enter DNS:"      dns
pa="/etc/sysconfig/network-scripts/ifcfg-"
echo "TYPE=Ethernet"  >  $pa$ens
echo "BOOTPROTO=none"  >>  $pa$ens
echo "NAME=$ens"  >>  $pa$ens
echo "DEVICE=$ens"  >>  $pa$ens
echo "ONBOOT=yes"  >>  $pa$ens
echo "IPADDR=$ip"  >>  $pa$ens
echo "NETMASK=$mask"  >>  $pa$ens
echo "GATEWAY=$gateway"  >>  $pa$ens
echo "DNS1=$dns"  >>  $pa$ens

systemctl restart NetworkManager

sleep 5
#---------------设置系统时间---------------#
echo "The current time of the system is:`date`"
current_years=`date +%Y`
function set_systime(){
  read -p "Please enter the date (format: 2022-01-01):"  ymd
  read -p "Please enter the time (format: 01:01:01):"   hms
  date -s $ymd >/dev/null
  echo "The modified time is: `date -s $hms`"
}
if [ $current_years -lt 1981 ];then
  echo "Please change the current time to the latest time!"
  set_systime
else
  read -p "Do you want to modify the current time?[y/n]" confirm
  if [ $confirm = 'y' ];then
    set_systime
  else
    echo "The system time does not need to be modified. Continue the installation."
  fi
fi

#---------------设置ssh免密登入---------------#
HOST_PASS_NODE=cmcc123*
expect << EOF
set timeout 5
spawn ssh-keygen -t rsa
expect "id_rsa):" 
send "\r" 
expect "passphrase):" 
send "\r"
expect "again:"
send "\r" 
expect eof
EOF
expect << EOF
set timeout 5
spawn ssh-copy-id root@$ip
expect "(yes/no)?" 
send "yes\r"
expect "password:" 
send "$HOST_PASS_NODE\r" 
expect eof
EOF

#---------------配置ansible主机清单---------------#
echo '[master]' >>/etc/ansible/hosts
echo "$ip" >>/etc/ansible/hosts
#---------------安装配置k8s---------------#
ansible-playbook -e master_ip=$ip -v nonet-k8s-install-nosriov.yml

sed -i '/^sh/d'  /root/.bash_profile
```

```shell
cat  edit_kernel.sh

#!/bin/bash
sed -i 's/^GRUB_CMDLINE_LINUX.*/GRUB_CMDLINE_LINUX=\"video=VGA-1:640x480-32@60me console=tty0 crashkernel=1024M,high smmu.bypassdev=0x1000:0x17 smmu.bypassdev=0x1000:0x15 isolcpus=8-63 rcu_nocbs=8-63 rcu_nocb_poll numa_balancing=disable nohlt intel_pstate=disable intel_idle.max_cstate=0 processor.max_cstate=1 nosoftlockup skew_tick=1 tsc=reliable quiet nmi_watchdog=0 default_hugepagesz=2M hugepagesz=2M hugepages=8192 iommu.passthrough=on selinux=0 audit=0 irqaffinity=0-7 idle=nomwait apparmor=0 iommu=pt intel_iommu=on video=efifb:off\"/g' /etc/default/grub
/usr/sbin/grub2-mkconfig  -o  /boot/efi/EFI/openEuler/grub.cfg
sed -i '/^sh/d'  /etc/rc.d/rc.local
CONFIG_DEBUG_KERNEL=n
CONFIG_WW_MUTEX_SELFTEST=n
sysctl -w kernel.hung_task_timeout_secs=600
sysctl -w kernel.sched_rt_runtime_us=-1
sysctl -w vm.stat_interval=10
sysctl -w kernel.timer_migration=0
sed -i '/^IRQBALANCE_BANNED_CPUS=/d' /etc/sysconfig/irqbalance
echo "IRQBALANCE_BANNED_CPUS=0fffffff,fffffff0" > /etc/sysconfig/irqbalance
for i in `pgrep ksoftirqd`; do chrt -p -f 2 $i; done
for i in `pgrep rcuc`; do chrt -p -f 4 $i; done
for i in `pgrep rcub`; do chrt -p -f 4 $i; done
for i in `pgrep ktimersoftd`; do chrt -p -f 3 $i; done
echo 0 > /dev/cpu_dma_latency
echo -1 > /proc/sys/kernel/sched_rt_period_us
echo -1 > /proc/sys/kernel/sched_rt_runtime_us
date -s "2022-09-23"  #不加的话，系统时间是1970，ansible命令不能执行
/usr/sbin/shutdown -r now
```

**6）** **配置修改normal.xml文件**

```shell
cp /mnt/repodata/*normal.xml /ISO/repodata
cd /ISO/repodata
mv *normal.xml normal.xml
vim /ISO/repodata/normal.xml 添加如下配置
```

```xml
<group>

  <id>yfqansible</id>

  <name>yfqansible</name>

  <name xml:lang="zh_CN">yfqansible</name>

  <description>yfqansible</description>

  <description xml:lang="zh_CN">yfqansible</description>

  <default>false</default>

  <uservisible>false</uservisible>

  <packagelist>

   <packagereq type="default">ansible</packagereq>

   <packagereq type="default">ansible-help</packagereq>

    <packagereq type="default">libsodium</packagereq>

    <packagereq type="default">python3-asn1crypto</packagereq>

    <packagereq type="default">python3-babel</packagereq>

    <packagereq type="default">python3-bcrypt</packagereq>

    <packagereq type="default">python3-cffi</packagereq>

    <packagereq type="default">python3-cryptography</packagereq>

    <packagereq type="default">python3-httplib2</packagereq>

    <packagereq type="default">python3-idna</packagereq>

    <packagereq type="default">python3-jinja2</packagereq>

    <packagereq type="default">python3-jmespath</packagereq>

    <packagereq type="default">python3-markupsafe</packagereq>

    <packagereq type="default">python3-paramiko</packagereq>

    <packagereq type="default">python3-ply</packagereq>

    <packagereq type="default">python3-pyasn1</packagereq>

    <packagereq type="default">python3-pycparser</packagereq>

    <packagereq type="default">python3-pynacl</packagereq>

    <packagereq type="default">python3-pytz</packagereq>

    <packagereq type="default">python3-pyyaml</packagereq>

    <packagereq type="default">sshpass</packagereq>

    <packagereq type="default">tar</packagereq>
    
    <packagereq type="default">tar</packagereq>

  </packagelist>

 </group>

 <group>

  <id>vim</id>

  <name>vim</name>

  <name xml:lang="zh_CN">vim</name>

  <description>vim</description>

  <description xml:lang="zh_CN">vim</description>

  <default>false</default>

  <uservisible>false</uservisible>

  <packagelist>

  <packagereq type="default">vim-enhanced</packagereq>

   <packagereq type="default">vim-filesystem</packagereq>

  <packagereq type="default">vim-common</packagereq>

  <packagereq type="default">gpm-libs</packagereq>

 </packagelist>

 </group>

 <group>

  <id>kernel-rt</id>

  <name>kernel-rt</name>

  <name xml:lang="zh_CN">kernel-rt</name>

  <description>kernel-rt</description>

  <description xml:lang="zh_CN">kernel-rt</description>

  <default>false</default>

  <uservisible>false</uservisible>

  <packagelist>

   <packagereq type="default">kernel-rt</packagereq>

  </packagelist>

  </group>
```

修改如下配置：

```xml
<environment>

  <id>minimal-environment</id>

  <name>Minimal Install</name>

  <name xml:lang="zh_CN">最小安装</name>

  <description>Basic functionality.</description>

  <description xml:lang="zh_CN">基本功能。</description>

  <display_order>1</display_order>

  <grouplist>

   <groupid>core</groupid>

   <groupid>yfqansible</groupid>

   <groupid>vim</groupid>

   <groupid>kernel-rt</groupid>

  </grouplist>

  <optionlist>

   <groupid>standard</groupid>

  </optionlist>

 </environment>

 <environment>
```

**7）** **制作repodata包**

```shell
cd /ISO 

createrepo -g repodata/normal.xml ./
```

#### 3、制作镜像

\# 注意参数中的-V，和上面的 grub.cfg 文件有关 

```shell
cd /ISO
#生成镜像包
genisoimage -e images/efiboot.img -no-emul-boot -T -J -R -c boot.catalog -hide boot.catalog -V openEuler-22.03-LTS-aarch64 -o openEuler-22.03-LTS-aarch64.iso /ISO
```

至此，自定义制作的镜像就已完成了。

