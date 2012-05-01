#!/bin/bash

# Enable the git service
config setprop git status enabled

# HTTP template
rm -f  /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
cp -r  root/etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit /etc/e-smith/templates/etc/httpd/conf/httpd.conf/
chown  -R root:root /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
chmod  444          /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
expand-template     /etc/httpd/conf/httpd.conf

# Gitweb Resources
rm -f      /etc/e-smith/web/common/git*
cp -r  root/etc/e-smith/web/common/git* /etc/e-smith/web/common
chown  -R root:root /etc/e-smith/web/common/git*
chmod  444          /etc/e-smith/web/common/git*

# Gitweb Config
rm -rf     /etc/e-smith/templates/etc/gitweb.conf
mkdir  -p  /etc/e-smith/templates/etc/gitweb.conf
cp -r  root/etc/e-smith/templates/etc/gitweb.conf/* /etc/e-smith/templates/etc/gitweb.conf
chown  -R root:root /etc/e-smith/templates/etc/gitweb.conf
chmod  444          /etc/e-smith/templates/etc/gitweb.conf/*
expand-template     /etc/gitweb.conf

# Gitweb home text
rm -rf     /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
mkdir  -p  /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
cp -r  root/etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html/* /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
chown  -R root:root /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
chmod  444          /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html/*
expand-template     /etc/e-smith/web/common/gitweb_home_text.html

/usr/sbin/apachectl -t
[ $? -eq 0 ] && /etc/init.d/httpd-e-smith restart && less -N /etc/httpd/conf/httpd.conf
