# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::FormModel;
use strict;
use base 'Bivio::Test::Unit';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub inline_commit {
    return sub {
	Bivio::Agent::Task->commit(req());
	return 1;
    } => 1,
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
	    return $params
		unless $method eq 'process';
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
		$case->put('execute_empty' => 1);
		return [$req];
	    }
	    my($hash) = $params->[0];
	    $hash = {
		%{$m->get_fields_for_primary_keys()},
		%$hash,
	    }
		if $m->isa('Bivio::Biz::ListFormModel');
	    return $params
		unless ref($hash) eq 'HASH';
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
	    my($o) = $case->get('object');
	    return $expect
		unless (ref($e) eq 'HASH' && @$expect == 1)
		    || ($o->isa('Bivio::Biz::ListFormModel')
			    && ref($expect->[0]) eq 'HASH');

	    # TODO: is the data munjing different enough for ListFormModel that
	    # maybe need to create a separate bunit type for it?
	    if ($o->isa('Bivio::Biz::ListFormModel')
		    && $case->unsafe_get('execute_empty')) {
		$e = [map(_walk_tree_expect($case, $_), @$expect)];
		my($i) = 0;
		$case->actual_return($o->get_list_model->map_rows(sub {
		    my($list) = @_;
		    return {map(($_ => $list->unsafe_get($_)),
				keys(%{$e->[$i++]}))};
		}));
	    }
	    else {
		$e = _walk_tree_expect($case, $e);
		$case->actual_return([
		    $case->unsafe_get('execute_empty')
			? {map(($_ => $o->unsafe_get($_)), keys(%$e))}
			    : $o->in_error
			? {map(($_ => $o->get_field_error($_)
				    ? $o->get_field_error($_)->get_name
				: undef),
			       keys(%$e))}
			: _walk_tree_actual($case, $e, [])
		    ]);
		$e = [$e];
	    }
	    return $e;
	},
	#TODO compute_return
	%$attrs,
    });
}

sub run_unit {
    return shift->SUPER::run_unit(@_)
	if @_ == 3;
    my($self, $case_group) = @_;
    my($req) = Bivio::Test::Request->initialize_fully;
    return $self->SUPER::run_unit([
	map(([$req] => [
	    ref($case_group->[0]) eq 'CODE' ? splice(@$case_group, 0, 2)
		: (process => [splice(@$case_group, 0, 2)]),
	    ]), 1 .. @$case_group/2),
    ]);
}

sub _walk_tree_actual {
    my($case, $e, $names) = @_;
    return ref($e) eq 'HASH'
	? {map(($_ => _walk_tree_actual($case, $e->{$_}, [@$names, $_])),
	       keys(%$e))}
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
