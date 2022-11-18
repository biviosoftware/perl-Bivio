# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::FormFieldLabel;
#package Bivio::UI::Bootstrap::Widget::FormFieldLabel;
use strict;
use Bivio::Base 'XHTMLWidget';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub COL_CLASS {
    return 'col-sm-2';
}

sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(
        value => LABEL(
            $self->get('label'),
            $self->COL_CLASS . ' control-label',
        ),
    )->SUPER::initialize(@_);
}

1;
