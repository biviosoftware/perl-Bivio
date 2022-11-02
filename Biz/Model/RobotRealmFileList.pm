# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RobotRealmFileList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_HTTP_MOVED_PERMANENTLY) = b_use('Ext.ApacheConstants')->HTTP_MOVED_PERMANENTLY;
my($_PAGE) = b_use('SQL.ListQuery')->to_char('page_number');
my($_COUNT) = b_use('SQL.ListQuery')->to_char('count');
my($_NOT_LIKE) = [
    b_use('Type.MailFileName')->to_sql_like_path,
    b_use('Type.MailFileName')->to_sql_like_path(1),
    b_use('Type.VersionsFileName')->to_sql_like_path,
];

sub PAGE_SIZE {
    return 1000;
}

sub execute_load_page {
    my($self) = @_;
    my($p, $c);
    if (my $q = $self->ureq('query') or my $pi = $self->ureq('path_info')) {
        $p = delete($q->{$_PAGE});
        $c = delete($q->{$_COUNT});
        return {
            method => 'client_redirect',
            task_id => 'file_tree_task',
            query => undef,
            path_info => undef,
            http_status_code => $_HTTP_MOVED_PERMANENTLY,
        } if %$q || defined($pi);
    }
    $self->req->put_durable(
        query => {
            $p ? ($_PAGE => $p) : (),
            $c ? ($_COUNT => $c) : (),
    });
    return shift->SUPER::execute_load_page(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 1,
        want_page_count => 0,
        auth_id => 'RealmFile.realm_id',
        primary_key => ['RealmFile.realm_file_id'],
        order_by => [qw(
            RealmFile.path_lc
        )],
        other => [
            'RealmFile.path',
            ['RealmFile.is_public', [1]],
            ['RealmFile.is_folder', [0]],
            $self->field_decl([[qw(detail_uri LongText)]]),
        ],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
        unless shift->SUPER::internal_post_load_row(@_);
    $row->{detail_uri}
        = $self->req->format_uri({
            task_id => $self->req('task')->get_attr_as_id('file_task'),
            query => undef,
            path_info => $row->{'RealmFile.path'},
            no_context => 1,
        });
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where(
        $stmt->map_invoke('NOT_LIKE', $_NOT_LIKE, ['RealmFile.path_lc']),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
