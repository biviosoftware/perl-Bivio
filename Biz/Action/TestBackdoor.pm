# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::TestBackdoor;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
use base ('Bivio::Biz::Action');
@Bivio::Biz::Action::TestBackdoor::ISA = ('Bivio::Biz::Action');

sub execute {
    my($proto, $req) = @_;
    # Extract form_model from $req.query and execute with remaining query
    # arguments.
    my($m) = Bivio::Biz::Model->get_instance(
	delete((my $q = $req->get('query'))->{form_model}));
    $m->execute($req, {
	map(($_ => ($m->get_field_type($_)->from_literal($q->{$_}))[0]),
	    keys(%$q)),
    });
    return;
}

1;
