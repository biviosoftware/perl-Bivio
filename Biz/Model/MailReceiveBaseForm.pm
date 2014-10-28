# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MailReceiveBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';


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

=head1 DESCRIPTION

C<Bivio::Biz::Model::MailReceiveBaseForm> defines the fields sent by
C<b-sendmail-http>, the bOP sendmail to http gateway.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

It's fatal to receive an empty mail message form

=cut

sub execute_empty {
    my($self) = @_;
    $self->throw_die(Bivio::DieCode->CORRUPT_QUERY, 'empty form');
    # DOES NOT RETURN
}

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

Copyright (c) 2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
