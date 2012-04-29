#!/bin/bash

rm -rf /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
rm -rf /etc/e-smith/templates-custom/etc/httpd/conf/httpd.conf/80SubDomainGit
cp -r  root/etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit /etc/e-smith/templates/etc/httpd/conf/httpd.conf/
chown  -R root:root /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
expand-template /etc/httpd/conf/httpd.conf

/usr/sbin/apachectl -t
[ $? -eq 0 ] && /etc/init.d/httpd-e-smith restart && less -N /etc/httpd/conf/httpd.conf
