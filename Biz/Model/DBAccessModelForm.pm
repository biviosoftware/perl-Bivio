# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::DBAccessModelForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_A) = b_use('Action.Acknowledgement');
my($_CL) = b_use('IO.ClassLoader');
my($_COUNT) = b_use('SQL.ListQuery')->to_char('count');
my($_DT) = b_use('Type.DateTime');
my($_E) = b_use('Type.Enum');
my($_ES) = b_use('Type.EnumSet');
my($_PAGE) = b_use('SQL.ListQuery')->to_char('page_number');
my($_PM) = b_use('Biz.PropertyModel');
my($_PN) = b_use('Type.PerlName');
my($_SEARCH) = b_use('SQL.ListQuery')->to_char('search');
my($_T) = b_use('Bivio.Type');
my($_CANCEL_BUTTONS) = [map(
    $_ . '_button',
    qw(clear_form first prev next last delete),
)];
my($_OK_BUTTONS) = [map(
    $_ . '_button',
    qw(search update create),
)];
my($_ALL_FIELDS);

sub execute_empty {
    my($self) = @_;
    my($model_name) = _model_from_path_info($self);
    my($query) = $self->req('query');
#TODO: User data needs to be type-checked
    my($status) = $query->{$_SEARCH};
    if (defined($query->{$_PAGE})) {
	$query->{$_COUNT} ||= _get_row_count($self, $query, $model_name);
	if ($query->{$_PAGE} <= $query->{$_COUNT}) {
	    if (my $row = _get_nth_row($self, $query, $model_name)) {
		foreach my $field (@{$row->get_keys}) {
		    $self->internal_put_field(
			"$model_name.$field",
			_value_db_to_form($self, $model_name, $field, $row->get($field)),
		    );
		}
	    }
	}
	$status ||= $query->{$_COUNT} > 0
	    ? "Displaying row $query->{$_PAGE} of $query->{$_COUNT}"
	    : "No rows found";
    }
    $self->internal_put_field('status', $status);
    return;
}

sub execute_cancel {
    return _execute_ok_cancel(@_);
}

sub execute_ok {
    return _execute_ok_cancel(@_);
}

sub get_all_fields {
    my($self) = @_;
    return $_ALL_FIELDS
	if $_ALL_FIELDS;
    $_ALL_FIELDS = {};
    $_PM->do_iterate_model_subclasses(sub {
	my($class) = @_;
	my($m) = $class->get_instance;
	foreach my $field (@{$m->get_info('column_names')}) {
	    $_ALL_FIELDS->{$m->simple_package_name}->{$field} = {
		map(($_ => $m->get_field_info($field, $_)), qw(type constraint)),
		related => [],
	    };
	}
	return 1;
    });
    foreach my $class (keys(%$_ALL_FIELDS)) {
	my($m) = b_use('Model.' . $class)->new;
	while (my($model, $pv) = each(%{$m->get_info('parents')})) {
	    while (my($fk, $fn) = each(%$pv)) {
		push(@{$_ALL_FIELDS->{$class}->{$fk}->{related}}, {
		    model => $model,
		    field => $fn,
		});
	    }
	}
	foreach my $child (@{$m->get_info('children')}) {
	    while (my($fk, $fn) = each(%{$child->[1]})) {
		my($model) =  $child->[0]->simple_package_name;
		push(
		    @{$_ALL_FIELDS->{$class}->{$fn}->{related}},
		    {
			model => $model,
			field => $fk,
		    },
		) if $_ALL_FIELDS->{$model}
		    && $_ALL_FIELDS->{$model}->{$fn}
		    && $_ALL_FIELDS->{$model}->{$fn}->{related};
	    }
	}
    }
    return $_ALL_FIELDS;
}

sub get_all_rows {
    my($self, $req) = @_;
    my($query) = $req->get('query');
    my($model_name) = _model_from_path_info($self);
    my($res) = [];
    my($index) = 0;
    _do_iterate(
	$self,
	$query,
	$model_name,
	sub {
	    my($it) = @_;
	    my($row) = {
		index => ++$index,
	    };
	    foreach my $field (@{$it->get_keys}) {
		my($f) = $field =~ qr{([^\.]*)$};
		my($t) = _field_type($self, $model_name, $field);
		my($dbv) = $it->get($field);
		my($fv);
		$fv = $t->to_xml($dbv)
		    if $_DT->is_super_of($t);
		$fv = $t->to_literal($dbv)
		    if $_ES->is_super_of($t);
		$fv = $dbv
		    unless defined($fv);
		$row->{"$model_name.$field"} = $fv;
	    }
	    push(@$res, $row);
	    return 1;
	},
    );
    return $res;
}


