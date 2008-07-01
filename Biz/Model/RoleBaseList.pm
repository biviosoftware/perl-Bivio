# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RoleBaseList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	can_iterate => 0,
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
