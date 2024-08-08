### 0、集群安装环境

<img width="662" alt="0891e363822b6aa9dbb355f066af4f9" src="https://github.com/user-attachments/assets/2ff36409-2e59-4be1-af16-176c7cabd066">

```
集群服务器架构：arm64
集群操作系统：openeuler22.03
ansible管理机环境：linux(架构、版本随意)
k8s版本：1.24.2
containerd版本：1.6.6
harbor版本：2.10.2
docekr版本：24.0.7
helm版本：3.11.1
helm_prometheus版本：45.23.0
```
<img width="761" alt="818f62181fc150751be1d332b499edb" src="https://github.com/user-attachments/assets/a47a0253-7844-425e-a185-0a6e80c745c0">


### 1、找一台服务器安装Ansible
```
# yum install epel-release -y
# yum install ansible -y
# yum install expect ssh sshpass -y

集群机器需要安装:
# yum install unzip zip tar iptables -y

NFS server机器需要安装：
yum install nfs-utils rpcbind -y
注：做好机器的时间同步
```
### 2、下载所需文件
![image](https://github.com/user-attachments/assets/dacf3102-0573-4420-8e77-2a0e0a87570d)

下载准备好软件包（包含所有涉及文件和镜像，比较大），解压到指定目录：
```
链接：https://pan.baidu.com/s/1I09BeIDG2nIgA9caPhTuiA 
提取码：1234
```
### 3、修改Ansible文件

修改hosts文件，根据规划修改对应IP和名称。

```
# vi hosts
# 根据管理机器架构，选择cfssl tar包版本（x86/arm）
...
```
修改group_vars/all.yml文件，修改软件包目录和证书可信任IP。

```
# vim group_vars/all.yml
software_dir: '/~/k8s_1.24.2'
...
cert_hosts:
  k8s:
  etcd:
```

### 4.2 部署命令
在ansible上运行SSH免密脚本：

```
# 配置 server.txt服务器信息
# sh setup_ssh_keys.sh
```

前期准备工作：
```
#新集群第一次安装，删除ssl文件夹
# ansible-playbook -i hosts 00_prepare.yml -uroot
```

单Master版：
```
# ansible-playbook -i hosts 01_install.yml -uroot
```
多Master版：
```
配置hosts，并且配置group_vars/all.yml HA_SUPPORT: true

# ansible-playbook -i hosts 01_install.yml -uroot
```

## 5、查看集群节点
```
# kubectl get node
NAME          STATUS   ROLES    AGE   VERSION
k8s-master1   Ready    <none>   9h    v1.24.2
k8s-node1     Ready    <none>   9h    v1.24.2
```

## 6、其他
### 6.1 部署控制
如果安装某个阶段失败，可针对性测试.

例如：只运行部署插件
```
# ansible-playbook -i hosts 01_install.yml -uroot --tags addons
```

### 6.2 节点扩容
1）修改hosts，添加新节点ip

```
# 配置 server.txt服务器信息
# sh setup_ssh_keys.sh

# vi hosts
...
[newnode]
192.168.114.75 node_name=k8s-node2
```
2）执行部署
```
# prepare.yml中hosts修改为newnode
# ansible-playbook -i hosts 00_prepare.yml -uroot
# ansible-playbook -i hosts 02_add-node.yml -uroot
```

### 6.3 安装harbor仓库
```
#配置hosts文件中harbor地址，可以和master地址一样
# ansible-playbook -i hosts 03_add-harbor.yml -uroot -t harbor
若docker登录失败，再次执行
# ansible-playbook -i hosts 03_add-harbor.yml -uroot -t harbor_login
```

### 6.4 安装gpu
```
#配置hosts和all.yaml文件中gpu参数
# ansible-playbook -i hosts 04_add-gpu.yml -uroot
```
![image](https://github.com/user-attachments/assets/85d66c2b-a656-466e-b818-2947819a0add)

![image](https://github.com/user-attachments/assets/2b0bea23-c5c1-4631-9764-ed2600575341)

![image](https://github.com/user-attachments/assets/47dfb72b-9e45-4a4f-896a-e289cc9e5425)

### 6.5 所有HTTPS证书存放路径
部署产生的证书都会存放到目录“kube-ansible/ssl”，一定要保存好，后面还会用到~

### 6.6 卸载k8s
```
# sh tools/remove_k8s.sh
```
