# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel::User;
use strict;
$Bivio::Biz::ListModel::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::ListModel::User - a list of user information

=head1 SYNOPSIS

    use Bivio::Biz::ListModel::User;
    Bivio::Biz::ListModel::User->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::ListModel::User::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::ListModel::User>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::SQL::ListSupport;

#=VARIABLES
my($_SQL_SUPPORT);

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref


=cut

sub internal_initialize {
    $_SQL_SUPPORT = Bivio::SQL::ListSupport->new('user_t, club_user_t',
	['user_t.name',
		'user_t.first_name,user_t.middle_name,user_t.last_name']);
    return [[
	    ['Login Name', Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
	    ['Full Name',
		    Bivio::Biz::FieldDescriptor->lookup('USER_FULL_NAME', 3)]],
	    $_SQL_SUPPORT,
	    ['sort']];
}

=for html <a name="find"></a>

=head2 load(hash query) : boolean

Loads the list given the specified search parameters.

=cut

sub load {
    my($self, %query) = @_;
    my($realm, $club_id) = $self->get_request->get(
	    'auth_owner_id_field', 'auth_owner_id');
    # Sanity check doesn't hurt
    die('attempt to check user in wrong realm')
	    unless $realm eq 'club_id';
#TODO: Fix 1000 here.
    $_SQL_SUPPORT->load($self, $self->internal_get_rows(), 0, 1000,
	    'where club_user_t.club_id=?'
	    .' and club_user_t.user_id=user_t.user_id'
	    .$self->get_order_by(\%query), $club_id);
    return;
}

=for html <a name="get_default_sort_key"></a>

=head2 get_default_sort_key() : string

Returns the sort key to use if no other sorting is specified.

=cut

sub get_default_sort_key {
    return 'name';
}

=for html <a name="get_sort_key"></a>

=head2 get_sort_key(int col) : string

Returns the sorting key for the specified column index.

=cut

sub get_sort_key {
    my($self, $col) = @_;
    return ('name', 'first_name')[$col];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
