# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::RendererCache;
use strict;
$Bivio::UI::HTML::RendererCache::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::RendererCache - A cache of renderers

=head1 SYNOPSIS

    use Bivio::UI::HTML::RendererCache;
    Bivio::UI::HTML::RendererCache->new();

=cut

@Bivio::UI::HTML::RendererCache::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::UI::HTML::RendererCache> keeps a collection of type renderers. Do
lookup by FieldDescriptor.

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="lookup"></a>

=head2 static lookup(FieldDescriptor d) : Bivio::UI::Renderer

Returns a renderer appropriate for the specified field type.

=cut

sub lookup {
    my($proto, $descriptor) = @_;

    #TODO: add cache
    return Bivio::
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
