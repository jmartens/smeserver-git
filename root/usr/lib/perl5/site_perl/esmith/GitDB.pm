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

package esmith::GitDB;

use strict;
use warnings;
use esmith::db;
use esmith::AccountsDB;

use vars qw( $AUTOLOAD @ISA );

use esmith::DB::db;
@ISA = qw(esmith::DB::db);

=head1 NAME

esmith::GitDB - interface to the Git respositories database

=head1 SYNOPSIS

  use esmith::GitDB;
  my $g = esmith::GitDB->open;

  my @repos = $g->repositories();

=head1 DESCRIPTION

This module provides an abstracted interface to the Git repositiries
database. The Git repositories are maintained in a separate database
so the Git repositories have their own name space and won't clash
with the accounts database entries such as ibays, pseudonyms and users.

=cut

our $VERSION = sprintf '%d.%03d', q$Revision: 1.0 $ =~ /: (\d+).(\d+)/;

=head2 open()

Loads an existing git database and returns an esmith::GitDB
object representing it.

=cut

sub open {
  my($class, $file) = @_;
  $file = $file || $ENV{ESMITH_GIT_DB} || "git";
  return $class->SUPER::open($file);
}

sub open_ro {
  my($class, $file) = @_;
  $file = $file || $ENV{ESMITH_GIT_DB} || "git";
  return $class->SUPER::open_ro($file);
}

sub AUTOLOAD {
  my $self = shift;
  my ($called_sub_name) = ($AUTOLOAD =~ m/([^:]*)$/);
  my @types = qw( repositories );
  if (grep /^$called_sub_name$/, @types) {
    $called_sub_name =~ s/s$//g;    # de-pluralize
    return $self->get_all_by_prop(type => qw( repository ));
  }
}

sub effective_users_list_from {
  my($class,$groups, $users) = @_;

  ### Generate effective list of users from the groups and individual users combined ### 
  my @effective_users_list;
  my $effective_users_list;

  ### Collect users listed for the named groups
  if ($groups) {
    my $accounts_db = esmith::AccountsDB->open;
    my @groups = split (/,/, $groups);
    foreach my $group (@groups) {
      my $record = $accounts_db->get($group);
      if ($record) {
        my $members = $record->prop('Members') || "";
        if (length($members) > 0) {
          push @effective_users_list, split (/,/, $members);
        }
      }
      undef $record;
    }
  }
    
  ### Combine individual users into the list generated so far
  if ($users) {
    push @effective_users_list, split (/,/, $users);
  }

  ### When there is more than one entry, sort it
  if (@effective_users_list > 1) {
    @effective_users_list = sort(@effective_users_list);
  }

  ### Ensure we only have unique entries
  my $prev = '';
  @effective_users_list = grep($_ ne $prev && (($prev) = $_), @effective_users_list);
  $effective_users_list = join(" ", @effective_users_list) || '';
  undef @effective_users_list;

  return $effective_users_list;
}
