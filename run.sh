#!/bin/sh
# 去除开头结尾的空白字符
trim() {
    str=""

    if [ $# -gt 0 ]; then
        str="$1"
    fi
    echo "$str" | sed -e 's/^[ \t\r\n]*//g' | sed -e 's/[ \t\r\n]*$//g'
}

# 获取系统标识符：ubuntu、centos、alpine等
getOs() {
    os=$(trim $(cat /etc/os-release 2>/dev/null | grep ^ID= | awk -F= '{print $2}'))

    if [ "$os" = "" ]; then
        os=$(trim $(lsb_release -i 2>/dev/null | awk -F: '{print $2}'))
    fi
    if [ ! "$os" = "" ]; then
        os=$(echo $os | tr '[A-Z]' '[a-z]')
    fi

    # 去除双引号返回
    echo $os | sed 's/\"//g'
}

# 具体业务逻辑
os=$(getOs)
case $os in
debian)
    # 安装软件vim/telnet/ping/ip addr/
    apt-get update && apt-get install vim telnet iputils-ping iproute2 -y
    TZ=Asia/Shanghai
    DEBIAN_FRONTEND=noninteractive
    ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
    echo ${TZ} > /etc/timezone
    dpkg-reconfigure --frontend noninteractive tzdata
    rm -rf /var/lib/apt/lists/*
    ;;
ubuntu)
    # 安装软件
    apt-get update && apt-get install vim telnet iputils-ping -y
    # 设置时区
    ln -sf /usr/share/zoneinfo/Asia/ShangHai /etc/localtime
    echo "Asia/Shanghai" > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
    rm -rf /var/lib/apt/lists/*
    ;;
centos)
    # 设置编码格式
    LC_ALL en_US.UTF-8
    # 设置时区
    TZ=Asia/Shanghai
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
    ;;
ol)
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "Asia/Shanghai" > /etc/timezone
    # microdnf update -y
    # microdnf install vim -y
    microdnf install telnet -y
    microdnf install iputils -y     # ping
    microdnf install openssl -y
    # microdnf install net-tools -y # ifconfig
    microdnf install iproute -y     # ip
    microdnf install nc -y
    ;;
alpine)
    # 更新
    apk update && apk upgrade
    # 设置时区
    apk add tzdata
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "Asia/Shanghai" > /etc/timezone
    apk del tzdata
    apk add curl
    apk add busybox-extras # telnet
    apk -U add openssl
    # 删除缓存
    rm -rf /var/cache/apk/*
    ;;
*)
    echo unknow os $os, exit!
    # return
    ;;
esac