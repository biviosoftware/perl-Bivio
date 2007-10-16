# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileBaseList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RF) = Bivio::Biz::Model->get_instance('RealmFile');
my($_FP) = $_RF->get_field_type('path');

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

sub internal_initialize {
    my($self) = @_;
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

sub internal_pre_load {
    my($self, $query, undef, $params) = @_;
    my($p) = $_RF->parse_path($query->unsafe_get('path_info'), $self);
    $query->put(path_info => $p);
    if (my $rfid = $query->unsafe_get('realm_file_id')) {
	push(@$params, $rfid);
	return q{folder_id = ?};
    }
    return q{POSITION('/' IN SUBSTRING(path_lc FROM 2)) = 0 AND path_lc != '/'}
	if $p eq '/';
    push(@$params, $p, lc($p) . '/', $p);
    return q{SUBSTRING(path_lc FROM 1 FOR LENGTH(?) + 1) = ?
        AND POSITION('/' IN SUBSTRING(path_lc FROM LENGTH(?) + 2)) = 0};
}

1;
