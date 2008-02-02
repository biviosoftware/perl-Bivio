# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_O) = __PACKAGE__->use('Mail.Outgoing');
my($_V) = __PACKAGE__->use('UI.View');
my($_RFC) = __PACKAGE__->use('Mail.RFC822');

sub execute_ok {
    my($self) = @_;
    my($r) = $self->req(qw(auth_realm owner));
    my($r_email) = $r->format_email;
    $self->internal_put_field(headers => {
	_from => $_RFC->format_mailbox(
	    $self->new_other('Email')->load_for_auth_user->get('email'),
	    $self->req(qw(auth_user display_name)),
	),
	_recipients => $r_email,
	Sender => $r_email,
	To => $_RFC->format_mailbox($r_email, $r->get('display_name')),
	Subject => $self->get('subject'),
#	In-Reply-To
    });
    $_V->execute('Mail->form_mail', $self->req);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
# 	    {
# 		name => 'to',
# 		type => 'MailFormTo',
# 		constraint => 'NOT_ZERO_ENUM',
# 	    },
	    {
		name => 'subject',
		type => 'RealmMail.subject',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'body',
		type => 'TextArea',
		constraint => 'NOT_NULL',
	    },
	    $self->map_attachments(sub {
		return +{
		    name => shift,
		    type => 'FileField',
		    constraint => 'NONE',
		};
	    }),
	],
	other => [
	    {
		name => 'headers',
		type => 'Hash',
		constraint => 'NONE',
	    },
	],
    });
}

sub mail_header_from {
    return shift->get('headers')->{_from};
}

sub mail_headers {
    my($h) = shift->get('headers');
    return [map(/^_/ ? () : [$_ => $h->{$_}], sort(keys(%$h)))];
}

sub mail_envelope_recipients {
    return shift->get('headers')->{_recipients};
}

sub map_attachments {
    my(undef, $op) = @_;
    return map($op->("attachment$_"), 1..3);
}

1;
