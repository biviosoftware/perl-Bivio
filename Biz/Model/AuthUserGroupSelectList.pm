# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AuthUserGroupSelectList;
use strict;
use Bivio::Base 'Model.AuthUserGroupList';

my($_T) = b_use('FacadeComponent.Text');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 0,
    });
}

sub internal_load {
    my($self, $rows, $query) = @_;
    my(@res) = shift->SUPER::internal_load(@_);
    unshift(@$rows, {
        map(
#TODO: Eval as prose
            ($_ => $_T->get_value(
                $self->simple_package_name . ".$_.select",
                $self->req,
            )),
            qw(RealmOwner.display_name RealmOwner.name),
        ),
        'RealmUser.realm_id' => undef,
    }) if @$rows;
    return @res;
}

1;
