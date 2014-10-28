# Copyright (c) 2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmDropDownList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_RT) = b_use('Auth.RealmType');
my($_REQUIRED_ROLE_GROUP) = b_use('Model.UserForumList')
    ->REQUIRED_ROLE_GROUP;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
	$self->field_decl(
	    primary_key => [
		[qw(RealmOwner.name)],
	    ],
            other => [
                [qw(link Text)],
            ],
	    undef, 'NOT_NULL',
	),
        other_query_keys => ['realm_types', 'task_id'],
    });
}

sub internal_load_rows {
    my($self, $query, $stmt, $where, $params, $sql_support) = @_;
    my($req) = $self->req;
    my($realm_types) = [map($_RT->from_any($_), @{$query->get('realm_types')})];
    my($task_id) = $query->get_or_default(
        task_id => $realm_types->[0]->get_name . '_HOME'
    );
    return [map(+{
        'RealmOwner.name' => $_,
        link => $req->format_stateless_uri({
            realm => $_,
            task_id => $task_id,
        }),
    }, @{$self->req->map_user_realms(
	sub {shift->{'RealmOwner.name'}},
	{
	    !@$realm_types ? ()
	        : ('RealmOwner.realm_type' => $realm_types),
	    roles => $_REQUIRED_ROLE_GROUP,
	},
    )})];
}

1;
