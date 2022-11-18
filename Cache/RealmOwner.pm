# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Cache::RealmOwner;
use strict;
use Bivio::Base 'Bivio.Cache';

my($_RO) = b_use('Model.RealmOwner');
b_use('Biz.PropertyModel')->register_handler(__PACKAGE__);

sub get_cache_value {
    my($self, $owner, $req) = @_;
    return $req->get_if_exists_else_put(__PACKAGE__, {})->{$owner}
        ||= $_RO->new($req)->unauth_load_by_id_or_name_or_die($owner);
}

sub handle_property_model_modification {
    my(undef, $model, $op, $query) = @_;
    return
        unless $model->simple_package_name eq 'RealmOwner';
    $model->req->delete(__PACKAGE__);
    return;
}

1;
