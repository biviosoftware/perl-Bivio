# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::UserCreateDone;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_V) = b_use('UI.View');

sub internal_views {
    my(undef, $req) = @_;
    return [
        $req->get('Model.UserRegisterForm')
	    ->unsafe_get('unapproved_applicant_mode')
	    ? 'UserAuth->unapproved_applicant_mail' : (),
	qw(UserAuth->create_mail UserAuth->create_done),
    ];
}

sub execute {
    my($proto, $req) = @_;
    foreach my $v (@{$proto->internal_views($req)}) {
	next unless my $res = $_V->execute($v, $req);
	return $res;
    }
    return 0;
}

1;
