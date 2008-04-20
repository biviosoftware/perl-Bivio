# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TextFileForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = __PACKAGE__->use('MIME.Type');

sub execute_empty {
    my($self) = @_;
    if (my $rf = $self->req->unsafe_get('Model.RealmFile')) {
	$self->internal_put_field(content => ${$rf->get_content});
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    if (my $rf = $self->req->unsafe_get('Model.RealmFile')) {
	$rf->update_with_content({}, $self->get('content'));
    }
    else {
	$self->new_other('RealmFile')->create_with_content(
	    {path => $self->get('RealmFile.path')}, $self->get('content'));
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	visible => [
	    {
		name => 'content',
		type => 'Text64K',
		constraint => 'NOT_NULL',
	    },
	],
	other => [
	    'RealmFile.path',
        ],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($rf) = $self->new_other('RealmFile');
    my($p) = $rf->parse_path($self->req('path_info'), $self);
    my($ct) = $rf->get_content_type_for_path($p);
    Bivio::Die->die(FORBIDDEN => {
	message => $ct . ': not a text mime type',
	entity => $p,
    }) unless $ct =~  m{^text/};
    if ($rf->unsafe_load({path => $p})) {
	foreach my $x (qw(is_folder is_read_only)) {
	    Bivio::Die->die(FORBIDDEN => {message => $x, entity => $p})
	        if $rf->get($x);
	}
    }
    else {
	$self->internal_put_field('RealmFile.path' => $p);
    }
    return;
}

1;
