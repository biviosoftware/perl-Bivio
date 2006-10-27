# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeBase;
use strict;
use base 'Bivio::UI::Facade';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new {
    my(undef, $config) = @_;
    _merge(_cfg_tuple(), $config);
    return shift->SUPER::new(@_);
}

sub _cfg_tuple {
    return !Bivio::Agent::TaskId->unsafe_from_name('FORUM_TUPLE_SLOT_TYPE_LIST') ? {} : {
	Task => [
	    [FORUM_TUPLE_DEF_EDIT => '?/edit-db-schemas'],
	    [FORUM_TUPLE_DEF_LIST => '?/db-schemas'],
	    [FORUM_TUPLE_EDIT => '?/edit-db-record'],
	    [FORUM_TUPLE_HISTORY => '?/db-record-history'],
	    [FORUM_TUPLE_LIST => '?/db-records'],
	    [FORUM_TUPLE_SLOT_TYPE_EDIT => '?/edit-db-type'],
	    [FORUM_TUPLE_SLOT_TYPE_LIST => '?/db-types'],
	    [FORUM_TUPLE_USE_EDIT => '?/edit-db-table'],
	    [FORUM_TUPLE_USE_LIST => '?/db-tables'],
	],
	Text => [
	    [title => [
		FORUM_TUPLE_DEF_EDIT => 'Modify Database Schema',
		FORUM_TUPLE_DEF_LIST => 'Database Schemas',
		FORUM_TUPLE_EDIT =>
		    q{Edit String(['Model.TupleUseList', 'TupleUse.label']); Record},
		FORUM_TUPLE_LIST =>
		    q{String(['Model.TupleUseList', 'TupleUse.label']); Records},
		FORUM_TUPLE_HISTORY =>
		    q{String([qw(Model.TupleUseList TupleUse.label)]); Record#String([qw(Model.TupleList Tuple.tuple_num)]); History},
		FORUM_TUPLE_MAIL_THREAD =>
		    q{String(['Model.TupleUseList', 'TupleUse.label']); Record #String(['Model.Tuple', 'tuple_num']);},
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Modify Database Type',
		FORUM_TUPLE_SLOT_TYPE_LIST => 'Database Types',
		FORUM_TUPLE_USE_EDIT => 'Modify Table',
		FORUM_TUPLE_USE_LIST => 'Database Tables',
	    ]],
	    ['task_menu.title' => [
		FORUM_TUPLE_DEF_EDIT => 'Add Schema',
		FORUM_TUPLE_DEF_LIST => 'Schemas',
		FORUM_TUPLE_LIST => 'Records',
		FORUM_TUPLE_EDIT => 'Add Record',
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Add Type',
		FORUM_TUPLE_SLOT_TYPE_LIST => 'Types',
		FORUM_TUPLE_USE_EDIT => 'Add Table',
		FORUM_TUPLE_USE_LIST => 'Tables',
		TupleHistoryList => [
		    FORUM_TUPLE_EDIT => 'Modify Record',
		    FORUM_TUPLE_LIST => 'back to list',
		],
	    ]],
	    [TupleHistoryList => [
		'RealmFile.modified_date_time' => 'Date',
		'RealmMail.from_email' => 'Who',
		slot_headers => 'Updated Fields',
		comment => 'Comment',
	    ]],
	    [[qw(TupleDefList TupleDefListForm)] => [
		'TupleDef.label' => 'Schema Name',
		'TupleDef.moniker' => 'Mail Prefix',
	    ]],
	    ['TupleUseForm.separator' => [
		optional => '(OPTIONAL) Fields will default to Schema values',
	    ]],
	    [[qw(TupleUseList TupleUseForm)] => [
		'TupleUse.label' => 'Table Name',
		'TupleUse.moniker' => 'Mail Prefix',
		'list_action.FORUM_TUPLE_EDIT' => 'Add Record',
		[qw(TupleUse.tuple_def_id TupleDef.label)] => 'Schema',
	    ]],
	    [TupleUseList => [
		empty_list_prose => 'No database Tables have been added.',
	    ]],
	    [TupleDefList => [
		empty_list_prose => 'No database Schemas have been defined.',
	    ]],
	    [TupleSlotListForm => [
		'Tuple.tuple_num' => 'Record#',
	    ]],
	    [[qw(TupleList TupleSlotListForm)] => [
		'Tuple.modified_date_time' => 'Last Update',
		comment => 'Comment',
		empty_list_prose => 'No database Records have been added.',
	    ]],
	    [TupleList => [
		'Tuple.tuple_num' => 'Record',
	    ]],
	    [[qw(TupleSlotTypeListForm TupleDefListForm TupleUseForm TupleSlotListForm)] => [
		ok_button => 'Save',
	    ]],
	    [[qw(TupleSlotDefList TupleDefListForm)] => [
		'TupleSlotDef.label' => 'Field',
		[qw(TupleSlotDef.tuple_slot_type_id TupleSlotType.label)]
		    => 'Type',
		'TupleSlotDef.is_required' => 'Required?',
	    ]],
	    [[qw(TupleSlotTypeList TupleDefList TupleUseList TupleList)] => [
		list_actions => 'Actions',
	    ]],
	    [TupleSlotTypeList => [
		empty_list_prose => 'No types have been defined.',
		'TupleSlotType.label' => 'Type Name',
		'TupleSlotType.default_value' => 'Default Value',
		'TupleSlotType.choices' => 'Pick List',
#TODO: Allow override
	    ]],
	    [TupleSlotTypeListForm => [
		'TupleSlotType.label' => 'Type Name',
		'TupleSlotType.type_class' => 'Class',
		'TupleSlotType.default_value' => 'Default Value',
	    ]],
	    [[qw(TupleSlotChoiceList TupleSlotTypeListForm)] => [
		choice => 'Pick List',
	    ]],
	    [list_action => [
		[qw(FORUM_TUPLE_DEF_EDIT FORUM_TUPLE_SLOT_TYPE_EDIT FORUM_TUPLE_USE_EDIT FORUM_TUPLE_EDIT)]
		    => 'Modify',
		FORUM_TUPLE_LIST => 'Records',
		FORUM_TUPLE_HISTORY => 'History',
	    ]],
	    [acknowledgement => [
		FORUM_TUPLE_DEF_EDIT => 'Schema definition has been saved.',
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Type definition has been saved.',
		FORUM_TUPLE_USE_EDIT => 'Table definition has been saved.',
		FORUM_TUPLE_EDIT => 'An email was sent to update the record.  Please wait a few seconds and then click Refresh.',
	    ]],
	],
	FormError => [
	    ['TupleSlotTypeListForm.TupleSlotType.default_value.NOT_FOUND' =>
		'Default value must be a value in the Pick List'],
	    ['TupleSlotTypeListForm.choice.EXISTS' =>
		'Duplicate Pick List value.  All values must be distinct.'],
	    ['TupleSlotTypeListForm.TupleSlotType.type_class.MUTUALLY_EXCLUSIVE' =>
		'You can only relax the Class of an existing Type, e.g. String is always accceptable'],
	    ['TupleDefListForm.TupleSlotDef.label.EXISTS' =>
		'Duplicate Field label.  All fields must be distinct.'],
	    ['TupleDefListForm.TupleSlotDef.label.NOT_FOUND' =>
		'You must specify at least one Field.'],
	    ['TupleUseForm.TupleUse.tuple_def_id.EXISTS' =>
		'This Table is in use so you cannot change the Schema.'],
	],
    };
}

sub _merge {
    my($my, $child) = @_;
    foreach my $k (keys(%$my)) {
	push(@{$child->{$k} ||= []}, @{$my->{$k}});
    }
    return;
}

1;
