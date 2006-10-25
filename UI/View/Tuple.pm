# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::View::Tuple;
use strict;
use base 'Bivio::UI::View::Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub slot_type_edit {
    view_put(
	body => vs_list_form(TupleSlotTypeListForm => [
            'TupleSlotTypeListForm.TupleSlotType.label',
            ['TupleSlotTypeListForm.TupleSlotType.type_class' => {
		wf_class => 'Select',
		choices => ['Model.TupleSlotTypeClassList'],
		list_display_field => 'TupleSlotType.label',
		list_id_field => 'TupleSlotType.label',
	    }],
            'TupleSlotTypeListForm.TupleSlotType.default_value',
            'TupleSlotTypeListForm.choice',
        ]),
    );
    return;
}

sub slot_type_list {
    view_put(
	base_tools => TaskMenu([qw(FORUM_TUPLE_SLOT_TYPE_EDIT)]),
	body => vs_paged_list(TupleSlotTypeList => [qw(
	    TupleSlotType.label
	    TupleSlotType.choices
	    TupleSlotType.default_value
	),
	    {
	        column_heading => String(vs_text(
		    'TupleSlotTypeList.list_actions')),
		column_widget => ListActions([
		    [
			vs_text('TupleSlotTypeList.FORUM_TUPLE_SLOT_TYPE_EDIT'),
			'FORUM_TUPLE_SLOT_TYPE_EDIT',
			URI({
			    task_id => 'FORUM_TUPLE_SLOT_TYPE_EDIT',
			    realm => ['RealmOwner.name'],
			    query => ['->format_query', 'THIS_DETAIL'],
			}),
			['RealmOwner.realm_type', '->eq_forum'],
			['RealmOwner.name'],
		    ],
	        ]),
		column_data_class => 'list_actions',
	    },
	]),
    );
    return;
}

1;
