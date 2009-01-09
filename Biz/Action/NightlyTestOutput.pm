# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::NightlyTestOutput;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    b_use('Test.Util')->nightly_output_to_wiki(
	$req->get('Model.MailReceiveDispatchForm')
	->get('message')->{content},
    );
    return 0;
}

1;
