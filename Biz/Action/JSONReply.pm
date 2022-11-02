# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::JSONReply;
use strict;
use Bivio::Base 'Action.EmptyReply';

my($_JSON) = b_use('MIME.JSON');

sub execute_api {
    my($proto, $req, $status) = @_;
    return $proto->execute($req, $status || 'BAD_REQUEST');
}

sub execute_check_req_is_json {
    my($proto, $req, $else) = @_;
    return $req->if_req_is_json(
        sub {
            my($t) = $req->get('task_id')->get_name;
            return $proto->execute_api(
                $req,
                $t =~ /FORBIDDEN/ ? 'FORBIDDEN'
                    : $t =~ /NOT_FOUND/ ? 'NOT_FOUND'
                    : 'BAD_REQUEST',
            );
        },
        $else || 0,
    );
}

sub execute_javascript_log_error {
    my($proto, $req) = @_;
    my($json_text) = ($req->get_form || {})->{json};
    if ($json_text) {
        my($json);
        b_use('Bivio.Die')->catch_quietly(sub {
            $json = $_JSON->from_text($json_text);
        });
        $req->warn('javascript error')
            if $proto->is_valid_javascript_error($json);
    }
    return $proto->execute($req, 'HTTP_OK');
}

sub is_valid_javascript_error {
    my($proto, $json) = @_;
    if (ref($json) eq 'HASH'
            && $json->{errorMsg}
            && $json->{url}
            && $json->{lineNumber}
            && $json->{lineNumber} =~ /^\d+$/
            && $json->{lineNumber} > 1
            && $json->{errorMsg} !~ /Error calling method on NPObject/
        ) {
        return 1;
    }
    return 0;
}

1;
