# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_EA) = __PACKAGE__->use('Type.EmailArray');
my($_I) = __PACKAGE__->use('Mail.Incoming');
my($_O) = __PACKAGE__->use('Mail.Outgoing');
my($_RFC) = __PACKAGE__->use('Mail.RFC822');
my($_V) = __PACKAGE__->use('UI.View');
my($_QUERY_WHO) = 'to';
my($_MRW) = __PACKAGE__->use('Type.MailReplyWho');

sub VIEW_CLASS {
    return (shift->simple_package_name =~ /(.+)Form/)[0];
}

sub execute_cancel {
    return shift->internal_return_value;
}

sub execute_empty {
    my($self) = @_;
    my($m) = $self->req->unsafe_get_nested('Model.RealmMail');
    my($in) = $m && $_I->new($m);
    $self->internal_put_field(subject => $in ? $in->get_reply_subject : '');
    my($to, $cc) =  ($in || $_I)->get_reply_email_arrays(
	$self->internal_query_who,
	$self->get('realm_emails'),
	$self->req,
    );
    $self->internal_put_field(to => $to);
    $self->internal_put_field(cc => $cc);
    return;
}

sub execute_ok {
    my($self) = @_;
    my($id) = $self->req->unsafe_get_nested(qw(Model.RealmMail message_id));
    my($cc) = $self->get('cc')->as_literal;
    my($to) = $self->get('to');
    my($sender) = $self->get('realm_emails')->[0];
    $self->internal_put_field(headers => {
	_from => $self->internal_format_from,
	_recipients => $to->new([
	    @{$to->as_array},
	    @{$self->get('cc')->as_array},
	])->as_literal,
	Sender => $sender,
	'Reply-To' => $sender,
	To => $to->as_literal,
	$cc ? (Cc => $cc) : (),
	Subject => $self->get('subject'),
	$id ? ('In-Reply-To' => $_RFC->format_angle_brackets($id)) : (),
    });
# create the message
# take message and recipients and incoming?  Need to
# generate message id
# then queue sending of email;
    my($im) = $_V->render($self->VIEW_CLASS . '->form_imail', $self->req);
    my($o) = Bivio::Mail::Outgoing->new(Bivio::Mail::Incoming->new($im));
    $o->set_recipients($to->new([
	    @{$to->as_array},
	    @{$self->get('cc')->as_array},
	])->as_literal,);
    $o->enqueue_send($self->req);
    return $self->internal_return_value;
}

sub get_realm_emails {
    my($self) = @_;
    return [
	$self->new_other('EmailAlias')->format_realm_as_incoming,
	$self->req(qw(auth_realm owner))->format_email,
    ];
}

sub internal_format_from {
    my($self) = @_;
    return $_RFC->format_mailbox(
	$self->new_other('Email')->load_for_auth_user->get('email'),
	$self->req(qw(auth_user display_name)),
    );
}

sub internal_format_reply_to {
    my($self) = @_;
    return $_RFC->format_mailbox(
	$self->get('realm_emails')->[0],
	$self->req(qw(auth_user display_name)),
    );
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
 	    {
 		name => 'to',
		type => 'EmailArray',
		constraint => 'NOT_NULL',
 	    },
 	    {
 		name => 'cc',
		type => 'EmailArray',
		constraint => 'NONE',
 	    },
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
	    @{$self->map_attachments(sub {
		return +{
		    name => shift,
		    type => 'FileField',
		    constraint => 'NONE',
		};
	    })},
	],
	other => [
	    {
		name => 'headers',
		type => 'Hash',
		constraint => 'NONE',
	    },
	    {
		name => 'RealmMail.realm_file_id',
		constraint => 'NONE',
	    },
	    {
		name => 'realm_emails',
		type => 'Array',
		constraint => 'NONE',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field(
	'RealmMail.realm_file_id' =>
	    $self->use('Type.FormMode')->setup_by_list_this(
		$self->new_other('RealmMailList'),
		'RealmMail',
	    )->eq_create ? undef
	    : $self->req(qw(Model.RealmMail realm_file_id)),
    );
    $self->internal_put_field(
	realm_emails => $self->get_realm_emails,
    );
    return shift->SUPER::internal_pre_execute(@_);
}

sub internal_query_who {
    return $_MRW->unsafe_from_any((shift->req('query') || {})->{$_QUERY_WHO})
	|| $_MRW->REALM;
}

sub internal_return_value {
    return {
	task_id => 'next',
	query => undef,
    };
}

sub is_reply {
    return shift->unsafe_get('RealmMail.realm_file_id') ? 1 : 0;
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
    return [map($op->("attachment$_"), 1..3)];
}

sub reply_query {
    my(undef, $who) = @_;
    return {
	'ListQuery.this' => ['RealmMail.realm_file_id'],
	$_QUERY_WHO => lc($_MRW->from_any($who)->as_uri),
    };
}

1;
