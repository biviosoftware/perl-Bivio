# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::DeleteMemberForm;
use strict;
$Bivio::Biz::Model::DeleteMemberForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::DeleteMemberForm - remove a member from the club

=head1 SYNOPSIS

    use Bivio::Biz::Model::DeleteMemberForm;
    Bivio::Biz::Model::DeleteMemberForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::DeleteMemberForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::DeleteMemberForm> remove a member from the club

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Auth::Role;
use Bivio::Biz::Model::User;
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Redirects to member withdrawal if the selected member has transactions.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;

    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $list->set_cursor(0);
    my($realm_user) = $list->get_model('RealmUser');

    # redirect if the user has accounting transactions
    if ($realm_user->has_transactions) {
	# use a client redirect so the displayed url changes
	$req->client_redirect(
		Bivio::Agent::TaskId::CLUB_ACCOUNTING_MEMBER_WITHDRAWAL(),
		$req->get(qw(auth_realm query)));
    }

    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Deletes the selected guest from the current club.

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;

    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $list->set_cursor(0);

    # shouldn't be able to delete the current user
    if ($list->is_auth_user) {
	$self->internal_put_error('error',
		Bivio::TypeError::CURRENT_USER_DELETE());
	return;
    }
    # don't allow removing a withdrawn member
    if ($list->get('RealmUser.role') == Bivio::Auth::Role::WITHDRAWN()) {
	$self->internal_put_error('error',
		Bivio::TypeError::DELETE_WITHDRAWN_USER());
	return;
    }

    # overwrite any club files/transactions user ids with current user id
    my($realm_user) = $list->get_model('RealmUser');
    # don't transfer the member's k-1
    $realm_user->change_ownership($req->get('auth_user')->get('realm_id'), 0);
    $realm_user->cascade_delete();

    # if the user is a shadow user, then delete the user as well
    if ($list->is_shadow_member) {
	my($user) = Bivio::Biz::Model::User->new($req);
	$user->unauth_load_or_die(user_id => $list->get('RealmUser.user_id'));
	$user->cascade_delete;
    }

#TODO: Need to generalize "delete_this"
    $req->client_redirect($req->get('task')->get('next'),
            undef, $list->format_query(Bivio::Biz::QueryType::ANY_LIST()));
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
