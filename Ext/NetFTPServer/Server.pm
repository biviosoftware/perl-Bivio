# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::NetFTPServer::Server;
use strict;
use base 'Net::FTPServer';
use Bivio::Agent::Request;
use Bivio::Ext::NetFTPServer::DirHandle;
use Bivio::IO::Config;
use Bivio::Type::DateTime;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_CFG);
Bivio::IO::Config->register({
    user_group => 'anonymous',
    realm => 'demo',
});

# Perform login against the database.

sub authentication_hook {
    my($self) = @_;
    # all access allowed
    $self->{user_is_anonymous} = 1;
    $self->{user} = $_CFG->{user_group};
    return 0;
}

# Returns (mode, perms, nlink, user, group, size, time)
# for a directory or file handle.

sub get_handle_status {
    my($self, $handle) = @_;
    my($realm_file) = Bivio::Biz::Model->new(
	$self->get_request, 'RealmFile')->load({
	    path => $handle->pathname,
	});
    my(@status);
    @status[0, 1, 5] = $realm_file->get('is_folder')
	? ('d', 0555, 1024)
	: ('f', 0444, $realm_file->get_content_length);
    my($username) = substr($self->{user}, 0, 8);
    @status[2, 3, 4, 6] = (1, $username, $username,
	Bivio::Type::DateTime->to_unix($realm_file->get('modified_date_time'))
    );
    return @status;
}

sub get_request {
    my($self) = @_;
    return $self->{request} || Bivio::Die->die('missing request');
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

# This is called before configuration.

sub pre_configuration_hook {
    my($self) = @_;
    # disable all site commands
    $self->{site_command_table} = {};
    $self->{version_string} = '1';
    return;
}

# This is called just after accepting a new connection. We connect
# to the database here.

sub post_accept_hook {
    my($self) = @_;
    _clear_request($self);
    $self->{request} = Bivio::Agent::Request->get_current_or_new;
    $self->{request}->set_realm($_CFG->{realm});
    return;
}

# This is called after executing every command.

sub post_command_hook {
}

# Called on normal exits (not crashes)

sub quit_hook {
    my($self) = @_;
    _clear_request($self);
    return;
}

# Return an instance of Net::FTPServer::DirHandle
# corresponding to the root directory.

sub root_directory_hook {
    my($self) = @_;
    return Bivio::Ext::NetFTPServer::DirHandle->new($self);
}

# Called just after user C<$user> has successfully logged in.

sub user_login_hook {
}

sub _clear_request {
    my($self) = @_;
    return unless $self->{request};
    $self->{request}->clear_current;
    delete($self->{request});
    return;
}

1;
