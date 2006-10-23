# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::LocalFile;
use strict;
use base 'Bivio::UI::View';
use Bivio::UI::LocalFileType;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub SUFFIX {
    return '.bview';
}

sub absolute_path {
    return shift->get('view_file_name');
}

sub compile {
    my($self) = @_;
    return Bivio::IO::File->read($self->get('view_file_name'));
}

sub unsafe_new {
    my($proto, $name, $facade) = @_;
    my($file) = $facade->get_local_file_name(VIEW => $name) . $proto->SUFFIX;
    return -r $file && -f _ ? $proto->new({view_file_name => $file}) : undef;
}

1;
