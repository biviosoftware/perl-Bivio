# Copyright (c) 2005-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_RF);
my($_FP);
my($_ARF);

sub delete {
    my($self) = @_;
    $self->new_other('RealmFile')->delete({
	map(($_ => $self->get("RealmFile.$_")), qw(realm_id realm_file_id)),
    });
    return;
}

sub get_content {
    return $_RF->get_content(shift, 'RealmFile.');
}

sub get_content_length {
    return $_RF->get_content_length(shift, 'RealmFile.');
}

sub get_content_type {
    return $_RF->get_content_type(shift, 'RealmFile.');
}

sub get_os_path {
    return $_RF->get_os_path(shift, 'RealmFile.');
}

sub internal_initialize {
    my($self) = @_;
    $_RF = $self->get_instance('RealmFile');
    $_FP = $_RF->get_field_type('path');
    $_ARF = b_use('Action.RealmFile');
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        auth_id => 'RealmFile.realm_id',
        primary_key => ['RealmFile.realm_file_id'],
	order_by => [qw(
	    RealmFile.path_lc
	    RealmFile.modified_date_time
	    RealmFile.realm_file_id
	)],
	other => [
	    map("RealmFile.$_", @{$_RF->get_keys}),
	],
	other_query_keys => [qw(path_info realm_file_id)],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{base_name} = $row->{'RealmFile.path'} eq '/' ? '/'
	: $_FP->get_tail($row->{'RealmFile.path'});
    return 1;
}

sub internal_pre_load {
    my($self, $query, undef, $params) = @_;
    my($p) = $_RF->parse_path($query->unsafe_get('path_info'), $self);
    $query->put(path_info => $p);
    if (my $rfid = $query->unsafe_get('realm_file_id')) {
	push(@$params, $rfid);
	return q{folder_id = ?};
    }
    return q{STRPOS(SUBSTR(path_lc, 2), '/') = 0 AND path_lc != '/'}
	if $p eq '/';
    push(@$params, $p, lc($p) . '/', $p);
    return q{SUBSTR(path_lc, 1, LENGTH(?) + 1) = ?
        AND STRPOS(SUBSTR(path_lc, LENGTH(?) + 2), '/') = 0};
}

sub prepare_statement_for_access_mode {
    my($self, $stmt, $doclet) = @_;
    my($am) = $self->req->unsafe_get('Type.AccessMode');
    my($is_public) = $am ? $am->eq_public
	: $_ARF->access_is_public_only($self->req);
    $stmt->where(
	$stmt->AND(
	    $stmt->OR(
		map(
		    $stmt->LIKE(
			'RealmFile.path_lc', $doclet->to_sql_like_path($_),
		    ),
		    1,
		    $is_public ? () : 0,
		),
	    ),
	    $is_public ? ['RealmFile.is_public', [1]] : (),
	),
    );
    return;
}

1;