sub get_property_model_names {
    return [sort(keys(%{shift->get_all_fields}))];
}

sub get_qualified_fields {
    my($self) = @_;
    my($model_name) = _model_from_path_info($self);
    return [map(
	"$model_name.$_",
	sort(keys(%{_model_fields($self, $model_name)})),
    )];
}

sub get_related {
    my($self, $model_name, $field) = @_;
    return _field_attr($self, $model_name, $field, 'related');
}

sub internal_initialize {
    my($self) = @_;
    my($visible) = [];
    while (my($model_name, $fields) = each(%{$self->get_all_fields})) {
    	foreach my $field (sort(keys(%$fields))) {
    	    my($e) = {
    		name => "$model_name.$field",
    		type => _type_map(_field_type($self, $model_name, $field)),
    		constraint => 'NONE',
    	    };
    	    push(@$visible, $e);
    	}
    }
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1, 
	visible => [
	    @$visible,
	    $self->field_decl(['status'], 'String'),
	    $self->field_decl($_CANCEL_BUTTONS, 'CancelButton'),
	    $self->field_decl($_OK_BUTTONS, 'OKButton'),
	],
    });
}

sub relation_exists {
    my($self, $qualified_field_name, $related_model, $related_field) = @_;
    return $self->has_fields($qualified_field_name)
	&& $self->new_other($related_model)->unauth_rows_exist(
	    {$related_field => $self->get($qualified_field_name)},
	);
}

sub _do_iterate {
    my($self, $query, $model_name, $op) = @_;
    my($res) = $self->new_other($model_name);
    $res->do_iterate(
	$op,
	'unauth_iterate_start',
	undef,
	{map(
	    $_ =~ /^($_PAGE$|$_SEARCH$|$_COUNT$|_)/o ? ()
		: ($_ => _value_query_to_db($self, $model_name, $_, $query->{$_})),
	    keys(%$query),
	)},
    );
    return $res;
}

sub _execute_ok_cancel {
    my($self, $button) = @_;
    my($query) = $self->req('query');
    delete($query->{$_SEARCH});
    my($sub) = \&{'_handle_' . $button};
    return {
	task_id => 'DEV_DBACCESS_MODEL_FORM',
	carry_path_info => 1,
	query => $sub->($self, $query, _model_from_path_info($self)),
    };
}


sub _field_attr {
    my($self, $model, $field, $attr) = @_;
    return _model_fields($self, $model)->{$field}->{$attr};
}

sub _field_type {
    return _field_attr(@_, 'type');
}

sub _get_nth_row {
    my($self, $query) = @_;
    my($i) = 0;
    my($res) = _do_iterate(
	@_,
	sub {
	    return ++$i < $query->{$_PAGE} ? 1 : 0;
	},
    );
    return $i == $query->{$_PAGE} ? $res : undef;
}

sub _get_row_count {
    my($self) = @_;
    my($c) = 0;
    _do_iterate(
	@_,
	sub {
	    $c++;
	    return 1;
	},
    );
    return $c;
}

sub _handle_clear_form_button {
    return {
	carry_path_info => 1,
    };
}

sub _handle_create_button {
    my($self, $query, $model_name) = @_;
    my($model) = $self->new_other($model_name)->create({
	map(
	    {
		my($v) = _value_form_to_db(
		    $self,
		    $model_name,
		    $_,
		    $self->unsafe_get("$model_name.$_"),
		);
		defined($v) && (($query || {})->{'_' . $_} || 0) == 1
		    ? ($_ => $v) : ();
	    }
	    keys(%{_model_fields($self, $model_name)}),
	),
    });
    my($res) = {
	$_SEARCH => 'Created',
	$_PAGE => 1,
	map(
	    ($_ => _value_db_to_query($self, $model_name, $_, $model->unsafe_get($_))),
	    @{$model->get_keys},
	),
    };
    $res->{$_COUNT} = _get_row_count($self, $res, $model_name);
    return $res;
}

sub _handle_delete_button {
    my($self, $query) = @_;
    return
	unless $query;
    if (my $row = _get_nth_row(@_)) {
	$row->delete;
    }
    return {$_SEARCH => 'Deleted'};
}

sub _handle_first_button {
    my($self, $query) = @_;
    return unless $query;
    return {
	%$query,
        $_PAGE => 1,
    };
}

