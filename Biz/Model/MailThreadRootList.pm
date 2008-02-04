# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailThreadRootList;
use strict;
use Bivio::Base 'Model.MailThreadList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NOT_FOUND_IF_EMPTY {
    return 0;
}

sub drilldown_uri {
    my($self) = @_;
    my($req) = $self->req;
    return $req->format_uri({
	task_id => $req->get_nested(qw(task thread_task)),
	query => $self->format_query('THIS_CHILD_LIST'),
    });
}

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    delete($info->{parent_id});
    return $self->merge_initialize_info($info, {
	other => [
	    ['RealmMail.thread_parent_id', [undef]],
	],
    });
}

1;
