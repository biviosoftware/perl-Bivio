# Copyright (c) 2002-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailReceiveDispatchForm;
use strict;
use Bivio::Base 'Model.MailReceiveBaseForm';
b_use('IO.Trace');
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_A) = b_use('Mail.Address');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('Biz.File');
my($_E) = b_use('Type.Email');
my($_I) = b_use('Mail.Incoming');
my($_RI) = b_use('Agent.RequestId');
my($_FP) = b_use('Type.FilePath');
my($_TEST_RECIPIENT_HDR) = qr{^@{[b_use('Mail.Common')->TEST_RECIPIENT_HDR]}:}m;
b_use('IO.Config')->register(my $_CFG = {
    filter_spam => 0,
    duplicate_threshold_seconds => 3600,
});

sub execute_ok {
    my($self) = @_;
    # Unpacks and stores an incoming mail message.
    # Requires form fields: client_addr, recipient, message.
    #
    # Sets facade, realm, user, and server_redirects to task.
    #
    # User is set from From: or Apparently-From:, in that order.
    #
    # op then maps to a URI:
    #
    #    Text->get_value('MailReceiveDispatchForm.uri_prefix') . $op
    #
    # I<op> must contain only \w and dashes (-).
    my($req) = $self->req;
    Type_UserAgent()->MAIL->execute($req, 1);
    $req->put_durable(client_addr => $self->get('client_addr'));
    $self->put_on_request(1);
    my($redirect, undef, $realm, $plus, $op) = _email_alias($self);
    return _redirect($redirect)
	if $redirect;
    my($mi) = $_I->new($self->get('message')->{content});
    $self->internal_put_field(
	mail_incoming => $mi,
	plus_tag => $plus,
    );
    return _redirect('ignore_task')
	if _ignore($self, \&_ignore_email, \&_ignore_forwarded, \&_ignore_spam);
    $self->internal_set_realm($realm);
    return _redirect('ignore_task')
	if _ignore($self, \&_ignore_duplicate, \&_ignore_mailer_daemon);
    $self->internal_put_field(
	task_id => _task($self, $op),
	from_email => ($mi->get_from)[0],
    );
    _trace($self->get('from_email'), ' ', $self->get('task_id')) if $_TRACE;
    $self->throw_die('FORBIDDEN', {
	entity => $realm,
        message => 'message missing "From"',
    }) unless $self->get('from_email');
    $self->new_other('UserLoginForm')->process({
	login => $self->internal_get_login($mi),
	via_mta => 1,
    });
    return {
	method => 'server_redirect',
	task_id => $self->get('task_id'),
	query => undef,
    };
}

sub format_recipient {
    my($self, $realm, $plus, $op) = @_;
    return $_E->format_email(
	$realm,
	undef,
	$plus,
	$op,
	$self->req,
    );
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub internal_get_login {
    my($self, $in) = @_;
    return $in->get_from_user_id($self->req);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	$self->field_decl(
	    other => [
		['mail_incoming', $_I],
		['from_email', 'Email'],
		['task_id', 'Agent.TaskId'],
		['plus_tag', 'String'],
	    ],
	),
    });
}

sub internal_set_realm {
    my($self, $realm) = @_;
    # Sets I<realm> or throws not_found.
    $realm = ref($realm) ? $realm
	: $self->new_other('RealmOwner')
	->unauth_load_by_id_or_name_or_die($realm);
    $self->throw_die('NOT_FOUND', {
	entity => $realm,
        message => 'cannot mail to a default realm or offline user',
    }) if $realm->is_default || $realm->is_offline_user;
    $self->req->set_realm($realm);
    return;
}

sub _email_alias {
    my($self) = @_;
    my($req) = $self->req;
    my($domain, $realm, $plus, $op) = _parse_recipient($self);
    Bivio::UI::Facade->setup_request($domain, $req);
    return (undef, $domain, $realm, $plus, $op)
	unless $req->get('task')->unsafe_get_redirect('email_alias_task', $req)
	and my $new = $self->new_other('EmailAlias')
	->incoming_to_outgoing($self->get('recipient'));
    if ($_E->is_valid($new)) {
	_trace($self->get('recipient'), ' => ', $new) if $_TRACE;
	$self->internal_put_field(recipient => $new);
	return 'email_alias_task';
    }
    $self->internal_put_field(recipient => $_E->join_parts($new, $domain));
    return (undef, _parse_recipient($self));
}

