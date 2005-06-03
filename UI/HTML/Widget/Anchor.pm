# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Anchor;
use strict;
$Bivio::UI::HTML::Widget::Anchor::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Anchor::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Anchor - a link target anchor

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Anchor;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Anchor::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Anchor> renders an anchor which can be used
as a link target.

=head1 ATTRIBUTES

=over 4

=item name : string or array_ref (required)

The name of the anchor.

=item value : string or array_ref or Bivio::UI::Widget (required)

The value inside the anchor.

=back

=cut

#=IMPORTS
use Bivio::HTML;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any name, any value, hash_ref attributes) : hash_ref

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $name, $value, $attributes) = @_;
    return {
        name => $name,
        value => $value,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Renders the named anchor.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    # call escape_query() and not escape() because MSIE
    # requires that the item match the URI value exactly
    $$buffer .= '<a name="'
        . Bivio::HTML->escape_query(${$self->render_attr('name', $source)})
        . '">';
    $self->render_attr('value', $source, $buffer);
    $$buffer .= '</a>';
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
