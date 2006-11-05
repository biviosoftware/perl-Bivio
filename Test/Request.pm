# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Request;
use strict;
$Bivio::Test::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Request::VERSION;

=head1 NAME

Bivio::Test::Request - manages requests for tests

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Request;

=cut

=head1 EXTENDS

L<Bivio::Agent::Job::Request>

=cut

use Bivio::Agent::Job::Request;
@Bivio::Test::Request::ISA = ('Bivio::Agent::Job::Request');

=head1 DESCRIPTION

C<Bivio::Test::Request> manages requests for tests.  Simply importing creates a
new request running in general realm.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Type::DateTime;
use Bivio::UI::Task;
# For convenience
use Bivio::Test;
use Bivio::Test::Bean;
use Bivio::Test::Reply;
use Bivio::ShellUtil;
use Socket ();

#=VARIABLES
my($_MSG_QUEUE_ATTR) = __PACKAGE__ . '.msg_queue';

=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::Test::Request

Same as L<get_current_or_new|"get_current_or_new">.

TODO: Probably should be deprecated.

=cut

sub get_instance {
    return shift->get_current_or_new(@_);
}

=for html <a name="new_unit"></a>

=head2 static new_unit(string class_name, string method, string args) : self

Creates new instance of self, unless one already exists iwc dies.

=cut

sub new_unit {
    my($proto, $class_name, $method, @args) = @_;
    Bivio::Die->die('request already exists: ', $proto->get_current)
        if $proto->get_current;
    $method ||= 'get_instance';
    return $proto->$method(@args)->put(class_name => $class_name);
}

=head1 METHODS

=cut

=for html <a name="capture_mail"></a>

=head2 capture_mail() : self

Captures mail from L<Bivio::Mail::Outgoing|Bivio::Mail::Outgoing> using
Mock object.

=cut

sub capture_mail {
    my($self) = @_;
    $self->put($_MSG_QUEUE_ATTR => []);
    Bivio::IO::ClassLoader->simple_require('Test::MockObject');
    foreach my $m (qw(
        Bivio::Mail::Outgoing
        Bivio::Mail::Common
    )) {
	Bivio::IO::ClassLoader->simple_require($m);
	Test::MockObject->fake_module($m,
	    map({
		$_ => sub {
		    push(@{$self->get($_MSG_QUEUE_ATTR)},
			shift->as_string);
		    return;
		};
	    } qw(send enqueue_send)),
	);
    }
    return $self;
}

=for html <a name="client_redirect"></a>

=head2 client_redirect(...)

Only does something if ignore_client_redirect is set on self.

=cut

sub client_redirect {
    return shift->SUPER::client_redirect(@_)
	unless $_[0]->unsafe_get('ignore_client_redirect');
    my($self, $named) =  shift->internal_get_named_args(
	ref($_[0]) && (ref($_[0]) ne 'HASH' || $_[0]->{task_id})
	    ? [qw(task_id realm query path_info no_context require_context)]
	    : [qw(uri query no_context)],
	\@_,
    );
    $self->clear_nondurable_state;
    $self->put_durable(%$named);
    return;
}

=for html <a name="commit"></a>

=head2 commit()

=cut

sub commit {
    return Bivio::Agent::Task->commit(shift(@_));
}

=for html <a name="execute_task"></a>

=head2 static execute_task(any task_id, hash_ref req_attrs) : array_ref

Executes I<task_id> in the context of a fully initialized instance.
I<req_attrs> allows you to add any configuration, e.g. query.

Returns an array_ref with Reply output string reference followed by
any messages queued by the request.

=cut

sub execute_task {
    my($self) = shift->initialize_fully(@_);
    $self->capture_mail;
    $self->get('task')->execute($self);
    my($o) = $self->get('reply')->get_output;
    return [$o ? $$o : undef, @{$self->unsafe_get_captured_mail || []}];
}

=for html <a name="format_http_toggling_secure"></a>

=head2 format_http_toggling_secure() : string

Nop.

=cut

sub format_http_toggling_secure {
    my($self) = @_;
    return '';
}

=for html <a name="get_current_or_new"></a>

=head2 static get_current_or_new() : Bivio::Agent::Request

Returns
L<Bivio::Agent::Request::get_current|Bivio::Agent::Request/"get_current"> or a
new instance of this class, which is set to current.

=cut

sub get_current_or_new {
    my($proto) = @_;
    my($self) = $proto->get_current;
    return $self
	if $self;
    $self = $proto->new({
	auth_id => undef,
	auth_user_id => undef,
	task_id => Bivio::Agent::TaskId->SHELL_UTIL,
	timezone => Bivio::Type::DateTime->timezone,
	is_secure => 0,
    })->put(
	reply => Bivio::Test::Reply->new,
    );
    $self->set_realm(undef);
    $self->set_user(undef);
    return $self;
}

=for html <a name="get_form"></a>

=head2 get_form() : hash_ref

Returns value of I<form> key.

=cut

sub get_form {
    return shift->unsafe_get('form');
}

=for html <a name="initialize_fully"></a>

=head2 static initialize_fully(string task_id, hash_ref req_attrs) : self

Initializes L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher> fully with
I<task_id> or with the task_id already on the request (defaults to SHELL_UTIL
if task_id is not specified and not found on the request).

=cut

