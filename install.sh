clear
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

wget https://github.com/KLDGodY/MTProxy/raw/master/MTProxy
mv ./MTProxy /usr/bin/MTProxy
chmod 700 /usr/bin/MTProxy

clear
sleep 2
echo "--------------------"
echo "你的MTProxy链接是:"
echo "tg://proxy?server=$IPAddress&port=$mtp_port&secret=ee$secret$domainhex"
echo
echo "你可以在终端输入\"MTProxy\"快速打开此脚本"
