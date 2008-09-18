# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileVersionsList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
        primary_key => ['RealmFile.realm_file_id'],
        auth_id => [qw(RealmFile.realm_id RealmOwner.realm_id)],
	order_by => [
	    'RealmFile.modified_date_time',
	    'RealmFileLock.modified_date_time',
	    {
		name => 'RealmFile.path_lc',
		sort_order => 0,
	    },
            'Email_2.email',
	    'RealmFileLock.comment',
	],
	other => [
            [qw(RealmFile.user_id Email_2.realm_id RealmOwner_2.realm_id)],
	    ['Email_2.location',
		[$self->use('Model.Email')->DEFAULT_LOCATION]],
	    'Email_2.email',
	    'RealmOwner.name',
	    'RealmOwner_2.display_name',
	    'RealmOwner_3.display_name',
	    'Email_3.email',
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
    $row->{file_name} = $_FP->get_tail($row->{'RealmFile.path'});
    $row->{revision_number} = $row->{file_name} =~ /.*\;((\d+)(\.\d+)?).*/
	? $1
	: 'current';
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->from($stmt->LEFT_JOIN_ON(qw(RealmFile RealmFileLock), [
	[qw(RealmFile.realm_file_id RealmFileLock.realm_file_id)],
    ]));
    $stmt->from($stmt->LEFT_JOIN_ON(qw(RealmFileLock RealmOwner_3), [
	[qw(RealmFileLock.user_id RealmOwner_3.realm_id)],
    ]));
    $stmt->from($stmt->LEFT_JOIN_ON(qw(RealmFileLock Email_3), [
	[qw(RealmFileLock.user_id Email_3.realm_id)],
	['Email_3.location', [$self->use('Model.Email')->DEFAULT_LOCATION]],
    ]));
    my(@parts) = split('/', $self->req('path_info'));
    my($name) = $_FP->get_base(pop(@parts));
    $stmt->where(
	$stmt->OR(
	    $stmt->LIKE('RealmFile.path_lc',
		lc($_FP->VERSIONS_FOLDER . join('/', @parts, $name .'%'))),
	    $stmt->EQ('RealmFile.path', [$self->req('path_info')]),
	));
    return shift->SUPER::internal_prepare_statement(@_);
}

sub is_locked {
    my($self) = @_;
    return 0 unless $self->get('RealmFileLock.modified_date_time');
    return $self->use('Model.RealmFileLock')
	->is_locked($self, 'RealmFileLock.');
}

1;
