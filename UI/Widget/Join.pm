# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
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

=item values : array_ref (required)

The widgets, text, and widget_values which will be rendered as a part of the
sequence.  The rendered values are unmodified.  If all the values are constant,
the result of this widget will be constant.

Widget_values can return widgets.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::Widget::Join

=head2 static new(array_ref values) : Bivio::UI::Widget::Join

Creates a new Join widget.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes widget state and children.

=cut

sub initialize {
    my($self, $source) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Already initialized?
    return if $fields->{values};

    # Save values and initialize children.  $name identifies each
    # widget uniquely for debugging purposes.
    my($name) = 0;
    $fields->{values} = $self->get('values');
    foreach my $v (@{$fields->{values}}) {
	$self->initialize_value($name++, $v);
    }
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
    my(undef, $values, $attributes) = @_;
    return '"values" attribute must be an array_ref'
	unless ref($values) eq 'ARRAY';
    return {
	values => $values,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($name) = 0;
    foreach my $v (@{$fields->{values}}) {
	$self->unsafe_render_value($name++, $v, $source, $buffer);
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
