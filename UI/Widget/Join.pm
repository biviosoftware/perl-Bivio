# Copyright (c) 1999-2005 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::Join;
use strict;
$Bivio::UI::Widget::Join::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::Join::VERSION;

=head1 NAME

Bivio::UI::Widget::Join - renders a sequence of widgets and strings

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Widget::Join;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Widget::Join::ISA = qw(Bivio::UI::Widget);

=head1 DESCRIPTION

C<Bivio::UI::Widget::Join> is a sequence of widgets and literal text.

=head1 ATTRIBUTES

=over 4

=item join_separator : any []

Widget which renders between values which render successfully
(unsafe_render_value returns true).

=item values : array_ref (required)

The widgets, text, and widget_values which will be rendered as a part of the
sequence.  The rendered values are unmodified.  If all the values are constant,
the result of this widget will be constant.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes widget state and children.

=cut

sub initialize {
    my($self) = @_;
    my($name) = 0;
    foreach my $v (@{$self->get('values')}) {
	$self->initialize_value($name++, $v);
    }
    $self->unsafe_initialize_attr('join_separator');
    return;
}

=for html <a name="internal_as_string"></a>

=head2 internal_as_string() : array

Returns the first two values in the join

See L<Bivio::UI::Widget::as_string|Bivio::UI::Widget/"as_string">.

=cut

sub internal_as_string {
    my($self) = @_;
    my($values) = $self->unsafe_get('values');
    # A little bit of safety.  Don't want to crash in "as_string".
    return ($values) unless ref($values) eq 'ARRAY';
    my(@res) = @$values;
    return int(@res) > 2 ? (splice(@res, 0, 2), '...') : @res;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $values, $join_separator, $attributes) = @_;
    return '"values" attribute must be an array_ref'
	unless ref($values) eq 'ARRAY';
    if (ref($join_separator) eq 'HASH') {
	$attributes = $join_separator;
	$join_separator = undef;
    }
    return {
	values => $values,
	($join_separator ? (join_separator => $join_separator) : ()),
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($name) = 0;
    if ($self->has_keys('join_separator')) {
	my($need_sep) = 0;
	foreach my $v (@{$self->get('values')}) {
	    my($b) = '';
	    my($next_sep)
		= $self->unsafe_render_value($name++, $v, $source, \$b)
		&& length($b);
	    $self->unsafe_render_attr('join_separator', $source, $buffer)
		if $need_sep && $next_sep;
	    $$buffer .= $b;
	    $need_sep = $next_sep;
	}
    }
    else {
	foreach my $v (@{$self->get('values')}) {
	    $self->unsafe_render_value($name++, $v, $source, $buffer);
	}
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
