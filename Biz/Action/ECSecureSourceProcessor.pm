# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ECSecureSourceProcessor;
use strict;
$Bivio::Biz::Action::ECSecureSourceProcessor::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::ECSecureSourceProcessor::VERSION;

=head1 NAME

Bivio::Biz::Action::ECSecureSourceProcessor - AIM Wells Fargo SecureSource

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::ECSecureSourceProcessor;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action::ECCreditCardProcessor>

=cut

use Bivio::Biz::Action::ECCreditCardProcessor;
@Bivio::Biz::Action::ECSecureSourceProcessor::ISA = ('Bivio::Biz::Action::ECCreditCardProcessor');

=head1 DESCRIPTION

C<Bivio::Biz::Action::ECSecureSourceProcessor>

=cut

#=IMPORTS
use Bivio::Biz::Model;
use Bivio::HTML;
use Bivio::Type::Location;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_get_additional_form_data"></a>

=head2 internal_get_additional_form_data(proto, Model.ECPayment payment) : string

Allow subclasses to provide additional form data for the payment processor.
Used by ECSecureSourceProcessor.

=cut

sub internal_get_additional_form_data {
    my($proto, $payment) = @_;
    my($req) = $payment->get_request;
    my($user) = Bivio::Biz::Model->new($req, 'User')->unauth_load_or_die({
        user_id => $payment->get('realm_id'),
    });
    my($address) = Bivio::Biz::Model->new($req, 'Address')
        ->unauth_load_or_die({
            realm_id => $payment->get('realm_id'),
            location => Bivio::Type::Location->HOME,
        });
    my($phone) = Bivio::Biz::Model->new($req, 'Phone')->unauth_load_or_die({
        realm_id => $payment->get('realm_id'),
        location => Bivio::Type::Location->HOME,
    });
    # send the email to support
    # - this is where the authorize.net receipt is sent
    return '&x_First_Name=' . _escape($user->get('first_name'))
        . '&x_Last_Name=' . _escape($user->get('last_name'))
        . '&x_Address=' . _escape($address->get('street1'))
        . '&x_City=' . _escape($address->get('city'))
        . '&x_State=' . _escape($address->get('state'))
        . '&x_Country=' . _escape($address->get('country'))
        . '&x_Phone=' . _escape($phone->get('phone'))
        . '&x_Email=' . _escape(Bivio::UI::Text->get_value(
            'support_email', $req))
        ;
}

#=PRIVATE SUBROUTINES

# _escape(string value) : string
#
# Returns the value escaped for URIs.
#
sub _escape {
    my($value) = @_;
    return Bivio::HTML->escape_uri($value);
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
