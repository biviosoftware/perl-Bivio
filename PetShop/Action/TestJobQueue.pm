# Copyright (c) 2017 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Action::TestJobQueue;
use strict;
use Bivio::Base 'Action.EmptyReply';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision: 0.0$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    if ($req->unsafe_get($proto->package_name)) {
        b_info('sleeping');
        sleep(1);
    }
    else {
        b_info('queueing');
        my($self) = $proto->new();
        b_use('AgentJob.Dispatcher')->enqueue(
            $req,
            'TEST_JOB_QUEUE',
            {
                    $self->package_name => $self,
                #auth_id => GENERAL,
    #                auth_user_id => undef,
            },
        );
    }
    return shift->SUPER::execute(@_);
}

1;
