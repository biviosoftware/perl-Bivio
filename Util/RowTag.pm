# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RowTag;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_RTK) = b_use('Type.RowTagKey');

sub USAGE {
    return <<'EOF';
usage: b-row-tag [options] command [args..]
commands
  replace_value key [value] -- calls RowTag->replace_value with auth_id
  list [key...] -- calls RowTag->replace_value with auth_id
EOF
}

sub list {
    sub LIST {[[
        '*key',
        'RowTagKey',
        sub {[sort({$a->get_name cmp $b->get_name} $_RTK->get_non_zero_list)]},
    ]]}
    my($self, $bp) = shift->parameters(\@_);
    my($rt) = $self->model('RowTag');
    my($id) = $self->req('auth_id');
    return {map(
        ($_->get_name, $rt->get_value($id, $_)),
        @{$bp->{key}},
    )};
}

sub replace_value {
    my($self, $key, $value) = shift->name_args([
        ['RowTagKey'],
        [RowTagValue => undef, undef],
    ], \@_);
    $self->model('RowTag')->replace_value($self->req('auth_id'), $key, $value);
    return;
}

1;
