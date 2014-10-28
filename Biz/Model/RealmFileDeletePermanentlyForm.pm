# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileDeletePermanentlyForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_ok {
    my($self) = @_;
    my($rf) = $self->new_other('RealmFile')->load({
	path => $self->req('path_info'),
    });
    $self->internal_put_field(realm_file => $rf);
    $rf->delete({
	override_is_read_only => 1,
	override_versioning => 1,
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	$self->field_decl(other => [
	    [qw(realm_file Model.RealmFile)],
	]),
    });
}

1;
