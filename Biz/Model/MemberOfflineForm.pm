# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MemberOfflineForm;
use strict;
$Bivio::Biz::Model::MemberOfflineForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::MemberOfflineForm::VERSION;

=head1 NAME

Bivio::Biz::Model::MemberOfflineForm - Take self or other member offline

=head1 SYNOPSIS

    use Bivio::Biz::Model::MemberOfflineForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::MemberOfflineForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MemberOfflineForm> Takes a member offline relative to a
club (they remain a bivio user).  If a user takes themself offline, they are
redirected to a confirmation page in the realm my-site.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Take user offline.  If user takes self offline, redirect to a confirmation page
(since can't go back to UserList).

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;

    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $list->set_cursor(0);

    # Note: if user hacks the query, may try to delete sole admin.  Will
    # die in RealmUser code.

    # Take the user offline
    my($realm_user) = $list->get_model('RealmUser');
    my($selected_user_id) = $realm_user->get('user_id');
    $realm_user->take_offline;
    $realm_user->delete;

    # If took self offline, display confirmation page
    if ($selected_user_id == $req->get('auth_user_id')) {
	$req->client_redirect(
		Bivio::Agent::TaskId::MEMBER_OFFLINE_CONFIRMATION,
		Bivio::Auth::Realm->new($selected_user_id, $req));
	# DOES NOT RETURN
    }
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

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
