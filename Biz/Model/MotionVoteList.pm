# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionVoteList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
#my($_IDI) = __PACKAGE__->instance_data_index;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
	primary_key => [[qw(MotionVote.user_id Email.realm_id)]],
	order_by => [
	    'MotionVote.vote',
	    'Email.email',
	],
#         other => [
# 	    'RealmUser.creation_date_time',
# 	],
	auth_id => ['MotionVote.realm_id'],
    });
}

# sub internal_post_load_row {
#     my($self, $row) = @_;
#     my($fields) = $self->[$_IDI] ||= {};
#     my($role) = lc($row->{'RealmUser.role'}->get_name);
#     my($r) = $fields->{$row->{'RealmUser.user_id'}} ||= $row;
#     $r->{$role} = 1;
#     return 0
# 	if $r ne $row;
#     return 1;
# }

1;