sub _handle_next_button {
    my($self, $query) = @_;
    return unless $query;
    return {
	%$query,
        $_PAGE => $query->{$_PAGE} + 1 <= $query->{$_COUNT} ? $query->{$_PAGE} + 1
	    : $query->{$_COUNT} > 0 ? $query->{$_COUNT}
	    : 1,
    };
}

sub _handle_last_button {
    my($self, $query) = @_;
    return unless $query;
    return {
	%$query,
        $_PAGE =>  $query->{$_COUNT} > 0 ? $query->{$_COUNT} : 1,
    };
}

sub _handle_prev_button {
    my($self, $query) = @_;
    return unless $query;
    return {
	%$query,
        $_PAGE =>  $query->{$_PAGE} > 1 ? $query->{$_PAGE} - 1 : 1,
    };
}

sub _handle_search_button {
    my($self, $query, $model_name) = @_;
    my($res) = {$_PAGE => 1};
    $query ||= {};
    foreach my $field (keys(%{_model_fields($self, $model_name)})) {
	my($value) = _value_form_to_query(
	    $self,
	    $model_name,
	    $field,
	    $self->unsafe_get("$model_name.$field"),
	);
	next
	    unless defined($value)
	    && ($query->{'_' . $field} || 0) == 1;
	$res->{$field} = $value;
    }
    $res->{$_COUNT} =  _get_row_count($self, $res, $model_name);
    return $res;
}

sub _handle_update_button {
    my($self, $query, $model_name) = @_;
    if (my $row = _get_nth_row(@_)) {
	$row->update({map(
	    {
		my($v) = _value_form_to_db(
		    $self,
		    $model_name,
		    $_,
		    $self->unsafe_get("$model_name.$_"),
		);
		defined($v) ? ($_ => $v) : ();
	    }
	    @{$row->get_keys}
	)});
	my($res) = {
	    $_SEARCH => 'Updated',
	    $_PAGE => 1,
	    map(
		{
		    my($v) = _value_db_to_query($self, $model_name, $_, $row->get($_));
		    defined($v) ? ($_ => $v) : ();
		}
		@{$row->get_keys}
	    ),
	};
	$res->{$_COUNT} =  _get_row_count($self, $res, $model_name);
	return $res;
    }
    return;
}

sub _model_fields {
    my($self, $model) = @_;
    return $self->get_all_fields->{$model};
}

sub _model_from_path_info {
    my($self) = @_;
    return undef
	unless $self->ureq('path_info');
    return $_PN->unsafe_from_path_info($self->req)
	|| b_die($self->req('path_info'), ': invalid path_info');
}

sub _type_map {
    my($type) = @_;
    foreach my $map (
	[qw(PrimaryId Integer)],
	[Enum => $type],
	[Number => 'Line'],
	[EmailVerifyKey => 'Line'],
	[EnumSet => 'Line'],
	[DateTime => 'Line'],
    ) {
	return $map->[1]
	    if $_T->get_instance($map->[0])->is_super_of($type);
    }
    return $type;
}

sub _value_db_to_query {
    my($self, $model_name, $field, $value) = @_;
    return
	unless defined($value);
    my($t) = _field_type($self, $model_name, $field);
    $value = $t->to_sql_param($value)
	if $_E->is_super_of($t);
    return $value;
}

sub _value_db_to_form {
    my($self, $model_name, $field, $value) = @_;
    return
	unless defined($value);
    my($t) = _field_type($self, $model_name, $field);
    return $t->to_xml($value)
	if $_DT->is_super_of($t);
    return $t->to_literal($value)
	if $_ES->is_super_of($t);
    return $value;
}

sub _value_form_to_db {
    my($self, $model_name, $field, $value) = @_;
    return
	unless defined($value);
    my($t) = _field_type($self, $model_name, $field);
    return $t->from_literal($value)
	if $_DT->is_super_of($t);
    return $t->from_literal($value)
	if $_ES->is_super_of($t);
    return $value;
}

sub _value_form_to_query {
    my($self, $model_name, $field, $value) = @_;
    return _value_db_to_query(
	$self,
	$model_name,
	$field,
	_value_form_to_db($self, $model_name, $field, $value),
    );
}
sub _value_query_to_db {
    my($self, $model_name, $field, $value) = @_;
    return
	unless defined($value);
    my($t) = _field_type($self, $model_name, $field);
    return $t->from_int($value)
	if $_E->is_super_of($t);
    return $value;
}


1;
