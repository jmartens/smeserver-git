#!/usr/bin/perl -w 
#----------------------------------------------------------------------
# vim: ft=perl ts=2 sw=2 et:
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
# $Id: git.pm 1 2012-03-23 11:25:58Z marco $
#----------------------------------------------------------------------

package esmith::FormMagick::Panel::git;

use strict;
use warnings;

use esmith::FormMagick;
use esmith::AccountsDB;
use esmith::ConfigDB;
use esmith::GitDB;

use esmith::cgi;
use esmith::util;
use File::Basename;
use Exporter;
use Carp;

use constant TRUE => 1;
use constant FALSE => 0;

our @ISA = qw(esmith::FormMagick Exporter);

our @EXPORT = qw(
  git_print_logo
  git_print_home_description
  git_repository_print_add_button
  git_repository_print_table
  
  git_repository_handle_create_or_modify
  git_repository_handle_remove

  git_repository_validate_name
  git_repository_validate_name_does_not_exist
  git_repository_validate_name_length
  
  git_repository_validate_description

  git_repository_print_name_field
  git_repository_print_privileges
  
  git_repository_group_list
  git_repository_user_list

  max_repository_name_length
  getExtraParams
  
  print_save_or_add_button
  validate_radio
  wherenext
);

our $config_db = esmith::ConfigDB->open
  or die "Can't open the Config database : $!\n" ;

our $account_db = esmith::AccountsDB->open
  or die "Can't open the Account database : $!\n" ;

our $git_db = esmith::GitDB->open
  or die "Can't open the Git database : $!\n" ;
  
# fields and records separator for sub records
use constant FS => "," ;
use constant RS => ";" ;

#----------------------------------------------------------------------

=pod

=head1 NAME

esmith::FormMagick::Panels::git - Git

=head1 SYNOPSIS

use esmith::FormMagick::Panels::git

my $panel = esmith::FormMagick::Panel::git->new();
$panel->display();

=head1 DESCRIPTION

This module is the backend to the git panel, responsible 
for supplying all functions used by that panel. It is a subclass 
of esmith::FormMagick itself, so it inherits the functionality 
of a FormMagick object.

=cut

#----------------------------------------------------------------------
# new()
# Exactly as for esmith::FormMagick

sub new
{
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = esmith::FormMagick::new($class);
  $self->{calling_package} = (caller)[0];

  return $self;
}

#######################################################################
### HTML GENERATION ROUTINES
#######################################################################

#----------------------------------------------------------------------
# git_print_logo()
# Print the Git logo image with a link reference to http://git-scm.com

sub git_print_logo {
  my $self = shift;
  my $q = $self->{cgi};
 
  print qq(<p><a href="http://git-scm.com" target="_blank"><img src="/server-common/git-logo.png" alt="GIT" style="float:right;margin:0 0 0 5px;" /></a></p>);
  return undef;    
}

#----------------------------------------------------------------------
# git_print_home_description()

sub git_print_home_description {
  my $self = shift;
  my $q = $self->{cgi};
 
  print qq(<tr>);
  print qq(<td><p>) . $self->localise('GIT_HOME_DESCRIPTION') . qq(</p></td>);
  print qq(<td><a href="http://git-scm.com" target="_blank"><img src="/server-common/git-logo.png" alt="GIT" style="float:right;margin:0 0 0 5px;" /></a></td>);
  print qq(</tr>);
  return undef;    
}

#----------------------------------------------------------------------
# git_repository_print_add_button()
# Prints a button to get to the add a new repository screen

sub git_repository_print_add_button {
  my $self = shift;
  my $q = $self->{cgi};
    
  print qq(<tr><td colspan="2"><a class="button-like" href="git?page=0&page_stack=&Next=Next&wherenext=GitCreateModify">) . $self->localise('GIT_REPOSITORY_ADD_BUTTON') . qq(</a></td></tr>);
  return "";
}

#----------------------------------------------------------------------
# git_repository_print_list()
# This function displays a table of repositories on the system 
# including the links to modify and remove the repository

