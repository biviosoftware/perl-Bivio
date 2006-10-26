# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotTypeClassList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub DEFAULT {
    return shift->get_instance('TupleSlotType')->DEFAULT_CLASS;
}

sub find_row_by_class {
    return shift->find_row_by('TupleSlotType.type_class', shift)
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => ['TupleSlotType.tuple_slot_type_id'],
	order_by => ['TupleSlotType.type_class'],
	other => [
	    ['TupleSlotType.realm_id',
	         [Bivio::Auth::Realm->get_general->get('id')]],
	],
    });
}

sub is_upgrade {
    my($self, $old, $new) = @_;
    return $old eq $new || $new eq $self->DEFAULT ? 0 : 1;
}

1;
