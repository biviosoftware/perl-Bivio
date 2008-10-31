# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmUserList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_NAME_SORT_COLS) = [map("User.${_}_name_sort", qw(last first middle))];
my($_NAME_COLS) = [grep(s/_sort//, @$_NAME_SORT_COLS)];
my($_U) = __PACKAGE__->use('Model.User');
my($_L) = __PACKAGE__->use('Type.Line');

sub LOAD_ALL_SEARCH_STRING {
    return 'All';
}

sub NAME_COLUMNS {
    return [@$_NAME_COLS];
}

sub NAME_SORT_COLUMNS {
    return [@$_NAME_SORT_COLS];
}

sub internal_initialize {
    my($delegator, $stmt, $info) = shift->delegated_args(@_);
    return $delegator->merge_initialize_info(
	$info || $delegator->SUPER::internal_initialize,
	{
	    version => 1,
	    can_iterate => 1,
	    order_by => [
		@{$delegator->NAME_SORT_COLUMNS},
		'Email.email',
	    ],
	    primary_key => [[qw(User.user_id Email.realm_id RealmOwner.realm_id)]],
	    other => [
		@{$delegator->NAME_COLUMNS},
		'Email.want_bulletin',
		'RealmOwner.display_name',
		'RealmOwner.name',
		[
		    'Email.location',
		    [$delegator->get_instance('Email')->DEFAULT_LOCATION],
		],
		{
		    name => 'display_name',
		    type => 'Line',
		    constraint => 'NOT_NULL',
		},
	    ],
	},
    );
}

sub internal_post_load_row {
    my($delegator, $row) = shift->delegated_args(@_);
    $row->{display_name} = $_U->concat_last_first_middle(@{$row}{@$_NAME_COLS});
    return 1;
}

sub internal_prepare_statement {
    my($delegator, $stmt, $query) = shift->delegated_args(@_);
    my($search) = $_L->from_literal($query->get('search'));
    return unless defined($search);
    if ($search eq $delegator->LOAD_ALL_SEARCH_STRING) {
	$query->put(count => $delegator->LOAD_ALL_SIZE);
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
