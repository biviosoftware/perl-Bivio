# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Name;
use strict;
$Bivio::Type::Name::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Name - holds a simple name, login id, account number, etc.

=head1 SYNOPSIS

    use Bivio::Type::Name;

=cut

=head1 EXTENDS

L<Bivio::Type::String>

=cut

use Bivio::Type::String;
@Bivio::Type::Name::ISA = ('Bivio::Type::String');

=head1 DESCRIPTION

C<Bivio::Type::Name> defines a simple name, e.g. first name,
last name, account identifier, and login name.  If you want
a compound name, use L<Bivio::Type::Line|Bivio::Type::Line>.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : any

Returns C<undef> if the name is empty.
Leading and trailing blanks are trimmed.

=cut

sub from_literal {
    my(undef, $value) = @_;
    return undef unless defined($value);
    # Leave middle spaces in case a "display" name.
    $value =~ s/^\s+|\s+$//g;
    return undef unless length($value);
    return $value;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 30.

=cut

sub get_width {
    return 30;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
