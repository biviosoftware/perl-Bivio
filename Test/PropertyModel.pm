# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::PropertyModel;
use strict;
use Bivio::Base 'TestUnit.Unit';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new_unit {
    my($proto, $class, $attrs) = @_;
    $attrs = {}
	unless ref($attrs);
    my($m) = $class;
    return $proto->SUPER::new({
	class_name => $m->package_name,
	check_return => sub {
	    my($case, $actual, $expect) = @_;
	    return $expect
		unless $case->get('method') =~ /^(create|update|load)/;
	    my($e) = $expect->[0];
	    return $expect
		unless ref($e) eq 'HASH' && @$expect == 1;
	    my($o) = $case->get('object');
	    $e = _walk_tree_expect($case, $e);
	    $case->actual_return([_walk_tree_actual($case, $e, [])]);
	    return [$e];
	},
	%$attrs,
    });
}

sub run_unit {
    # Example RealmMail.bunit.
    return shift->new(shift)->unit(shift)
	if @_ == 3;
    my($self, $method_groups) = @_;
    return $self->SUPER::run_unit([
	[$self->builtin_req->initialize_fully] => $method_groups,
    ]);
}

sub _walk_tree_actual {
    my($case, $e, $names) = @_;
    my($o) = $case->get('object');
    return ref($e) eq 'HASH'
	? {map(($_ => _walk_tree_actual($case, $e->{$_}, [@$names, $_])),
	       keys(%$e))}
	: @$names == 1 && $o->has_fields($names->[0])
	? $o->get($names->[0])
	: Bivio::Test::Request->get_instance->unsafe_get_nested(@$names);
}

sub _walk_tree_expect {
    my($case, $e) = @_;
    return ref($e) eq 'HASH'
	? {map(($_ => _walk_tree_expect($case, $e->{$_})), keys(%$e))}
	: ref($e) eq 'CODE'
	    ? $e->($case)
	    : $e;
}

1;
