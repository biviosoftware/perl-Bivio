# Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForbiddenForm;
use strict;
$Bivio::Biz::Model::ForbiddenForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ForbiddenForm::VERSION;

=head1 NAME

Bivio::Biz::Model::ForbiddenForm - handles default forbidden

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::ForbiddenForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::ForbiddenForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ForbiddenForm>

=cut

=head1 TASK ATTRIBUTES

=over 4

=head1 require_explicit_su : boolean

If true for executing task, will not try to auto-logout super users.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Called when a FORBIDDEN expection is thrown.  Context tells us about the
calling realm.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    my($auth_user, $agent) = $req->get('auth_user', 'Type.UserAgent');
    my($reply) = $req->get('reply');
    return 'next'
	unless $agent->is_browser;
    $req->server_redirect($req->get_nested('task', 'login_task'))
	unless $auth_user;
    return 'next'
	if $req->get('task')->unsafe_get('require_explicit_su');
    my($c) = $self->unsafe_get_context;
    my($task) = $c->get('unwind_task');
    $req->set_realm($c->get('realm'));
    if ($req->is_substitute_user) {
	Bivio::Biz::Action->get_instance('UserLogout')->execute($req);
	$self->internal_redirect_next
	    if $req->task_ok($task);
    }
    if ($req->is_super_user && !$req->get('auth_realm')->is_default) {
	Bivio::Biz::Model->get_instance('AdmSubstituteUserForm')->execute(
	    $req, {
		login => $req->get_nested(qw(auth_realm owner_name)),
	    }
	);
	$self->internal_redirect_next
	    if $req->task_ok($task);
    }
    return 'next';
}

=for html <a name="execute_unwind"></a>

=head2 execute_unwind()

Unwinds another level to the previous task.  Called after a successful login or
su.

=cut

sub execute_unwind {
    my($self) = @_;
    # Don't redirect too many times
    my($rc) = ($self->unsafe_get('redirect_count') || 0) + 1;
    $self->internal_put_field(redirect_count => $rc);
    return $rc < 2 ? $self->internal_redirect_next : 'forbidden_task';
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Config

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	require_context => 1,
	hidden => [
	    {
		name => 'redirect_count',
		type => 'Integer',
		constraint => 'NONE',
	    },
	],
    });
}

#=PRIVATE SUBROUTINES

# _really_forbidden(self) : any
#
# Returns forbidden_task or exists with forbidden status.
#
sub _really_forbidden {
    my($self) = @_;
    my($req) = $self->get_request;
    return 'forbidden_task'
	if $req->get('task')->unsafe_get('forbidden_task');
    $req->get('reply')->set_http_status(
	Bivio::Ext::ApacheConstants->FORBIDDEN
    ) if $req->get('reply')->can('set_http_status');
}

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
