# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::Embed::Request;
use strict;
use Bivio::Base 'Agent.Request';

my($_HTML) = b_use('Bivio.HTML');
my($_F) = b_use('UI.Facade');
my($_R) = b_use('AgentEmbed.Reply');

sub agent_execution_is_secure {
    return 1;
}

sub get_form {
    my($self) = @_;
    return $self->get('form');
}

sub internal_need_to_toggle_secure_agent_execution {
    return 0;
}

sub new {
    my(undef, $req, $full_uri, $params) = @_;
    my($self) = shift->internal_new($params || {});
    $self->put_durable(
        @{$req->map_each(sub {
            my(undef, $k, $v) = @_;
            return $k =~ m{
                ^(?:client_addr|r|is_secure|timezone|auth_user|super_user_id)$
                |\bUserAgent$
            }ix ? ($k => $v) : ();
        })},
        parent_request => $req,
        reply => $_R->new->put(parent_request => $req),
        embed_level => ($req->unsafe_get('embed_level') || 0) + 1,
    );
    $self->throw_die(DIE => {
        message => 'embedding too deep; possible nested loop',
        embed_level => $self->get('embed_level'),
        parent_request => $self->get('parent_request'),
    }) if $self->get('embed_level') > 2;
    if (my $f = $_F->unsafe_get_from_source($req)) {
        $f->setup_request($self);
    }
    $full_uri =~ s/\?(.*)//;
    my($query) = $1;
    return $self->internal_initialize_with_uri(
        $_HTML->unescape($full_uri),
        $query,
    )->put(form => undef);
}

sub unsafe_get_current_root {
    return undef
        unless my $self = shift->get_current;
    foreach my $x (1..10) {
        return $self
            unless my $p = $self->unsafe_get('parent_request');
        $self = $p;
    }
    b_die($self, ': no parent');
    # DOES NOT RETURN
}

1;
