# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::API;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.ClassLoaderAUTOLOAD');

my($_API_JSON) = b_use('Agent.TaskId')->API_JSON;
my($_VERSION_PREFIX) = '/v1';

sub execute_json {
    my($proto, $req) = @_;
    $req->put_req_is_json;
    return $proto->task_error($req, 'no path_info')
        unless my $pi = $req->get('path_info');
    return $proto->task_error(
        $req, $pi, ": invalid or missing version (expecting $_VERSION_PREFIX)")
        unless $pi =~ s{^$_VERSION_PREFIX(?=/)}{}so;
    my($t, $r, $p) = b_use('FacadeComponent.Task')->parse_uri($pi, $req);
    return {
        method => 'server_redirect',
        realm => $r,
        task_id => $t,
        carry_query => 1,
        path_info => $p,
        no_context => 1,
        form => $req->get_form,
    };
}

sub format_uri {
    my($proto, $uri_params) = @_;
    my($req) = delete($uri_params->{req});
    my($uri) = $req->format_uri({
        %$uri_params,
        no_context => 1,
        query => undef,
        require_absolute => 0,
        carry_query => 0,
        carry_path_info => 1,
        acknowledgement => undef,
        require_secure => 0,
        anchor => undef,
        no_form => 1,
        require_context => 0,
    });
    $uri_params->{query} = $req->get('query')
        if $uri_params->{carry_query};
    return $req->format_stateless_uri({
        task_id => $_API_JSON,
        path_info => $_VERSION_PREFIX . $uri,
        query => $uri_params->{query},
        anchor => $uri_params->{anchor},
    });
}

sub task_error {
    my($proto, $req, @msg) = @_;
    $req->warn(@msg)
        if @msg;
    return b_use('Action.JSONReply')->execute_api($req)
}

1;
