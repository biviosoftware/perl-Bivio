# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::HTTPURI;
use strict;
$Bivio::Type::HTTPURI::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::HTTPURI::VERSION;

=head1 NAME

Bivio::Type::HTTPURI - uniform resource locator

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::HTTPURI;

=cut

=head1 EXTENDS

L<Bivio::Type::String>

=cut

use Bivio::Type::String;
@Bivio::Type::HTTPURI::ISA = ('Bivio::Type::String');

=head1 DESCRIPTION

C<Bivio::Type::HTTPURI>

=cut

#=IMPORTS
use URI ();

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : any

Returns C<undef> if the line is empty.
Leading and trailing blanks are trimmed.
Length is checked.

=cut

sub from_literal {
    my($proto, $value) = @_;
    $value =~ s/^\s+|\s+$//g
	if defined($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless defined($v);
    my($u) = Bivio::Die->eval(sub {URI->new($v)});
    return $u && ($u->scheme || '') =~ /^https?$/i && $u->host ? $v
	: (undef, Bivio::TypeError->HTTP_URI);
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 255.

=cut

sub get_width {
    return 255;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
