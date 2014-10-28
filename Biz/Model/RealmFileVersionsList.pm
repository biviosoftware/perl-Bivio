# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileVersionsList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_FP) = b_use('Type.FilePath');
my($_RFL) = b_use('Model.RealmFileLock');
my($_LOCK) = $_RFL->if_enabled;
my($_DEFAULT_LOCATION) = b_use('Model.Email')->DEFAULT_LOCATION;

sub internal_format_uri_get_path_info {
    my($self) = shift;
    if (my $pi = $self->SUPER::internal_format_uri_get_path_info(@_)) {
	return $pi;
    }
    my($type) = @_;
    return
	unless $type->can_take_path_info;
    return $self->req('path_info');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
        primary_key => ['RealmFile.realm_file_id'],
        auth_id => [qw(RealmFile.realm_id RealmOwner.realm_id)],
	order_by => [
	    'RealmFile.modified_date_time',
	    {
		name => 'RealmFile.path_lc',
		sort_order => 0,
	    },
            'Email_2.email',
	],
	other => [
            [qw(RealmFile.user_id Email_2.realm_id RealmOwner_2.realm_id)],
	    ['Email_2.location', [$_DEFAULT_LOCATION]],
	    'Email_2.email',
	    'RealmOwner.name',
	    'RealmOwner_2.display_name',
	    !$_LOCK ? () : (
		'RealmFileLock.modified_date_time',
		'RealmFileLock.comment',
		'RealmOwner_3.display_name',
		'Email_3.email',
	    ),
	    'RealmFile.path',
	    'RealmFile.folder_id',
	    'RealmFile.is_folder',
	    {
		name => 'file_name',
		type => 'FilePath',
		constraint => 'NONE',
	    },
	    {
		name => 'revision_number',
		type => 'FilePath',
		constraint => 'NONE',
	    },
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    $row->{file_name} = $_FP->get_tail($row->{'RealmFile.path'});
    $row->{revision_number} = $row->{file_name} =~ /.*\;((\d+)(\.\d+)?).*/
	? $1
	: 'current';
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $self->prepare_statement_for_realm_file_lock($stmt, 1);
    $self->throw_die('CORRUPT_QUERY', 'must have path_info')
	unless my $p = $self->req('path_info');
    my(@parts) = split('/', $p);
    my($name) = pop(@parts);
    $stmt->where(
	$stmt->OR(
	    $stmt->LIKE('RealmFile.path_lc',
		lc($_FP->VERSIONS_FOLDER .
		       join('/', @parts, $_FP->get_base($name) . '%'
				. $_FP->get_suffix($name)))),
	    $stmt->EQ('RealmFile.path', [$p]),
	));
    return shift->SUPER::internal_prepare_statement(@_);
}

sub is_locked {
    return $_RFL->is_locked(shift, 'RealmFileLock.');
}

sub prepare_statement_for_realm_file_lock {
    my($self, $stmt, $all_locks) = @_;
    return
	unless $_LOCK;
    $stmt->from($stmt->LEFT_JOIN_ON(qw(RealmFile RealmFileLock), [
	[qw(RealmFile.realm_file_id RealmFileLock.realm_file_id)],
	$all_locks ? () : ['RealmFileLock.comment', [undef]],
    ]));
    $stmt->from($stmt->LEFT_JOIN_ON(qw(RealmFileLock RealmOwner_3), [
	[qw(RealmFileLock.user_id RealmOwner_3.realm_id)],
    ]));
    $stmt->from($stmt->LEFT_JOIN_ON(qw(RealmFileLock Email_3), [
	[qw(RealmFileLock.user_id Email_3.realm_id)],
	['Email_3.location', [$_DEFAULT_LOCATION]],
    ]));
    return;

}

sub _lock {
    return $_LOCK ? @_ : ();
}

1;
