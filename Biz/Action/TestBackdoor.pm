# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::TestBackdoor;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    $req->assert_test;
    my($q) = $req->get('query');
    if (my $m = delete($q->{form_model})) {
	$m = Bivio::Biz::Model->get_instance($m);
	$m->execute($req, {
	    map(($_ => ($m->get_field_type($_)->from_literal($q->{$_}))[0]),
		keys(%$q)),
	});
    }
    elsif (my $u = delete($q->{shell_util})) {
	Bivio::ShellUtil->new_other($u)->main(split(' ', $q->{command}));
    }
    else {
	Bivio::Die->die($q, ': invalid query');
    }
    return;
}

1;
