# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmUserList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LOAD_ALL_SEARCH_STRING {
    # : string
    # Returns string used for load all.
    return 'All';
}

sub internal_initialize {
    # (self) : hash_ref
    # Returns config
    return {
	version => 1,
	can_iterate => 1,
	order_by => [
	    'User.last_name',
	    'User.first_name',
	    'User.middle_name',
	],
        primary_key => ['User.user_id'],
	other => [
	    {
		name => 'display_name',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

sub internal_post_load_row {
    # (self, hash_ref) : boolean
    # Format display_name.
    my($self, $row) = @_;
    $row->{display_name} = Bivio::Biz::Model->get_instance('User')
        ->concat_last_first_middle(
	    @{$row}{map({"User.$_"} qw(last_name first_name middle_name))});
    return 1;
}

sub internal_prepare_statement {
    # (self, SQL.Statement, SQL.ListQuery) : undef
    # Narrow the search of users by last name.
    my($self, $stmt, $query) = @_;
    my($search) = $query->get('search');

    return unless $search;

    if ($search eq $self->LOAD_ALL_SEARCH_STRING) {
#TODO: Why is this here?
	$query->put(count => $self->LOAD_ALL_SIZE);
    }
    elsif ($search =~ /^\d+$/) {
	$stmt->where(['User.user_id', [$search]]);
    }
    else {
	$stmt->where($stmt->LIKE('User.last_name_sort', lc($search) . '%'));
    }

    return;
}

1;
