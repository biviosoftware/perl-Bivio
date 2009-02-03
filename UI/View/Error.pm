# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Error;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub default {
    my($self, @extra) = @_;
    return shift->internal_body(DIV_page_error(
	Join([
            [sub {
                 my($source, $status, $ff) = @_;
                 my($req) = $source->req;
                 return $ff ? $req->with_realm(
                     $ff->unsafe_realm_name_from_context, sub {
                         return vs_text_as_prose($req, "page_error.$status");
                     }) : vs_text_as_prose("page_error.$status");
             },
             [qw(->req Action.Error status)],
             [qw(->ureq Model.ForbiddenForm)],
            ],
            ' ',
            Cond(
                @extra,
                map(($_->[0] => XLink($_->[1])),
                    [['->req', 'Action.Error', 'uri'] => 'page_error_referer'],
                    [['auth_user_id'] => 'page_error_user'],
                    [1 => 'page_error_visitor'],
                )
            ),
	]),
    ));
}

1;
