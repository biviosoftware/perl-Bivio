# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmUserList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_NAME_SORT_COLS) = [map("User.${_}_name_sort", qw(last first middle))];
my($_NAME_COLS) = [grep(s/_sort//, @$_NAME_SORT_COLS)];
my($_U) = b_use('Model.User');
my($_L) = b_use('Type.Line');

sub LOAD_ALL_SEARCH_STRING {
    return 'All';
}

sub NAME_COLUMNS {
    return [@$_NAME_COLS];
}

sub NAME_SORT_COLUMNS {
    return [@$_NAME_SORT_COLS];
}

sub SUBSTITUTE_USER_FORM {
    return 'AdmSubstituteUserForm';
}

sub can_substitute_user {
    my($self) = @_;
    return $self->new_other($self->SUBSTITUTE_USER_FORM)
	->can_substitute_user($self->get('User.user_id'));
}

sub internal_initialize {
    my(undef, $delegator, $stmt, $info) = shift->delegated_args(@_);
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
		'RealmOwner.display_name',
		'RealmOwner.name',
		{
		    name => 'display_name',
		    type => 'Line',
		    constraint => 'NOT_NULL',
		},
		[
		    'Email.location',
		    [$delegator->get_instance('Email')->DEFAULT_LOCATION],
		],
		'Email.want_bulletin',
	    ],
	},
    );
}

sub internal_post_load_row {
    my(undef, $delegator, $row) = shift->delegated_args(@_);
    $row->{display_name} = $_U->concat_last_first_middle(
	@{$row}{@{$delegator->NAME_COLUMNS}});
    return 1;
}

sub internal_prepare_statement {
    my(undef, $delegator, $stmt, $query) = shift->delegated_args(@_);
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
