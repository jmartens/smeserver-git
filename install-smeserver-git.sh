#!/bin/bash

echo "Enabling the git service ..."
config setprop git status enabled

echo "Creating repository base directory ..."
mkdir -p  /home/e-smith/files/git
chown  admin:www /home/e-smith/files/git
chmod  770       /home/e-smith/files/git
chmod  g+s       /home/e-smith/files/git

echo "Installing HTTP template ..."
rm -f  /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
cp -r  root/etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit /etc/e-smith/templates/etc/httpd/conf/httpd.conf/
chown  -R root:admin /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
chmod  544           /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit

echo "Installing Git repository database library ..."
cp -f     root/usr/lib/perl5/site_perl/esmith/GitDB.pm /usr/lib/perl5/site_perl/esmith
chown  -R root:admin /usr/lib/perl5/site_perl/esmith/GitDB.pm
chmod  644           /usr/lib/perl5/site_perl/esmith/GitDB.pm

echo "Installing server manager FormMagick handler ..."
cp -f  root/usr/lib/perl5/site_perl/esmith/FormMagick/Panel/git.pm /usr/lib/perl5/site_perl/esmith/FormMagick/Panel
chown  -R root:admin /usr/lib/perl5/site_perl/esmith/FormMagick/Panel/git.pm
chmod  644           /usr/lib/perl5/site_perl/esmith/FormMagick/Panel/git.pm

echo "Installing server manager FormMagick module  ..."
cp -f  root/etc/e-smith/web/functions/git /etc/e-smith/web/functions
chown  -R root:admin /etc/e-smith/web/functions/git
chmod  755           /etc/e-smith/web/functions/git
chmod  u+s           /etc/e-smith/web/functions/git

echo "Installing server manager FormMagick language module en-us ..."
cp -f  root/etc/e-smith/locale/en-us/etc/e-smith/web/functions/git /etc/e-smith/locale/en-us/etc/e-smith/web/functions
chown  -R root:admin /etc/e-smith/locale/en-us/etc/e-smith/web/functions/git
chmod  644           /etc/e-smith/locale/en-us/etc/e-smith/web/functions/git

echo "Installing server manager action scripts ..."
cp -f  root/etc/e-smith/events/actions/git* /etc/e-smith/events/actions
chown  -R root:root  /etc/e-smith/events/actions/git*
chmod  554           /etc/e-smith/events/actions/git*

echo "Linking events to action scripts ..."
echo "TBD"

echo "Updating server-manager panel ..."
/etc/e-smith/events/actions/navigation-conf

echo "Expanding HTTP template ..."
expand-template     /etc/httpd/conf/httpd.conf

echo "Installing Markdown.pl package ..."

mkdir -p  /usr/share/markdown
cp -rf    root/usr/share/markdown/* /usr/share/markdown
chown  -R root:root /usr/share/markdown
chown  -R root:root /usr/share/markdown/*
chmod  444          /usr/share/markdown/*

echo "Installing Gitweb resources ..."
rm -f      /etc/e-smith/web/common/git*
cp -r  root/etc/e-smith/web/common/git* /etc/e-smith/web/common
chown  -R root:root /etc/e-smith/web/common/git*
chmod  444          /etc/e-smith/web/common/git*

# Gitweb Config
echo "Installing Gitweb.conf template fragments ..."
rm -rf     /etc/e-smith/templates/etc/gitweb.conf
mkdir  -p  /etc/e-smith/templates/etc/gitweb.conf
cp -r  root/etc/e-smith/templates/etc/gitweb.conf/* /etc/e-smith/templates/etc/gitweb.conf
chown  -R root:root /etc/e-smith/templates/etc/gitweb.conf
chmod  444          /etc/e-smith/templates/etc/gitweb.conf/*

echo "Expanding gitweb.conf template fragments ..."
expand-template     /etc/gitweb.conf

echo "Installing gitweb home text template fragments ..."
rm -rf     /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
mkdir  -p  /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
cp -r  root/etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html/* /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
chown  -R root:root /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
chmod  444          /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html/*

echo "Expanding gitweb home text template fragments ..."
expand-template     /etc/e-smith/web/common/gitweb_home_text.html

echo "Validating httpd.cond syntax and restarting Apache ..."
/usr/sbin/apachectl -t
[ $? -eq 0 ] && /etc/init.d/httpd-e-smith restart && less -N /etc/httpd/conf/httpd.conf
