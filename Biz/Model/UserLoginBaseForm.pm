# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserLoginBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub PASSWORD_FIELD {
    return 'p';
}

sub USER_FIELD {
    # Returns the cookie key for the super user value.
    return 'u';
}

sub internal_initialize {
    my($self) = @_;
    # B<FOR INTERNAL USE ONLY>
    my($info) = $self->merge_initialize_info(
        shift->SUPER::internal_initialize(@_), {
	# Form versions are checked and mismatches causes VERSION_MISMATCH
	version => 1,

	# This form's "next" is the task which redirected to this form.
	# If redirect was not from a task, returns to normal "next".
	require_context => 1,

	# Fields which are shown to the user.
	visible => [
	    {
		name => 'login',
		type => 'Line',
		constraint => 'NOT_NULL',
                form_name => 'x1',
	    },
            {
                name => 'RealmOwner.password',
                form_name => 'x2',
            },
	],

	# Fields used internally which are computed dynamically.
	# They are not sent to or returned from the user.
	other => [
	    # The following fields are computed by validate
	    {
		name => 'realm_owner',
		# PropertyModels may act as types.
		type => 'Bivio::Biz::Model::RealmOwner',
		constraint => 'NONE',
	    },
	    {
		# Only set by validate
		name => 'validate_called',
		type => 'Boolean',
		constraint => 'NONE',
	    },
            {
                # Don't assert the cookie is valid
                name => 'disable_assert_cookie',
		type => 'Boolean',
		constraint => 'NONE',
            },
	    {
		name => 'via_mta',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
    });

    foreach my $field (@{$info->{visible}}) {
        $field = {
            name => $field,
        } unless ref($field);
        next if $field->{form_name};
        $field->{form_name} = $field->{name};
    }
    return $info;
}

1;
