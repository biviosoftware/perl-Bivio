# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Acknowledgement;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->use('Agent.Task')->register(__PACKAGE__);
our($_TRACE);
my($_TI) = __PACKAGE__->use('Agent.TaskId');
my($_T) = __PACKAGE__->use('FacadeComponent.Text');

sub QUERY_KEY {
    return 'ack';
}

sub execute {
    shift->extract_label(@_);
    return 0;
}

sub extract_label {
    my($proto, $req) = @_;
    return $req->unsafe_get_nested($proto->package_name, 'label')
	|| _extract($proto, $req);
}

sub handle_pre_execute_task {
    my($proto, $task, $req) = @_;
    $proto->execute($req);
    return;
}

sub save_label {
    my($proto, $label, $req, $query) = @_ >= 3 ? @_ : (shift(@_), undef, @_);
    unless ($label) {
	return
	    unless $_T->get_from_source($req)->unsafe_get_widget_value_by_name(
		"acknowledgement." . $req->get('task_id')->get_name,
	    );
	$label = $req->get('task_id')->as_int;
    }
    _trace($proto->QUERY_KEY, '=', $label) if $_TRACE;
    if (ref($query) eq 'HASH') {
	# Don't override if already set on passed in query
	$query->{$proto->QUERY_KEY} ||= $label;
	return;
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
    return undef
	unless my $l = delete(
	    ($req->unsafe_get('query') || {})->{$proto->QUERY_KEY});
    $l = $_TI->from_int($l)->get_name
	if $l && $l =~ /^\d+$/;
    $proto->new($req)->put_on_request($req)->put(label => $l);
    _trace($proto->QUERY_KEY, '=', $l) if $_TRACE;
    return $l;
}

1;
