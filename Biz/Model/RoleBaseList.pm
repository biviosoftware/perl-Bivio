# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RoleBaseList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PAGE_SIZE) = b_use('Type.PageSize')->get_default
    * b_use('Auth.Role')->get_overlap_count;
my($_LOAD_ALL_SIZE) = __PACKAGE__->SUPER::LOAD_ALL_SIZE
    * b_use('Auth.Role')->get_overlap_count;

sub LOAD_ALL_SIZE {
    return $_LOAD_ALL_SIZE;
}

sub PAGE_SIZE {
    return $_PAGE_SIZE;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	can_iterate => 0,
	version => 1,
	other => [{
	    name => 'roles',
	    type => 'Array',
	    constraint => 'NONE',
	}],
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($pk) = $self->get_info('primary_key_names');
    $self->die('must be single-valued primary_key')
	unless @$pk == 1;
    $pk = $pk->[0];
    my($roles) = {};
    return [grep(
	push(
	    @{$_->{roles} = ($roles->{$_->{$pk}} ||= [])},
	    $_->{'RealmUser.role'}
	) == 1,
	@{shift->SUPER::internal_load_rows(@_)},
    )];
}

1;
