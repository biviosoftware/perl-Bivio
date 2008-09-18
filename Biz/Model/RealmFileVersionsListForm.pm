# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileVersionsListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub execute_ok {
    my($self) = @_;
    $self->req->put(query => {
 	ldiff => $self->get('left'),
 	rdiff => $self->get('right'),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'RealmFileVersionsList',
	visible => [
	    map({
		name => $_,
		type => 'PrimaryId',
		constraint => 'NONE',
		in_list => 0,
	    }, qw(left right)),
	],
    });
}

sub internal_initialize_list {
    my($self) = @_;
    my($lm) = shift->SUPER::internal_initialize_list(@_);
    $self->[$_IDI] = (
	@{$lm->map_rows(sub {
	    return shift->get('RealmFile.realm_file_id');
	})},
    );
    $lm->reset_cursor;
    return $lm;
}

1;
