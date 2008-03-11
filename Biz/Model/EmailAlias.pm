# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EmailAlias;
use strict;
use Bivio::Base 'Biz.PropertyModel';

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

sub format_realm_as_incoming {
    my($self, $realm) = @_;
    $realm ||= $self->req('auth_realm');
    return (
	@{$self->map_iterate(
	    sub {shift->get('incoming')},
	    'incoming asc',
	    {outgoing => $realm->get_nested(qw(owner name))},
	)},
	$realm->get('owner')->format_email,
    )[0];
}

1;
