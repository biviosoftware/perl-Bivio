# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Update;
use strict;
$Bivio::UI::PDF::Update::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Update - encapsulate a PDF "update".

=head1 SYNOPSIS

    use Bivio::UI::PDF::Update;
    Bivio::UI::PDF::Update->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::Update::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Update> encapsulates a PDF "update", a term coined by the
author that describes the text added to a PDF file to change or update it.
In PDF land, one changes a PDF file not by changing the original contents, but
by adding more text that describe the changes to the original.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Update



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_prev_offset"></a>

=head2 abstract get_prev_offset() : 



=cut

sub get_prev_offset {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    die(__FILE__, ", ", __LINE__, ": abstract method.\n");
    return;
}

=for html <a name="get_xref_offset"></a>

=head2 abstract get_xref_offset() : 



=cut

sub get_xref_offset {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    die(__FILE__, ", ", __LINE__, ": abstract method.\n");
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
