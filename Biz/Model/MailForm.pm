# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_EA) = b_use('Type.EmailArray');
my($_I) = b_use('Mail.Incoming');
my($_O) = b_use('Mail.Outgoing');
my($_RFC) = b_use('Mail.RFC822');
my($_V) = b_use('UI.View');
my($_MRW) = b_use('Type.MailReplyWho');
my($_ARM) = b_use('Action.RealmMail');
my($_MA) = b_use('Mail.Address');
my($_QUERY_WHO) = 'to';

sub MAIL_REFLECTOR_TASK {
    return undef;
}

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
	_reply_to($self),
	$self->get_realm_emails,
	$self->req,
    );
    $self->internal_put_field(to => $to);
    $self->internal_put_field(cc => $cc);
    return;
}

sub execute_ok {
    my($self) = @_;
    my($req) = $self->req;
    my($id) = $req->unsafe_get_nested(qw(Model.RealmMail message_id));
    my($cc) = $self->get('cc')->as_literal;
    my($to) = $self->get('to');
    my($from) = $self->internal_format_from;
    my($from_email) = $_MA->parse($from);
    my($sender) = $self->internal_format_sender(_reply_to($self));
    my($removed_sender) = 0;
    $self->internal_put_field(headers => {
	_from => $from,
	_recipients => my $other_recipients = $to->new([
	    map({
		my($r) = $_;
		if (grep($r eq $_, @{$self->get_realm_emails})) {
		    $r = undef;
		    $removed_sender++;
		}
		$r ? $r : ();
	    }
	        @{$to->as_array},
		@{$self->get('cc')->as_array},
	    ),
	])->as_literal,
	Sender => $sender,
	'Reply-To' => $sender,
	To => $to->as_literal,
	$cc ? (Cc => $cc) : (),
	Subject => $self->get('subject'),
	$id ? ('In-Reply-To' => $_RFC->format_angle_brackets($id)) : (),
    });
    my($im) = $_V->render($self->VIEW_CLASS . '->form_imail', $req);
    $im = $self->internal_send_to_realm($im)
	if $removed_sender;
    $_O->new($im)
	->set_recipients($other_recipients)
	->set_envelope_from($from_email)
	->enqueue_send($req)
	if $other_recipients;
    return $self->internal_return_value;
}

sub get_realm_emails {
    my($self) = @_;
    return $self->new_other('EmailAlias')->get_all_emails;
}

sub internal_format_from {
    my($self) = @_;
    return $_RFC->format_mailbox(
	$self->new_other('EmailAlias')
	    ->format_realm_as_incoming($self->req('auth_user')),
	$self->req(qw(auth_user display_name)),
    );
}

sub internal_format_reply_to {
    my($self) = @_;
    return $_RFC->format_mailbox(
	_reply_to($self),
	$self->req(qw(auth_user display_name)),
    );
}

sub internal_format_sender {
    my($self, $reply_to_email) = @_;
    return $self->new_other('RowTag')
	->get_value($self->req('auth_id'), 'CANONICAL_SENDER_EMAIL')
	|| $reply_to_email;
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
		name => 'RealmMail.thread_root_id',
		constraint => 'NONE',
	    },
	    {
		name => 'is_new',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($rml) = $self->new_other('RealmMailList');
    my($edit) = $self->use('Type.FormMode')
	->setup_by_list_this($rml, 'RealmMail')
	->eq_edit;
    $self->internal_put_field(is_new => $edit ? 0 : 1);
    foreach my $f (qw(RealmMail.realm_file_id RealmMail.thread_root_id)) {
	$self->internal_put_field($f => $edit && $rml->get($f));
    }
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

sub internal_send_to_realm {
    my($self, $rfc822) = @_;
    my($req) = $self->req;
    $_ARM->execute_receive($req, $rfc822, $self->MAIL_REFLECTOR_TASK);
    return $req->get('Model.RealmMail')->get_rfc822;
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

sub _reply_to {
    my($self) = @_;
    return $self->new_other('EmailAlias')->format_realm_as_incoming;
}

1;
