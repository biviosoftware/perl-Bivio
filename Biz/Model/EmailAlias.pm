# Copyright (c) 2006-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EmailAlias;
use strict;
use Bivio::Base 'Biz.PropertyModel';

my($_E) = b_use('Type.Email');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'email_alias_t',
        as_string_fields => [qw(incoming)],
        columns => {
            incoming => ['EmailAliasIncoming', 'PRIMARY_KEY'],
            outgoing => ['EmailAliasOutgoing', 'NOT_NULL'],
        },
    });
}

sub format_realm_as_incoming {
    my($self, $realm_owner) = @_;
    $realm_owner ||= $self->req(qw(auth_realm owner));
    return $self->new_other('RowTag')
        ->get_value($realm_owner->get('realm_id'), 'CANONICAL_EMAIL_ALIAS')
        || $self->get_all_emails($realm_owner)->[0];
}

sub format_realm_as_sender {
    my($self, $incoming_email) = @_;
    return $self->new_other('RowTag')
        ->get_value($self->req('auth_id'), 'CANONICAL_SENDER_EMAIL')
        || $incoming_email
        || $self->format_realm_as_incoming;
}

sub get_all_emails {
    my($self, $realm_owner) = @_;
    $realm_owner ||= $self->req(qw(auth_realm owner));
    return [
        @{$self->map_iterate(
            sub {shift->get('incoming')},
            'incoming asc',
            {outgoing => $realm_owner->get('name')},
        )},
        $realm_owner->get('realm_type')->eq_user
            ? $self->new_other('Email')
                ->unauth_load_or_die({realm_id => $realm_owner->get('realm_id')})
                ->get('email')
            : $realm_owner->format_email,
    ];
}

sub incoming_to_outgoing {
    my($self, $recipient) = @_;
#TODO: Deal with plussed recipients
#TODO: Allow @foo => joe@bar  joe@foo => @bar (joe@bar)
    return $self->get('outgoing')
        if $self->unsafe_load({incoming => $recipient});
    my($local, $domain) = $_E->split_parts($recipient);
    return
        unless $local;
    my($t) = $self->get_field_type('outgoing');
    return $_E->join_parts(
        $local,
        $t->get_domain_part($self->get('outgoing')),
    ) if $self->unsafe_load({incoming => $t->format_domain($domain)});
    return;
}

1;
