# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::Widget::Gradient;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('FacadeComponent.Color');

sub NEW_ARGS {
    return [qw(from_color to_color)];
}

sub initialize {
    my($self) = @_;
    my($from) = vs_css_color($self->get('from_color'));
    my($to) = vs_css_color($self->get('to_color'));
    $self->put_unless_exists(
	value => Join([
	    'background:', $to, ';', "\n",
	    'filter:progid:DXImageTransform.Microsoft.gradient(startColorstr="', $from, '", endColorstr="', $to, '");', "\n",
	    'background:-webkit-gradient(linear, left top, left bottom, from(', $from, '), to(', $to, '));', "\n",
	    'background:-moz-linear-gradient(top, ', $from, ',', $to, ');', "\n",
	]),
    );
    return;
}

1;
