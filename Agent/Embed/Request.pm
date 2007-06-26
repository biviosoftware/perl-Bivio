# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
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
    my($query) = $1
	if $full_uri =~ s/\?(.*)//;
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
    my($task_id, $auth_realm, $path_info, $uri)
	= Bivio::UI::Task->parse_uri($full_uri, $self);
    $self->internal_set_current();
    $query = Bivio::Agent::HTTP::Query->parse($query);
    delete($query->{auth_id})
	if $query;
    return $self->put_durable(
	uri => $uri && Bivio::HTML->escape_uri($uri),
	query => $query,
	path_info => $path_info,
	task_id => $task_id,
	form => undef,
    )->internal_initialize($auth_realm, $self->get('auth_user'));
}

1;
