# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailReceiveDispatchForm;
use strict;
use Bivio::Base 'Model.MailReceiveBaseForm';
use Bivio::Ext::MIMEParser;
use Bivio::IO::Trace;
use Bivio::Mail::Address;
use Bivio::UI::Task;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_E) = Bivio::Type->get_instance('Email');
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_MAX_COMPARE_SIZE) = 1000;
Bivio::IO::Config->register(my $_CFG = {
    ignore_dashes_in_recipient => Bivio::IO::Config->if_version(
	5 => sub {1},
	sub {0},
    ),
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
    #    Bivio::UI::Text->get_value('MailReceiveDispatchForm.uri_prefix') . $op
    #
    # I<op> must contain only \w and dashes (-).
    my($req) = $self->req;
    Bivio::Type::UserAgent->MAIL->execute($req, 1);
    $req->put_durable(client_addr => $self->get('client_addr'));
    $self->put_on_request(1);
    my($redirect, $realm, $op, $plus_tag) = _email_alias($self);
    $redirect = _ignore_email($self)
	unless $redirect;
    _trace($redirect) if $_TRACE;
    return {
	method => 'server_redirect',
	task_id => $redirect,
	query => undef,
    } if $redirect;
    $self->internal_set_realm($realm);
    my($copy) = ${$self->get('message')->{content}};
    my($parser) = Bivio::Ext::MIMEParser->parse_data(\$copy);
    $self->internal_put_field(mime_parser => $parser);
    $self->internal_put_field(task_id => _task($self, $op));
    $self->internal_put_field(plus_tag => $plus_tag);
#TODO: Use Mail.Incoming
    $self->internal_put_field(from_email => _from_email(
	$parser->head->get('from') || $parser->head->get('apparently-from')));
    _trace($self->get('from_email'), ' ', $self->get('task_id')) if $_TRACE;
    $self->throw_die('FORBIDDEN', {
	entity => $realm,
        message => 'message missing from email',
    }) unless $self->get('from_email');
    $self->new_other('UserLoginForm')->process({
	login => $self->internal_get_login,
	via_mta => 1,
    });
    if (my $rfid = _detect_mail_loop($self)) {
	if ($req->unsafe_get('auth_user')) {
	    my($rmb) = $self->new_other('RealmMailBounce');
	    $self->internal_put_field(recipient => $rmb->return_path(
		$req->get('auth_user')->get('realm_id'),
		$self->get('from_email'),
		$rfid,
	    ));
	    my($bn, $bo, $bp, $bd) = $self->parse_recipient;
	    $self->internal_put_field(plus_tag => $bp);
	    $self->internal_put_field(task_id => 'USER_MAIL_BOUNCE');
	}
	else {
	    Bivio::IO::Alert->warn(
		$self->get('from_email'),
		': ignoring duplicate message from unknown user',
	    );
	    $self->internal_put_field(task_id => _ignore_task($self, 1));
	}
    }
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
    my($self) = @_;
    # Returns the value to be passed to I<UserLoginForm.login> before the server
    # redirect in L<execute_ok|"execute_ok">.  All other fields are initialized
    # at time of call.  May return C<undef> (no login).
    # We must load the email explicitly, because we won't want the
    # general check in UserLoginForm which strips the domain and
    # checks the login.  Also, we need to handle the case where
    # the user doesn't exist.
    my($email) = $self->new_other('Email');
    return $email->unauth_load({email => $self->get('from_email')})
	? $email->get('realm_id') : undef;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	other => [
	    {
		name => 'mime_parser',
		type => 'String',
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

sub _body {
    my($content) = @_;
    if ((my $start = index($$content, "\n\n")) > 0) {
	$start += 2;
	if ((my $len = length($$content) - $start) > 0) {
	    $len = $_MAX_COMPARE_SIZE
		if $len > $_MAX_COMPARE_SIZE;
	    return substr($$content, $start, $len);
	}
    }
    Bivio::IO::Alert->warn(
	(/Message-Id:\s*(\S+)/)[0],
	': message contains empty body or is not valid RFC822',
    );
    return $content . '';
}

sub _detect_mail_loop {
    my($self) = @_;
    my($rml) = $self->new_other('RealmMailList');
    if ($rml->unsafe_load_this_or_first) {
	my($rf) = $rml->get_model('RealmFile');
	return 0
	    if $_DT->compare($_DT->add_seconds($rf->get('modified_date_time'),
					       $_ONE_HOUR_SECONDS),
			     $_DT->now) == -1;
	my($rfid) = $rf->get('realm_file_id');
	my($last_body) = _body($rf->get_content);
	my($body) = _body($self->get('message')->{content});
	if ($body && $last_body && $body eq $last_body) {
	    Bivio::IO::Alert->warn('Mail loop detected for realm_file_id '
				       . $rfid . ":\n",
				   ${$self->get('message')->{content}});
	    return $rfid
	}
    }
    return 0;
}

sub _email_alias {
    my($self) = @_;
    my($req) = $self->req;
    my($realm, $op, $plus_tag, $domain) = $self->parse_recipient;
    Bivio::UI::Facade->setup_request($domain, $req);
    my($ea) = $self->new_other('EmailAlias');
    return (undef, $realm, $op, $plus_tag)
	unless $req->get('task')->unsafe_get_redirect('email_alias_task', $req)
	&& $ea->unsafe_load({incoming => $self->get('recipient')});
    my($n) = $ea->get('outgoing');
    if ($n =~ /\@/) {
	_trace($self->get('recipient'), ' => ', $n) if $_TRACE;
	$self->internal_put_field(recipient => $n);
	return 'email_alias_task';
    }
    $self->internal_put_field(recipient => "$n\@$domain");
    return (undef, $self->parse_recipient);
}

sub _forwarding_loop {
    my($self) = @_;
    ${$self->get('message')->{content}} =~ /X-Bivio-Forwarded:\s*(\d*)/s;
    Bivio::IO::Alert->warn("Forwarding threshold exceeded, message ignored:\n",
			   ${$self->get('message')->{content}})
	    if $1 && $1 > 3;
    return $1 ? $1 > 3 : 0;
}

sub _from_email {
    my($from) = @_;
    ($from) = $from && Bivio::Mail::Address->parse($from);
    return $from && lc($from);
}

sub _get_body {
    my($self) = @_;
    ${$self->get('message')->{content}} =~ /\n\n(.*)$/s;
    return $1;
}

sub _ignore_email {
    my($self) = @_;
    return _ignore_task($self,
			$_E->is_ignore($self->get('recipient'))
			    || _forwarding_loop($self));
}

sub _ignore_task {
    my($self, $ignore_email) = @_;
    return $self->req->get('task')
	->unsafe_get_redirect('ignore_task', $self->req) && $ignore_email
	    ? 'ignore_task' : undef;
}

sub _task {
    my($self, $op) = @_;
    my($req) = $self->req;
    $op ||= '';
    $self->throw_die('NOT_FOUND', {
	entity => $op,
        message => 'operation is invalid',
    }) unless $op =~ /^[-\w]*$/;
    return Bivio::UI::Task->unsafe_get_from_uri(
	Bivio::UI::Text->get_value('MailReceiveDispatchForm.uri_prefix',
				   $req) . $op,
	$req->get('auth_realm')->get('type'),
	$req
    ) || $self->throw_die('NOT_FOUND', {
	entity => $op,
	message => 'task not found',
    });
}

1;
