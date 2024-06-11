#!/bin/bash

#apt install expect ssh sshpass

# 文件名
SERVER_LIST="servers.txt"
KEY_PATH="$HOME/.ssh/id_rsa"

# 检查是否已经生成了密钥对
if [ ! -f "$KEY_PATH" ]; then
    echo "SSH key not found, generating one..."
    #ssh-keygen -t rsa -N "" -f "$KEY_PATH"
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
else
    echo "SSH key already exists."
fi

# 遍历服务器列表并设置免密登录
while IFS=' ' read -r ip password; do
    echo "Setting up SSH key for $USER@$ip"

	#ssh-copy-id -i $KEY_PATH.pub $USER@$ip
	expect << EOF
		set timeout 5
		spawn ssh-copy-id $USER@$ip
		expect "(yes/no)?" 
		send "yes\r"
		expect "password:" 
		send "$password\r" 
		expect eof
EOF


done < "$SERVER_LIST"

echo "SSH key setup complete for all servers."
