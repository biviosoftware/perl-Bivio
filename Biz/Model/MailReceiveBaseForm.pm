# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MailReceiveBaseForm;
use strict;
$Bivio::Biz::Model::MailReceiveBaseForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::MailReceiveBaseForm::VERSION;

=head1 NAME

Bivio::Biz::Model::MailReceiveBaseForm - field definitions for b-sendmail-http form

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::MailReceiveBaseForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::MailReceiveBaseForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MailReceiveBaseForm> defines the fields sent by
C<b-sendmail-http>, the bOP sendmail to http gateway.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

Defines the following fields:

=over 4

=item client_addr : Line

The address of the SMTP originator.

=item recipient : Line

The name of the recipient (what comes after "_mail_receive/*")

=item message : FileField

The actual message received in RFC822 format.

=back

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 2,
	visible => [
	    {
		name => 'client_addr',
		form_name => 'client_addr',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'recipient',
		form_name => 'recipient',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'message',
		form_name => 'message',
		type => 'FileField',
		constraint => 'NOT_NULL',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