sub git_repository_print_table {
  my $self                     = shift;
  my $q                        = $self->{cgi};
  my $name                     = $self->localise('NAME');
  my $description              = $self->localise('DESCRIPTION');
  my $access                   = $self->localise('ACCESS');
  
  my $modify                   = $self->localise('MODIFY');
  my $remove                   = $self->localise('REMOVE');
  my $action_h                 = $self->localise('ACTION');
  
  my @repositories = $git_db->get_all_by_prop('type' => 'repository');

  unless ( scalar @repositories )
  {
    print qq(<tr><td colspan="2"><p>) . $self->localise('GIT_NOTIFY_NO_REPOSITORIES') . qq(</a></td></tr>);
    return "";
  }
  
  print qq(<tr><td colspan="2"><p>) . $self->localise('GIT_REPOSITORY_LIST_DESCRIPTION') . qq(</a></td></tr>);

  print qq(<tr><td colspan="2">);
  print $q->start_table({-CLASS => "sme-border"}),"\n";
  print $q->Tr (
                esmith::cgi::genSmallCell($q, $name,"header"),
                esmith::cgi::genSmallCell($q, $description,"header"),
                esmith::cgi::genSmallCell($q, $access,"header"),
                esmith::cgi::genSmallCell($q, $action_h,"header", 3)), "\n";
  
  my $scriptname = basename($0);

  foreach my $repository (@repositories)
  {
    my $repo_name                    = $repository->key();
    my $repo_description             = $repository->prop('Description');
    my $repo_access_type             = $repository->prop('AccessType');

    my $params = $self->build_repository_cgi_params($repo_name, $repository->props());
    my $href = "$scriptname?$params&action=modify&wherenext=";
    my $actionModify = '&nbsp;' . $q->a({href => "${href}GitCreateModify"},$modify) . '&nbsp;';
    my $actionRemove = '&nbsp;' . $q->a({href => "${href}GitRemove"}, $remove) . '&nbsp';

    print $q->Tr (
        esmith::cgi::genSmallCell($q, $repo_name . ".git", "normal"),
        esmith::cgi::genSmallCell($q, $repo_description, "normal"),
        esmith::cgi::genSmallCell($q, $repo_access_type, "normal"),

        esmith::cgi::genSmallCell($q, $actionModify,"normal"),
        esmith::cgi::genSmallCell($q, $actionRemove,"normal"));
  }

  print $q->end_table,"\n";
  print qq(</td></tr>);
  return "";
}

#----------------------------------------------------------------------
# print_privileges()
sub print_privileges {
  my $self = shift;
  my $q = $self->{cgi};
  print qq(<tr><td colspan="2">) . $self->localise('GIT_PRIVILEGES_NOTE') . qq(</td></tr>);
  return "";
}

#----------------------------------------------------------------------
# git_repository_print_save_or_add_button()
# Prints the ADD button when a new repository is addded and the SAVE buttom 
# whem modifications are made.

sub git_repository_print_save_or_add_button {
  my ($self) = @_;
  if ($self->cgi->param("action") eq "modify") {
    $self->print_button("SAVE");
  } else {
    $self->print_button("ADD");
  }
}

#######################################################################
# HELPER FUNCTIONS FOR THE PANEL
#######################################################################
#
# Routines for modifying the database and signaling events 
# from the server-manager panel

=head2 build_repository_cgi_params($self, $repositoryName, %oldprops)

Constructs the parameters for the links in the repository table

=cut

sub build_repository_cgi_params {
  my ($self, $repositoryName, %oldprops) = @_;

  #$oldprops{'description'} = $oldprops{Name};
  #delete $oldprops{Name};

  my %props = (
    page    => 0,
    page_stack => "",
    #".id"         => $self->{cgi}->param('.id') || "",
    name => $repositoryName,
    #%oldprops
  );

  return $self->props_to_query_string(\%props);
}

#----------------------------------------------------------------------

*wherenext = \&CGI::FormMagick::wherenext;

