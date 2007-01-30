# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::View::SiteRoot;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub VALID_METHOD_REGEXP {
    return qr{^hm_}s;
}

sub execute_task_item {
    my($proto, $view_name, $req) = @_;
    return shift->SUPER::execute_task_item(@_)
	unless $view_name eq 'execute_uri';
    (my $uri = $req->get('uri')) =~ s/\W+/_/g;
    $uri =~ s/^_+//;
    Bivio::Die->throw('NOT_FOUND', {
	message => 'view not found',
	entity => $uri,
	class => $proto,
    }) unless $uri =~ $proto->VALID_METHOD_REGEXP;
    return shift->SUPER::execute_task_item($uri, $req);
}

1;
