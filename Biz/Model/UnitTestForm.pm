# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UnitTestForm;
use strict;
use Bivio::Base 'Biz.FormModel';
b_use('IO.ClassLoaderAUTOLOAD');


sub execute_ok {
    my($self) = @_;
    $self->internal_put_field('RealmOwner.name' => 'root');
    $self->new_other('RealmOwner')->create({
	realm_id => 9999999999,
	realm_type => Auth_RealmType('USER'),
	display_name => 'anything',
	password => 'anything',
	name => Util_TestUser()->ADM,
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->field_decl(
	    visible => [
		[
		    'User.first_name',
		    {
			constraining_field => 'RealmOwner.name',
		    },
		],
	    ],
	),
    });
}

1;
