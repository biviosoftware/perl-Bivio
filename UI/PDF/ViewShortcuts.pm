# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::PDF::ViewShortcuts;
use strict;
$Bivio::UI::PDF::ViewShortcuts::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::PDF::ViewShortcuts::VERSION;

=head1 NAME

Bivio::UI::PDF::ViewShortcuts - PDF view shortcuts

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::PDF::ViewShortcuts;

=cut

=head1 EXTENDS

L<Bivio::UI::ViewShortcuts>

=cut

use Bivio::UI::ViewShortcuts;
@Bivio::UI::PDF::ViewShortcuts::ISA = ('Bivio::UI::ViewShortcuts');

=head1 DESCRIPTION

C<Bivio::UI::PDF::ViewShortcuts>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="vs_new"></a>

=head2 static vs_new(string class, any new_args, ...) : Bivio::UI::Widget

Returns an instance of I<class> created with I<new_args>.  Loads I<class>, if
not already loaded.

=cut

sub vs_new {
    my(undef, $class) = (shift, shift);
    my($c) = _use($class);
    return $c->new(@_);
}

#=PRIVATE SUBROUTINES

# _use(string class, ....) : array
#
# Executes Bivio::IO::ClassLoader->simple_require on its args.  Inserts
# PDFWidget prefix, if class does not contain colons.  Returns the
# named classes.
#
sub _use {
    my(@class) = @_;
    return map {
	$_ =~ /:/ ? Bivio::IO::ClassLoader->simple_require($_)
	: Bivio::IO::ClassLoader->map_require('PDFWidget', $_);
    } @class;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
