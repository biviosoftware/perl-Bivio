# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::FormModel;
use strict;
use base 'Bivio::Test::Unit';

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

sub file_field {
    return shift->use('Bivio::Biz::FormModel')->format_file_field(@_);
}

sub simple_case {
    my($proto, $input, $return) = @_;
    return ([$input] => [{
	$proto->builtin_class() => $return,
    }]);
}

sub new_unit {
    my($proto, $class, $attrs) = @_;
    # $attrs gets passed to SUPER below and SUPER doesn't know setup_request
    my($fn) = delete($attrs->{setup_request});
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
	    }));
	    $fn->($case)
		if ref($fn) eq 'CODE';
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
			($m->get_field_name_for_html($_) =>
			     ($t->isa('Bivio::Type::FileField') ? $hash->{$_}
				  : $t->to_literal($hash->{$_})));
		    } keys(%$hash),
		    )},
	    )];
	},
	check_return => sub {
	    my($case, $actual, $expect) = @_;
	    return $expect
		unless $case->get('method') eq 'process';
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
	    $e = [$e];
	    return $e;
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

sub _walk_tree_actual {
    my($case, $e, $o) = @_;
    return ref($e) eq 'HASH'
	? {map(($_ => _walk_tree_actual(
	    $case, $e->{$_},
	    !defined($o) ? undef
		: UNIVERSAL::can($o, 'unsafe_get')
		? $o->can('get_field_error') && $o->get_field_error($_)
		? $o->get_field_error($_)->get_name
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
