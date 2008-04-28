# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FileAddForm;
use strict;
use Bivio::Base 'Model.FileBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_FN) = __PACKAGE__->use('Type.FileName');

sub execute_ok {
    my($self) = @_;
    return unless _file_name($self);
    my($realm_file_id) = $self->new_other('RealmFile')->create_with_content({
	path => $_FP->join($self->get('realm_file')->get('path'),
	    _file_name($self)),
    }, $self->get('file')->{content})->get('realm_file_id');
    $self->new_other('RowTag')->replace_value($realm_file_id,
	REALM_FILE_COMMENT => $self->get('comment'))
	if defined($self->get('comment'));
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	visible => [
	    {
		name => 'file',
		type => 'FileField',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'comment',
		type => 'RowTagValue',
		constraint => 'NONE',
	    },
	],
    });
}

sub validate {
    my($self) = @_;
    _file_name($self)
	unless $self->in_error;
    return;
}

sub _file_name {
    my($self) = @_;
    my($name, $err) = $_FN->from_literal(
	$_FP->get_tail($self->get('file')->{filename}));

    if ($err) {
	$self->internal_put_error(file => $err);
	return;
    }
    $self->internal_put_error(file => 'FILE_NAME')
	unless defined($name);
    return $name;
}

1;
