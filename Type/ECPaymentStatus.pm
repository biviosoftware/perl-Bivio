# Copyright (c) 2000-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECPaymentStatus;
use strict;
use Bivio::Base 'Type.Enum';

# C<Bivio::Type::ECPaymentStatus> describes the possible states
# a payment can be associated with.

__PACKAGE__->compile([
    TRY_CAPTURE => [1],
    CAPTURED => [2],
    DECLINED => [3],
    FAILED => [4],
    CANCELLED => [5],
    TRY_VOID => [6],
    VOIDED => [7],
    TRY_CREDIT => [8],
    CREDITED => [9],
]);
my($_SUCCESS_MAP) = {
    TRY_CAPTURE => 'CAPTURED',
    TRY_VOID => 'VOIDED',
    TRY_CREDIT => 'CREDITED',
};
my($_AUTHORIZE_NET_MAP) = {
    TRY_CAPTURE => 'AUTH_CAPTURE',
    TRY_VOID => 'VOID',
    TRY_CREDIT => 'CREDIT',
};
my($_PAYPAL_MAP) = {
    TRY_CAPTURE => 'DoDirectPayment',
    TRY_CREDIT => 'RefundTransaction',
};
my($_NEEDS_PROCESSING_LIST) = [map {__PACKAGE__->$_()}
    qw(TRY_CAPTURE TRY_VOID TRY_CREDIT)];
my($_APPROVED_SET, $_BAD_SET, $_NEEDS_PROCESSING_SET);

sub get_authorize_net_type {
    # (self) : string
    # Return the appropriate Authorize.Net transaction type
    return _map(shift, $_AUTHORIZE_NET_MAP);
}

sub get_paypal_type {
    my($self) = @_;
    return _map(shift, $_PAYPAL_MAP);
}

sub get_success_state {
    # (self) : Type.ECPaymentStatus
    # From any TRY_* state, change to the corresponding success state.
    my($res) = _map(shift, $_SUCCESS_MAP);
    return __PACKAGE__->$res();
}

sub is_approved {
    # (self) : boolean
    # Return TRUE if self is one of the approved states.
    return _is_set(shift, \$_APPROVED_SET);
}

sub is_bad {
    # (self) : boolean
    # Returns true if self is one of the declined states.
    return _is_set(shift, \$_BAD_SET);
}

sub needs_processing {
    # (self) : boolean
    # Return TRUE if self needs further processing.
    return _is_set(shift, \$_NEEDS_PROCESSING_SET);
}

sub needs_processing_list {
    # (self) : array_ref
    # List of statuses which need processing.
    return [@$_NEEDS_PROCESSING_LIST];
}

sub _init_set {
    # (string_ref, array) : string_ref
    # Initializes a bit vector.
    my($set) = shift;
    $$set = '';
    return Bivio::Type::ECPaymentStatusSet->set(
	$set,
	map {
	    __PACKAGE__->from_any($_),
	} @_
    );
}

sub _is_set {
    # (self, string_ref) : boolean
    # Returns true if $self is set in $set.  Initializes sets, if need be.
    my($self, $set) = @_;
    unless (defined($$set)) {
	# Avoids circular import.
	Bivio::IO::ClassLoader->simple_require(
	    'Bivio::Type::ECPaymentStatusSet');
	_init_set(\$_APPROVED_SET, qw(CAPTURED VOIDED CREDITED));
	_init_set(\$_BAD_SET, qw(DECLINED FAILED));
	_init_set(\$_NEEDS_PROCESSING_SET, @$_NEEDS_PROCESSING_LIST);
    }
    return Bivio::Type::ECPaymentStatusSet->is_set($set, $self);
}

sub _map {
    # (self, hash_ref) : string
    # Maps value or blows up.
    my($self, $map) = @_;
    my($res) = $map->{$self->get_name};
    Bivio::Die->die($self, ': invalid status') unless $res;
    return $res;
}

1;
