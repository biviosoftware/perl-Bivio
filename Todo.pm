# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$

package Bivio::Todo;

use strict;
use Apache::Constants qw(OK);
use Bivio::ToDo::ToDoUser;
use Bivio::ToDo::ToDoManager;
use URI;
use DBI;


my($_CONNECTION);
my($mgr);

sub _get_manager {
    if(!$mgr){
         $mgr = Bivio::ToDo::ToDoManager->new( );
    }
    return $mgr;
}



# main entry point. We switch to different "views" depending
# on the parameter sent in as part of the query.
sub handler {
    my $r = shift;
    print(STDERR "Todo.handler( ) called..\n\n\n");
    $r->content_type("text/html");
    $r->send_http_header;
    $r->print("<HTML><HEAD><TITLE>Bivio Worker's Todo Lists</TITLE></HEAD>\n");
    $r->print("<BODY bgcolor=\"#C0C0C0\">");
    my(%args) = $r->args;
    my(@keys) = keys %args;
    my(@values) = values %args;
    while(@keys){
	print(STDERR "\n" . pop(@keys) . "=" . pop(@values));
    }
    print(STDERR "\n\n");

    if (%args){
	my($view) = $args{view};
	my($the_user) = $args{user};
	my($manager) = _get_manager( );
	if($manager){
	    my($arguments) = \%args;
	    $manager->render_view($view, $r, $the_user, $arguments);
	}
    }
    else{
	print(STDERR "no arguments found \nDisplaying users...\n\n");
	$mgr = Bivio::ToDo::ToDoManager->new( );
	$mgr->render_view("main", $r);
    }
    $r->print("</BODY></HTML>");
    return OK;
}

#this method is not used.
sub _parse_request {
    my($str) = @_;

    # trim leading and trailing '/'
    $str =~ s|^/(.+)$|$1|;
    $str =~ s|^(.+)/$|$1|;

    my(@parts) = split('/', $str);

    my($target) = $parts[0];
    my($controller) = $parts[1] || '';
    my($view) = $parts[2] || '';

    return ($target, $controller, $view);
}



1;
