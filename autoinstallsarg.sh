#!/bin/bash

## SETANDO VARIAVEIS ##
depend=("epel-release wget tar ndash gcc gd gd-devel make perl-GD httpd")
urlsarg=("https://iweb.dl.sourceforge.net/project/sarg/sarg/sarg-2.3.11/sarg-2.3.11.tar.gz")
osversion=$(awk '{if ($3 ~ /[0-9]/) print $3} ; {if ($4 ~ /[0-9]/) print $4}' /etc/centos-release | cut -d. -f 1)
sgconf="/usr/local/etc/sarg.conf"
httpdconf="/etc/httpd/conf/httpd.conf"
IP_1="ServerName"
IP_2=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
IP_Global="$IP_1 $IP_2:80"

## SETANDO IP ##

echo "EDITE O IP ABAIXO SE NESCESSARIO"
read -p "Endereco IP: " -e -i $IP_2 IP

## INSTALANDO  DEPENDENCIAS ##

yum install "$depend" -y > /dev/null 2>&1
echo -ne '###                                  (10%)\r'
sleep 1

## INICIANDO O SERVICO DO APACHE ##

if [ "$osversion" -lt "7" ]
        then
            /etc/init.d/httpd start > /dev/null 2>&1
        else
            systemctl start httpd > /dev/null 2>&1
fi
echo -ne '######                               (33%)\r'
sleep 1

## CONFIGURANFO O ARQUIVO .CONF DO APACHE ##

if [ -f "$httpdconf" ]
	then
		cp -f "$httpdconf" "$httpdconf.bkp"
		sed -i "s/^#ServerName.*/$IP_Global/" "$httpdconf"
fi

echo -ne '#########                            (42%)\r'
sleep 1

## REINICIAR APACHE ##
if [ "$osversion" -lt "7" ]
	then
		/etc/init.d/httpd restart > /dev/null 2>&1
	else
		systemctl restart httpd > /dev/null 2>&1
fi

echo -ne '############                         (55%)\r'
sleep 1

## CRIANDO E MUDANDO DE DIRETORIO ##

mkdir -p ~/install_sarg
cd ~/install_sarg

echo -ne '###############                      (61%)\r'
sleep 1

## DOWNLOAD SARG ##

wget "$urlsarg" > /dev/null 2>&1

echo -ne '##################                   (77%)\r'
sleep 1

## EXTRAINDO SARG ##

tar -xvzf sarg-2.3.11.tar.gz > /dev/null 2>&1
cd sarg-2.3.11

echo -ne '#####################                (85%)\r'
sleep 1

## RODANDO .CONFIGURE ##

./configure > /dev/null 2>&1

echo -ne '########################             (90%)\r'
sleep 1

## RODANDO MAKE ##

make > /dev/null 2>&1
echo -ne '###########################          (93%)\r'
sleep 1

## RODANDO MAKE INSTALL ##

make install > /dev/null 2>&1
echo -ne '##############################       (98%)\r'
sleep 1

## EDITANDO O ARQUIVO .CONF DO SARG ##

if [ -f "$sgconf" ]
	then
		cp "$sgconf" "$sgconf.bkp"
		cat <<EOF >"$sgconf"
access_log /var/log/squid/access.log
output_dir /var/www/html/squid-report
date_format e
overwrite_report yes
EOF
fi

echo -ne '################################        (99%)\r'
sleep 1

## REMOVENDO ARQUIVOS TEMPORARIOS ##

rm -rf ~/install_sarg > /dev/null 2>&1

echo -ne '#################################        (100%)\r'
sleep 1
echo -ne '\n'
