# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::NetFTPServer::DirHandle;
use strict;
use base 'Net::FTPServer::DirHandle';
use Bivio::Biz::Model::RealmFileList;
use Bivio::Ext::NetFTPServer::FileHandle;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# Return a subdirectory handle or a file handle within this directory.

sub get {
    my($self, $filename) = @_;
    my($path) = Bivio::Type::FilePath->join($self->pathname, $filename);
    my($realm_file) = Bivio::Biz::Model->new(
	$self->{ftps}->get_request, 'RealmFile');
    return undef
	unless $realm_file->unsafe_load({
	    path => $path,
	});
    return $realm_file->get('is_folder')
	? __PACKAGE__->new($self->{ftps}, $path)
	: Bivio::Ext::NetFTPServer::FileHandle->new($self->{ftps}, $path);
  }

# Get parent of current directory.

sub parent {
    my($self) = @_;
    return $self if $self->is_root;
    return __PACKAGE__->new($self->{ftps}, $self->dirname);
}

sub list {
    return shift->list_status(@_);
}

sub _list_status {
    return shift->list_status(@_);
}

sub list_status {
    my($self, $wildcard) = @_;

    if ($wildcard) {
	$wildcard = $self->{ftps}->wildcard_to_regex($wildcard);
    }
    return Bivio::Biz::Model->new(
	$self->{ftps}->get_request, 'RealmFileList')->map_iterate(sub {
	my($list) = @_;
	my($name) = Bivio::Type::FilePath->get_tail(
	    $list->get('RealmFile.path'));
    	return () if $wildcard && $name !~ /$wildcard/;
	my($handle) = $list->get('RealmFile.is_folder')
	    ? __PACKAGE__->new($self->{ftps}, $list->get('RealmFile.path'))
	    : Bivio::Ext::NetFTPServer::FileHandle->new($self->{ftps},
		$list->get('RealmFile.path'));
  	return [$name, $handle, [$handle->status]];
    }, {
	path_info => $self->pathname,
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
