# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BlogEditForm;
use strict;
use Bivio::Base 'Model.WikiBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_BFN) = b_use('Type.BlogFileName');
my($_BC) = b_use('Type.BlogContent');

sub execute_empty {
    my($self) = @_;
    my($l) = $self->get_request->get('Model.BlogList');
    foreach my $f (qw(title body RealmFile.is_public)) {
	$self->internal_put_field($f => $l->get($f));
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    my($id, $fn) = $self->req('Model.BlogList')
	->get(qw(RealmFile.realm_file_id path_info));
    my($public) = $self->get('RealmFile.is_public');
    $self->new_other('RealmFile')->load({
	realm_file_id => $id,
    })->update_with_content({
	path => $_BFN->to_absolute($fn, $public),
	'RealmFile.is_public' => $public,
    }, $_BC->join($self->get(qw(title body))))
	->put_on_request;
    return $self->return_with_validate({
        carry_path_info => 1,
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'RealmFile.is_public',
	    {
		name => 'title',
		type => 'BlogTitle',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'body',
		type => 'BlogBody',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($req) = $self->get_request;
    b_use('Type.AccessMode')->execute_private($req);
    $self->new_other('BlogList')->execute_load_this($req);
    return;
}

1;
