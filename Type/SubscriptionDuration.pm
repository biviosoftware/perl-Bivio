# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::SubscriptionDuration;
use strict;
$Bivio::Type::SubscriptionDuration::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::SubscriptionDuration::VERSION;

=head1 NAME

Bivio::Type::SubscriptionDuration - how many years a subscription is for

=head1 SYNOPSIS

    use Bivio::Type::SubscriptionDuration;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::SubscriptionDuration::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::SubscriptionDuration> is the number of years a premium services
subscription should last for.  Used in calculating the end date.

=cut

#=IMPORTS
use Bivio::Type::Date;

#=VARIABLES
__PACKAGE__->compile([
    # Configuration: NAME => [num_days, display name],
    YEAR_1 => [1, '1 Year'],
    YEAR_2 => [2, '2 Years'],
    YEAR_3 => [3, '3 Years'],
    YEAR_4 => [4, '4 Years'],
    YEAR_5 => [5, '5 Years'],
    YEAR_6 => [6, '6 Years'],
    YEAR_7 => [7, '7 Years'],
    YEAR_8 => [8, '8 Years'],
    YEAR_9 => [9, '9 Years'],
    YEAR_10 => [10, '10 Years'],
]);

=head1 METHODS

=cut

=for html <a name="get_default"></a>

=head2 get_default() : any

Returns C<YEAR_1>.

=cut

sub get_default {
    return shift->YEAR_1;
}

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : boolean

Returns false.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
