# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
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

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok() : boolean

Unpacks and stores an incoming mail message.
Requires form fields: client_addr, recipient, message.

Sets realm, user, and server_redirects to task.

User is set from From: or Apparently-From:, in that order.

op then maps to a URI:

   Bivio::UI::Text->get_value('MailReceiveDispatchForm.uri_prefix') . $op

I<op> must contain only \w and dashes (-).

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    # All this state must be durable
    Bivio::Type::UserAgent->MAIL->execute($req);
    $req->put_durable(
	client_addr => $self->get('client_addr'),
	'Model.' . $self->simple_package_name => $self,
    );
    my($name, $op) = $self->parse_recipient;
    _set_realm($self, $name);
    my($copy) = ${$self->get('message')->{content}};
    my($parser) = Bivio::Ext::MIMEParser->parse_data(\$copy);
    $self->internal_put_field(mime_parser => $parser);
    $self->internal_put_field(task_id => _task($self, $op));
    $self->internal_put_field(from_email =>
	_from_email($parser->head->get('from')
	    || $parser->head->get('apparently-from')));
    _trace($self->get('from_email'), ' ', $self->get('task_id')) if $_TRACE;
    Bivio::Biz::Model->get_instance('UserLoginForm')->execute($req, {
	login => $self->internal_get_login,
    });
    # Should not return, but always put in a return just in case
    $req->server_redirect($self->get('task_id'));
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
	],
    });
}

=for html <a name="parse_recipient"></a>

=head2 parse_recipient() : array

Returns (realm, op) from recipient.  I<op> may be undef.

Two addresses are parsed:

   op.realm
   realm-op

=cut

sub parse_recipient {
    my($self) = @_;
    my($to) = lc($self->get('recipient'));
    my($name, $op) = $to =~ /^(\w+)(?:-([^\.]+))?$/;
    ($op, $name) = $to =~/^(?:(.+)\.)(\w+)$/
	unless $name;
    _trace('name: ', $name, ' op: ', $op) if $_TRACE;
    return ($name, $op);
}

#=PRIVATE SUBROUTINES

# _from_email(string from)
#
# Parses from_email
#
sub _from_email {
    my($from) = @_;
    ($from) = $from && Bivio::Mail::Address->parse($from);
    return $from && lc($from);
}

# _set_realm(self, string name)
#
# Validates incoming realm is correct.
#
sub _set_realm {
    my($self, $name) = @_;
    my($req) = $self->get_request;
    my($realm) = Bivio::Biz::Model->new($req, 'RealmOwner')
	->unauth_load_or_die({
	    name => $name,
	});
    $self->throw_die('NOT_FOUND', {
	entity => $realm,
        message => 'cannot mail to a default realm or offline user',
    }) if $realm->is_default || $realm->is_offline_user;
    $req->set_realm($realm);
    return;
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
    }) unless $op =~ /^[-\w]+$/;
    return Bivio::UI::Task->unsafe_get_from_uri(
	Bivio::UI::Text->get_value('MailReceiveDispatchForm.uri_prefix', $req)
	. $op,
	$req->get('auth_realm')->get('type'),
	$req)
	|| $self->throw_die('NOT_FOUND', {
	    entity => $op,
	    message => 'task not found',
	});
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
