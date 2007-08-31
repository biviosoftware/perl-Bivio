# Copyright (c) 2007 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::OTP::Model::OTP;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
use base 'Bivio::Biz::PropertyModel';

# C<Bivio::OTP::Model::OTP>

#=IMPORTS
use Bivio::OTP::RFC2289;

#=VARIABLES

=head1 METHODS

=cut

sub get_challenge {
    my($self) = @_;
    return join(' ', 'otp-md5', $self->get('count'), $self->get('seed'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'otp_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            otp => ['Line', 'NONE'],   #VARCHAR(16),
            seed => ['Line', 'NONE'],   #VARCHAR(16),
            count => ['Number', 'NONE'],   #NUMERIC(4),
	},
	auth_id => 'realm_id',
    });
}

sub verify {
    my($self, $input) = @_;
    my($otp) = Bivio::OTP::RFC2289->canonical_hex($input);
    return 0
	unless $otp;
    return 0
	unless Bivio::OTP::RFC2289->verify($otp, $self->get('otp'));
    $self->update({
        otp => $otp,
        count => $self->get('count') - 1,
    });
    return 1;
}

#=PRIVATE SUBROUTINES

1;
