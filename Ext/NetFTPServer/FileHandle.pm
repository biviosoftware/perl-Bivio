# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::NetFTPServer::FileHandle;
use strict;
use base 'Net::FTPServer::FileHandle';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

use Bivio::Type::DateTime;
use IO::Scalar;

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
    return IO::Scalar->new(Bivio::Biz::Model->new(
	$self->{ftps}->get_request, 'RealmFile')->load({
	path => $self->pathname,
    })->get_content);
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

