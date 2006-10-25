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
	    [FORUM_TUPLE_SLOT_TYPE_LIST => '?/db-types'],
	    [FORUM_TUPLE_SLOT_TYPE_EDIT => '?/edit-db-type'],
	],
	Text => [
	    [title => [
		FORUM_TUPLE_SLOT_TYPE_LIST => 'Database Types',
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Add or Modify Database Type',
	    ]],
	    [task_menu => [
		FORUM_TUPLE_SLOT_TYPE_LIST => 'Types',
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Add Type',
	    ]],
	    [TupleSlotTypeList => [
		empty_list_prose => 'No types have been defined.',
		'TupleSlotType.label' => 'Type Name',
		'TupleSlotType.default_value' => 'Default Value',
		'TupleSlotType.choices' => 'Pick List',
#TODO: Allow override
		list_actions => 'Actions',
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Modify',
	    ]],
	    [TupleSlotTypeListForm => [
		'TupleSlotType.label' => 'Type Name',
		'TupleSlotType.type_class' => 'Category',
		'TupleSlotType.default_value' => 'Default Value',
		ok_button => 'Save',
	    ]],
	    [[qw(TupleSlotChoiceList TupleSlotTypeListForm)] => [
		choice => 'Pick List',
	    ]],
	],
	FormError => [
	    ['TupleSlotTypeListForm.TupleSlotType.default_value.NOT_FOUND' =>
		'Default value must be a value in the Pick List'],
	    ['TupleSlotTypeListForm.choice.EXISTS' =>
		'Duplicate Pick List value'],
	    ['TupleSlotTypeListForm.TupleSlotType.type_class.MUTUALLY_EXCLUSIVE' =>
		'You can only relax the Category of an existing Type, e.g. String is always accceptable'],
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
