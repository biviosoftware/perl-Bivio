# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Cache::RealmFileBase;
use strict;
use Bivio::Base 'Bivio.Cache';


sub handle_property_model_modification {
    my($proto, $model, $op, $query) = @_;
    return
        unless $model->simple_package_name eq 'RealmFile';
    return
        unless _path_matches_pessimistically($proto, $query, $model);
    return b_warn($op, ' ', $query, ': missing_realm_id')
        unless my $rid = $query->{realm_id} || $model->get('realm_id');
    $model->req->push_txn_resource($proto->new({realm_id => $rid}));
    return;
}

sub _path_matches_pessimistically {
    my($proto, $query, $model) = @_;
    return 1
        unless my $p = $query->{path_lc}
        || $query->{path}
        || $model->unsafe_get('path_lc');
    return $p =~ $proto->FILE_PATH_REGEX ? 1 : 0;
}

1;
