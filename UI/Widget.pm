# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Widget;
use strict;
$Bivio::UI::Widget::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Widget - a displayable entity

=head1 SYNOPSIS

    use Bivio::UI::Widget;
    Bivio::UI::Widget->new();

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::UI::Widget::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::UI::Widget> is the parent of all UI widgets.

=head1 ATTRIBUTES

=over 4

=item parent : Bivio::UI::HTML::Widget

This widget's "owner".  There actually may be several parents,
so it is unclear if this attribute is all that useful.

The descendent hierarchy is searched for attributes, i.e. attributes
are inherited from parents.

=back

=cut


#=IMPORTS

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::UI::Widget

=cut

sub new {
    return Bivio::Collection::Attributes::new(@_);
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes the widgets internal structures.  Widgets should cache static
attributes.  Widgets initialize should be callable more than once.

=cut

sub initialize {
    die('abstract method');
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Will this widget always render exactly the same way?
May only be called after the first render call.

Returns false by default.

=cut

sub is_constant {
    return 0;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Appends the value of the widget to I<buffer>.

=cut

sub render {
    die('abstract method');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
