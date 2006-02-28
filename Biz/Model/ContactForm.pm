# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ContactForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    Bivio::UI::View->execute('contact-mail', $req);
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
		constraint => 'NONE',
	    },
	],
    });
}

1;
