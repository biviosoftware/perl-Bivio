# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::General::UserAgreement;
use strict;
$Bivio::UI::HTML::General::UserAgreement::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::General::UserAgreement - renders the user agreement

=head1 SYNOPSIS

    use Bivio::UI::HTML::General::UserAgreement;
    Bivio::UI::HTML::General::UserAgreement->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::General::UserAgreement::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::General::UserAgreement> renders the user agreement
with an included form.

=cut


=head1 CONSTANTS

=cut

=for html <a name="PAGE_HEADING"></a>

=head2 PAGE_HEADING : string

Returns 'Terms of Service'

=cut

sub PAGE_HEADING {
    return 'Terms of Service';
}

=for html <a name="PAGE_TOPIC"></a>

=head2 PAGE_TOPIC : string

Returns 'Terms of Service'

=cut

sub PAGE_TOPIC {
    return PAGE_HEADING();
}

#=IMPORTS
use Bivio::Agent::HTTP::Location;
use Bivio::Agent::Request;
use Bivio::Agent::TaskId;
use Bivio::Biz::Action::HTTPDocument;
use Bivio::UI::HTML::DescriptivePageForm;

#=VARIABLES
my($_P) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content()

Returns the form.

=cut

sub create_content {
    my($self) = @_;
    my($req) = Bivio::Agent::Request->new();

    # Read in terms of service
    my($fh) = Bivio::Biz::Action::HTTPDocument->open($req,
	    Bivio::Agent::HTTP::Location->format(
		    Bivio::Agent::TaskId::USER_AGREEMENT_TEXT()));
    local($_);
    0 while defined($_ = <$fh>) && !/<td>.*Terms of Service/;
    my($text) = '';
    $text .= $_ while defined($_ = <$fh>) && !/^\<\!--FORM--/;
    close($fh);
    die('unable to open hm/user.html') unless $text;

    my($form) = Bivio::UI::HTML::DescriptivePageForm->new({
	form_class => 'Bivio::Biz::Model::UserAgreementForm',
	header => $_P->join([$text]),
    });

    # No fields, just header
    $form->put(value => $form->create_fields([]));
    return $form;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
