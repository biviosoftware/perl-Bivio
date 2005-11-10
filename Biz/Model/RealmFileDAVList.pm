# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileDAVList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RF) = Bivio::Biz::Model->get_instance('RealmFile');
my($_FP) = $_RF->get_field_type('path');

sub as_string {
    my($self) = @_;
    if (my $q = $self->get_query) {
	my($r, $p) = $q->unsafe_get(qw(realm_id path));
	return ref($self) . "[$r,$p]"
	    if $r && $p;
    }
    return $self->SUPER::as_string;
}

sub dav_copy {
    my($self, $dest) = @_;
    _instance($self, copy_deep => _load_args($dest));
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
    return 0;
}

sub dav_load {
    my($self, $query) = @_;
    my($p, $e) = $_FP->from_literal($query->{path});
    Bivio::Die->throw_die(
	CORRUPT_QUERY => {
	    message => 'invalid path',
	    type_error => $e,
	    entity => $query->{path},
        },
    ) if $e;
    $p = $p ? lc($p) : '/';
    $self->unsafe_load_this({
	path => $p,
	this => $p,
	realm_id => $query->{realm}->get('id'),
    });
    return $self;
}

sub dav_mkcol {
    my($self) = @_;
    _instance($self, create_folder => _load_args($self));
    return;
}

sub dav_move {
    my($self, $dest) = @_;
    _instance($self, update => _load_args($dest));
    return;
}

sub dav_propfind {
    my($self) = @_;
    return {
	map(($_ => $self->get($_)), qw(displayname uri)),
	$self->get('RealmFile.is_folder') ? ()
	   : (getcontenttype => _static($self, 'get_content_type'),
	       getcontentlength => _static($self, 'get_content_length'),
	   ),
	getlastmodified => $self->get('RealmFile.modified_date_time'),
    };
}

sub dav_propfind_children {
    my($self) = @_;
    $self->set_cursor_or_die(0);
    return $self->new->map_iterate(
	sub {shift->dav_propfind},
	{
	    realm_id => $self->get('RealmFile.realm_id'),
	    path => lc($self->get('RealmFile.path')),
	},
    );
}

sub dav_put {
    my($self, $content) = @_;
    return _instance(
	$self,
	($self->get_result_set_size > 0 ? 'update' : 'create') . '_with_content',
	_load_args($self),
	$content,
    );
    return;
}

sub execute {
    my($proto, $req) = @_;
    $proto->new($req)->put_on_request;
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => ['RealmFile.path_lc'],
	other => [qw(
	    RealmFile.path
	    RealmFile.realm_file_id
	    RealmFile.modified_date_time
	    RealmFile.is_folder
	    RealmFile.realm_id
	    RealmFile.volume
        ),
	    map(
		+{
		    name => $_,
		    constraint => 'NONE',
		    type => 'FilePath',
		}, qw(displayname uri),
	    ),
	],
	other_query_keys => [qw(realm_id path)],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    my($q) = $self->get_query;
    my($p) = $q->get('path');
    return 0
	unless $row->{'RealmFile.path_lc'} =~ /^\Q$p/;
    if ($p eq $row->{'RealmFile.path_lc'}) {
	return 0
	    unless $q->get('this');
	$row->{uri} = '';
	$row->{displayname}
	    = ($row->{'RealmFile.path'} =~ m{([^/]+$)})[0] || $p;
	return 1;
    }
    $row->{uri} = $row->{displayname}
	= substr($row->{'RealmFile.path'}, $p eq '/' ? 1 : length($p) + 1);
    return $row->{displayname} =~ m{/} ? 0 : 1;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $stmt->where(
	$stmt->GTE(
	    'LENGTH(RealmFile.path_lc)', [length($query->get('path'))]),
	$stmt->EQ('RealmFile.realm_id', [$query->get('realm_id')]),
	$stmt->EQ('RealmFile.volume', [Bivio::Type::FileVolume->PLAIN]),
    );
    return;
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
	volume => Bivio::Type::FileVolume->PLAIN,
	map(($_ => $q->get($_)), qw(path realm_id)),
    };
}

sub _static {
    my($self, $method) = splice(@_, 0, 2);
    return $_RF->$method($self, 'RealmFile.', @_);
}

1;
