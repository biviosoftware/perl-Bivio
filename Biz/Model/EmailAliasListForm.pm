# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EmailAliasListForm;
use strict;
use Bivio::Base 'Biz.ExpandableListFormModel';


sub MUST_BE_SPECIFIED_FIELDS {
    return [qw(
	EmailAlias.incoming
	EmailAlias.outgoing
    )];
}

sub WANT_EXECUTE_OK_ROW_DISPATCH {
    return 1;
}

sub execute_ok_row_create {
    my($self) = @_;
    $self->create_model_properties('EmailAlias');
    return;
}

sub execute_ok_row_delete {
    shift->get_list_model->get_model('EmailAlias')->delete;
    return;
}

sub execute_ok_row_update {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    $self->new_other('EmailAlias')->load({
	incoming => $lm->get('EmailAlias.incoming'),
	outgoing => $lm->get('EmailAlias.outgoing'),
    })->update({
	%{$self->get_model_properties('EmailAlias')},
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'EmailAliasList',
	primary_key => ['primary_key'],
	visible => [
	    $self->field_decl([qw(
		EmailAlias.incoming
		EmailAlias.outgoing
	    )], {in_list => 1}),
	],
    });
}

1;
