#!/bin/bash


blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
bred(){
    echo -e "\033[31m\033[01m\033[05m$1\033[0m"
}
byellow(){
    echo -e "\033[33m\033[01m\033[05m$1\033[0m"
}


function install_smartpi(){
apt update && apt upgrade -y
apt install --no-install-recommends --no-install-suggests -y git net-tools curl
source /etc/profile

wget https://github.com/pymumu/smartdns/releases/download/Release28/smartdns.1.2019.12.15-1028.x86_64-linux-all.tar.gz
tar zxf smartdns.1.2019.12.15-1028.x86_64-linux-all.tar.gz
cd smartdns
chmod +x ./install
./install -i
rm -rf /etc/smartdns/smartdns.conf
cat > /etc/smartdns/smartdns.conf <<-EOF

bind [::]:5599

cache-size 512

prefetch-domain yes

rr-ttl 300
rr-ttl-min 60
rr-ttl-max 86400

log-level info
log-file /var/log/smartdns.log
log-size 128k
log-num 2

server 202.141.162.123
server 202.141.176.93
server-tcp 202.141.162.123
server-tcp 202.141.176.93
server-tcp 114.114.114.114
server-tls 8.8.8.8
server-tls 8.8.4.4

EOF

cp /etc/smartdns/smartdns.conf /etc/smartdns/smartdns.conf.bak

systemctl enable smartdns > /dev/null 2>&1
systemctl restart smartdns > /dev/null 2>&1

mkdir /etc/pihole/

pi_wd="4739aedfec7b085af55a29976725a386ad39c9d88f1228c6cffe4ee52971b206"

lan_n=$(ip --oneline link show up | grep -v "lo" | awk '{print $2}' | cut -d':' -f1 | cut -d'@' -f1 | awk 'NR==1{print}')
loc_ip=$(ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:")

echo "" > /etc/pihole/adlists.list

cat > /etc/pihole/setupVars.conf << EOF
PIHOLE_INTERFACE=$lan_n
IPV4_ADDRESS=$loc_ip/24
QUERY_LOGGING=false
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
BLOCKING_ENABLED=true
WEBPASSWORD=$pi_wd
DNSMASQ_LISTENING=single
PIHOLE_DNS_1=127.0.0.1#5599
DNS_FQDN_REQUIRED=true
DNS_BOGUS_PRIV=true
DNSSEC=false
CONDITIONAL_FORWARDING=false
EOF

cd ~

git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
bash ~/Pi-hole/"automated install"/basic-install.sh /dev/stdin --unattended
rm -rf ~/Pi-hole

systemctl mask --now dhcpcd > /dev/null 2>&1
systemctl daemon-reload > /dev/null 2>&1

systemctl restart pihole-FTL
pihole -f

cat > cat /etc/resolvconf/resolv.conf.d/base << EOF
nameserver 114.114.114.114
EOF

	green " ===========================请重启debian系统=============================="
	green " SmartPi安装完成"
    green " 系统：>=debian9"
    green " Youtube：米月"
    green " 电报群：https://t.me/mi_yue"
    green " Youtube频道地址：https://www.youtube.com/channel/UCr4HCEgaZ0cN5_7tLHS_xAg"
	green " SmartPi后台地址：http://$loc_ip/admin"
	green " ===========================请重启debian系统=============================="

}

function update_smartdns(){
if test -s /etc/smartdns/smartdns.conf.bak; then
	rm -rf /etc/smartdns/smartdns.conf.bak
	cp /etc/smartdns/smartdns.conf /etc/smartdns/smartdns.conf.bak
	./install -u
	rm -rf /root/smartdns*
fi
wget https://github.com/pymumu/smartdns/releases/download/Release28/smartdns.1.2019.12.15-1028.x86_64-linux-all.tar.gz
tar zxf smartdns.1.2019.12.15-1028.x86_64-linux-all.tar.gz
cd smartdns
chmod +x ./install
./install -i
if test -s /etc/smartdns/smartdns.conf.bak; then
	rm -rf /etc/smartdns/smartdns.conf
	cp /etc/smartdns/smartdns.conf.bak /etc/smartdns/smartdns.conf
fi
systemctl enable smartdns
systemctl restart smartdns
pihole restartdns
	green " ===========================请重启debian系统=============================="
	green " SmartPi更新完成"
    green " 系统：>=debian9"
    green " Youtube：米月"
    green " 电报群：https://t.me/mi_yue"
    green " Youtube频道地址：https://www.youtube.com/channel/UCr4HCEgaZ0cN5_7tLHS_xAg"
	green " ===========================请重启debian系统=============================="
}

function m_pass(){
    red " =================================="
    red " 修改pi-hole密码"
    red " =================================="
    pihole -a -p
    red " =================================="
    red " pi-hole密码修改完成"
    red " =================================="
}

function rebuil_pi-hole(){
    green " ================================"
    green " 开始重新安装pi-hole"
    green " ================================"
    pihole -r
    green " ================================"
    green " pi-hole安装完成"
    green " ================================"
}

start_menu(){
    clear
    green " ========================================================================"
    green " 简介：debian一键安装SmartPi"
    green " 系统：>=debian9"
    green " Youtube：米月"
    green " 电报群：https://t.me/mi_yue"
    green " Youtube频道地址：https://www.youtube.com/channel/UCr4HCEgaZ0cN5_7tLHS_xAg"
	green " SmartPi版本：20200107v3"
    green " ========================================================================"
    echo
    green  " 1. 一键安装SmartPi"
	green  " 2. 一键更新SmartPi"
	green  " 3. 重新安装pi-hole"
	green  " 4. 更改pi-hole密码"
    yellow " 0. 退出脚本"
    echo
    read -p " 请输入数字:" num
    case "$num" in
    1)
    install_smartpi
    ;;
    2)
    update_smartdns
    ;;
	3)
    rebuil_pi-hole 
    ;;
	4)
    m_pass 
    ;;
    0)
    exit 1
    ;;
    *)
    clear
    red "输入的数字不正确，请重新输入"
    sleep 1s
    start_menu
    ;;
    esac
}

start_menu
