# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECSubscription;
use strict;
$Bivio::Type::ECSubscription::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECSubscription::VERSION;

=head1 NAME

Bivio::Type::ECSubscription - list of premium services

=head1 SYNOPSIS

    use Bivio::Type::ECSubscription;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECSubscription::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECSubscription> describes the premium services
a realm can be subscribed to. The current choices are:

=over 4

=item UNKNOWN

=item PREMIUM_SUPPORT

=item ACCOUNT_SYNC

=item ACCOUNT_KEEPER

=item BASIC_SERVICE

=item FREE_TRIAL

=item TAX_SEASON

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

__PACKAGE__->compile([
    UNKNOWN => [
	0,
        'None',
    ],
    PREMIUM_SUPPORT => [
	1,
        'Premium Support',
    ],
    ACCOUNT_SYNC => [
	2,
        'AccountSync',
    ],
    ACCOUNT_KEEPER => [
	3,
        'AccountKeeper',
    ],
    BASIC_SERVICE => [
	4,
	'Club Accounting',
    ],
    FREE_TRIAL => [
	5,
	'Free Trial',
    ],
    TAX_SEASON => [
	6,
	'Tax Season',
    ],
]);
# Tells us whether we can upgrade to the new value.  UNKNOWN is
# not upgradeable.
my(%_UPGRADE_INDEX);
{
    my($i) = 0;
    %_UPGRADE_INDEX = map {
	(__PACKAGE__->$_(), $i++);
    } qw(
	FREE_TRIAL
	PREMIUM_SUPPORT
	TAX_SEASON
	BASIC_SERVICE
	ACCOUNT_SYNC
	ACCOUNT_KEEPER
    );
};

=head1 METHODS

=cut

=for html <a name="upgrade_allowed"></a>

=head2 upgrade_allowed(Bivio::Type::ECSubscription new) : boolean

Returns true if I<self> can be upgraded to I<new>.

=cut

sub upgrade_allowed {
    my($self, $new) = @_;
    my($old) = $_UPGRADE_INDEX{$self};
    # This might happen if there was no old
    return 0 unless defined($old);
    $new = $_UPGRADE_INDEX{$new};
    return 0 unless defined($new);
    return $new > $old;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
