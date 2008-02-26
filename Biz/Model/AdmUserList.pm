# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmUserList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_NAME_COLS) = [map("User.${_}_name", qw(last first middle))];
my($_U) = __PACKAGE__->use('Model.User');
my($_L) = __PACKAGE__->use('Type.Line');

sub LOAD_ALL_SEARCH_STRING {
    return 'All';
}

sub NAME_SORT_COLUMNS {
    return [@$_NAME_COLS];
}

sub internal_initialize {
    my($self) = @_;
    return {
	version => 1,
	can_iterate => 1,
	order_by => $self->NAME_SORT_COLUMNS,
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
    my($self, $row) = @_;
    $row->{display_name} = $_U->concat_last_first_middle(@{$row}{@$_NAME_COLS});
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($search) = $_L->from_literal($query->get('search'));
    return unless defined($search);
    if ($search eq $self->LOAD_ALL_SEARCH_STRING) {
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
