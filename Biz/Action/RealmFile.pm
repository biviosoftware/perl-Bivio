# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmFile;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($self, $req, $is_public) = @_;
    my($f) = Bivio::Biz::Model->new($req, 'RealmFile');
    my($p, $e) = $f->get_field_type('path')
	->from_literal($req->get('path_info'));
    Bivio::Die->throw(NOT_FOUND => {
	entity => $req->get('path_info'),
	message => 'bad RealmFile.path',
	type_error => $e,
    }) if $e;
    my($h) = $f->load({
	is_folder => 0,
	volume => $req->get('Type.FileVolume'),
	path_lc => lc($p),
	defined($is_public) ? (is_public => $is_public) : (),
    })->get_handle;
    my($reply) = $req->get('reply');
    my($t) = Bivio::MIME::Type->from_extension($p);
    $reply->set_output_type($f->get_content_type);
    $reply->set_output($h);
    return;
}

sub execute_public {
    return shift->execute(shift(@_), 1);
}

1;
