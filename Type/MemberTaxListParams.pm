# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::MemberTaxListParams;
use strict;
$Bivio::Type::MemberTaxListParams::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::MemberTaxListParams::VERSION;

=head1 NAME

Bivio::Type::MemberTaxListParams - parameters for MemberTaxList

=head1 SYNOPSIS

    use Bivio::Type::MemberTaxListParams;
    Bivio::Type::MemberTaxListParams->new();

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::MemberTaxListParams::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::MemberTaxListParams> parameters for MemberTaxList

The following entry classes are defined:

=over 4

=item UNKNOWN

not set

=item SHOW_VALID_MEMBERS

show valid members

=item HIDE_VALID_MEMBERS

hide valid members

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    'UNKNOWN' => [
    	0,
	'unknown',
    ],
    'SHOW_VALID_MEMBERS' => [
    	1,
	'show valid members',
    ],
    'HIDE_VALID_MEMBERS' => [
	2,
	'hide valid members',
    ],
]);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
