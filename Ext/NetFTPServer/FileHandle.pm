# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::NetFTPServer::FileHandle;
use strict;
use base 'Net::FTPServer::FileHandle';
use IO::Scalar;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# Return the directory handle for this file.

sub dir {
    my($self) = @_;
    return Bivio::Ext::NetFTPServer::DirHandle->new($self->{ftps},
	$self->dirname);
}

# Open the file handle.

sub open {
    my($self, $mode) = @_;
    return undef unless $mode eq "r";
    my($realm_file) = $self->{ftps}->get_realm_file($self->pathname);
    return $realm_file
	? IO::Scalar->new($realm_file->get_content)
	: undef;
}

sub status {
    my($self) = @_;
    return $self->{ftps}->get_handle_status($self);
}

# Move a file to elsewhere.

sub move {
    return -1;
}

# Delete a file.

sub delete {
    return -1;
}

1;
