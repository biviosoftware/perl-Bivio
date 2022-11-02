# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::LocalFile;
use strict;
use Bivio::Base 'UI.View';


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
    return -r $file && -f _
        ? $proto->new({
            view_file_name => $file,
            view_name => _clean_name($proto, $name),
        }) : undef;
}

sub _clean_name {
    my($proto, $n) = @_;
    $n =~ s!^/|/$!!g;
    $n =~ s!/+!/!g;
    $n =~ s/\Q@{[$proto->SUFFIX]}\E$//og;
    return $n;
}

1;
