# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::WikiForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_cancel {
    my($self) = @_;
    # Need to clear path_info so we don't come right back to here with
    # "auto-create" on the wiki workflow
    $self->get_request->put(path_info => undef);
    return 'next';
}

sub execute_empty {
    my($self) = @_;
    return unless _is_edit($self);
    $self->internal_put_field('RealmFile.path_lc' => _authorized_name($self));
    $self->internal_put_field(
	content => ${$self->get('realm_file')->get_content},
    ) if $self->get('file_exists');
    return;
}

sub execute_ok {
    my($self) = @_;
    my($new) = $self->name_type
	->to_absolute($self->get('RealmFile.path_lc'));
    my($c) = $self->get('content');
    my($m) = $self->get('file_exists')
	? 'update_with_content' : 'create_with_content';
    $self->get('realm_file')->$m({path => $new}, \$c);
    $self->get_request->put(path_info => $self->get('RealmFile.path_lc'));
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'content',
		type => 'Text64K',
		constraint => 'NOT_NULL',
	    },
	    {
		# This is where the constraint is
		name => 'RealmFile.path_lc',
		type => $self->name_type,
	    },
	],
	other => [
	    {
		name => 'realm_file',
		# PropertyModels may act as types.
		type => 'Bivio::Biz::Model::RealmFile',
		constraint => 'NONE',
	    },
	    {
		name => 'file_exists',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($rf) = $self->new_other('RealmFile');
    $self->internal_put_field(realm_file => $rf);
    $self->internal_put_field(file_exists =>
        _is_edit($self) && $rf->unsafe_load({path => _curr_path($self)}));
    return;
}

sub name_type {
    return Bivio::Type->get_instance('WikiName');
}

sub _curr_path {
    my($self) = @_;
    return $self->name_type->to_absolute(_authorized_name($self));
}

sub _is_edit {
    return shift->get_request->unsafe_get('path_info') ? 1 : 0;
}

sub _authorized_name {
    # SECURITY: By validating the name, we are sure that we aren't opening
    # up writes in any other directory.
    my($self) = @_;
    return $self->name_type->from_literal_or_die(
	shift->get_request->get('path_info') =~ m{^/*(.+)});
}

1;
