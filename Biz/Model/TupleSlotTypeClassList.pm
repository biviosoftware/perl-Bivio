# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotTypeClassList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub DEFAULT_LABEL {
    return 'String';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => ['TupleSlotType.tuple_slot_type_id'],
	order_by => ['TupleSlotType.label'],
	other => [
	    'TupleSlotType.type_class',
	    ['TupleSlotType.realm_id',
	         [Bivio::Auth::Realm->get_general->get('id')]],
	],
    });
}

sub is_upgrade {
    my($self, $old, $new) = @_;
    return $old eq $new
	|| $new eq (
	    $self->unsafe_label_to_type_class($self->DEFAULT_LABEL)
	    || $self->die($self->DEFAULT_LABEL, ': missing label'
        )) ? 0 : 1;
}

sub type_class_to_label {
    return shift->find_row_by('TupleSlotType.type_class', shift)
	->get('TupleSlotType.label');
}

sub unsafe_label_to_type_class {
    my($self, $label) = @_;
    return $self->find_row_by('TupleSlotType.label', $label)
	? $self->get('TupleSlotType.type_class') : undef;
}

1;
