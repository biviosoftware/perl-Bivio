# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::FileName;
use strict;
$Bivio::Type::FileName::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::FileName - makes sure name does not contain certain special chars

=head1 RELEASE SCOPE

bOP

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

=head1 METHODS

=cut

=for html <a name="add_trailing_slash"></a>

=head2 static add_trailing_slash(string path) : string

Adds a trailing slash (/) unless one is already there.

=cut

sub add_trailing_slash {
    my(undef, $path) = @_;
    return $path =~ m,/$, ? $path : $path.'/';
}

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

    # This is the same as the Win32 set, so we are pretty safe.
    # Don't allow '.' or '..'.
    return (undef, Bivio::TypeError::FILE_NAME())
	    if $value =~ m!^\.\.?$|[\\/:*?"<>|\0-\037\177]!;
    return $value;
}

=for html <a name="get_tail"></a>

=head2 static get_tail(string value) : string

Returns the basename, stripping directories and drive names.

=cut

sub get_tail {
    my(undef, $value) = @_;
    $value =~ s!.*[:\/\\]!!;
    return $value;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
