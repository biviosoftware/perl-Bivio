# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::PingReply;
use strict;
use Bivio::Base 'Action.EmptyReply';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_HANDLERS) = b_use('Biz.Registrar')->new;

sub execute {
    my($proto, $req) = @_;
    return $proto->SUPER::execute(
	$req,
	grep(!$_, @{$_HANDLERS->call_fifo(handle_ping_reply => [$req])})
	    ? 'HTTP_PRECONDITION_FAILED' : 'HTTP_OK',
	$_DT->now_as_file_name,
    );
}

sub register_handler {
    shift;
    $_HANDLERS->push_object(@_);
    return;
}

1;
