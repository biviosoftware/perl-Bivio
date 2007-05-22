# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Text::Widget::Link;
use strict;
$Bivio::UI::Text::Widget::Link::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Text::Widget::Link::VERSION;

=head1 NAME

Bivio::UI::Text::Widget::Link - renders an absolute URI link

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Text::Widget::Link;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Text::Widget::Link::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Text::Widget::Link> implements a text http: link.

=head1 ATTRIBUTES

=over 4

=item value : any (required)

Value to use for the uri.  If I<value> is a valid enum name or is an actual
TaskId instance, I<value> will be treated as a task.  Otherwise, I<value> will
be treated as a literal uri.  If value is in all capital letters, then it is
treated as a task id, and a widget value for format_stateless_uri() will be
used.

If I<value> is an array_ref, it will be dereferenced and passed to
C<$source-E<gt>get_widget_value> to get the uri to use.

=back

=cut

#=IMPORTS
use Bivio::Die;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(any value, hash_ref attributes) : Bivio::UI::Text::Widget::Link

Creates a C<Link> widget with attributes I<value>.
And optionally, set extra I<attributes>.

=head2 static new(hash_ref attributes) : Bivio::UI::Text::Widget::Link

If I<attributes> supplied, creates with attribute (name, value) pairs.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Partially initializes by copying attributes to fields.
It is fully initialized after first render.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{value};

    $fields->{value} = _initialize_value($self);
    return $self->SUPER::initialize();
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(proto, any arg) : hash_ref

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $value, $attributes) = @_;
    return '"value" must be defined' unless defined($value);
    return {
	value => $value,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the absolute URI.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($v) = $self->render_value('value', $fields->{value}, $source);
    # Insert http: prefix, if not already there.
    $$buffer .= $source->get_request->format_http_prefix
	unless $$v =~ /^\w+:/;
    $$buffer .= $$v;
    return;
}

#=PRIVATE METHODS

# _initialize_value(self) : any
#
# Returns the value as initialized.
#
#TODO: Share this code with HTML::Link
#
sub _initialize_value {
    my($self) = @_;
    my($value) = $self->initialize_attr('value');
    if (ref($value)) {
	return $value if ref($value) eq 'ARRAY';
	$self->die('value', undef, 'unknown type for value: ', $value)
		unless ref($value) eq 'Bivio::Agent::TaskId';
	return [['->get_request'], '->format_stateless_uri',
	    Bivio::Agent::TaskId->$value()];
    }
    return [['->get_request'], '->format_stateless_uri',
	Bivio::Agent::TaskId->$value()]
	    if Bivio::Agent::TaskId->is_valid_name($value);
    return $value;
}

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
