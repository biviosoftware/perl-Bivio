# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AdmSubstituteUserForm;
use strict;
$Bivio::Biz::Model::AdmSubstituteUserForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::AdmSubstituteUserForm::VERSION;

=head1 NAME

Bivio::Biz::Model::AdmSubstituteUserForm - allows general admin to become other user

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::AdmSubstituteUserForm;
    Bivio::Biz::Model::AdmSubstituteUserForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::AdmSubstituteUserForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::AdmSubstituteUserForm> allows a general admin to
become another user.
Sets the special cookie value
so we know the we are operating in super-user mode.

=cut

=head1 CONSTANTS

=cut

=for html <a name="SUPER_USER_FIELD"></a>

=head2 SUPER_USER_FIELD : string

Returns the cookie key for the super user value.

=cut

sub SUPER_USER_FIELD {
    return 's';
}

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Perform lookup and su automatically if coming in with query string.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    my($this) = ($req->unsafe_get('query') || {})
	->{Bivio::SQL::ListQuery->to_char('this')};
    return unless $this;
    $self->internal_put_field(login => $this);
    $req->put(query => {});
    return $self->validate_and_execute_ok($self->OK_BUTTON_NAME);
}

=for html <a name="execute_ok"></a>

=head2 execute_ok() : boolean

Logs in the I<realm_owner> and updates the cookie.

=cut

sub execute_ok {
    my($self) = @_;
    # user is validated in internal_pre_execute
    return $self->new_other('UserLoginForm')->substitute_user(
	$self->get('realm_owner'),
	$self->get_request,
    );
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info(
	$self->SUPER::internal_initialize, {
	    version => 1,
	    visible => [
		{
		    name => 'login',
		    type => 'Line',
		    constraint => 'NOT_NULL',
		},
	    ],
	    other => [
		{
		    name => 'realm_owner',
		    type => 'Bivio::Biz::Model::RealmOwner',
		    constraint => 'NONE',
		},
	    ],
	},
    );
}

=for html <a name="internal_pre_execute"></a>

=head2 internal_pre_execute(string method)

Look up the user by email, user_id, or name.

=cut

sub internal_pre_execute {
    my($self, $method) = @_;
    $self->internal_put_field(realm_owner =>
	Bivio::Biz::Model->get_instance('UserLoginForm')
	->validate_login($self)
    ) if $method =~ /execute_ok/;
    return;
}

=for html <a name="su_logout"></a>

=head2 su_logout(Bivio::Agent::Request req) : Bivio::Agent::TaskId

Logout as substitute user, return to super user.
Return next task (if any).

=cut

sub su_logout {
    my($proto, $req) = @_;
    my($su) = $req->get('super_user_id');
    $req->delete('super_user_id');
    $req->get('cookie')->delete($proto->SUPER_USER_FIELD)
	if $req->unsafe_get('cookie');
    my($realm) = Bivio::Biz::Model->new($req, 'RealmOwner');
    Bivio::Biz::Model->get_instance('UserLoginForm')->execute($req, {
	realm_owner => $realm->unauth_load({realm_id => $su})
	    ? $realm : undef,
    });
    _trace($realm) if $_TRACE;
    return $realm->is_loaded
	? $req->get('task')->unsafe_get_attr_as_id('su_task')
	    || Bivio::Agent::TaskId->ADM_SUBSTITUTE_USER : 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
