# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::Director;
use strict;
$Bivio::UI::Widget::Director::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::Director::VERSION;

=head1 NAME

Bivio::UI::Widget::Director - directs rendering to one widget of a set

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Widget::Director;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Widget::Director::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Widget::Director> is used to dynamically select among a set
of widgets.  A C<Director> is never constant but its I<values> might be.

=head1 ATTRIBUTES

=over 4

=item control : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>.
The result must match one of the keys in I<values>
or I<default_value> will be returned.  If I<default_value>
is not defined, is an error.

=item values : hash_ref (required)

The value selection of values.  The keys must match the type
of I<control>.  The values are widgets.
If a value is zero (0), renders nothing.

=item default_value : widget []

The widget to use when the I<control> does not match any of
the keys in I<values>.  If zero (0), renders nothing.

=item undef_value : widget []

The widget to use when the I<control> is undefined.
If zero (0), renders nothing.

=back

=cut

#=IMPORTS
use Bivio::Die;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(any control, hash_ref values, Bivio::UI::Widget default_value, Bivio::UI::Widget undef_value, hash_ref attributes) : Bivio::UI::Widget::Director

Create a C<Director> widget with I<control>, I<values>,
I<default_value>, and I<undef_value>.  The last three of
which may be C<undef>.

Creates a new Director widget.

=head2 static new(hash_ref attributes) : Bivio::UI::Widget::Director

Creates a new Director widget with named attributes.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Executes the child widget as selected from I<req> (as source).

=cut

sub execute {
    my($self, $req) = @_;
    my($w) = _select($self, $req);
    Bivio::Die->die('Director did not select a widget; no content type')
        unless defined($w);
    return $w->execute($req);
}

=for html <a name="initialize"></a>

=head2 initialize()

Copies the attributes to local fields.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{initialized}++;
    $self->initialize_attr('control');
    $self->unsafe_initialize_attr('default_value');
    $self->unsafe_initialize_attr('undef_value');
    while (my($k, $v) = each(%{$self->get('values')})) {
	$self->initialize_value($k, $v);
    }
    return;
}

=for html <a name="internal_as_string"></a>

=head2 internal_as_string() : array

Returns I<control>.

See L<Bivio::UI::Widget::as_string|Bivio::UI::Widget/"as_string">.

=cut

sub internal_as_string {
    my($self) = @_;
    return $self->unsafe_get('control');
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $control, $values, $default_value, $undef_value, $attrs) = @_;
    return '"control" attribute must be defined' unless defined($control);
    return {
	control => $control,
	values => $values ? $values : {},
	default_value => $default_value,
	undef_value => $undef_value,
	($attrs ? %$attrs : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the selected value.  Most of the code is involved in avoiding
unnecessary method calls.  If the I<value> is a constant, then it will only be
rendered once.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($v, $n) = _select($self, $source);
    $self->unsafe_render_value($n, $v, $source, $buffer)
	if defined($v);
    return;
}

#=PRIVATE METHODS

# _select(self, any source) : Bivio::UI::Widget
#
# Returns the widget to render, undef, or dies.
#
sub _select {
    my($self, $source) = @_;
    my($ctl) = '';
    my($n) = 'undef_value';
    if ($self->unsafe_render_attr('control', $source, \$ctl)) {
	my($values) = $self->get('values');
	return ($values->{$ctl} || undef, $ctl)
	    if defined($values->{$ctl});
	$n = 'default_value';
    }
    my($v) = $self->unsafe_get($n);
    return ($v || undef, $n)
	if defined($v);
    Bivio::Die->die($self->get('control'), ': invalid control value: ', $ctl);
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
