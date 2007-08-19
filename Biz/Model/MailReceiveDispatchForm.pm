# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailReceiveDispatchForm;
use strict;
$Bivio::Biz::Model::MailReceiveDispatchForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::MailReceiveDispatchForm::VERSION;

=head1 NAME

Bivio::Biz::Model::MailReceiveDispatchForm - redirect to realm/task based on recipient

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::MailReceiveDispatchForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MailReceiveBaseForm>

=cut

use Bivio::Biz::Model::MailReceiveBaseForm;
@Bivio::Biz::Model::MailReceiveDispatchForm::ISA = ('Bivio::Biz::Model::MailReceiveBaseForm');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MailReceiveDispatchForm> dispatches incoming
mail to realm/task based on incoming recipient.  See L<execute|"execute">.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Ext::MIMEParser;
use Bivio::Mail::Address;
use Bivio::UI::Task;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_E) = Bivio::Type->get_instance('Email');
Bivio::IO::Config->register(my $_CFG = {
    ignore_dashes_in_recipient => 0,
});

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok() : boolean

Unpacks and stores an incoming mail message.
Requires form fields: client_addr, recipient, message.

Sets facade, realm, user, and server_redirects to task.

User is set from From: or Apparently-From:, in that order.

op then maps to a URI:

   Bivio::UI::Text->get_value('MailReceiveDispatchForm.uri_prefix') . $op

I<op> must contain only \w and dashes (-).

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
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
    $self->internal_put_field(from_email =>
	_from_email(
	    $parser->head->get('from')
	    || $parser->head->get('apparently-from')));
    _trace($self->get('from_email'), ' ', $self->get('task_id')) if $_TRACE;
    Bivio::Biz::Model->get_instance('UserLoginForm')->execute($req, {
	login => $self->internal_get_login,
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

=for html <a name="internal_get_login"></a>

=head2 internal_get_login() : string

Returns the value to be passed to I<UserLoginForm.login> before the server
redirect in L<execute_ok|"execute_ok">.  All other fields are initialized at
time of call.  May return C<undef> (no login).

=cut

sub internal_get_login {
    my($self) = @_;
    # We must load the email explicitly, because we won't want the
    # general check in UserLoginForm which strips the domain and
    # checks the login.  Also, we need to handle the case where
    # the user doesn't exist.
    my($email) = Bivio::Biz::Model->new($self->get_request, 'Email');
    return $email->unauth_load({email => $self->get('from_email')})
	? $email->get('realm_id') : undef;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

=cut

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

=for html <a name="internal_set_realm"></a>

=head2 internal_set_realm(string realm)

Sets I<realm> or throws not_found.

=cut

sub internal_set_realm {
    my($self, $realm) = @_;
    $realm = ref($realm) ? $realm
	: $self->new_other('RealmOwner')
	->unauth_load_by_id_or_name_or_die($realm);
    $self->throw_die('NOT_FOUND', {
	entity => $realm,
        message => 'cannot mail to a default realm or offline user',
    }) if $realm->is_default || $realm->is_offline_user;
    $self->get_request->set_realm($realm);
    return;
}

=for html <a name="parse_recipient"></a>

=head2 parse_recipient(boolean ignore_dashes) : array

Returns (realm, op, plus_tag, domain) from recipient.  I<op> may be undef.
I<realm> may be a Model.RealmOwner, name, or realm_id.  Dies with NOT_FOUND
if recipient not syntactically valid.

Two addresses are parsed:

   op.realm+plus_tag@domain
   realm-op+plus_tag@domain  (only if !$ignore_dashes)

Where +plus_tag is like sendmail style +anything after the address.  You don't
need +plus_tag.

=cut

sub parse_recipient {
    my($self, $ignore_dashes) = @_;
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

#=PRIVATE SUBROUTINES

# _email_alias()
sub _email_alias {
    my($self) = @_;
    my($req) = $self->get_request;
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

# _ignore_email()
sub _ignore_email {
    my($self) = @_;
    my($req) = $self->get_request;
    return $req->get('task')->unsafe_get_redirect('ignore_task', $req)
	&& $_E->is_ignore($self->get('recipient')) ? 'ignore_task' : undef;
}

# _from_email(string from)
#
# Parses from_email
#
sub _from_email {
    my($from) = @_;
    ($from) = $from && Bivio::Mail::Address->parse($from);
    return $from && lc($from);
}

# _task(self, string op) : Bivio::Agent::TaskId
#
# Returns the task for the op.
#
sub _task {
    my($self, $op) = @_;
    my($req) = $self->get_request;
    $op ||= '';
    $self->throw_die('NOT_FOUND', {
	entity => $op,
        message => 'operation is invalid',
    }) unless $op =~ /^[-\w]*$/;
    return Bivio::UI::Task->unsafe_get_from_uri(
	Bivio::UI::Text->get_value('MailReceiveDispatchForm.uri_prefix', $req)
	. $op,
	$req->get('auth_realm')->get('type'),
	$req
    ) || $self->throw_die('NOT_FOUND', {
	entity => $op,
	message => 'task not found',
    });
}

=head1 COPYRIGHT

Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
