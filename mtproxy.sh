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
echo "Telegram: https://t.me/joinchat/MjcleElLvN0VZSoHrmKKdw"
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
	wget https://github.com/KLDGodY/MTProxy/raw/master/install.sh
	bash install.sh
	rm -rf install.sh
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
