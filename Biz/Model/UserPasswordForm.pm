# Copyright (c) 2003-2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserPasswordForm;
use strict;
$Bivio::Biz::Model::UserPasswordForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::UserPasswordForm::VERSION;

=head1 NAME

Bivio::Biz::Model::UserPasswordForm - change user password

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserPasswordForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::UserPasswordForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserPasswordForm>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Updates the password in the database and the cookie.

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->get_instance('UserLoginForm')->execute($req, {
	realm_owner => $req->get_nested(qw(auth_realm owner))
	    ->update_password($self->get('new_password')),
    });
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Return config.

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	@{$self->internal_initialize_local_fields(
	    visible => [
		[old_password => undef, 'NONE'],
		qw(new_password confirm_new_password),
	    ],
	    hidden => [
		[qw(display_old_password  Boolean)],
		[query_password => undef, 'NONE'],
	    ],
	    'Password', 'NOT_NULL',
	)},
    });
}

=for html <a name="internal_pre_execute"></a>

=head2 internal_pre_execute(string method)

Sets the 'display_old_password' field based on if the user is the
super user.

=cut

sub internal_pre_execute {
    my($self, $method) = @_;
    my($req) = $self->get_request;
    my($qp) = $req->unsafe_get_nested(qw(Action.UserPasswordQuery password));
    $self->internal_put_field(query_password => $qp)
	if $qp;
    $self->internal_put_field(old_password => $qp)
	if $qp ||= $self->unsafe_get('query_password');
    $self->internal_put_field(
	display_old_password => $qp || $req->is_substitute_user ? 0 : 1);
    return;
}

=for html <a name="validate"></a>

=head2 validate()

Validates the old password for normal users.
Ensures the new password and confirm password matches.

=cut

sub validate {
    my($self) = @_;
    my($req) = $self->get_request;
    unless ($req->is_substitute_user) {
	return unless $self->validate_not_null('old_password');
	Bivio::IO::Alert->info(
	    $req->get_nested(qw(auth_realm owner password)),
	    ' ', 
	    $self->get('old_password'),
	);

	unless (Bivio::Type::Password->is_equal(
	    $req->get_nested(qw(auth_realm owner password)),
	    $self->get('old_password'),
        )) {
	    $self->internal_put_error(qw(old_password PASSWORD_MISMATCH));
	    return;
	}
    }
    $self->internal_put_error(qw(confirm_new_password CONFIRM_PASSWORD))
        unless $self->in_error
        || $self->get('new_password') eq $self->get('confirm_new_password');
     return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003-2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
