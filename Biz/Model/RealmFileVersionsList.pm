# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileVersionsList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_RTK) = __PACKAGE__->use('Type.RowTagKey');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
        primary_key => ['RealmFile.realm_file_id'],
        auth_id => [qw(RealmFile.realm_id RealmOwner.realm_id)],
	order_by => [
	    {
		name => 'RealmFile.path_lc',
		sort_order => 0,
	    },
	    'RealmFile.modified_date_time',
	    'RealmOwner_2.display_name',
            'Email.email',
	    {
		name => 'comment',
		type => 'RowTag.value',
		in_select => 1,
		select_value => "(
                    SELECT value
                    FROM row_tag_t
                    WHERE primary_id = realm_file_t.realm_file_id
                    AND key = @{[$_RTK->REALM_FILE_COMMENT->as_sql_param]}
                 ) AS comment",
	    },
	],
	other => [
            [qw(RealmFile.user_id Email.realm_id RealmOwner_2.realm_id)],
	    ['Email.location', [$self->use('Model.Email')->DEFAULT_LOCATION]],
	    'Email.email',
	    'RealmOwner.name',
	    'RealmOwner_2.display_name',
	    'RealmFile.path',
	    'RealmFile.folder_id',
	    'RealmFile.is_folder',
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
    $row->{revision_number} = $self->use('Type.FileName')
	->get_tail($row->{'RealmFile.path'}) =~ /.*\;(\d*).*/
	? $1
	: 'current';
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
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

1;
