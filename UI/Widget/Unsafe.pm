# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Unsafe;
use strict;
use Bivio::Base 'Widget.Simple';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DIE) = __PACKAGE__->use('Bivio.Die');

sub render {
    my($self, $source, $buffer) = @_;
    $_DIE->catch_quietly(sub {
        $$buffer .= ${$self->render_attr(value => $source)};
	return;
    });
    return;
}

1;
