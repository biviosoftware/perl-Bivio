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

=item href : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item href : string (required)

Literal text to use for C<HREF> attribute of C<A> tag.
Will be passed to L<Bivio::Util::escape_html|Bivio::Util/"escape_html">
before rendering.

The result will be used for C<HREF> attribute of C<A> tag.
Will be passed to L<Bivio::Util::escape_html|Bivio::Util/"escape_html">
before rendering.

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
    if (ref($href)) {
	$fields->{href} = $href;
    }
    else {
	$p .= ' href="'.Bivio::Util::escape_html($href).'"';
    }
    # We assume is not a constant and on first rendering, may be set to true
    $fields->{is_constant} = 0;
    $fields->{is_initialized} = 0;
    $fields->{prefix} = $p;
    $fields->{value}->put(parent => $self);
    $fields->{value}->initialize;
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
    unless ($fields->{is_initialized}) {
	Carp::croak($self, '->initialize: not called')
		    unless $fields->{value};
	# If everything is constant, just return value
	# Build up suffix in local buffer
	my($suffix) = '>';
	$fields->{value}->render($source, \$suffix);
	$suffix .= '</a>';

	# If the value is constant, then have {suffix} and no {value}
	$fields->{suffix} = $suffix, delete($fields->{value})
		if $fields->{is_constant} = $fields->{value}->is_constant;

	# Render the href.  If it is constant, then {href} won't be defined
	$$buffer .= $fields->{prefix};
	if ($fields->{href}) {
	    # href isn't constant, so just use suffix optimization if available
	    $$buffer .= ' href="'.Bivio::Util::escape_html(
		    $source->get_widget_value(@{$fields->{href}})).'"';
	    $fields->{is_constant} = 0;
	}
	elsif ($fields->{is_constant}) {
	    # Everything is constant.  Delete other fields and store constant
	    $fields->{value} = $fields->{prefix} . $fields->{suffix};
	    delete($fields->{prefix});
	    delete($fields->{suffix});
	}

	# Finish first rendering.  Suffix contains value.
	$$buffer .= $suffix;
	$fields->{is_initialized} = 1;
	return;
    }
    # Not a constant, render href (if needed) and value.
    $$buffer .= $fields->{prefix};
    $$buffer .= ' href="'.Bivio::Util::escape_html(
	    $source->get_widget_value(@{$fields->{href}})).'"'
		    if $fields->{href};

    # If value is a constant, suffix contains the rest.  We're done
    $$buffer .= $fields->{suffix}, return if $fields->{suffix};

    # Value isn't a constant, render away...
    $$buffer .= '>';
    $fields->{value}->render($source, $buffer);
    $$buffer .= '</a>';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
