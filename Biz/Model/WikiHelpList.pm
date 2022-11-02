# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::WikiHelpList;
use strict;
use Bivio::Base 'Model.WikiList';

my($_WN) = b_use('Type.WikiName');
my($_S) = b_use('Bivio.Search');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
            $self->field_decl(
                [
                    qw(
                        result_title
                        result_excerpt
                    ),
                    [qw(name WikiName)],
                ],
                'Text', 'NOT_NULL',
            ),
        ],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
        unless $_WN->is_valid(
            $row->{name} = $_WN->get_base($row->{'RealmFile.path'}),
        );
    my($p) = $_S->get_values_for_primary_id(
        $row->{'RealmFile.realm_file_id'},
        $self->new_other('RealmFile'),
    );
    unless ($p) {
        b_warn($row, ': unable to parse excerpt');
        return 0;
    }
    $row->{result_excerpt} = $p->{excerpt};
    ($row->{result_title} = $p->{title}) =~ s/ Help$//i;
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($rf) = $self->new_other('RealmFile');
    $stmt->where(
        $stmt->LIKE('RealmFile.path_lc', '%help'),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
