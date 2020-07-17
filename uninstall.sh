if [ ! -d "/root/mtprotoproxy" ]; then
	echo "宝贝,都没安装呢:("
else
	echo "你确定要卸载吗?(请输入y或者n):"
	read choice
	if [ "$choice" = "y" ]; then
		docker stop mtprotoproxy_mtprotoproxy_1
		cd /root
		rm -rf /root/mtprotoproxy
	elif [ "$choice" = "n" ]; then
		echo "，，，"
	else
		echo "退出ing..."
	fi
fi
