# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::View;
use strict;
use Bivio::UI::Renderer;
$Bivio::UI::View::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::View - Abstract base class of model renderers.

=head1 SYNOPSIS

    use Bivio::UI::View;
    Bivio::UI::View->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

@Bivio::UI::View::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::View>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES

my($PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::View

Creates a view.

=cut

sub new {
    return &Bivio::UI::Renderer::new(@_);
}

=head1 METHODS

=cut

=for html <a name="get_title"></a>

=head2 abstract get_title(UNIVERSAL target) : string

Returns an appropriate name for the view when used in the target's
context.

=cut

sub get_title {
    die("abstract method View::get_title invoked!\n");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
