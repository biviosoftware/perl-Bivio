# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Line;
use strict;
$Bivio::Type::Line::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Line - holds a line of text or full name

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Line;

=cut

=head1 EXTENDS

L<Bivio::Type::String>

=cut

use Bivio::Type::String;
@Bivio::Type::Line::ISA = qw(Bivio::Type::String);

=head1 DESCRIPTION

C<Bivio::Type::Line> defines a compound name or long line of text, e.g.
a person's full name, an e-mail address, and an account name.
If you want
a simple name, e.g.
first name, use L<Bivio::Type::Name|Bivio::Type::Name>.

Note: leading and trailing spaces are trimmed in
L<from_literal|"from_literal">.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : any

Returns C<undef> if the line is empty.
Leading and trailing blanks are trimmed.

=cut

sub from_literal {
    my(undef, $value) = @_;
    return undef unless defined($value);
    # Leave middle spaces in case a "display" or file name.
    $value =~ s/^\s+|\s+$//g;
    return undef unless length($value);
    return $value;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 100.

=cut

sub get_width {
    return 100;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
