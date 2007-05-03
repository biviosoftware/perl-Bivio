# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::SiteRoot;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub VALID_METHOD_REGEXP {
    return qr{^hm_}s;
}

sub unsafe_new {
    my($proto, $name) = (shift, shift);
    $name =~ s/[\W_]+/_/g;
    $name =~ s/^_//;
    return undef
	unless $name =~ $proto->VALID_METHOD_REGEXP;
    my($self) = $proto->SUPER::unsafe_new($name, @_);
    return $self && $self->put(view_name => $name);
}

sub execute_task_item {
    my($proto, $view_name, $req) = @_;
    return shift->SUPER::execute_task_item(
	$view_name eq 'execute_uri' ? $req->get('uri') : $view_name, $req)
}

sub format_uri {
    my($proto, $view_name, $req) = @_;
    Bivio::Die->die($view_name, ': invalid view name')
        unless $view_name =~ $proto->VALID_METHOD_REGEXP
        && $proto->can($view_name);
    $view_name =~ s{_}{/}g;
    return $req->format_uri({
	task_id => Bivio::Agent::TaskId->SITE_ROOT,
	path_info => $view_name,
	no_context => 1,
	query => undef,
    });
}

1;
