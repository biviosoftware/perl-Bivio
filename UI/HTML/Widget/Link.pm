# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Link;
use strict;
$Bivio::UI::HTML::Widget::Link::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Link - renders a URI link

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Link;
    Bivio::UI::HTML::Widget::Link->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Link::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Link> implements an HTML C<A> tag with
an C<HREF> attribute.

=head1 ATTRIBUTES

=over 4

=item control : string []

=item control : Bivio::Agent::TaskId []

=item control : array_ref []

Don't make a link if doesn't return true.
If string or task, will generate the appropriate control.

=item href : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item href : string (required)

Literal text to use for C<HREF> attribute of C<A> tag.

=item name : string []

Anchor name.

=item value : widget (required)

The value between the C<A> tags aka the label.

=back

=cut

#=IMPORTS
use Bivio::Util;
use Carp ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Link

Creates a new Link widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
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
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{value});
    # Both must be defined
    my($href);
    ($fields->{value}, $href) = $self->get('value', 'href');
    my($p, $s) = ('<a', '');
    my($n) = $self->get_or_default('name', 0);
    $p .= ' name="'.Bivio::Util::escape_html($n).'"' if $n;
    if (ref($href)) {
	$fields->{href} = $href;
    }
    else {
	$p .= ' href="'.$href.'"';
    }
    # We assume is not a constant and on first rendering, may be set to true
    $fields->{is_constant} = 0;
    $fields->{is_initialized} = 0;
    $fields->{prefix} = $p;
    $fields->{value}->put(parent => $self);
    $fields->{value}->initialize;

    # check control
    $fields->{control} = $self->unsafe_get('control');
    $fields->{control} = [['->get_request'], '->can_user_execute_task',
	Bivio::Agent::TaskId->from_any($fields->{control})]
	    unless !$fields->{control} || $fields->{control} eq 'ARRAY';
    return;
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Is this instance a constant?

=cut

sub is_constant {
    my($fields) = shift->{$_PACKAGE};
    Carp::croak('can only be called after first render')
		unless $fields->{is_initialized};
    return $fields->{is_constant};
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the link.  Most of the code is involved in avoiding unnecessary method
calls.  If I<value> is a constant, then it will be rendered only once.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= $fields->{value}, return if $fields->{is_constant};

    if ($fields->{control}
	    && !$source->get_widget_value(@{$fields->{control}})) {
	$fields->{value}->render($source, $buffer);
	# Make sure we initialize
	$fields->{is_initialized} = 1 unless $fields->{is_initialized};
	return;
    }

    # Used only at initialization
    my($start) = length($$buffer);

    # Render href
    $$buffer .= $fields->{prefix};
    $$buffer .= ' href="'.
	    $source->get_widget_value(@{$fields->{href}}).'"'
		    if $fields->{href};

    # Render value
    $$buffer .= '>';
    $fields->{value}->render($source, $buffer);
    $$buffer .= '</a>';

    # Initialize?
    return if $fields->{is_initialized};
    Carp::croak($self, '->initialize: not called')
		unless $fields->{value};
    $fields->{is_initialized} = 1;

    # Can't be constant if control or href
    return if $fields->{control} || $fields->{href}
	    || !$fields->{value}->is_constant;

    # Everything is constant.  Delete other fields and store constant
    $fields->{value} = substr($$buffer, $start);
    $fields->{is_constant} = 1;
    delete($fields->{prefix});
    delete($fields->{suffix});
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
