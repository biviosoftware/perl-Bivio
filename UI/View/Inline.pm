# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Inline;
use strict;
use base 'Bivio::UI::View';
use Bivio::UI::LocalFileType;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub absolute_path {
    return shift->get('view_code') . '';
}

sub compile {
    my($self) = @_;
    my($c) = $self->get('view_code');
    return ref($c) eq 'CODE' ? $c->() : $c;
}

sub unsafe_new {
    my($proto, $name, $facade) = @_;
    return ref($name) eq 'SCALAR' ? $proto->new({
	view_code => $name,
	view_name => substr($$name, 0, 100),
    }) : ref($name) eq 'CODE' ? $proto->new({
	view_code => $name,
	view_name => $name . '',
    }) : undef;
}

1;
