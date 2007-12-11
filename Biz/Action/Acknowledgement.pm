# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Acknowledgement;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);

sub QUERY_KEY {
    return 'ack';
}

sub execute {
    shift->extract_label(@_);
    return 0;
}

sub extract_label {
    my($proto, $req) = @_;
    if (my $l = delete(($req->unsafe_get('query') || {})->{$proto->QUERY_KEY})) {
	$l = Bivio::Agent::TaskId->from_int($l)->get_name
	    if $l && $l =~ /^\d+$/;
	$proto->new($req)->put_on_request($req)->put(label => $l);
	_trace($proto->QUERY_KEY, '=', $l) if $_TRACE;
	return $l;
    }
    $proto->delete_from_request($req);
    return undef;
}

sub save_label {
    my($proto, $label, $req, $query) = @_ >= 3 ? @_ : (shift(@_), undef, @_);
    unless ($label) {
	return unless Bivio::UI::Text->get_from_source($req)
	    ->unsafe_get_widget_value_by_name(
		"acknowledgement." . $req->get('task_id')->get_name,
	    );
	$label = $req->get('task_id')->as_int;
    }
    _trace($proto->QUERY_KEY, '=', $label) if $_TRACE;
    if (ref($query) eq 'HASH') {
	$query->{$proto->QUERY_KEY} = $label;
	return;
    }
    my($x) = $req->unsafe_get('form_model');
    $x &&= $x->unsafe_get_context;
    foreach my $y ($x, $req) {
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

1;
