# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECCreditCardExpYear;
use strict;
$Bivio::Type::ECCreditCardExpYear::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECCreditCardExpYear::VERSION;

=head1 NAME

Bivio::Type::ECCreditCardExpYear - list of possible credit card expiration years

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::ECCreditCardExpYear;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECCreditCardExpYear::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECCreditCardExpYear>

=cut

#=IMPORTS
use Bivio::Type::Date;

#=VARIABLES
my($_NOW) = Bivio::Type::Date->get_part(Bivio::Type::Date->now, 'year');

# 10 year window from current year forward, ex. (Y2004 => [2004, 2004])
__PACKAGE__->compile([
    map({
	("Y$_" => [$_, $_]),
    } ($_NOW .. $_NOW + 9)),
]);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
