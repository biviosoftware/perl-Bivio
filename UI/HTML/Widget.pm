# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget;
use strict;
$Bivio::UI::HTML::Widget::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget - an HTML display entity

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget;
    Bivio::UI::HTML::Widget->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::ISA = qw(Bivio::UI::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget> is the superclass of all HTML
widgets.

Provides many utility routines to help build widgets.

=cut

#=IMPORTS

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::UI::HTML::Widget

Creates the widget.

=cut

sub new {
    return Bivio::UI::Widget::new(@_);
}

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
