# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECPaymentStatus;
use strict;
$Bivio::Type::ECPaymentStatus::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECPaymentStatus::VERSION;

=head1 NAME

Bivio::Type::ECPaymentStatus - list of payment statuses

=head1 SYNOPSIS

    use Bivio::Type::ECPaymentStatus;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECPaymentStatus::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECPaymentStatus> describes the possible states
a payment can be associated with. The current choices are:

=over 4

=item TRY_CAPTURE

=item CAPTURED

=item DECLINED

=item FAILED

=item CANCELLED

=item TRY_VOID

=item VOIDED

=item TRY_CREDIT

=item CREDITED

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

__PACKAGE__->compile([
    TRY_CAPTURE => [
	1,
    ],
    CAPTURED => [
	2,
    ],
    DECLINED => [
	3,
    ],
    FAILED => [
	4,
    ],
    CANCELLED => [
	5,
    ],
    TRY_VOID => [
	6,
    ],
    VOIDED => [
	7,
    ],
    TRY_CREDIT => [
	8,
    ],
    CREDITED => [
	9,
    ],
]);

=head1 METHODS

=cut

=for html <a name="get_authorize_net_type"></a>

=head2 get_authorize_net_type() : string

Return the appropriate Authorize.Net transaction type

=cut

sub get_authorize_net_type {
    my($self) = @_;
    return 'AUTH_CAPTURE'
	    if $self == Bivio::Type::ECPaymentStatus::TRY_CAPTURE();
    return 'VOID' if $self == Bivio::Type::ECPaymentStatus::TRY_VOID();
    return 'CREDIT'
	    if $self == Bivio::Type::ECPaymentStatus::TRY_CREDIT();
    Bivio::Die->die('Status not appropriate: ', $self);
    # DOES NOT RETURN
}

=for html <a name="get_success_state"></a>

=head2 get_success_state() : Bivio::Type::ECPaymentStatus

From any TRY_* state, change to the corresponding success state.

=cut

sub get_success_state {
    my($self) = @_;
    my($new_state) = $self;
    return Bivio::Type::ECPaymentStatus::CAPTURED()
	    if $self == Bivio::Type::ECPaymentStatus::TRY_CAPTURE();
    return Bivio::Type::ECPaymentStatus::VOIDED()
	    if $self == Bivio::Type::ECPaymentStatus::TRY_VOID();
    return Bivio::Type::ECPaymentStatus::CREDITED()
	    if $self == Bivio::Type::ECPaymentStatus::TRY_CREDIT();
#TODO: Is this right?
    return $self;
}

=for html <a name="is_approved"></a>

=head2 is_approved() : boolean

Return TRUE if self is one of the approved states

=cut

sub is_approved {
    my($self) = @_;
    return $self == Bivio::Type::ECPaymentStatus::CAPTURED()
            || $self == Bivio::Type::ECPaymentStatus::VOIDED()
                    || $self == Bivio::Type::ECPaymentStatus::CREDITED()
			    ? 1 : 0;
}

=for html <a name="needs_processing"></a>

=head2 needs_processing() : boolean

Return TRUE if self needs further processing

=cut

sub needs_processing {
    my($self) = @_;
    return $self == Bivio::Type::ECPaymentStatus::TRY_CAPTURE()
            || $self == Bivio::Type::ECPaymentStatus::TRY_VOID()
                    || $self == Bivio::Type::ECPaymentStatus::TRY_CREDIT()
			    ? 1 : 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