sub git_repository_print_name_field {
  my $self = shift;
  my $in = $self->{cgi}->param('name') || '';
  my $action = $self->{cgi}->param('action') || '';
  my $recMaxLength = $config_db->get('maxRepositoryNameLength');
  my $maxLength = $recMaxLength->value;
  
  print qq(<tr><td colspan="2">) . $self->localise('GIT_NAME_FIELD_DESC', {maxLength => $maxLength}) . qq(</td></tr>);
      
  print qq(<tr><td class="sme-noborders-label">) .
      $self->localise('NAME') . qq(</td>\n);
      
  if ($action eq 'modify' and $in) {
    my $repository = $git_db->get($in);
    print qq(
          <td class="sme-noborders-content">
            <input type="text" name="name" value="$in.git" disabled>
            <input type="hidden" name="action" value="modify">
          </td>
      );

    # Read the values for each field from the git db and store
    # them in the cgi object so our form will have the correct
    # info displayed.
    my $q = $self->{cgi};
    if ($repository)
    {
      $q->param(-name=>'description',             -value=>$repository->prop('Description'));
      $q->param(-name=>'access_type',             -value=>$repository->prop('AccessType'));
      $q->param(-name=>'groupsPull',              -value=>join(FS, split(FS, $repository->prop('GroupsPull'))));
      $q->param(-name=>'usersPull',               -value=>join(FS, split(FS, $repository->prop('UsersPull'))));
      $q->param(-name=>'groupsPush',              -value=>join(FS, split(FS, $repository->prop('GroupsPush'))));
      $q->param(-name=>'usersPush',               -value=>join(FS, split(FS, $repository->prop('UsersPush'))));
    }
  } else {
    print qq(
          <td>
            <input type="text" name="name" value="$in">
            <input type="hidden" name="action" value="create">
          </td>
      );
  }
  print qq(</tr>\n);
  return undef;
}

#----------------------------------------------------------------------
# git_repository_group_list()
# Returns a hash of groups for the Create/Modify screen's group 
# field's drop down list.

sub git_repository_group_list
{
  my @groups = $account_db->groups();
  my %groups = ();
  foreach my $g (@groups) {
    $groups{$g->key()} = $g->prop('Description')." (".$g->key.")";
  }
  return \%groups;
}

#----------------------------------------------------------------------
# git_repository_user_list()
# Returns a hash of users for the Create/Modify screen's user field's
# drop down list.

sub git_repository_user_list
{
  my @users = $account_db->users();
  my %users = ();
  foreach my $u (@users) {
    $users{$u->key()} = $u->prop('LastName').", ". $u->prop('FirstName')." (". $u->key.")";
  }
  return \%users;
}

#######################################################################
# THE ROUTINES THAT ACTUALLY DO THE WORK
#######################################################################

#----------------------------------------------------------------------
# git_repository_handle_add_or_modify()
# Determine whether to modify or add the git repository

sub git_repository_handle_create_or_modify {
  my ($self) = @_;

  if ($self->cgi->param("action") eq "create") {
    $self->git_repository_handle_create();
  } else {
    $self->git_respository_handle_modify();
  }
}

#----------------------------------------------------------------------
# git_repository_handle_create()
# Handle the create event for the git repository

sub git_repository_handle_create {
  my ($self) = @_;
  my $repositoryName = $self->cgi->param('name');
  my $msg;

  $msg = $self->git_repository_validate_name($repositoryName);
  unless ($msg eq "OK")
  {
    return $self->error($msg);
  }

  $msg = $self->git_repository_validate_name_length($repositoryName);
  unless ($msg eq "OK")
  {
    return $self->error($msg);
  }

  $msg = $self->git_repository_validate_name_does_not_exist($repositoryName);
  unless ($msg eq "OK")
  {
    return $self->error($msg);
  }

  $msg = $self->validate_radio($self->cgi->param('access_type'));
  unless ($msg eq "OK")
  {
    return $self->error($msg);
  }

  my $groups_allowed_to_pull = "";
  my @groupsPull = $self->cgi->param('groupsPull');
  foreach my $grp_pull (@groupsPull) {
    if ($groups_allowed_to_pull) {
      $groups_allowed_to_pull .= "," . $grp_pull;
    } else {
      $groups_allowed_to_pull = $grp_pull;
    }
  }

  my $users_allowed_to_pull = "";
  my @usersPull = $self->cgi->param('usersPull');
  foreach my $usr_pull (@usersPull) {
    if ($users_allowed_to_pull) {
      $users_allowed_to_pull .= "," . $usr_pull;
    } else {
      $users_allowed_to_pull = $usr_pull;
    }
  }

  my $groups_allowed_to_push = "";
  my @groupsPush = $self->cgi->param('groupsPush');
  foreach my $grp_push (@groupsPush) {
    if ($groups_allowed_to_push) {
      $groups_allowed_to_push .= "," . $grp_push;
    } else {
      $groups_allowed_to_push = $grp_push;
    }
  }

  my $users_allowed_to_push = "";
  my @usersPush = $self->cgi->param('usersPush');
  foreach my $usr_push (@usersPush) {
    if ($users_allowed_to_push) {
      $users_allowed_to_push .= "," . $usr_push;
    } else {
      $users_allowed_to_push = $usr_push;
    }
  }
  
  # The new_record below will fail if the named repository already exists
  # which can be the case when the previous one was deleted but not properly
  # cleaned up.
  
  if (my $repository = $git_db->new_record($repositoryName, 
       {
          Description => $self->cgi->param('description'),
          GroupsPull  => "$groups_allowed_to_pull",
          UsersPull   => "$users_allowed_to_pull",
          GroupsPush  => "$groups_allowed_to_push",
          UsersPush   => "$users_allowed_to_push",
          AccessType  => $self->cgi->param('access_type'),
          type        => 'repository',
        } ) )
  {
    # Untaint $name before use in system()
    $repositoryName =~ /(.+)/; 
    $repositoryName = $1;
    if (system ("/sbin/e-smith/signal-event", "git-repository-create", $repositoryName) == 0) {
      $self->success("GIT_SUCCESS_CREATED_REPOSITORY");
    } else {
      $self->error("GIT_ERROR_CREATING_REPOSITORY");
    }
  } else {
    $self->error('GIT_ERROR_CANT_CREATE_REPOSITORY');
  }
}

