# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::UserLogout;
use strict;
use Bivio::Base 'Bivio::Biz::Action';

# C<Bivio::Biz::Action::UserLogout> clears the user on the request
# and in the cookie.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    # (proto, Agent.Request) : Agent.TaskId
    # Calls the I<Model.LoginForm> to clear the user.
    my(undef, $req) = @_;
    return Bivio::Biz::Model->get_instance('UserLoginForm')->execute(
	$req, {realm_owner => undef});
}

1;
