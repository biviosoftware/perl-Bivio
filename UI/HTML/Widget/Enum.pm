# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Enum;
use strict;
use Bivio::Base 'HTMLWidget.String';


sub NEW_ARGS {
    return ['field'];
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('field');
    $self->put_unless_exists(
#TODO: enable a lookup on the value
        value => [
            sub {
                my($source) = @_;
                my($v) = $self->unsafe_resolve_widget_value(
                    [$self->get('field')],
                    $source,
                );
                return $v && $v->get_short_desc;
            },
        ],
    );
    return shift->SUPER::initialize(@_);
}

1;
