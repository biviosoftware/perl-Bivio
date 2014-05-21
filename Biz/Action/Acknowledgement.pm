# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Acknowledgement;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TI) = b_use('Agent.TaskId');
my($_T) = b_use('FacadeComponent.Text');
my($_HTML) = b_use('Bivio.HTML');
b_use('Agent.Task')->register(__PACKAGE__);
b_use('Agent.Request')->register_handler(__PACKAGE__);
our($_TRACE);

sub SAVE_LABEL_DEFAULT {
    # IMPLICIT: save_label
    return 0;
}

sub QUERY_KEY {
    return 'ack';
}

sub execute {
    shift->extract_label(@_);
    return 0;
}

sub exists_in_facade {
    my($proto, $req, $label) = @_;
    return $_T->get_from_source($req)->unsafe_get_widget_value_by_name(
	"acknowledgement." . $label);
}

sub extract_and_delete_label {
    my($proto, $req) = @_;
    my($label) = $proto->extract_label($req);
    $proto->delete_from_req($req);
    return $label;
}

sub extract_label {
    my($proto, $req) = @_;
    return _extract($proto, $req)
	|| $req->unsafe_get_nested($proto->package_name, 'label');
}

sub handle_client_redirect {
    my($proto, $named, $req) = @_;
    return
	if $named->{uri} =~ /\b@{[$proto->QUERY_KEY]}=/;
    return
	unless my $label = $proto->extract_and_delete_label($req);

    if (my $t = $_TI->unsafe_from_name($label)) {
	$label = $t->as_int;
    }
    $named->{uri} .= ($named->{uri} =~ /\?/ ? '&' : '?')
	. $proto->QUERY_KEY
	. '='
	. $_HTML->escape_query($label);
    return;
}

sub handle_pre_execute_task {
    my($proto, $task, $req) = @_;
    $proto->execute($req);
    return;
}

sub handle_server_redirect {
    my($proto, $named, $req) = @_;
    return
	if ($named->{query} ||= {})->{$proto->QUERY_KEY};
    return
	unless my $label = $proto->extract_and_delete_label($req);
    ($named->{query} ||= {})->{$proto->QUERY_KEY} = $label;
    return;
}

sub save_label {
    my($proto, $label, $req, $query) = @_ >= 3 ? @_ : (shift(@_), undef, @_);
    unless ($label) {
	return
	    unless $proto
		->exists_in_facade($req, $req->get('task_id')->get_name);
	$label = $req->get('task_id');
    }
    unless (ref($label)) {
	if (my $t = $_TI->unsafe_from_name($label)) {
	    $label = $t;
	}
    }
    $label = $label->as_int
	if ref($label);
    _trace($proto->QUERY_KEY, '=', $label) if $_TRACE;
    if (ref($query) eq 'HASH') {
	# Don't override if already set on passed in query
	$query->{$proto->QUERY_KEY} ||= $label;
	return $query;
    }
    my($x) = $req->unsafe_get('form_model');
    $x &&= $x->unsafe_get_context;
    foreach my $y ($x, $req) {
	# Always override in context and request
	($y->unsafe_get('query') || $y->put(query => {})->get('query'))
	    ->{$proto->QUERY_KEY} = $label
	    if $y;
    }
    return;
}

sub save_label_and_execute {
    my($proto, $label, $req) = @_;
    $proto->save_label($label, $req);
    $proto->execute($req);
    return;
}

sub _extract {
    my($proto, $req) = @_;
    my($id) = delete(
	($req->unsafe_get('query') || {})->{$proto->QUERY_KEY});
    return undef
	unless $id;
    my($label);
    if ($id =~ /^\d+$/) {
	b_use('Bivio.Die')->catch_quietly(sub {
            $label = $_TI->from_int($id)->get_name
	});
    }
    else {
    	$label = $id;
    }
    $proto->new($req)->put_on_request($req)->put(label => $label)
	if $label;
    _trace($proto->QUERY_KEY, '=', $label) if $_TRACE;
    return $label;
}

1;
