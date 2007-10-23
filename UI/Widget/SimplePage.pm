# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::SimplePage;
use strict;
use Bivio::Base 'Widget.Simple';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type(
	$req, ${$self->render_attr('content_type')});
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('content_type', 'text/html');
    return shift->SUPER::initialize(@_);
}

1;
