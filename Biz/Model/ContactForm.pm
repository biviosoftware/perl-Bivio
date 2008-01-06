# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ContactForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    if ($self->get_request->get('auth_user')) {
	my($e) = $self->new_other('Email');
	$self->internal_put_field('from' => $e->get('email'))
	    if $e->load_for_auth_user;
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->internal_put_field(subject => 'Web Contact')
	unless $self->unsafe_get('subject');
    Bivio::UI::View->execute(
	Bivio::IO::Config->if_version(
	    3 => sub {'UserAuth->general_contact_mail'},
	    sub {'contact-mail'},
	),
	$self->req,
    );
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	visible => [
	    {
		name => 'from',
		type => 'Email.email',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'text',
		type => 'TextArea',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'subject',
		type => 'Line',
		constraint => 'NONE',
	    },
	],
    });
}

1;
