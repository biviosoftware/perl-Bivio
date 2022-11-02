# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileRevertForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_ok {
    my($self) = @_;
    $self->get('realm_file')
        ->update_with_file({}, $self->get('new_realm_file_id'));
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        other => [
            {
                name => 'realm_file',
                type => 'Model.RealmFile',
            },
            {
                name => 'new_realm_file_id',
                type => 'PrimaryId',
            },
            {
                name => 'new_version',
                type => 'Integer',
            },
        ],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    my($nrf) = $self->new_other('RealmFile')->load({
        realm_file_id => $self->req('query')->{'t'},
    });
    $nrf->get('path') =~ /.*\;((\d+)(\.\d+)?).*/;
    my($v) = $1;
    $self->internal_put_field(
        realm_file => $self->new_other('RealmFile')
            ->set_ephemeral
            ->load({path => $self->req('path_info')}),
        new_realm_file_id => $nrf->get('realm_file_id'),
        new_version => $v,
    );
    return @res;
}

1;