sub initialize_fully {
    my($self) = shift(@_);
    $self = $self->get_instance unless ref($self);
    my($task_id, $req_attrs) = @_;
    ($req_attrs ||= {})->{task_id} = Bivio::Agent::TaskId->from_any(
	$task_id || $self->unsafe_get('task_id') || 'SHELL_UTIL');
    Bivio::IO::ClassLoader->simple_require(
	'Bivio::Agent::Dispatcher')->initialize;
    $self->put(%$req_attrs)->setup_all_facades;
    Bivio::Die->die(
	'facade not fully initialized; this method must be called before'
	. ' any setup_facade or Bivio::ShellUtil->initialize_ui'
    ) unless Bivio::UI::Facade->is_fully_initialized;
    $self->put_durable(uri => $self->format_uri)
        if Bivio::UI::Task->has_uri($self->get('task_id'), $self);
    return $self;
}

=for html <a name="is_test"></a>

=head2 is_test() : boolean

Return value of is_test attribute or SUPER::is_test if not defined.

=cut

sub is_test {
    my($self) = @_;
    return $self->get_or_default('is_test', shift->SUPER::is_test(@_));
}

=for html <a name="put_form"></a>

=head2 put_form(Bivio::Biz::FormModel form, hash_ref fields) : self

Converts I<fields> to names in I<form>.  Then puts hash_ref of new fields on
result.  Converts to literal any values, which will need to be parsed.

=cut

sub put_form {
    my($self, $form, $fields) = @_;
    return $self->put(form => {
	$form->VERSION_FIELD => $form->get_info('version'),
	map({
	    my($f) = $_;
	    # There are sometimes junk fields in fields of form, e.g.
	    # ListFormModel fields.
	    defined($form->get_field_name_for_html($f))
	        ? ($form->get_field_name_for_html($f) =>
		    $form->get_field_type($f)->to_literal($fields->{$f}))
	        : ();
	} keys(%$fields)),
    });
}

=for html <a name="run_unit"></a>

=head2 static run_unit(array_ref cases)

Calls L<Bivio::Test::unit|Bivio::Test/"unit">.

=cut

sub run_unit {
    shift;
    return Bivio::Test::Unit->run_unit(@_);
}

=for html <a name="set_realm_and_user"></a>

=head2 static set_realm_and_user(any realm, any user) : self

Sets the realm and user.  See
L<Bivio::ShellUtil|Bivio::ShellUtil> for details.

If called statically, will call L<get_instance|"get_instance"> first.

=cut

sub set_realm_and_user {
    my($self) = shift;
    $self = $self->get_instance unless ref($self);
    Bivio::ShellUtil->set_realm_and_user(@_);
    return $self;
}

=for html <a name="setup_all_facades"></a>

=head2 setup_all_facades() : self

Same as L<setup_facade|"setup_facade">, but initializes all facades.

=cut

sub setup_all_facades {
    my($self) = shift->setup_http;
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Dispatcher')
	->initialize(0);
    return $self->setup_facade;
}

=for html <a name="setup_facade"></a>

=head2 setup_facade() : self

Sets up the default facade.  Sets up http unless already setup.

=cut

sub setup_facade {
    my($self) = shift->setup_http;
    Bivio::ShellUtil->initialize_ui;
    return $self;
}

=for html <a name="setup_http"></a>

=head2 static setup_http(string cookie_class) : self

Sets up self to look like an http request.  You probably don't need
to pass I<cookie_class>.  See UserLoginForm.t and
PersistentCookie.t for examples.

If called statically, will call L<get_instance|"get_instance"> first.

Redirects are ignored.

=cut

sub setup_http {
    my($self, $cookie_class) = @_;
    $self = $self->get_instance unless ref($self);
    return $self if $self->unsafe_get('r');
    $self->ignore_redirects(1);
    # What's required by bOP infrastructure.
    Bivio::Type::UserAgent->BROWSER_HTML4->execute($self, 1);
    my($r) = Bivio::Test::Bean->new;
    $self->put_durable(r => $r);
    my($c) = Bivio::Test::Bean->new;
    $r->connection($c);
    $c->remote_ip('127.0.0.1');
    $c->local_addr(
	Socket::pack_sockaddr_in(80, Socket::inet_aton($c->remote_ip)));
    $c->remote_addr($c->local_addr);
    $r->method('GET');
    $r->server(Bivio::Test::Bean->new);
    $r->uri('/');
    Bivio::IO::Config->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    delegates => {
		'Bivio::Agent::HTTP::Cookie' =>
		    $cookie_class || 'Bivio::Delegate::NoCookie',
	    },
	},
    });
    # Cookie overwrites, so we have to reset below
    my($user) = $self->get('auth_user');
    $self->put_durable(
	uri => '/',
	path_info => $self->unsafe_get('path_info'),
	query => $self->unsafe_get('query'),
	cookie => Bivio::Agent::HTTP::Cookie->new($self, $r),
	client_addr => $c->remote_ip,
    );
    # Sets user after cookie clears it
    if ($user) {
	if ($user->is_default) {
	    $self->set_user($user);
	}
	else {
	    Bivio::Biz::Model->get_instance('UserLoginForm')->execute($self, {
		realm_owner => $user,
	    });
	}
    }
    Bivio::IO::ClassLoader->simple_require('Bivio::Biz::Action')
	->get_instance('JobBase')->set_sentinel($self);
    return $self;
}

=for html <a name="unsafe_get_captured_mail"></a>

=head2 unsafe_get_captured_mail() : array_ref

Returns captured mail and clears queue.

Returns empty array_ref if no queue mail.

Returns undef if L<capture_mail|"capture_mail"> hasn't been called.

=cut

sub unsafe_get_captured_mail {
    my($self) = @_;
    my($res) = $self->unsafe_get($_MSG_QUEUE_ATTR);
    return undef
	unless $res;
    $self->put($_MSG_QUEUE_ATTR => []);
    return $res;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
