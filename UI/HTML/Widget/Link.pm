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

L<Bivio::UI::HTML::Widget::AbstractControl>

=cut

use Bivio::UI::HTML::Widget::AbstractControl;
@Bivio::UI::HTML::Widget::Link::ISA = ('Bivio::UI::HTML::Widget::AbstractControl');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Link> implements an HTML C<A> tag with
an C<HREF> attribute.

=head1 ATTRIBUTES

=over 4

=item attributes : string []

Arbitrary HTML attributes to be applied to the begin tag.  Must begin
with leading space.

=item control : any

See L<Bivio::UI::HTML::Widget::AbstractControl|Bivio::UI::HTML::Widget::AbstractControl>.

=item href : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item href : string (required)

Literal text to use for C<HREF> attribute of C<A> tag.

=item link_target : string [] (inherited)

The value to be passed to the C<TARGET> attribute of C<A> tag.

=item name : string []

Anchor name.

=item value : widget (required)

The value between the C<A> tags aka the label.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::HTML;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Link

Creates a new Link widget.

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::AbstractControl::new(@_);
    $self->{$_PACKAGE} = {};
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
    my($fields) = $self->{$_PACKAGE};

    $$buffer .= $fields->{prefix};
    $$buffer .= ' href="'.$source->get_widget_value(@{$fields->{href}}).'"'
	    if $fields->{href};
    $$buffer .= '>';
    $fields->{value}->render($source, $buffer);
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
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{value};

    # href and value both must be defined
    my($href);
    ($fields->{value}, $href) = $self->get('value', 'href');
    my($p, $s) = ('<a'.$self->link_target_as_html, '');
    my($n) = $self->get_or_default('name', 0);
    $p .= ' name="'.$n.'"' if $n;
    my($a) = $self->unsafe_get('attributes');
    $p .= $a if $a;

    if (ref($href)) {
	$fields->{href} = $href;
    }
    else {
	$p .= ' href="'.$href.'"';
    }
    $fields->{prefix} = $p;
    $fields->{value}->put(parent => $self);

    # Child initializations happen last.  Parent happens after that.
    $fields->{value}->initialize;
    return $self->SUPER::initialize();
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
