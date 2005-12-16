# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumUserList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub LOAD_ALL_SIZE {
    return 1000;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
	primary_key => [['RealmUser.user_id', 'Email.realm_id']],
	order_by => [
	    'Email.email',
	    'RealmUser.role',
	],
	other => $self->internal_initialize_local_fields(
	    [qw(administrator mail_recipient file_writer)],
	    Boolean => 'NOT_NULL',
	),
	auth_id => ['RealmUser.realm_id'],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    my($fields) = $self->[$_IDI] ||= {};
    my($role) = lc($row->{'RealmUser.role'}->get_name);
    my($r) = $fields->{$row->{'RealmUser.user_id'}} ||= $row;
    $r->{$role} = 1;
    return 0
	if $r ne $row;
    foreach my $x (qw(administrator mail_recipient file_writer)) {
	$r->{$x} ||= 0;
    }
    return 1;
}

1;
