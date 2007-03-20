# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::SimplePage;
use strict;
use Bivio::Base 'Bivio::UI::Widget::Simple';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type($req, 'text/html');
}

1;
