# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Section;
use strict;
$Bivio::UI::PDF::Section::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Section - base class for PDF section objects.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Section;
    Bivio::UI::PDF::Section->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::Section::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Section> is a base class for PDF section objects, which are
Bivio::UI::PDF::Body, Bivio::UI::PDF::Header, Bivio::UI::PDF::Trailer,
and Bivio::UI::PDF::Xref.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Section



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="emit_section_text"></a>

=head2 abstract emit_section_text() : 



=cut

sub emit_section_text {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    die(__FILE__, ", ", __LINE__, ": Abstract object\n");
    return;
}

=for html <a name="extract"></a>

=head2 abstract extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    die(__FILE__, ", ", __LINE__, ": Abstract object\n");
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
