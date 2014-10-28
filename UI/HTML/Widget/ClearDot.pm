# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ClearDot;
use strict;
use Bivio::Base 'HTMLWidget.Tag';

# C<Bivio::UI::HTML::Widget::ClearDot> displays the clear dot
#
#
# A widget value of zero (0) will result in nothing being rendered,
# i.e. zero means "doesn't exist".
#
#
# align : string []
#
# How to align the image.  The allowed (case
# insensitive) values are defined in
# L<Bivio::UI::Align|Bivio::UI::Align>.
# The value affects the C<ALIGN> and C<VALIGN> attributes of the C<IMG> tag.
#
# height : int [1]
#
# height : array_ref []
#
# The (constant) height of the dot.
#
# width : int [1]
#
# width : array_ref []
#
# The (constant) width of the dot.

my($_IDI) = __PACKAGE__->instance_data_index;
my($_I) = b_use('FacadeComponent.Icon');
my($_R) = b_use('Agent.Request');

sub NEW_ARGS {
    return [qw(?width ?height ?class)];
}

sub as_html {
    my($self, $width, $height) = @_;
    if (@_ > 1) {
	$self = $self->new($width, $height);
    }
    elsif (!ref($self)) {
	b_die('must pass width and height if called statically');
    }
    $self->initialize_with_parent(undef);
    my($b) = '';
    $self->render($_R->get_current, \$b);
    return $b;
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	tag => 'img',
	ALT => 'dot',
	class => 'b_clear_dot',
	SRC => $_I->get_clear_dot->{uri},
	_dims($self),
    );
    return shift->SUPER::initialize(@_);
}

sub _dims {
    my($self) = @_;
    return (
	WIDTH => $self->unsafe_get('width'),
	HEIGHT => $self->unsafe_get('height'),
    ) unless ref($self->unsafe_get('width')) || ref($self->unsafe_get('height'));
    return (
	STYLE => [sub {
	    my($source) = @_;
	    my($res) = '';
	    foreach my $k (qw(height width)) {
		if (length(my $v = $self->render_simple_attr($k, $source))) {
		    $v .= 'px'
			unless $v =~ /\D/;
		    $res .= "$k: $v;"
		}
	    }
	    return $res;
	}],
    );
}

1;
