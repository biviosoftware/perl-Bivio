# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::UserRealmList;
use strict;
$Bivio::Biz::Model::UserRealmList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::UserRealmList::VERSION;

=head1 NAME

Bivio::Biz::Model::UserRealmList - a list of realms to which a user belongs

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserRealmList;
    Bivio::Biz::Model::UserRealmList->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::UserRealmList::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserRealmList> finds the realms to which a user
belongs.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="find_row_by_type"></a>

=head2 find_row_by_type(Bivio::Auth::RealmType type) : Bivio::Biz::Model::UserRealmList

Sets the cursor by I<type> and returns self or returns undef.

=cut

sub find_row_by_type {
    my($self, $type) = @_;
    return $self->do_rows(sub {$self->get('RealmOwner.realm_type') != $type})
	->has_cursor ? $self : undef;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	can_iterate => 1,
	other => [qw(
            RealmOwner.name
	    RealmUser.role
	    RealmOwner.realm_type
            RealmOwner.display_name
	), {
	    name => 'roles',
	    type => 'Array',
	    constraint => 'NONE',
	}],
	primary_key => [
	    [qw(RealmUser.realm_id RealmOwner.realm_id)],
	],
	auth_id => ['RealmUser.user_id'],
    };
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

Return only one row per user/realm.  Collect roles into seperate attribute.

=cut

sub internal_load_rows {
    my($self) = @_;
    my($rows) = shift->SUPER::internal_load_rows(@_);
    my($roles) = {};
    return [
	grep({_internal_post_load_row($_, $roles)}
	    @$rows),
    ];
}

#=PRIVATE METHODS

# _internal_post_load_row() : 
#
# Gather multiple realm roles into a single row record.
#
sub _internal_post_load_row {
    my($row, $roles) = @_;

    if (exists($roles->{$row->{'RealmUser.realm_id'}})) {
	push(@{$roles->{$row->{'RealmUser.realm_id'}}},
	    $row->{'RealmUser.role'});
	return 0;
    }
    else {
	$row->{roles} =
	    $roles->{$row->{'RealmUser.realm_id'}} =
		[$row->{'RealmUser.role'}];
	return 1;
    }
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
