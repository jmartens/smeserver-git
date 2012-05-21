#!/bin/bash

if [ `config getprop git status` != 'enabled' ]
then
  echo "Enabling the git service ..."
  config setprop git status enabled
  HTTP_UPDATED=1
fi

if [ ! -d /home/e-smith/files/git ]
then
  echo "Creating repository base directory ..."
  mkdir -p  /home/e-smith/files/git
  chown  admin:www /home/e-smith/files/git
  chmod  770       /home/e-smith/files/git
  chmod  g+s       /home/e-smith/files/git
fi
  
cmp -s root/usr/lib/perl5/site_perl/esmith/GitDB.pm /usr/lib/perl5/site_perl/esmith/GitDB.pm > /dev/null
if [ $? -ne 0 ]
then
  echo "Installing Git repository database library ..."
  touch     /home/e-smith/db/git
  cp -f     root/usr/lib/perl5/site_perl/esmith/GitDB.pm /usr/lib/perl5/site_perl/esmith
  chown  -R root:admin /usr/lib/perl5/site_perl/esmith/GitDB.pm
  chmod  644           /usr/lib/perl5/site_perl/esmith/GitDB.pm
fi

cmp -s root/etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit > /dev/null
if [ $? -ne 0 ]
then
  echo "Installing HTTP template ..."
  rm -f  /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
  cp -r  root/etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit /etc/e-smith/templates/etc/httpd/conf/httpd.conf/
  chown  -R root:admin /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
  chmod  544           /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
  HTTP_UPDATED=1
fi

echo "Installing server manager action scripts ..."
cp -f  root/etc/e-smith/events/actions/git* /etc/e-smith/events/actions
chown  -R root:root  /etc/e-smith/events/actions/git*
chmod  554           /etc/e-smith/events/actions/git*

cmp -s root/etc/e-smith/web/functions/git /etc/e-smith/web/functions/git > /dev/null
if [ $? -ne 0 ]
then
  echo "Installing server manager FormMagick module  ..."
  cp -f  root/etc/e-smith/web/functions/git /etc/e-smith/web/functions
  chown  -R root:admin /etc/e-smith/web/functions/git
  chmod  755           /etc/e-smith/web/functions/git
  chmod  u+s           /etc/e-smith/web/functions/git
  pushd .
  cd /etc/e-smith/web/panels/manager/cgi-bin
  ln -sf ../../../functions/git git
  popd
  REGENERATE_PANEL=1
fi

cmp -s root/etc/e-smith/locale/en-us/etc/e-smith/web/functions/git /etc/e-smith/locale/en-us/etc/e-smith/web/functions/git > /dev/null
if [ $? -ne 0 ]
then
  echo "Installing server manager FormMagick language module en-us ..."
  cp -f  root/etc/e-smith/locale/en-us/etc/e-smith/web/functions/git /etc/e-smith/locale/en-us/etc/e-smith/web/functions
  chown  -R root:admin /etc/e-smith/locale/en-us/etc/e-smith/web/functions/git
  chmod  644           /etc/e-smith/locale/en-us/etc/e-smith/web/functions/git
  REGENERATE_PANEL=1
fi

cmp -s root/usr/lib/perl5/site_perl/esmith/FormMagick/Panel/git.pm //usr/lib/perl5/site_perl/esmith/FormMagick/Panel/git.pm > /dev/null
if [ $? -ne 0 ]
then
  echo "Installing server manager FormMagick handler ..."
  cp -f  root/usr/lib/perl5/site_perl/esmith/FormMagick/Panel/git.pm /usr/lib/perl5/site_perl/esmith/FormMagick/Panel
  chown  -R root:admin /usr/lib/perl5/site_perl/esmith/FormMagick/Panel/git.pm
  chmod  644           /usr/lib/perl5/site_perl/esmith/FormMagick/Panel/git.pm
  REGENERATE_PANEL=1
fi

if [ $REGENERATE_PANEL ] 
then
  echo "Updating server-manager panel ..."
  /etc/e-smith/events/actions/navigation-conf
fi

echo "Linking events to action scripts ..."
echo "TBD"

if [ ! -d /usr/share/markdown ]
then
  echo "Installing Markdown.pl package ..."
  mkdir -p  /usr/share/markdown
  cp -rf    root/usr/share/markdown/* /usr/share/markdown
  chown  -R root:root /usr/share/markdown
  chown  -R root:root /usr/share/markdown/*
  chmod  444          /usr/share/markdown/*
fi

echo "Installing Gitweb resources ..."
rm -rf     /etc/e-smith/web/common/git*
cp     root/etc/e-smith/web/common/git-*.png /etc/e-smith/web/common
mkdir      /etc/e-smith/web/common/gitweb
cp     root/etc/e-smith/web/common/gitweb/git* /etc/e-smith/web/common/gitweb
chown  -R root:root /etc/e-smith/web/common/git*
chmod  444          /etc/e-smith/web/common/git-*.png
chmod  555          /etc/e-smith/web/common/gitweb/
chmod  444          /etc/e-smith/web/common/gitweb/*

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

if [ $HTTP_UPDATED ]
then  
  echo "Expanding HTTP template ..."
  expand-template     /etc/httpd/conf/httpd.conf

  echo "Validating httpd.cond syntax and restarting Apache ..."
  /usr/sbin/apachectl -t
  if [ $? -eq 0 ]
  then 
    /etc/init.d/httpd-e-smith restart
    less -N /etc/httpd/conf/httpd.conf
  fi
fi

echo "-----------------------------------------------------------------------------------------------------"
echo "smeserver-git contrib installed."
echo "Ensure you configure the domain correctly with:"
echo " "
echo "  config setprop git domain git.yourdomain.tld"
echo "  expand-template /etc/httpd/conf/httpd.conf"
echo "  expand-template /etc/gitweb.conf"
echo " "
echo "-----------------------------------------------------------------------------------------------------"

