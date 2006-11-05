# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::NetFTPServer::Server;
use strict;
use base 'Net::FTPServer';
use Bivio::Agent::Request;
use Bivio::Biz::Model;
use Bivio::Ext::NetFTPServer::RootHandle;
use Bivio::IO::Config;
use Bivio::Type::DateTime;
use Bivio::Type::DocletFileName;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_CFG);
Bivio::IO::Config->register({
    ftp_user => 'anonymous',
});

sub authentication_hook {
    my($self) = @_;
    # all access allowed
    $self->{user_is_anonymous} = 1;
    $self->{user} = $_CFG->{ftp_user};
    return 0;
}

# Returns (mode, perms, nlink, user, group, size, time)
# for a directory or file handle.

sub get_handle_status {
    my($self, $handle) = @_;
    my($realm_file) = $self->get_realm_file($handle->pathname);
    return () unless $realm_file;
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

# Sets the realm to the forum and return the appropriate RealmFile

sub get_realm_file {
    my($self, $path) = @_;
    my($forum_name, $file_path) = $path =~ m,^/([^/]+)(.*),;
    return undef unless $forum_name;
    my($realm) = Bivio::Biz::Model->new($self->get_request, 'RealmOwner');
    return undef unless $realm->unauth_load({
	name => $forum_name,
    });
    $self->get_request->set_realm($realm);
    my($realm_file) = $realm->new_other('RealmFile');
    return $realm_file->unsafe_load({
	path => Bivio::Type::DocletFileName->PUBLIC_FOLDER_ROOT
            . (defined($file_path) ? $file_path : ''),
    }) ? $realm_file : undef;
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

# This is called just after accepting a new connection.

sub post_accept_hook {
    my($self) = @_;
    _clear_request($self);
    $self->{request} = Bivio::Agent::Request->get_current_or_new;
    $self->{request}->set_realm(undef);
    return;
}

sub post_configuration_hook {
    my($self) = @_;
    $self->{site_command_table} = {};
    $self->{version_string} = '1';
    return;
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
    return Bivio::Ext::NetFTPServer::RootHandle->new($self);
}

sub _clear_request {
    my($self) = @_;
    return unless $self->{request};
    $self->{request}->clear_current;
    delete($self->{request});
    return;
}

1;
