# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::NetFTPServer::DirHandle;
use strict;
use base 'Net::FTPServer::DirHandle';
use Bivio::Biz::Model;
use Bivio::Ext::NetFTPServer::FileHandle;
use Bivio::Type::FilePath;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# Return a subdirectory handle or a file handle within this directory.

sub get {
    my($self, $filename) = @_;
    my($path) = Bivio::Type::FilePath->join($self->pathname, $filename);
    my($realm_file) = $self->{ftps}->get_realm_file($path);
    return undef unless $realm_file;
    return $realm_file->get('is_folder')
	? __PACKAGE__->new($self->{ftps}, $path)
	: Bivio::Ext::NetFTPServer::FileHandle->new($self->{ftps}, $path);
  }

# Get parent of current directory.

sub parent {
    my($self) = @_;
    my($path) = $self->dirname;
    return $path eq '/'
	? Bivio::Ext::NetFTPServer::RootHandle->new($self->{ftps}, $path)
	: __PACKAGE__->new($self->{ftps}, $path);
}

sub list {
    return shift->list_status(@_);
}

sub _list_status {
    return shift->list_status(@_);
}

sub list_status {
    my($self, $wildcard) = @_;
    my($folder) = $self->{ftps}->get_realm_file($self->pathname);
    return undef unless $folder;

    if ($wildcard) {
	$wildcard = $self->{ftps}->wildcard_to_regex($wildcard);
    }
    return Bivio::Biz::Model->new(
	$self->{ftps}->get_request, 'RealmFile')->map_iterate(sub {
	my($realm_file) = @_;
	my($name) = Bivio::Type::FilePath->get_tail(
	    $realm_file->get('path'));
    	return () if $wildcard && $name !~ /$wildcard/;
	my($path) = Bivio::Type::FilePath->join($self->pathname, $name);
	my($handle) = $realm_file->get('is_folder')
	    ? __PACKAGE__->new($self->{ftps}, $path)
	    : Bivio::Ext::NetFTPServer::FileHandle->new($self->{ftps},
		$path);
  	return [$name, $handle, [$handle->status]];
    }, 'is_folder DESC, path_lc', {
	folder_id => $folder->get('realm_file_id'),
    });
}

sub status {
    my($self) = @_;
    return $self->{ftps}->get_handle_status($self);
}

sub delete {
    return -1;
}

sub mkdir {
    return -1;
}

sub open {
    return undef;
}

1;
