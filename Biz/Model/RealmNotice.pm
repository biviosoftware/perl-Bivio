# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmNotice;
use strict;
$Bivio::Biz::Model::RealmNotice::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmNotice::VERSION;

=head1 NAME

Bivio::Biz::Model::RealmNotice - manage realm_notice_t

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmNotice;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmNotice::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmNotice> manages realm_notice_t.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values) : self

Sets I<creation_date_time>, I<realm_id> (auth_id), and
I<at_least_role> (ACCOUNTANT)
if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless $values->{creation_date_time};
    $values->{realm_id} = $self->get_request->get('auth_id')
	    unless $values->{realm_id};
    $values->{at_least_role} = Bivio::Auth::Role::ACCOUNTANT()
	    unless $values->{at_least_role};
    return $self->SUPER::create($values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns configuration.

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_notice_t',
	columns => {
            realm_notice_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
            at_least_role => ['Bivio::Auth::Role', 'NOT_ZERO_ENUM'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
            realm_notice_type => ['RealmNotice', 'NOT_ZERO_ENUM'],
	    template_params => ['Array', 'NONE'],
        },
	auth_id => 'realm_id',
    };
}

=for html <a name="unauth_create_unless_type_exists"></a>

=head2 unauth_create_unless_type_exists(string realm_id, any type, array_ref params, hash_ref values) : self

Creates a notice of I<type> only if one doesn't exist for this realm.
I<params> may be undef.  I<values> may be undef.

=cut

sub unauth_create_unless_type_exists {
    my($self, $realm_id, $type, $params, $values) = @_;
    $values ||= {};
    $values->{realm_id} = $realm_id;
    $values->{realm_notice_type} = Bivio::Type::RealmNotice->from_any($type);
    $values->{template_params} = $params || $params;
    return $self
	    if $self->unauth_load(realm_id => $realm_id,
		    realm_notice_type => $values->{realm_notice_type});
    return $self->create($values);
}

=for html <a name="unauth_delete_by_type"></a>

=head2 unauth_delete_by_type(string realm_id, any type) : boolean

Deletes the notice for I<realm_id> if I<type> exists.  May delete more than
one record.

Returns true if it deleted one or more records.

=cut

sub unauth_delete_by_type {
    my($self, $realm_id, $type) = @_;
    my($it) = $self->unauth_iterate_start('realm_notice_id', {
	realm_id => $realm_id,
	realm_notice_type => Bivio::Type::RealmNotice->from_any($type)
    });
    my($res) = 0;
    while ($self->iterate_next_and_load($it)) {
	$res = 1 if $self->unauth_delete;
    }
    return $res;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