#----------------------------------------------------------------------
# git_respository_handle_modify()
# Handle the modify event for the repository

sub git_respository_handle_modify {
  my ($self) = @_;
  my $repositoryName = $self->cgi->param('name');
  my $msg;

  $msg = $self->git_repository_validate_name($repositoryName);
  unless ($msg eq "OK")
  {
    return $self->error($msg);
  }

  $msg = $self->validate_radio($self->cgi->param('access_type'));
  unless ($msg eq "OK")
  {
    return $self->error($msg);
  }

  my $groups_allowed_to_pull = "";
  my @groupsPull = $self->cgi->param('groupsPull');
  foreach my $grp_pull (@groupsPull) {
    if ($groups_allowed_to_pull) {
      $groups_allowed_to_pull .= "," . $grp_pull;
    } else {
      $groups_allowed_to_pull = $grp_pull;
    }
  }

  my $users_allowed_to_pull = "";
  my @usersPull = $self->cgi->param('usersPull');
  foreach my $usr_pull (@usersPull) {
    if ($users_allowed_to_pull) {
      $users_allowed_to_pull .= "," . $usr_pull;
    } else {
      $users_allowed_to_pull = $usr_pull;
    }
  }

  my $groups_allowed_to_push = "";
  my @groupsPush = $self->cgi->param('groupsPush');
  foreach my $grp_push (@groupsPush) {
    if ($groups_allowed_to_push) {
      $groups_allowed_to_push .= "," . $grp_push;
    } else {
      $groups_allowed_to_push = $grp_push;
    }
  }

  my $users_allowed_to_push = "";
  my @usersPush = $self->cgi->param('usersPush');
  foreach my $usr_push (@usersPush) {
    if ($users_allowed_to_push) {
      $users_allowed_to_push .= "," . $usr_push;
    } else {
      $users_allowed_to_push = $usr_push;
    }
  }

  if (my $repository = $git_db->get($repositoryName)) {
    if ($repository->prop('type') eq 'repository') {
      $repository->merge_props( Description => $self->cgi->param('description'),
                                GroupsPull  => "$groups_allowed_to_pull",
                                UsersPull   => "$users_allowed_to_pull",
                                GroupsPush  => "$groups_allowed_to_push",
                                UsersPush   => "$users_allowed_to_push",
                                AccessType  => $self->cgi->param('access_type'),
                                type        => 'repository',
                                );

      # Untaint $name before use in system()
      $repositoryName =~ /(.+)/; 
      $repositoryName = $1;
      if (system ("/sbin/e-smith/signal-event", "git-repository-modify", $repositoryName) == 0) {
        $self->success("GIT_SUCCESS_MODIFIED_REPOSITORY");
      } else {
        $self->error("GIT_ERROR_MODIFYING_REPOSITORY");
      }
    } else {
      $self->error('GIT_ERROR_CANT_FIND_REPOSITORY');
    }
  } else {
    $self->error('GIT_ERROR_CANT_FIND_REPOSITORY');
  }
}

#----------------------------------------------------------------------
# git_repository_remove()
# Handle the remove event for the repository

