#!/bin/bash

rm -rf   /etc/e-smith/templates/etc/gitweb.conf
mkdir -p /etc/e-smith/templates/etc/gitweb.conf
cp -r    root/etc/e-smith/templates/etc/gitweb.conf/* /etc/e-smith/templates/etc/gitweb.conf/
chown -R root:root /etc/e-smith/templates/etc/gitweb.conf

rm -rf   /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
mkdir -p /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
cp -r    root/etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html/* /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html
chown -R root:root /etc/e-smith/templates/etc/e-smith/web/common/gitweb_home_text.html

expand-template /etc/e-smith/web/common/gitweb_home_text.html
expand-template /etc/gitweb.conf

less -N /etc/gitweb.conf