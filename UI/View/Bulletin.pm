# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Bulletin;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub form {
    my($self) = @_;
    return shift->internal_body(vs_simple_form(BulletinForm => [
	'BulletinForm.to',
    ]));
}

1;