sub git_repository_handle_remove {
  my ($self) = @_;
  my $repositoryName = $self->cgi->param('name');
  if (my $repository = $git_db->get($repositoryName)) {
    if ($repository->prop('type') eq 'repository') {
      $repository->set_prop('type', 'repository-deleted');

      # Untaint $repository_name before use in system() ????
      $repositoryName =~ /(.+)/; 
      $repositoryName = $1;
      if (system ("/sbin/e-smith/signal-event", "git-repository-delete", $repositoryName) == 0) {
        $self->success("GIT_SUCCESS_DELETED_REPOSITORY");
        $repository->delete();
      } else {
        $self->error("GIT_ERROR_DELETING_REPOSITORY");
      }
    } else {
      $self->error('GIT_ERROR_CANT_FIND_REPOSITORY');
    }
  } else {
      $self->error('GIT_ERROR_CANT_FIND_REPOSITORY');
  }
  $self->wherenext('First');
}

#######################################################################
# VALIDATION ROUTINES
#######################################################################


#----------------------------------------------------------------------

=head2 getExtraParams()

Sets variables used in the lexicon to their required values.

=cut

sub getExtraParams
{
  my $self = shift;
  my $q = $self->{cgi};
  my $repositoryName        = $q->param('name');
  my $repositoryDescription = '';

  if ($repositoryName)
  {
    my $repository = $git_db->get($repositoryName);
    if ($repository)
    {
      $repositoryDescription = $repository->prop('Description');
    }
  }
  return (name => $repositoryName, description => $repositoryDescription);
}

#----------------------------------------------------------------------
# git_repository_validate_name()
#
# Checks that the name supplied does not contain any unacceptable chars.
# Returns OK on success or a localised error message otherwise.

sub git_repository_validate_name {
  my ($self, $repositoryName) = @_;
  unless ($repositoryName =~ /^([a-z][\_\-a-z0-9]*)$/)
  {
    return $self->localise('GIT_ERROR_NAME_HAS_INVALID_CHARS',
                           {repositoryName => $repositoryName});
  }
  return "OK";
}

#----------------------------------------------------------------------
# git_repository_validate_name_does_not_exist()
# Check the proposed repository name for clashes with existing respositories.

sub git_repository_validate_name_does_not_exist
{
  my ($self, $repositoryName) = @_;
  my $repository = $git_db->get($repositoryName);

  if (defined $repository)
  {
    my $type = $repository->prop('type');
    if ($type eq "repository")
    {
      return $self->localise('GIT_ERROR_ALREADY_EXISTS', {repositoryName => $repositoryName});
    }
  }
  # Repository does not exist yet.
  return 'OK';
}

#----------------------------------------------------------------------
# git_repository_validate_name_length()
#
# Checks the length of a given repository name against the maximum set in the
# maxAcctNameLength record of the configuration database.  Defaults to a
# maximum length of $self->{defaultMaxLength} if nothing is set in the 
# config db.
sub git_repository_validate_name_length {
  my ($self, $data) = @_;
  $config_db->reload();
  my $max;
  if (my $max_record = $config_db->get('maxRepositoryNameLength')) {
    $max = $max_record->value();
  }

  if (length($data) <= $max) {
    return "OK";
  } else {
    return $self->localise("GIT_ERRROR_NAME_TOO_LONG",
                            {repositoryName => $data,
                             maxRepositoryNameLength => $max });
  }
}

#----------------------------------------------------------------------
# git_repository_validate_description()
#
# Checks that the description supplied does not contain any unacceptable chars.
# Returns OK on success or a localised error message otherwise.
sub git_repository_validate_description {
  my ($self, $repositoryDescription) = @_;
  unless ($repositoryDescription =~ /^([\w\s\_\.\-]*)$/) {
    return $self->localise('GIT_ERROR_DESCRIPTION_HAS_INVALID_CHARS',
                           {repositoryDescription => $repositoryDescription});
  }
  return "OK";
}

#----------------------------------------------------------------------
# validate_radio()
# Checks wether a value is checked for a radio button

sub validate_radio {
  my ($self, $acctName) = @_;
  unless($acctName ne '') {
    return $self->localise('GIT_ERROR_RADIO_VALUE_NOT_CHECKED', acctName => $acctName);
  }
  return "OK";
}

#----------------------------------------------------------------------

1;
