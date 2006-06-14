# Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.
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

=head1 CONSTANTS

=cut

=for html <a name="ILLEGAL_CHAR_REGEXP"></a>

=head2 ILLEGAL_CHAR_REGEXP : regexp

Characters not allowed in file names

=cut

sub ILLEGAL_CHAR_REGEXP {
    return qr{^\.\.?$|[\\/:*?"<>|\0-\037\177]};
}

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
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return undef unless defined($value);
    # Leave middle spaces.
    $value =~ s/^\s+|\s+$//g;
    return undef unless length($value);

    # This is the same as the Win32 set, so we are pretty safe.
    # Don't allow '.' or '..'.
    return (undef, Bivio::TypeError->FILE_NAME)
	if $value =~ $proto->ILLEGAL_CHAR_REGEXP;
    return $proto->SUPER::from_literal($value);
}

=for html <a name="get_clean_base"></a>

=head2 static get_clean_base(string value) : array

Returns the base name of value cleaned of any non-alpha-numeric input chars and
without the suffix.

May return undef, if the there are no clean chars in the tail.

=cut

sub get_clean_base {
    my($proto, $value) = @_;
    return undef
	unless defined($value);
    $value = $proto->get_base($value);
    $value =~ s/^\W+|\W+$//g;
    $value =~ s/\W+/-/g;
    my($n) = $proto->get_width - 6;
    return length($value) > $n ? substr($value, 0, $n)
	: length($value) ? $value : undef;
}

=for html <a name="get_tail"></a>

=head2 static get_tail(string value) : string

Returns the basename including file suffix, stripping directories
and drive names.  '/' returns empty string.

=cut

sub get_tail {
    my(undef, $value) = @_;
    $value =~ s{[:\/\\]+$}{};
    $value =~ s{.*[:\/\\]}{};
    return $value;
}

=for html <a name="get_base"></a>

=head2 static get_base(string value) : string

Returns the basename excluding file suffix, stripping directories
and drive names.

=cut

sub get_base {
    my($proto, $value) = @_;
    $value = $proto->get_tail($value);
    return $value
	if $value =~ /^\.+[^\.]*$/;
    $value =~ s/\.[^\.]+$//;
    return $value;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
