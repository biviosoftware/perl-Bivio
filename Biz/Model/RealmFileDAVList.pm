# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileDAVList;
use strict;
use Bivio::Base 'Model.DAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RF) = Bivio::Biz::Model->get_instance('RealmFile');

sub dav_copy {
    my($self, $dest) = @_;
    _instance($self, copy_deep => {
	%{_load_args($dest)},
	user_id => $self->get_request->get('auth_user_id'),
    });
    return;
}

sub dav_delete {
    my($self) = @_;
    _instance($self, 'delete_deep');
    return;
}

sub dav_get {
    my($self) = @_;
    return _static($self, 'get_handle');
}

sub dav_is_read_only {
    my($self) = @_;
    return $self->get_result_set_size > 0 ? $self->set_cursor_or_die(0)
	->get('RealmFile.is_read_only') : 0;
}

sub dav_mkcol {
    my($self) = @_;
    _instance($self, create_folder => _load_args($self));
    return;
}

sub dav_move {
    my($self, $dest) = @_;
    my($a) = _load_args($dest);
    $dest->dav_delete
	if $dest->dav_exists;
    _instance($self, update => $a);
    return;
}

sub dav_propfind {
    my($self) = @_;
    return {
	map(($_ => $self->get($_)), qw(getlastmodified displayname uri)),
	$self->get('RealmFile.is_folder') ? ()
	   : (getcontenttype => _static($self, 'get_content_type'),
	       getcontentlength => _static($self, 'get_content_length'),
	   ),
    };
}

sub dav_put {
    my($self, $content) = @_;
    return $self->req->with_realm(
	$self->get_auth_id,
	sub {
	    return _instance(
		$self,
		($self->get_result_set_size > 0 ? 'update' : 'create')
		    . '_with_content',
		_load_args($self),
		$content,
	    );
	},
    );
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	auth_id => 'RealmFile.realm_id',
	primary_key => ['RealmFile.path_lc'],
	order_by => ['RealmFile.path_lc'],
	other => [qw(
	    RealmFile.path
	    RealmFile.realm_file_id
	    RealmFile.modified_date_time
	    RealmFile.is_folder
	    RealmFile.is_read_only
        )],
	other_query_keys => ['realm_file_id'],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    my($pi) = $self->get_query->get('path_info');
    if ($row->{'RealmFile.path_lc'} eq lc($pi)) {
	$row->{uri} = '';
	$row->{displayname} = $pi eq '/' ? '/'
	    : ($row->{'RealmFile.path'} =~ m{([^/]+)$})[0];
    }
    else {
	$row->{uri} = $row->{displayname}
	    = substr(
		$row->{'RealmFile.path'}, length($pi) + ($pi eq '/' ? 0 : 1));
    }
    $row->{getlastmodified} = $row->{'RealmFile.modified_date_time'};
    return 1;
}

sub internal_pre_load {
    my($self, $query) = @_;
    return $query->get('this') ? ''
	: shift->get_instance('RealmFileList')->internal_pre_load(@_);
}

sub load_dav {
    my($self) = @_;
    my($p) = $_RF->parse_path($self->get_request->get('path_info'), $self);
    $self->get_query->put(realm_file_id => $self->get('RealmFile.realm_file_id'))
	if $self->unsafe_load_this({
	    this => lc($p),
	    path_info => $p,
	});
    return 1;
}

sub _instance {
    my($self, $method) = splice(@_, 0, 2);
    my($m) = $self->get_result_set_size > 0 ? 'get_model' : 'new_other';
    return $self->$m('RealmFile')->$method(@_);
}

sub _load_args {
    my($self) = @_;
    my($q) = $self->get_query;
    return {
	path => $q->get('path_info'),
	realm_id => $q->get('auth_id'),
    };
}

sub _static {
    my($self, $method) = @_;
    return $_RF->$method($self, 'RealmFile.');
}

1;
