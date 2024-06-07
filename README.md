### 1、找一台服务器安装Ansible
```
# yum install epel-release -y
# yum install ansible -y
```
### 2、下载所需文件

下载Ansible部署文件：

```
# git clone https://github.com/lizhenliang/ansible-install-k8s
# cd ansible-install-k8s
```

下载准备好软件包（包含所有涉及文件和镜像，比较大），解压到指定目录：

```
# tar zxf binary_pkg.tar.gz
```
### 3、修改Ansible文件

修改hosts文件，根据规划修改对应IP和名称。

```
# vi hosts
...
```
修改group_vars/all.yml文件，修改软件包目录和证书可信任IP。

```
# vim group_vars/all.yml
software_dir: '/root/binary_pkg'
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

单Master版：
```
# ansible-playbook -i hosts single-master-deploy.yml -uroot
```
多Master版(未开发)：
```
# ansible-playbook -i hosts multi-master-deploy.yml -uroot
```

## 5、查看集群节点
```
# kubectl get node
NAME          STATUS   ROLES    AGE   VERSION
k8s-master1   Ready    <none>   9h    v1.24.2
k8s-node1     Ready    <none>   9h    v1.24.2
k8s-node2     Ready    <none>   9h    v1.24.2
```

## 6、其他
### 6.1 部署控制
如果安装某个阶段失败，可针对性测试.

例如：只运行部署插件
```
# ansible-playbook -i hosts single-master-deploy.yml -uroot --tags addons
```

### 6.2 节点扩容
1）修改hosts，添加新节点ip

```
# 配置 server.txt服务器信息
# sh setup_ssh_keys.sh

# vi hosts
...
[newnode]
192.168.114.75 node_name=k8s-node3
```
2）执行部署
```
# ansible-playbook -i hosts add-node.yml -uroot
```
### 6.3 所有HTTPS证书存放路径
部署产生的证书都会存放到目录“ansible-install-k8s-master/ssl”，一定要保存好，后面还会用到~
