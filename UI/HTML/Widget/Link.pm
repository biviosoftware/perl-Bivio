# Copyright (c) 1999-2005 bivio Inc.  All rights reserved.
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

L<Bivio::UI::HTML::Widget::ControlBase>

=cut

use Bivio::UI::HTML::Widget::ControlBase;
@Bivio::UI::HTML::Widget::Link::ISA = ('Bivio::UI::HTML::Widget::ControlBase');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Link> implements an HTML C<A> tag with
an C<HREF> attribute.

=head1 ATTRIBUTES

=over 4

=item attributes : string []

Arbitrary HTML attributes to be applied to the begin tag.  Must begin
with leading space.

=item class : string []

Class attribute.

=item control : any

See L<Bivio::UI::Widget::ControlBase|Bivio::UI::Widget::ControlBase>.

=item event_handler : Bivio::UI::Widget []

If set, this widget will be initialized as a child and must
support a method C<get_html_field_attributes> which returns a
string to be inserted in this fields declaration.
I<event_handler> will be rendered before this field.

=item href : any (required)

Value to use for C<HREF> attribute of C<A> tag.  If I<href> renders to a valid
enum name or is an L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>,
I<href> will be passed passed
using L<Bivio::Agent::Request::format_stateless_uri|Bivio::Agent::Request/"format_stateless_uri">
If I<href> renders as a hash_ref, it will passed to
L<Bivio::Agent::Request::format_uri|Bivio::Agent::Request/"format_uri">.
Otherwise, I<href> will be treated as a literal uri.

=item link_target : any [] (inherited)

The value to be passed to the C<TARGET> attribute of C<A> tag.

=item name : any []

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

=head2 static new(any value, any href, any class, hash_ref attributes) : Bivio::UI::HTML::Widget::Link

=head2 static new(any value, any href, hash_ref attributes) : Bivio::UI::HTML::Widget::Link

Creates a C<Link> widget with attributes I<value> and I<href>.  I<class> is
optionally a widget value, constant, or widget.  And optionally, set extra
I<attributes>.

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Link

If I<attributes> supplied, creates with attribute (name, value) pairs.

=cut

=head1 METHODS

=cut

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Render the link.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= '<a' . $_VS->vs_link_target_as_html($self, $source);
    $self->SUPER::control_on_render($source, $buffer);
    $self->unsafe_render_attr('attributes', $source, $buffer);
    my($n) = '';
    $$buffer .= ' name="' . Bivio::HTML->escape($n) . '"'
	if $self->unsafe_render_attr('name', $source, \$n);
    my($href) = _render_href($self, $source);
    $$buffer .= qq{ href="$href"}
        if defined($href);
    my($handler) = $self->unsafe_resolve_widget_value(
	$self->unsafe_get('event_handler'), $source);
    $$buffer .= $handler->get_html_field_attributes(undef, $source)
	if $handler;
    $$buffer .= '>';
    $self->render_attr('value', $source, $buffer); 
    $$buffer .= '</a>';
    $handler->render($source, $buffer)
	if $handler;
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Partially initializes by copying attributes to fields.
It is fully initialized after first render.

=cut

sub initialize {
    my($self) = @_;
    $self->map_invoke(
	'unsafe_initialize_attr',
	[qw(attributes event_handler name link_target)],
    );
    my($v) = $self->get('value');
    $self->put(value => $_VS->vs_new('String', $v))
	unless UNIVERSAL::isa($v, 'Bivio::UI::Widget');
    $self->map_invoke('initialize_attr', [qw(value href)]);
    return shift->SUPER::initialize(@_);
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

=head2 static internal_new_args() :  hash_ref

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    return shift->SUPER::internal_new_args([qw(value href)], \@_);
}

#=PRIVATE METHODS

# _render_href(self, any source) : string
#
# Returns a string.  May format it using format_uri or format_stateless_uri
#
sub _render_href {
    my($self, $source) = @_;
    my($href) = $self->unsafe_resolve_widget_value(
        $self->get('href'), $source);
    if (UNIVERSAL::isa($href, 'Bivio::UI::Widget')) {
	my($v) = $href;
	$href = undef;
	$self->unsafe_render_value('href', $v, $source, \$href);
    }
    return undef
	unless defined($href) && length($href);
    return $href
	unless ref($href) || Bivio::Agent::TaskId->is_valid_name($href);
    my($req) = $source->get_request;
    return $req->format_stateless_uri($href)
	if !ref($href) || UNIVERSAL::isa($href, 'Bivio::Agent::TaskId');
    # use a copy of the hash because format_uri() munges it
    return $req->format_uri({%$href})
	if ref($href) eq 'HASH';
    $self->die(
	'href', $source,
	$href, ': unknown type for href (must be scalar, hash, or TaskId)'
    );
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
