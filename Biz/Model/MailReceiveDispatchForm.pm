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

User is set from Reply-To:, From:, Apparently-From:, in that order.
You can forge any address, but we respect the Reply-To: override.

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
    _login($self,
	$parser->head->get('reply-to')
	|| $parser->head->get('from')
        || $parser->head->get('apparently-from'));
    # Should not return, but always put in a return just in case
    $req->server_redirect(_task($self, $op));
    return;
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
    my($name, $op) = $to =~ /^(\w+)(?:-(.+))?$/;
    ($op, $name) = $to =~/^(?:(.+)\.)(\w+)$/
	unless $name;
    _trace('name: ', $name, ' op: ', $op) if $_TRACE;
    return ($name, $op);
}

#=PRIVATE SUBROUTINES

# _login(self, string from)
#
# Asserts user and role.
#
sub _login {
    my($self, $from) = @_;
    my($req) = $self->get_request;
    _trace('from: ', $from) if $_TRACE;
    ($from) = $from && Bivio::Mail::Address->parse($from);
    $self->internal_put_field(from_email => $from && lc($from));
    _trace('from_email: ', $self->get('from_email')) if $_TRACE;
    # We must load the email explicitly, because we won't want the
    # general check in UserLoginForm which strips the domain and
    # checks the login.  Also, we need to handle the case where
    # the user doesn't exist.
    my($email) = Bivio::Biz::Model->new($req, 'Email');
    Bivio::Biz::Model->get_instance('UserLoginForm')->execute($req, {
	login => $email->unauth_load({email => $self->get('from_email')})
	    ? $email->get('realm_id') : undef,
    });
    return;
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
