#!/bin/bash
#----------------------------------------------------------------------
# vim: ft=bash ts=2 sw=2 et:
#----------------------------------------------------------------------
#
# Copyright (C) 2012 - Marco Hess <marco.hess@through-ip.com>
#
# This file is part of the "Git Repositories" panel in the
# SME Server server-manager panel to configure git repositories.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#----------------------------------------------------------------------

# Main GIT repository directory
mkdir -p /home/e-smith/files/git

# Separate empty database for GIT
touch /home/e-smith/db/git

# Separate database for GIT repositories
#mkdir -p /etc/e-smith/db/git
#mkdir -p /etc/e-smith/db/git/defaults
#mkdir -p /etc/e-smith/db/git/force
#mkdir -p /etc/e-smith/db/git/migrate

# WebGit Configuration Files
mkdir -p                                                                             /etc/e-smith/templates/etc/gitweb.conf
/bin/cp -f etc/e-smith/templates/etc/gitweb.conf/*                                   /etc/e-smith/templates/etc/gitweb.conf

# HTTP Configuration Files
/bin/cp -f etc/e-smith/templates/etc/httpd/conf/httpd.conf/VirtualHosts/28GitContent /etc/e-smith/templates/etc/httpd/conf/httpd.conf/VirtualHosts

# Web Interface Functions & Locale
/bin/cp -f etc/e-smith/web/functions/git                                             /etc/e-smith/web/functions
/bin/cp -f etc/e-smith/locale/en-us/etc/e-smith/web/functions/git                    /etc/e-smith/locale/en-us/etc/e-smith/web/functions

# FormMagick Panel
/bin/cp -f usr/lib/perl5/site_perl/esmith/FormMagick/Panel/git.pm                    /usr/lib/perl5/site_perl/esmith/FormMagick/Panel

# GitDB wrapper around DB
/bin/cp -f usr/lib/perl5/site_perl/esmith/GitDB.pm                                   /usr/lib/perl5/site_perl/esmith

# Images
/bin/cp -f etc/e-smith/web/common/*                                                  /etc/e-smith/web/common

cd /etc/e-smith/web/panels/manager/cgi-bin
ln -s ../../../functions/git git

##############################################################################################

### Install Event Actions ###

mkdir -p /etc/e-smith/events/actions
cp       etc/e-smith/events/actions/*                                        /etc/e-smith/events/actions

##############################################################################################

### GIT Modify ###

mkdir -p /etc/e-smith/events/git-modify

mkdir -p /etc/e-smith/events/git-modify/services2adjust
cd       /etc/e-smith/events/git-modify/services2adjust
ln -s    sigusr1                                                            httpd-e-smith

mkdir -p /etc/e-smith/events/git-modify/templates2expand/etc/httpd/conf/
touch    /etc/e-smith/events/git-modify/templates2expand/etc/httpd/conf/httpd.conf

##############################################################################################

### GIT Delete ###

mkdir -p /etc/e-smith/events/git-delete
cd       /etc/e-smith/events/git-delete
ln -s    ../actions/git-delete                                              S05git-delete

mkdir -p /etc/e-smith/events/git-delete/services2adjust
cd       /etc/e-smith/events/git-delete/services2adjust
ln -s    sigusr1                                                            httpd-e-smith

mkdir -p /etc/e-smith/events/git-delete/templates2expand/etc/httpd/conf/
touch    /etc/e-smith/events/git-delete/templates2expand/etc/httpd/conf/httpd.conf

##############################################################################################

### Git Repository Create ###

mkdir -p /etc/e-smith/events/git-repository-create
cd       /etc/e-smith/events/git-repository-create
ln -s    ../actions/git-repository-create-modify                            S05git-repository-create-modify

mkdir -p /etc/e-smith/events/git-repository-create/services2adjust
cd       /etc/e-smith/events/git-repository-create/services2adjust
ln -s    sigusr1                                                            httpd-e-smith

mkdir -p /etc/e-smith/events/git-repository-create/templates2expand
mkdir -p /etc/e-smith/events/git-repository-create/templates2expand/etc/httpd/conf/
touch    /etc/e-smith/events/git-repository-create/templates2expand/etc/httpd/conf/httpd.conf

##############################################################################################

### Git Repository Modify ###

mkdir -p /etc/e-smith/events/git-repository-modify
cd       /etc/e-smith/events/git-repository-modify
ln -s    ../actions/git-repository-create-modify                            S05git-repository-create-modify

mkdir -p /etc/e-smith/events/git-repository-modify/services2adjust
cd       /etc/e-smith/events/git-repository-modify/services2adjust
ln -s    sigusr1                                                            httpd-e-smith

mkdir -p /etc/e-smith/events/git-repository-modify/templates2expand
mkdir -p /etc/e-smith/events/git-repository-modify/templates2expand/etc/httpd/conf/
touch    /etc/e-smith/events/git-repository-modify/templates2expand/etc/httpd/conf/httpd.conf

##############################################################################################

### Git Repository Delete ###

mkdir -p /etc/e-smith/events/git-repository-delete
cd       /etc/e-smith/events/git-repository-delete
ln -s    ../actions/git-repository-delete                                   S05git-repository-delete

mkdir -p /etc/e-smith/events/git-repository-delete/services2adjust
cd       /etc/e-smith/events/git-repository-delete/services2adjust
ln -s    sigusr1                                                            httpd-e-smith

mkdir -p /etc/e-smith/events/git-repository-delete/templates2expand
mkdir -p /etc/e-smith/events/git-repository-delete/templates2expand/etc/httpd/conf/
touch    /etc/e-smith/events/git-repository-delete/templates2expand/etc/httpd/conf/httpd.conf

##############################################################################################

### User Delete ###

cd       /etc/e-smith/events/user-delete
ln -s    ../actions/git-delete-user-or-group-from-access-list              S05git-delete-user-or-group-from-access-list

##############################################################################################

### Group Delete ###

cd       /etc/e-smith/events/group-delete
ln -s    ../actions/git-delete-user-or-group-from-access-list              S05git-delete-user-or-group-from-access-list

##############################################################################################

### Group Modify ###

# Can have users added or removed from group. Will be covered with the expand-template of /etc/http/conf/httpd.conf

##############################################################################################

### Update server-manager UI ###

/etc/e-smith/events/actions/navigation-conf

##############################################################################################

### Expand Configuration Files ###

expand-template /etc/gitweb.conf
expand-template /etc/httpd/conf/httpd.conf
