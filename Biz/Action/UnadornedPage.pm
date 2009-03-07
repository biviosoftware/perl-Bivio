# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::UnadornedPage;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    my($reply) = b_use('AgentEmbed.Dispatcher')
	->call_task($req, $req->format_uri({
	    uri => $req->unsafe_get('path_info') || '/',
	    path_info => undef,
	    query => $req->unsafe_get('query'),
	    anchor => undef,
	    no_context => 1,
	}));
    my($ot) = $reply->get_output_type;
    my($o) = $reply->get_output;
    $o = \("<html><body>$$o</body></html>")
	if $ot eq 'text/html' && $$o !~ /<html>/i;
    $req->get('reply')->set_output($o)->set_output_type($ot);
    return 1;
}

1;
