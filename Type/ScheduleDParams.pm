# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::ScheduleDParams;
use strict;
$Bivio::Type::ScheduleDParams::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::ScheduleDParams - parameters for InstrumentSaleList

=head1 SYNOPSIS

    use Bivio::Type::ScheduleDParams;
    Bivio::Type::ScheduleDParams->new();

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ScheduleDParams::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ScheduleDParams> parameters for InstrumentSaleList

The following entry classes are defined:

=over 4

=item UNKNOWN

not set

=item SHOW_DISTRIBUTIONS

show gains distributions in sub lists

=item HIDE_DISTRIBUTIONS

don't show gains distributions in sub lists

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    'UNKNOWN' => [
    	0,
	'unknown',
    ],
    'SHOW_DISTRIBUTIONS' => [
    	1,
	'show distributions',
    ],
    'HIDE_DISTRIBUTIONS' => [
	2,
	'hide distributions',
    ],
);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
