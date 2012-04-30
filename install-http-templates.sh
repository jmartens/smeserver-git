#!/bin/bash

rm -rf /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
rm -rf /etc/e-smith/templates-custom/etc/httpd/conf/httpd.conf/80SubDomainGit
cp -r  root/etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit /etc/e-smith/templates/etc/httpd/conf/httpd.conf/
chown  -R root:root /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit

rm -rf /etc/e-smith/web/common/git*
cp -r  root/etc/e-smith/web/common/git* /etc/e-smith/web/common
chown  -R root:root /etc/e-smith/web/common/git*
chmod  444 /etc/e-smith/web/common/git*

expand-template /etc/gitweb.conf
expand-template /etc/e-smith/web/common/gitweb_home_text.html
expand-template /etc/httpd/conf/httpd.conf

/usr/sbin/apachectl -t
[ $? -eq 0 ] && /etc/init.d/httpd-e-smith restart && less -N /etc/httpd/conf/httpd.conf
