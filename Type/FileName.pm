# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::FileName;
use strict;
$Bivio::Type::FileName::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::FileName - makes sure name does not contain certain special chars

=head1 SYNOPSIS

    use Bivio::Type::FileName;
    Bivio::Type::FileName->new();

=cut

=head1 EXTENDS

L<Bivio::Type::Line>

=cut

use Bivio::Type::Line;
@Bivio::Type::FileName::ISA = ('Bivio::Type::Line');

=head1 DESCRIPTION

C<Bivio::Type::FileName>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Returns C<undef> if the name is empty or zero length.
Checks syntax and returns L<Bivio::TypeError|Bivio::TypeError>.

=cut

sub from_literal {
    my(undef, $value) = @_;
    return undef unless defined($value);
    # Leave middle spaces.
    $value =~ s/^\s+|\s+$//g;
    return undef unless length($value);

    # This is the same as the Win32 set, so we are pretty safe
    return (undef, Bivio::TypeError::FILE_NAME())
	    if $value =~ m![\\/:*?"<>|]!;
    return $value;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
