# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Link;
use strict;
$Bivio::UI::HTML::Widget::Link::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Link::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Link - renders a URI link

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Link;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget::ControlBase>

=cut

use Bivio::UI::Widget::ControlBase;
@Bivio::UI::HTML::Widget::Link::ISA = ('Bivio::UI::Widget::ControlBase');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Link> implements an HTML C<A> tag with
an C<HREF> attribute.

=head1 ATTRIBUTES

=over 4

=item attributes : string []

Arbitrary HTML attributes to be applied to the begin tag.  Must begin
with leading space.

=item control : any

See L<Bivio::UI::Widget::ControlBase|Bivio::UI::Widget::ControlBase>.

=item href : any (required)

Value to use for C<HREF> attribute of C<A> tag.  If I<href> is a valid
enum name or is an actual TaskId instance, I<href> will be treated as a task.
Otherwise, I<href> will be treated as a literal uri.

If I<href> is an array_ref, it will be dereferenced and passed to
C<$source-E<gt>get_widget_value> to get the uri to use.

Literal text to use for C<HREF> attribute of C<A> tag.
If href is in all capital letters, then it is treated as a task id,
and a widget value for format_stateless_uri() will be used.

=item link_target : string [] (inherited)

The value to be passed to the C<TARGET> attribute of C<A> tag.

=item name : string []

Anchor name.

=item value : any (required)

The value between the C<A> tags aka the label.  May be any
renderable value
(see L<Bivio::UI::Widget::render_value|Bivio::UI::Widget/"render_value">).
If not a widget, will be wrapped in a I<Widget.String>.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::HTML;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(any value, any href, hash_ref attributes) : Bivio::UI::HTML::Widget::Link

Creates a C<Link> widget with attributes I<value> and I<href>.
And optionally, set extra I<attributes>.

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Link

If I<attributes> supplied, creates with attribute (name, value) pairs.

=cut

sub new {
    my($self) = Bivio::UI::Widget::ControlBase::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Render the link.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];

    $$buffer .= $fields->{prefix};
    $$buffer .= ' href="'
	. _fixup_href($source->get_request,
	    $source->get_widget_value(@{$fields->{href}}))
	. '"'
	    if $fields->{href};
    $$buffer .= '>';
    $self->render_value('value', $fields->{value}, $source, $buffer);
    $$buffer .= '</a>';
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Partially initializes by copying attributes to fields.
It is fully initialized after first render.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{value};

    # href and value both must be defined
    my($p, $s) = ('<a'.$_VS->vs_link_target_as_html($self), '');
    my($n) = $self->get_or_default('name', 0);
    $p .= ' name="'.$n.'"' if $n;
    my($a) = $self->unsafe_get('attributes');
    $p .= $a if $a;

    $fields->{value} = $self->initialize_attr('value');
    $fields->{value} = $_VS->vs_new(
	    'String', $fields->{value},
	)->put_and_initialize(parent => $self)
	unless ref($fields->{value})
	    && UNIVERSAL::isa($fields->{value}, 'Bivio::UI::Widget');
    $fields->{href} = _initialize_href($self);
    unless (ref($fields->{href})) {
	# Format literally if a constant
	$p .= ' href="'.$fields->{href}.'"';
	delete($fields->{href});
    }
    $fields->{prefix} = $p;
    return $self->SUPER::initialize();
}

=for html <a name="internal_as_string"></a>

=head2 internal_as_string() : array

Returns this widget's config for
L<Bivio::UI::Widget::as_string|Bivio::UI::Widget/"as_string">.

=cut

sub internal_as_string {
    my($self) = @_;
    return $self->unsafe_get('value', 'href');
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args() : 

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $value, $href, $attributes) = @_;
    return '"value" must be defined' unless defined($value);
    return '"href" must be defined' unless defined($href);
    return {
	value => $value,
	href => $href,
	($attributes ? %$attributes : ()),
    };
}

#=PRIVATE METHODS

# _fixup_href(Bivio::Agent::Request req, any href) : string
#
# Returns a string.  May format if not already a TaskId.
#
sub _fixup_href {
    my($req, $href) = @_;
    return $href unless ref($href);
    Bivio::Die->die('unknown type for href: ', $href)
	unless ref($href) eq 'Bivio::Agent::TaskId';
    return $req->format_stateless_uri($href);
}

# _initialize_href(self) : any
#
# Returns the href as initialized.
#
sub _initialize_href {
    my($self) = @_;
    my($href) = $self->initialize_attr('href');
    if (ref($href)) {
	return $href if ref($href) eq 'ARRAY';
	$self->die('href', undef, 'unknown type for href: ', $href)
		unless ref($href) eq 'Bivio::Agent::TaskId';
	return [['->get_request'], '->format_stateless_uri',
	    Bivio::Agent::TaskId->$href()];
    }
    return [['->get_request'], '->format_stateless_uri',
	Bivio::Agent::TaskId->$href()]
	    if Bivio::Agent::TaskId->is_valid_name($href);
    return $href;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
