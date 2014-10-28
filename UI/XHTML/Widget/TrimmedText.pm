# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::TrimmedText;
use strict;
use Bivio::Base 'HTMLWidget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_JS) = b_use('HTMLWidget.JavaScript');

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(cutoff => 200);
    b_die('missing id') unless $self->unsafe_get('ID');
    $self->put(values => [
	Script('common'),
	Script('trim_text'),
	Tag('DIV', {
	    ID => $self->get('ID'),
	    value => $self->get('value'),
	}),
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(value ?cutoff)], \@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($buf) = '';
    shift->SUPER::render($source, \$buf);
    return
	unless defined($buf) && length($buf);
    $$buffer .= $buf;
    return
	unless length($buf) > $self->get('cutoff');
    my($id) = ${$self->render_attr('ID', $source)};
    $_JS->render($source, $buffer, undef, undef,
        "b_trim_text('$id', @{[$self->get('cutoff')]});");
    return;
}

1;
