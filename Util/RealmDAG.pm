# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmDAG;
use strict;
use Bivio::Base 'Bivio.ShellUtil';


sub USAGE {
    return <<'EOF';
usage: bivio RealmDAG [options] command [args..]
commands
  list_parents [RealmDAG...] -- list all parents of realm [type]
EOF
}

sub list_parents {
    sub LIST_PARENTS {[qw(*RealmDAG)]}
    my($self, $bp) = shift->parameters(\@_);
    $bp->{RealmDAG} = [b_use('Type.RealmDAG')->get_non_zero_list]
        unless @{$bp->{RealmDAG}};
    return $self->model('RealmDAG')->map_iterate(
        sub {
            my($pid, $type) = shift->get(qw(parent_id realm_dag_type));
            return
                unless grep($_->equals($type), @{$bp->{RealmDAG}});
            return join(
                ' ',
                $type->get_name,
                $self->unauth_model('RealmOwner', {realm_id => $pid})
                    ->get(qw(name realm_id)),
            );
        },
        'realm_dag_type, parent_id',
        {child_id => $self->req('auth_id')},
    );
}

1;
