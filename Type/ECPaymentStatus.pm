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
my($_APPROVED_SET, $_BAD_SET, $_NEEDS_PROCESSING_SET);

=head1 METHODS

=cut

=for html <a name="get_authorize_net_type"></a>

=head2 get_authorize_net_type() : string

Return the appropriate Authorize.Net transaction type

=cut

sub get_authorize_net_type {
    return _map(shift, $_AUTHORIZE_NET_MAP);
}

=for html <a name="get_success_state"></a>

=head2 get_success_state() : Bivio::Type::ECPaymentStatus

From any TRY_* state, change to the corresponding success state.

=cut

sub get_success_state {
    my($res) = _map(shift, $_SUCCESS_MAP);
    return __PACKAGE__->$res();
}

=for html <a name="is_approved"></a>

=head2 is_approved() : boolean

Return TRUE if self is one of the approved states.

=cut

sub is_approved {
    return _is_set(shift, \$_APPROVED_SET);
}

=for html <a name="is_bad"></a>

=head2 is_bad() : boolean

Returns true if self is one of the declined states.

=cut

sub is_bad {
    return _is_set(shift, \$_BAD_SET);
}

=for html <a name="needs_processing"></a>

=head2 needs_processing() : boolean

Return TRUE if self needs further processing.

=cut

sub needs_processing {
    return _is_set(shift, \$_NEEDS_PROCESSING_SET);
}

#=PRIVATE METHODS

# _init_set(string_ref set, array names) : string_ref
#
# Initializes a bit vector.
#
sub _init_set {
    my($set) = shift;
    $$set = '';
    return Bivio::Type::ECPaymentStatusSet->set(
	$set,
	map {
	    __PACKAGE__->$_(),
	} @_
    );
}

# _is_set(self, string_ref set) : boolean
#
# Returns true if $self is set in $set.  Initializes sets, if need be.
#
sub _is_set {
    my($self, $set) = @_;
    unless (defined($$set)) {
	# Avoids circular import.
	Bivio::IO::ClassLoader->simple_require(
	    'Bivio::Type::ECPaymentStatusSet');
	_init_set(\$_APPROVED_SET, qw(CAPTURED VOIDED CREDITED));
	_init_set(\$_BAD_SET, qw(DECLINED FAILED));
	_init_set(\$_NEEDS_PROCESSING_SET,
	    qw(TRY_CAPTURE TRY_VOID TRY_CREDIT));
    }
    return Bivio::Type::ECPaymentStatusSet->is_set($set, $self);
}

# _map(self, hash_ref map) : string
#
# Maps value or blows up.
#
sub _map {
    my($self, $map) = @_;
    my($res) = $map->{$self->get_name};
    Bivio::Die->die($self, ': invalid status') unless $res;
    return $res;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
