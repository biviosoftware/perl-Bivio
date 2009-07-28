# Copyright (c) 2002-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailReceiveDispatchForm;
use strict;
use Bivio::Base 'Model.MailReceiveBaseForm';
b_use('IO.Trace');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_A) = b_use('Mail.Address');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('Biz.File');
my($_E) = b_use('Type.Email');
my($_I) = b_use('Mail.Incoming');
my($_RI) = b_use('Agent.RequestId');
my($_TASK) = b_use('FacadeComponent.Task');
my($_TEXT) = b_use('FacadeComponent.Text');
my($_FP) = b_use('Type.FilePath');
Bivio::IO::Config->register(my $_CFG = {
    ignore_dashes_in_recipient => Bivio::IO::Config->if_version(
	5 => sub {1},
	sub {0},
    ),
    filter_spam => 0,
});
my($_ONE_HOUR_SECONDS) = 3600;

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
    Bivio::Type::UserAgent->MAIL->execute($req, 1);
    $req->put_durable(client_addr => $self->get('client_addr'));
    $self->put_on_request(1);
    my($redirect, $realm, $op, $plus_tag) = _email_alias($self);
    return _redirect($redirect)
	if $redirect;
    my($mi) = $_I->new($self->get('message')->{content});
    $self->internal_put_field(
	mail_incoming => $mi,
	plus_tag => $plus_tag,
    );
    return _redirect('ignore_task')
	if _ignore($self, \&_ignore_email, \&_ignore_forwarded, \&_ignore_spam);
    $self->internal_set_realm($realm);
    return _redirect('ignore_task')
	if _ignore($self, \&_ignore_duplicate);
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
	other => [
	    {
		name => 'mail_incoming',
		type => $_I,
		constraint => 'NONE',
	    },
	    {
		# User we authenticated (or not)
		name => 'from_email',
		type => 'Email',
		constraint => 'NONE',
	    },
	    {
		name => 'task_id',
		type => 'Bivio::Agent::TaskId',
		constraint => 'NONE',
	    },
	    {
		name => 'plus_tag',
		type => 'String',
		constraint => 'NONE',
	    },
	],
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

sub parse_recipient {
    my($self, $ignore_dashes) = @_;
    # Returns (realm, op, plus_tag, domain) from recipient.  I<op> may be undef.
    # I<realm> may be a Model.RealmOwner, name, or realm_id.  Dies with
    # NOT_FOUND if recipient not syntactically valid.
    #
    # Two addresses are parsed:
    #
    #    op.realm+plus_tag@domain
    #    realm-op+plus_tag@domain  (only if !$ignore_dashes)
    #
    # Where +plus_tag is like sendmail style +anything after the address.  You
    # don't need +plus_tag.
    $ignore_dashes = $_CFG->{ignore_dashes_in_recipient}
	unless defined($ignore_dashes);
    my($to) = $self->get('recipient');
    _trace('to: ', $to) if $_TRACE;
    my($domain) = $1
	if $to =~ s/\@(.*)$//;
    my($plus_tag) = $1
	if $to =~ s/\+(.*)$//;
    my($name, $op) = $ignore_dashes ? () : $to =~ /^(\w+)(?:-([^\.]+))?$/;
    ($op, $name) = $to =~/^(?:([^\.]+)\.)?([\w-]+)$/
	unless $name;
    $self->throw_die('NOT_FOUND', {
	entity => $to,
        message => 'invalid recipient',
    }) unless defined($name);
    _trace('name: ', $name, ' op: ', $op, ' plus_tag: ', $plus_tag,
	' domain: ', $domain)
	if $_TRACE;
    return ($name, $op, $plus_tag, $domain);
}

sub _email_alias {
    my($self) = @_;
    my($req) = $self->req;
    my($realm, $op, $plus_tag, $domain) = $self->parse_recipient;
    Bivio::UI::Facade->setup_request($domain, $req);
    return (undef, $realm, $op, $plus_tag)
	unless $req->get('task')->unsafe_get_redirect('email_alias_task', $req)
	and my $new = $self->new_other('EmailAlias')
	->incoming_to_outgoing($self->get('recipient'));
    if ($_E->is_valid($new)) {
	_trace($self->get('recipient'), ' => ', $new) if $_TRACE;
	$self->internal_put_field(recipient => $new);
	return 'email_alias_task';
    }
    $self->internal_put_field(recipient => $_E->join_parts($new, $domain));
    return (undef, $self->parse_recipient);
}

sub _from_email {
    my($from) = @_;
    ($from) = $from && $_A->parse($from);
    return $from && lc($from);
}

sub _ignore {
    my($self, @ops) = @_;
    foreach my $op (@ops) {
	next
	    unless my $which = $op->($self);
	$_F->write(
	    $_FP->join(
		'MailReceiveDispatchForm',
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
    return undef
	unless $rml->unsafe_load_this_or_first
	&& _ignore_duplicate_threshold(
	    $rml->get('RealmFile.modified_date_time'));
#TODO: Should decode body
    return $_I->new($rml->get_rfc822)->get_body
	eq $self->get('mail_incoming')->get_body
        ? 'duplicate' : undef;
}

sub _ignore_duplicate_threshold {
    my($prev) = @_;
    return $_DT->compare(
	$_DT->add_seconds($prev, $_ONE_HOUR_SECONDS),
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
#TODO: Couple with Mail.Common
    return $self->get('mail_incoming')->get('header')
	=~ /^X-Bivio-Forwarded:\s*(\d*)/im
	&& $1 > 3 ? 'too-many-forwards' : undef;
}

sub _ignore_spam {
    my($self) = @_;
    return $_CFG->{filter_spam}
	&& $self->get('mail_incoming')->get('header') =~ /^X-Spam-Flag:\s*Y/im
	? 'spam' : undef;
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

sub _task {
    my($self, $op) = @_;
    my($req) = $self->req;
    $op ||= '';
    $self->throw_die('NOT_FOUND', {
	entity => $op,
        message => 'operation is invalid',
    }) unless $op =~ /^[-\w]*$/;
    return $_TASK->unsafe_get_from_uri(
	$_TEXT->get_value('MailReceiveDispatchForm.uri_prefix', $req) . $op,
	$req->get('auth_realm')->get('type'),
	$req
    ) || $self->throw_die('NOT_FOUND', {
	entity => $op,
	message => 'task not found',
    });
}

1;
