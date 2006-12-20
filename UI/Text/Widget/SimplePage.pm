# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Text::Widget::SimplePage;
use strict;
use base 'Bivio::UI::Widget::Simple';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type($req, 'text/csv');
}

1;
