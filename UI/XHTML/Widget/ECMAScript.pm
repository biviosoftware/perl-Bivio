# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ECMAScript;
use strict;
use Bivio::Base 'HTMLWidget.Tag';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
        tag => 'script',
        SRC => '',
        value => '',
        TYPE => 'text/javascript',
        bracket_value_in_comment => 1,
        control => [sub {
            return $self->unsafe_get('value') || $self->unsafe_get('SRC')
                ? 1 : 0;
        }],
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args(['value'], \@_);
}

sub strip {
    my(undef, $code) = @_;
    # Strips leading blanks and comments.
    # Strip leading blanks and blank lines
    $code =~ s/^\s+//sg;
    $code =~ s/\n\s+/\n/g;

    # Strip comments
    $code =~ s/\/\/.*\n//g;
    return $code;
}

1;
