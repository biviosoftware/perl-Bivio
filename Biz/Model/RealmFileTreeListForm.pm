# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileTreeListForm;
use strict;
use base 'Bivio::Biz::Model::TreeBaseListForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty_row {
    my($self) = shift;
    my(@res) = $self->SUPER::execute_empty_row(@_);
    # Root node is always expanded
    $self->internal_put_field(
	node_state => $self->get('node_state')->NODE_EXPANDED
    ) if $self->get_list_model->get('RealmFile.path_lc') eq '/';
    return @res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'RealmFileFullTreeList',
    });
}

1;
