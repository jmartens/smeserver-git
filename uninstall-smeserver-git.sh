#!/bin/bash

echo "Disabling git config entries ..."
config setprop git status disabled
  
echo "Removing GitDB handler ..."
rm -f /usr/lib/perl5/site_perl/esmith/GitDB.pm 

echo "Removing server manager action scripts ..."
rm -f /etc/e-smith/events/actions/git* 

echo "Removing server manager FormMagick handler ..."
rm -f /etc/e-smith/web/functions/git 
rm -f /etc/e-smith/web/panels/manager/cgi-bin/git
rm -f /etc/e-smith/locale/en-us/etc/e-smith/web/functions/git 
rm -f /usr/lib/perl5/site_perl/esmith/FormMagick/Panel/git.pm 
rm -f /etc/e-smith/web/panels/manager/cgi-bin/git

echo "Updating server-manager panel ..."
/etc/e-smith/events/actions/navigation-conf

echo "Removing linked events to action scripts ..."
echo "TBD"

echo "Removing Markdown.pl package ..."
rm -rf /usr/share/markdown

echo "Removing gitweb resources ..."
rm -f   /etc/e-smith/web/common/git*

echo "Removing gitweb.conf template fragments ..."
rm -rf /etc/e-smith/templates/etc/gitweb.conf

echo "Removing gitweb home text template fragments ..."
rm -rf  /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
rm -f  /etc/e-smith/web/common/gitweb_home_text.html

echo "Removing HTTP template ..."
rm -f  /etc/e-smith/templates/etc/httpd/conf/httpd.conf/80SubDomainGit
expand-template /etc/httpd/conf/httpd.conf
/etc/init.d/httpd-e-smith restart

echo "-----------------------------------------------------------------------------------------------------"
echo "smeserver-git contrib has been removed, but the databases and git repositories have been left intact."
echo "To completely remove everything, use the following commands:"
echo " "
echo "  config delete git"
echo "  rm -f  /home/e-smith/db/git"
echo "  rm -rf /home/e-smith/files/git"
echo " "
echo "-----------------------------------------------------------------------------------------------------"
