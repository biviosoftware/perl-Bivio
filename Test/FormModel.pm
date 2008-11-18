# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::FormModel;
use strict;
use Bivio::Base 'TestUnit.Unit';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_M) = b_use('Biz.Model');
my($_A) = b_use('IO.Alert');
my($_R) = b_use('IO.Ref');

sub empty_case {
    my($proto, $return) = @_;
    return ([] => [{
	$proto->builtin_class() => $return,
    }]);
}

sub error_case {
    return shift->simple_case(@_);
}

sub simple_case {
    my($proto, $input, $return) = @_;
    return ([$input] => [{
	$proto->builtin_class() => $return,
    }]);
}

sub new_unit {
    my($proto, $class_name, $attrs) = @_;
    my($class) = $proto->use(($attrs ||= {})->{class_name} ||= $class_name);
    $proto->builtin_options({class_name => $class});
    # $attrs gets passed to SUPER below and SUPER doesn't know setup_request
    my($setup_request) = delete($attrs->{setup_request});
    $attrs = {}
	unless ref($attrs);
    my($req) = $proto->use('Bivio::Test::Request')->get_instance;
    return $proto->SUPER::new({
	class_name => $_M->get_instance($class)->package_name,
	compute_params => sub {
	    my($case, $params, $method, $object) = @_;
	    $object->reset_instance_state;
	    return $params
		unless $method eq 'process';
	    if (my $l = $req->unsafe_get('Model.Lock')) {
		$l->release;
	    }
	    _setup_request($proto, $setup_request, @_);
	    unless (@$params) {
		$req->delete('form');
		return [$req];
	    }
	    my($hash) = $params->[0];
	    return $params
		unless ref($hash) eq 'HASH';
	    $hash = {
		%{$object->get_fields_for_primary_keys()},
		%$hash,
	    } if $object->isa('Bivio::Biz::ListFormModel');
	    Bivio::Die->die('You must set empty_row_count on case: ', $case)
	        if $object->isa('Bivio::Biz::ExpandableListFormModel')
	        && !exists($hash->{empty_row_count});
	    Bivio::Die->die(
		ref($object),
		': auxiliary form; set task with initialize_fully; primary=',
		$req->get('task')->get('form_model'),
	    ) if $object->is_auxiliary_on_task;
	    return [$req->put(
		form => {
		    $object->VERSION_FIELD => $object->get_info('version'),
		    map({
			my($t) = $object->get_field_type($_);
			my($v) = $hash->{$_};
			$v = $v->($case)
			    if ref($v) eq 'CODE';
			($object->get_field_name_for_html($_) =>
			     ($t->isa('Bivio::Type::FileField')
				  ? $v
				  : $t->to_literal($v)));
		    } keys(%$hash),
		    )},
	    )];
	},
	check_return => sub {
	    my($case, $actual, $expect) = @_;
	    return $expect
		unless $case->get('method') eq 'process';
	    $req->put(actual_return => $actual->[0]);
	    my($e) = $expect->[0];
	    if ($case->get('comparator') eq 'nested_contains') {
		$case->actual_return([_walk_tree_actual($case, $e, $req)]);
		return [$e];
	    }
	    my($o) = $case->get('object');
	    return $expect
		unless (ref($e) eq 'HASH' && @$expect == 1)
		    || ($o->isa('Bivio::Biz::ListFormModel')
			    && ref($expect->[0]) eq 'HASH');
	    $e = _walk_tree_expect($case, $e);
	    $case->actual_return([_walk_tree_actual($case, $e, $req)]);
	    return [$e];
	},
	%$attrs,
    });
}

sub req_state {
    my($proto, $params) = @_;
    $params = $_R->nested_copy($params);
    return sub {
	$proto->builtin_self->put(req_state => $params);
	return 1;
    } => 1;
}

sub req_state_merge {
    my($proto, $params) = @_;
    $params = $_R->nested_copy($params);
    return sub {
	my($self) = $proto->builtin_self;
	$self->put(req_state => {
	    %{$self->get_or_default('req_state', {})},
	    %$params,
	});
	return 1;
    } => 1;
}

sub run_unit {
    return shift->SUPER::run_unit(@_)
	if @_ == 3;
    my($self, $case_group) = @_;
    my($req) = Bivio::Test::Request->initialize_fully;
    return $self->SUPER::run_unit(
	$self->map_by_two(sub {
            my($params, $return) = @_;
	    return ([$req] => [
		ref($params) eq 'ARRAY' ? (process => [$params => $return])
		    : ($params, $return),
	    ]);
	}, $case_group),
    );
}

sub _eval {
    return map(ref($_) eq 'CODE' ? $_->() : $_, @_);
}

sub _field_err {
    my($o, $field) = @_;
    my($ed) = $o->get_field_error_detail($field);
    return $o->get_field_error($field)->get_name
	. ($ed ? ": $ed" : '');
}

sub _setup_request {
    my($proto, $setup_request, $case, $params, undef, $object) = @_;
    my($self) = $proto->builtin_self;
    my($req) = $proto->builtin_req;
    $req->clear_nondurable_state;
    $req->put(
	path_info => undef,
	query => undef,
	form => undef,
    );
    $req->get('task')->put_attr_for_test(
	form_model => ref($object),
	next => $req->get('task_id'),
	require_context => 0,
    ) unless $req->get('task')->unsafe_get_attr_as_id('next')
	&& !$req->get('task_id')->eq_shell_util;
    if (my $rs = $self->unsafe_get('req_state')) {
	$rs = {%$rs};
        foreach my $p (qw(user realm)) {
	    next
		unless exists($rs->{$p});
	    my($m) = "set_$p";
	    $req->$m(_eval(delete($rs->{$p})));
	};
	if (my $t = delete($rs->{task})) {
	    $req->initialize_fully(_eval($t));
	}
	$req->put(_eval(%$rs))
	    if %$rs;
    }
    $setup_request->($case, $params)
	if $setup_request;
    return;
}

sub _walk_tree_actual {
    my($case, $e, $o) = @_;
    return ref($e) eq 'HASH'
	? {map(($_ => _walk_tree_actual(
	    $case, $e->{$_},
	    !defined($o) ? undef
		: UNIVERSAL::can($o, 'unsafe_get')
		? $o->can('get_field_error') && $o->get_field_error($_)
		? _field_err($o, $_)
		: $o->unsafe_get($_)
		: ref($o) eq 'HASH' ? $o->{$_}
		: ref($o) eq 'ARRAY' && $_ =~ /^\d+$/ ? $o->[$_]
		: $_A->format_args($_, ': not index of ', $o))),
	    keys(%$e),
	)} : $o;
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
