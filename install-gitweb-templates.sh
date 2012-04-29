#!/bin/bash

rm -rf /etc/e-smith/templates/etc/gitweb.conf/*
cp -r  root/etc/e-smith/templates/etc/gitweb.conf/* /etc/e-smith/templates/etc/gitweb.conf/
chown  -R root:root /etc/e-smith/templates/etc/gitweb.conf
expand-template /etc/gitweb.conf
less -N /etc/gitweb.conf