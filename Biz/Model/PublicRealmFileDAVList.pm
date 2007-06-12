# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::PublicRealmFileDAVList;
use strict;
use Bivio::Base 'Model.RealmFileDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RF) = Bivio::Biz::Model->get_instance('RealmFile');
my($_FP) = Bivio::Type->get_instance('FilePath');

sub dav_is_read_only {
    return 1;
}

sub load_dav {
    my($self) = @_;
    my($req) = $self->get_request;
    $req->put(path_info => $_FP->to_public(
	$_RF->parse_path($req->get('path_info'), $self)));
    return shift->SUPER::load_dav(@_);
}

1;
