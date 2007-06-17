# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EmailAlias;
use strict;
use base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'email_alias_t',
	as_string_fields => [qw(incoming)],
        columns => {
            incoming => ['Email', 'PRIMARY_KEY'],
	    outgoing => ['EmailAliasOutgoing', 'NOT_NULL'],
        },
    });
}

1;
