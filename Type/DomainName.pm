# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DomainName;
use strict;
$Bivio::Type::DomainName::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::DomainName::VERSION;

=head1 NAME

Bivio::Type::DomainName - internet domain names

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::DomainName;

=cut

=head1 EXTENDS

L<Bivio::Type::Name>

=cut

use Bivio::Type::Name;
@Bivio::Type::DomainName::ISA = ('Bivio::Type::Name');

=head1 DESCRIPTION

C<Bivio::Type::DomainName> desribes a domain name.  Allows dotted
decimal names (ip numbers).

=cut


=head1 CONSTANTS

=cut

=for html <a name="REGEXP"></a>

=head2 REGEXP : regexp_ref

Returns regular expression used for validating.

=cut

sub REGEXP {
    return qr/^(?:[-a-z0-9]{1,63})(?:\.[-a-z0-9]{1,63})+$/is;
}

#=IMPORTS

#=VARIABLES
my($_REGEXP) = __PACKAGE__->REGEXP;

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : any

Downcases result of super and validates against dotted decimal.

=cut

sub from_literal {
    my($value, $err) = shift->SUPER::from_literal(@_);
    return ($value, $err)
	unless defined($value);
    return (undef, Bivio::TypeError->DOMAIN_NAME)
	unless $value =~ $_REGEXP;
    return lc($value);
}

=for html <a name="get_width"></a>

=head2 static get_width() : int

Max host name is 255.

=cut

sub get_width {
    return 255.
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