sub _from_email {
    my($from) = @_;
    ($from) = $from && $_A->parse($from);
    return $from && lc($from);
}

sub _from_mailer_daemon {
    return shift->get('mail_incoming')->get('header')
	    =~ /^Return-Path:\s*<MAILER-DAEMON>/im;
}

sub _ignore {
    my($self, @ops) = @_;
    foreach my $op (@ops) {
	next
	    unless my $which = $op->($self);
	$_F->write(
	    $_FP->join(
		$self->simple_package_name,
		$which,
		$_RI->current($self->req) . '.eml',
	    ),
	    $self->get('message')->{content},
	);
	return 1;
    }
    return 0;
}

sub _ignore_duplicate {
    my($self) = @_;
    my($rml) = $self->new_other('RealmMailList');
    my($mi) = $self->get('mail_incoming');
    return undef
	if $self->req->if_test(
	sub {$mi->get('header') !~ $_TEST_RECIPIENT_HDR});
    return undef
	unless $rml->unsafe_load_this_or_first
	&& _ignore_duplicate_threshold(
	    $rml->get('RealmFile.modified_date_time'));
#TODO: Should we decode body?
    return $_I->new($rml->get_rfc822)->get_body eq $mi->get_body
	? 'duplicate' : undef;
}

sub _ignore_duplicate_threshold {
    my($prev) = @_;
    return $_DT->compare(
	$_DT->add_seconds($prev, $_CFG->{duplicate_threshold_seconds}),
	$_DT->now,
    ) > 0;
}


sub _ignore_email {
    my($self) = @_;
    return undef
	unless $_E->is_ignore($self->get('recipient'));
    return 'ignore-mail';
}

sub _ignore_forwarded {
    my($self) = @_;
    return $self->get('mail_incoming')->is_forwarding_loop
        ? 'too-many-forwards' : undef;
}

sub _ignore_mailer_daemon {
    my($self) = @_;
    return undef
	unless $self->new_other('RowTag')->get_value(
	    $self->req('auth_id'),
	    Type_RowTagKey()->FILTER_MAILER_DAEMON,
	);
    return undef
	unless _from_mailer_daemon($self);
    foreach my $id (_related_message_ids($self)) {
	return undef
	    if $self->new_other('RealmMail')->unsafe_load({
		message_id => $id,
	    });
    }
    return 'mailer-daemon';
}

sub _ignore_spam {
    my($self) = @_;
    return $_CFG->{filter_spam}
	&& $self->get('mail_incoming')->get('header') =~ /^X-Spam-Flag:\s*Y/im
	? 'spam' : undef;
}

sub _parse_recipient {
    my($self) = @_;
    my($to) = $self->get('recipient');
    my(undef, $domain, $name, $plus, $op) = $_E->split_parts($to);
    $self->throw_die(
	'NOT_FOUND',
	{
	    entity => $to,
	    message => 'invalid recipient',
	},
    ) unless defined($name);
    return ($domain, $name, $plus, $op);
}

sub _redirect {
    my($task) = @_;
    _trace($task) if $_TRACE;
    return {
	method => 'server_redirect',
	task_id => $task,
	query => undef,
    };
}

sub _related_message_ids {
    return (shift->get('mail_incoming')->get_rfc822
		=~ /^Message-Id:\s+<(.+?)>/mig);
}

sub _task {
    my($self, $op) = @_;
    my($req) = $self->req;
    $op ||= '';
    $self->throw_die('NOT_FOUND', {
	entity => $op,
        message => 'operation is invalid',
    }) unless $op =~ /^\w*$/;
    return b_use('FacadeComponent.Task')->unsafe_get_from_uri(
	b_use('FacadeComponent.Text')
	    ->get_value('MailReceiveDispatchForm.uri_prefix', $req)
	    . $op,
	$req->get('auth_realm')->get('type'),
	$req,
    ) || $self->throw_die('NOT_FOUND', {
	entity => $op,
	message => 'task not found',
    });
}

1;
