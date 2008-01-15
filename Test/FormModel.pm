# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::FormModel;
use strict;
use Bivio::Base 'TestUnit.Unit';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    my($model) = $class;
    $attrs = {}
	unless ref($attrs);
    my($req) = $proto->use('Bivio::Test::Request')->get_instance;
    my($m) = Bivio::Biz::Model->new($req, $model);
    return $proto->SUPER::new({
	class_name => $m->package_name,
	compute_params => sub {
	    my($case, $params, $method, $object) = @_;
	    $m->reset_instance_state;
	    return $params
		unless $method eq 'process';
	    if (my $l = $req->unsafe_get('Model.Lock')) {
		$l->release;
	    }
	    $req->clear_nondurable_state;
	    $req->put(task => Bivio::Collection::Attributes->new({
		form_model => ref($m),
		next => $req->get('task_id'),
		require_context => 0,
	    })) unless $req->unsafe_get_nested(qw(task next))
		&& !$req->get('task_id')->eq_shell_util;
	    $setup_request->($case, $params)
		if $setup_request;
	    unless (@$params) {
		$req->delete('form');
		return [$req];
	    }
	    my($hash) = $params->[0];
	    return $params
		unless ref($hash) eq 'HASH';
	    $hash = {
		%{$m->get_fields_for_primary_keys()},
		%$hash,
	    } if $m->isa('Bivio::Biz::ListFormModel');
	    Bivio::Die->die('You must set empty_row_count on case: ', $case)
	        if $m->isa('Bivio::Biz::ExpandableListFormModel')
	        && !exists($hash->{empty_row_count});
	    return [$req->put(
		form => {
		    $m->VERSION_FIELD => $m->get_info('version'),
		    map({
			my($t) = $m->get_field_type($_);
			my($v) = $hash->{$_};
			$v = $v->($case)
			    if ref($v) eq 'CODE';
			($m->get_field_name_for_html($_) =>
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

sub _field_err {
    my($o, $field) = @_;
    my($ed) = $o->get_field_error_detail($field);
    return $o->get_field_error($field)->get_name
	. ($ed ? ": $ed" : '');
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
		: Bivio::IO::Alert->format_args($_, ': not index of ', $o))),
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
