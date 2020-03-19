#!/bin/bash

pause() {
	read -rsp "$(echo -e "按$green Enter 回车键 $none继续....或按$red Ctrl + C $none取消.")" -d $'\n'
	echo
}
red='\e[91m'
none='\e[0m'

[[ $(id -u) != 0 ]] && echo -e "哎呀......请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1
clear
echo "--------------------"
echo "项目地址: https://github.com/KLDGodY/MTProxy"
echo "运行脚本: bash <(curl -sSL https://git.io/JvXJX)"
echo "Telegram: https://t.me/kldgodynb"
echo
echo "1) 安装代理"
echo "2) 卸载代理"
echo "3) 运行服务"
echo "4) 重启服务"
echo "5) 停止服务"
echo "0) 退出脚本"
echo "--------------------"
echo "请输入命令:"
read choice
if [ "$choice" = "1" ]; then
	if [ -d "/root/mtprotoproxy" ]; then
		echo "!检测到目录存在!(如果没安装提示这个 请 rm -rf /root/mtprotoproxy)"
		exit 1
	fi
	cd /root
	echo "开始安装MTProxy"
	
	#安装必要组件
	apt update 2>/dev/null
	apt install git wget curl -y 2>/dev/null
	yum update -y 2>/dev/null
	yum install install git wget curl -y 2>/dev/null
	wget -qO- get.docker.com | sh
	systemctl enable docker
	curl -L https://github.com/docker/compose/releases/download/1.25.0-rc4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	
	#Clone & cd
	git clone https://github.com/alexbers/mtprotoproxy.git -b stable
	cd mtprotoproxy
	
	#端口
	mtp_port=443
	while true
	do
		echo "请输入要设置的端口(不填写则默认443端口):"
		read mtp_port
		if [ ! -n "$mtp_port" ]; then
			echo "使用默认端口: 443"
			mtp_port=443
			break
		else
			if [ ${mtp_port} -ge 1 ] && [ ${mtp_port} -le 65535 ] && [ ${mtp_port:0:1} != 0 ]; then
				echo "使用自定义端口: $mtp_port"
				sed -i "s/PORT = 443/PORT = $mtp_port/g" /root/mtprotoproxy/config.py
				break
			fi
		fi
		echo -e "[\033[33m错误\033[0m] 请重新输入一个客户端连接端口 [1-65535]"
	done
	
	
	#Fake TLS
	while true
	do
		echo "请输入需要伪装的域名:"
		read domain
		if [ ! -n "$domain" ]; then
			echo "使用默认域名: www.cloudflare.com"
			sed -i "s/# TLS_DOMAIN = \"www.google.com\"/TLS_DOMAIN = \"www.cloudflare.com\"/g" /root/mtprotoproxy/config.py
			domain='www.cloudflare.com'
			break
		else
			http_code=$(curl -I -m 10 -o /dev/null -s -w %{http_code} $domain)
			if [ $http_code -eq "200" ] || [ $http_code -eq "302" ]; then
				sed -i "s/# TLS_DOMAIN = \"www.google.com\"/TLS_DOMAIN = \"$domain\"/g" /root/mtprotoproxy/config.py
				break
			fi
		fi
		echo -e "[\033[33m错误\033[0m] 域名无法访问,请重新输入或更换域名!"
	done
	
	secret=$(head -c 16 /dev/urandom | xxd -ps)
	sed -i "s/00000000000000000000000000000001/$secret/g" /root/mtprotoproxy/config.py
	
	#AG_TAG
	echo "请输入你的AD_TAG(留空则跳过 你的secret为$secret):"
	read adtag
		sed -i "s/# AD_TAG = \"3c09c680b76ee91a4c25ad51f742267d\"/AD_TAG = \"$adtag\"/g" /root/mtprotoproxy/config.py
	
	hexvel=$(xxd -pu <<< "$domain")
	domainhex=${hexvel%0a}
	
	echo "请确认配置是否有误"
	echo "--------------------"
	echo "Secret: $secret"
	echo "Port: $mtp_port"
	echo "Fake TLS domain: $domain"
	echo "AD_TAG: $adtag"
	echo "--------------------"
	pause
	
	#获取IP
	IPAddress=$(curl -s https://api.ip.sb/ip --ipv4)
	
	docker-compose up -d
	
	clear
	sleep 2
	echo "--------------------"
	echo "你的MTProxy链接是:"
	echo "tg://proxy?server=$IPAddress&port=$mtp_port&secret=ee$secret$domainhex"
#结束安装

elif [ "$choice" = "2" ]; then
	if [ ! -d "/root/mtprotoproxy" ]; then
		echo "宝贝,都没安装呢:("
	else
		cd /root/mtprotoproxy && docker stop mtprotoproxy_mtprotoproxy_1 && docker rm mtprotoproxy_mtprotoproxy_1 && rm -rf /root/mtprotoproxy
		echo "卸载完成!"
	fi
elif [ "$choice" = "0" ]; then
	exit
#结束卸载

elif [ "$choice" = "3" ]; then
	if [ ! -d "/root/mtprotoproxy" ]; then
		echo "宝贝,都没安装呢:("
	else
		cd /root/mtprotoproxy && docker start mtprotoproxy_mtprotoproxy_1
	fi
#结束启动

elif [ "$choice" = "4" ]; then
	if [ ! -d "/root/mtprotoproxy" ]; then
		echo "宝贝,都没安装呢:("
	else
		cd /root/mtprotoproxy
		docker stop mtprotoproxy_mtprotoproxy_1
		service docker restart
		docker start mtprotoproxy_mtprotoproxy_1
	fi
#结束重启

elif [ "$choice" = "5" ]; then
	if [ ! -d "/root/mtprotoproxy" ]; then
		echo "宝贝,都没安装呢:("
	else
		cd /root/mtprotoproxy
		docker stop mtprotoproxy_mtprotoproxy_1
	fi
#结束停止

elif [ "$choice" = "" ];then
	echo "你什么都不输入你到底想让我干什么..."

else
	echo "???你输入的东西 这个辣鸡脚本不懂诶:("
fi
