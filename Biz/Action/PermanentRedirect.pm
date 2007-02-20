# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::PermanentRedirect;
use strict;
use base 'Bivio::Biz::Action';
use Bivio::IO::Config;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register(my $_CFG = {
    redirects => {},
    redirect_patterns => [],
});

sub execute {
    my($proto, $req) = @_;
    my($request_uri) = $req->get('uri');
    my($correct_uri) = $_CFG->{redirects}->{$request_uri};
    unless (defined($correct_uri)) {
	my($patterns) = [@{$_CFG->{redirect_patterns}}];
	while(my($re, $replace) = splice(@$patterns, 0, 2)) {
	    if (my @groups = $request_uri =~ $re) {
		$correct_uri = $replace->(@groups);
		last;
	    }
	}
    }

    Bivio::Die->throw(MODEL_NOT_FOUND => {entity => $request_uri})
	unless $correct_uri;

    return {uri => $correct_uri};
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

1;
