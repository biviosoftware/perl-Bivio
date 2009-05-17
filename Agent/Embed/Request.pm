# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::Embed::Request;
use strict;
use base 'Bivio::Agent::Request';
use Bivio::Agent::Embed::Reply;
use Bivio::Agent::HTTP::Query;
use Bivio::HTML;
use Bivio::UI::Task;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_form {
    my($self) = @_;
    return $self->get('form');
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
	reply => Bivio::Agent::Embed::Reply->new->put(parent_request => $req),
	embed_level => ($req->unsafe_get('embed_level') || 0) + 1,
    );
    $self->throw_die(DIE => {
	message => 'embedding too deep; possible nested loop',
	embed_level => $self->get('embed_level'),
	parent_request => $self->get('parent_request'),
    }) if $self->get('embed_level') > 2;
    if (my $f = $req->unsafe_get('Bivio::UI::Facade')) {
	$f->setup_request($self);
    }
    $full_uri =~ s/\?(.*)//;
    return $self->internal_initialize_with_uri($full_uri, $1)
	->put(form => undef);
}

1;
