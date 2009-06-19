# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RoundedBox;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_MARGINS) = {
#   radius_px => [margins],
    3 => [1],
    4 => [2, 1],
    6 => [3, 1, 1],
    8 => [5, 3, 2, 1, 1],
    10 => [6, 4, 3, 2, 1, 1],
    12 => [7, 5, 4, 3, 2, 1, 1],
    16 => [10, 7, 5, 4, 3, 2, 2, 1, 1, 1],
    20 => [13, 10, 8, 7, 6, 5, 4, 3, 2, 2, 1, 1, 1, 1],
};

sub internal_new_args {
    #1) RoundedBox(10, DIV(), 'someclass');
    #2) RoundedBox(DIV(), 'someclass');
    my($proto) = shift;
    my($radius, $value, $class, $err);
    ($radius, $err) = $proto->use('Type.Integer')->from_literal($_[0]);
    shift
        unless defined($err);
    ($value, $class) = @_;
    return {
        radius => $radius,
	value => $value,
	defined($class) ? (class => $class) : (),
    };
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(tag => 'div');
    if (my $radius = $self->render_simple_attr('radius', $self->req)) {
        $self->die('radius must be '.
                       join(', ', sort({$a <=> $b} keys(%$_MARGINS))))
            unless my $margins = $_MARGINS->{$radius};
        $self->put_unless_exists(
            tag_pre_value => Join([
                map(EmptyTag(div => "b_round_$_"), @$margins),
            ]),
            tag_post_value => Join([
                map(EmptyTag(div => "b_round_$_"), reverse(@$margins)),
            ]),
        );
    }
    else {
        $self->put_unless_exists(
            class => 'b_rounded_box',
        )->put(
            value => Join([
                map(EmptyTag(span => "b_rounded_box_body b_rounded_box_$_"), 1..4),
                Tag('div', $self->get('value'), 'b_rounded_box_body'),
                map(EmptyTag(span => "b_rounded_box_body b_rounded_box_$_"), reverse(1..4)),
            ]),
        );
    }
    return shift->SUPER::initialize(@_);
}

1;

