# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TimeZoneSelector;
use strict;
use Bivio::Base 'Type.DisplayName';

my($_TZ) = b_use('Type.TimeZone');

sub row_tag_get {
    my(undef, $req) = @_;
#TODO: Only supports implicit realm_id format
    return $req->get('Model.TimeZoneList')
	->display_name_for_enum($_TZ->row_tag_get($req));
}

sub row_tag_replace {
    my(undef, $value, $req) = @_;
#TODO: Only supports implicit realm_id format
    return $_TZ->row_tag_replace(
	$req->get('Model.TimeZoneList')->enum_for_display_name($value),
	$req,
    );
}

1;
