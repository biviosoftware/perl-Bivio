# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Tables::Cell;
use strict;
$Bivio::Test::HTMLParser::Tables::Cell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::HTMLParser::Tables::Cell::VERSION;

=head1 NAME

Bivio::Test::HTMLParser::Tables::Cell - cell of Bivio::Test::HTMLParser::Tables

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::HTMLParser::Tables::Cell;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Test::HTMLParser::Tables::Cell::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Test::HTMLParser::Tables::Cell> is the value for an
individual L<Bivio::Test::HTMLParser::Tables|Bivio::Test::HTMLParser::Tables>.

This class implements a deprecated usage for getting the I<text> of the cell
if called within a string.

=head1 ATTRIBUTES

=over 4

=item Links : Bivio::Test::HTMLParser::Links

The instance that holds the links in the cell.

=item text : string

The concatenated text within the cell.

=back

=cut

#=IMPORTS
use overload
    '""' => \&deprecated_as_string;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns I<text> attribute if available, or ''.

=cut

sub as_string {
    my($self) = @_;
    return $self->has_keys('text') ? $self->get('text')
	: ref($self) ? undef : $self;
}

=for html <a name="deprecated_as_string"></a>

=head2 deprecated_as_string() : string

Calls L<Bivio::IO::Alert::warn_deprecated|Bivio::IO::Alert/"warn_deprecated">
and then calls L<as_string|"as_string">.

=cut

sub deprecated_as_string {
    my($self) = @_;
    # Avoid infinite recursion when stack_trace_warn is true
    Bivio::IO::Alert->warn_deprecated(q{use [value]->get('text') form})
        unless (caller(0))[0] eq 'Carp';
    return $self->as_string;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
