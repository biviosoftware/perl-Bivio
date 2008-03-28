# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::UserState;
use strict;
use Bivio::Base 'XHTMLWidget.XLink';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	facade_label => [sub {'user_' . shift->req('user_state')->get_name}],
    );
    return shift->SUPER::initialize(@_);
}

1;
