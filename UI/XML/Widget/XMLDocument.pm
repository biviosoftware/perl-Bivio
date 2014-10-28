# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::XMLDocument;
use strict;
use Bivio::Base 'Widget.Simple';


sub NEW_ARGS {
    return [qw(value ?version ?encoding)];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
        version => '1.0',
	encoding => 'utf-8',
    );
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= join(
	'',
	'<?xml version="',
	$self->render_simple_attr('version', $source),
	'" encoding="',
	$self->render_simple_attr('encoding', $source),
	qq{"?>\n},
    );
    return shift->SUPER::render(@_);
}

1;
