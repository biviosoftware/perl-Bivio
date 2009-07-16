# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::XMLDocument;
use strict;
use Bivio::Base 'Widget.Simple';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    my($b) = '<?xml version="';
    $self->render_attr('version', $source, \$b);
    $b .= '" encoding="';
    $self->render_attr('encoding', $source, \$b);
    $b .= '"?>'."\n";
    $self->SUPER::render($source, \$b);
    $$buffer .= $b;
    return;
}

1;
