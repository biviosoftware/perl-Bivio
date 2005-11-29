# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmFile;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($self, $req, $is_public) = @_;
    my($f) = Bivio::Biz::Model->new($req, 'RealmFile');
    $req->get('reply')->set_output(
	$f->load({
	    is_folder => 0,
	    path_lc => lc($f->parse_path($req->get('path_info'))),
	    defined($is_public) ? (is_public => $is_public) : (),
	})->get_handle,
    )->set_output_type($f->get_content_type);
    return;
}

sub execute_public {
    return shift->execute(shift(@_), 1);
}

1;
