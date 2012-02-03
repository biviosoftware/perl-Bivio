# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::DBAccessModelForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

my($_A) = b_use('Action.Acknowledgement');

my(@_CANCEL_BUTTONS) = map($_ . '_button',
		    qw(clear_form first prev next last  delete));
my(@_OK_BUTTONS) = map($_ . '_button',
		    qw(search update create));

my($_all_fields);

sub execute_empty {
    my($self) = @_;
    my($model_name) = $self->req('path_info') =~ qr{^/(.*)};
    my($query) = $self->req('query');
    my($status) = $query->{s};
    if (defined($query->{n})) {       
	$query->{c} ||= _get_row_count($self, $query, $model_name);
	if ($query->{n} <= $query->{c}) {
	    if (my $row = _get_nth_row($self, $query, $model_name, $query->{n})) {	       
		foreach my $field (@{$row->get_keys}) {
		    $self->internal_put_field($model_name . '.' . $field,
					      _value_db_to_form($model_name, $field, $row->get($field)));
		}
	    }
	}
	$status ||=  $query->{c} > 0 ? "Displaying row $query->{n} of $query->{c}"
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
    my($proto) = @_;
    unless (defined($_all_fields)) {
	$_all_fields = {};
	foreach my $class (@{Bivio::IO::ClassLoader->list_simple_packages_in_map('Model')}) {
	    next if $class =~ /Base$/;	
	    #TODO: investigate FormUserAddForm
	    next if $class eq 'FormUserAddForm';
	    if (b_use('Model.' . $class)->isa('Bivio::Biz::PropertyModel')) {
		my($m) = b_use('Model.' . $class)->new;
		foreach my $field (@{$m->get_info('column_names')}) {
		    $_all_fields->{$class}->{$field} = {
			map(($_ => $m->get_field_info($field, $_)), qw(type constraint)),
			related => [],
		    };
		}
	    }
	}
	foreach my $class (keys(%$_all_fields)) {
	    my($m) = b_use('Model.' . $class)->new;
	    while (my($pk, $pv) = each(%{$m->get_info('parents')})) {
		my($model) = split(qr{\s+}, $pk);
		while (my($fk, $fn) = each(%$pv)) {
		    push(@{$_all_fields->{$class}->{$fk}->{related}}, {
		    	model => $model,
		    	field => $fn,
		    });
		}
	    }
	    foreach my $child (@{$m->get_info('children')}) {	    
		while (my($fk, $fn) = each(%{$child->[1]})) {
		    my($model) =  $child->[0] =~ /([^:]*)$/;
		    next unless defined $_all_fields->{$model};
		    next unless defined $_all_fields->{$model}->{$fn};
		    next unless defined $_all_fields->{$model}->{$fn}->{related};
		    push(@{$_all_fields->{$class}->{$fn}->{related}}, {
		         model => $model,
		         field => $fk,
		    });
		}
	    }
	}
    }
    return $_all_fields;        
}

sub get_all_rows {
    my($proto, $req) = @_;
    my($query) = $req->get('query');
    my($model_name) = $req->get('path_info') =~ qr{^/(.*)};
    my($res) = [];
    my($index) = 0;
    b_use("Model.$model_name")->new()->do_iterate(
	sub {
	    my($model) = @_;
	    my($row) = {
		index => ++$index,
	    };
	    foreach my $field (@{$model->get_keys}) {
		my($f) = $field =~ qr{([^\.]*)$};
		my($t) = get_all_fields()->{$model_name}->{$field}->{type};
		my($dbv) = $model->get($field);
		my($fv);
		$fv = $t->to_xml($dbv) if $t eq 'Bivio::Type::DateTime';
		$fv = $t->to_literal($dbv) if $t->isa('Bivio::Type::EnumSet');
		$fv = $dbv unless defined($fv);
		$row->{"$model_name.$field"} = $fv;
	    }
	    push(@$res, $row);
	    return 1;
	}, 'unauth_iterate_start', undef, _get_iterator_params($query, $model_name)
    );
    return $res;
}


sub get_property_model_names {
    return sort(keys(%{get_all_fields()}));
}

sub get_qualified_fields {
    my($proto) = @_;
    my($model_name) = $proto->req('path_info') =~ qr{^/(.*)};
    return map("$model_name.$_", sort(keys(%{get_all_fields()->{$model_name}})));
}

sub get_related {
    my($proto, $model_name, $field) = @_;
    return get_all_fields()->{$model_name}->{$field}->{related};
}

sub internal_initialize {
    my($self) = @_;
    my($visible) = [];
    while (my($model_name, $fields) = each(%{get_all_fields()})) {
    	foreach my $field (sort(keys(%$fields))) {
    	    my($e) = {
    		name => "$model_name.$field",
    		type => get_all_fields()->{$model_name}->{$field}->{type},
    		constraint => 'NONE',
    	    };
	    $e->{type} = 'Integer' if  $e->{type}->isa('Bivio::Type::PrimaryId');
	    $e->{type} = 'Line' if  $e->{type}->isa('Bivio::Type::Number')
		&& !$e->{type}->isa('Bivio::Type::Enum');
    	    $e->{type} = 'Line' if $e->{type}->isa('Bivio::Type::EnumSet');
    	    $e->{type} = 'Line' if $e->{type}->isa('Bivio::Type::EmailVerifyKey');
	    $e->{type} = 'Line' if $e->{type}->isa('Bivio::Type::DateTime');
    	    push(@$visible, $e);
    	}
    }
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1, 
	visible => [
	    @$visible,
	    {
		name => 'status',
		type => 'String',
		constraint => 'NONE',
	    },
	    map({
                name => $_,
                type => 'CancelButton',
                constraint => 'NONE',
            }, @_CANCEL_BUTTONS),
	    map({
                name => $_,
                type => 'OKButton',
                constraint => 'NONE',
            }, @_OK_BUTTONS),
	],
    });
}

sub relation_exists {
    my($self, $qualified_field_name, $related_model, $related_field) = @_;
    my($exists) = 0;
    $self->new_other($related_model)->do_iterate(
	sub {
	    $exists = 1;
	    return 0;
	}, 'unauth_iterate_start', undef, {
	    $related_field => $self->get($qualified_field_name)
	}
    );    
    return $exists;
}

sub _execute_ok_cancel {
    my($self) = @_;
    my($query) = $self->req('query');
    my($button) = grep(defined($self->get($_)), (@_CANCEL_BUTTONS, @_OK_BUTTONS));
    my($method) = '_handle_' . $button;
    my($model_name) = $self->req('path_info') =~ qr{^/(.*)};
    delete($query->{s});
    $query = $self->$method($query, $model_name);
    return {
	    task_id => 'DEV_DBACCESS_MODEL_FORM',
	    path_info => $self->req('path_info'),
	    query => $query,
    };
}


sub _get_iterator_params {
    my($query, $model_name) = @_;
    my($res) = {};
    foreach my $field (keys(%$query)) {	
	next if $field =~ /^(n$|s$|c$|_)/;
	$res->{$field} = _value_query_to_db($model_name, $field, $query->{$field});
    }
    return $res;
}


sub _get_nth_row {
    my($self, $query, $model_name) = @_;
    my($i) = 0;
    my($res) = $self->new_other($model_name);
    $res->do_iterate(
	sub {
	    return (++$i < $query->{n}) ? 1 : 0;
	}, 'unauth_iterate_start', undef, _get_iterator_params($query, $model_name)
    );
    return $i == $query->{n} ? $res : undef;
}

sub _get_row_count {
    my($self, $query, $model_name) = @_;
    my($c) = 0;
    $self->new_other($model_name)->do_iterate(
	sub {
	    $c++;
	    return 1;
	}, 'unauth_iterate_start', undef, _get_iterator_params($query, $model_name)
    );
    return $c;
}

sub _handle_clear_form_button {
    return {};
}

sub _handle_create_button {
    my($self, $query, $model_name) = @_;
    my($model) = $self->new_other($model_name)->create({
	map(
	    {
		my($v) = _value_form_to_db($model_name, $_,
				           $self->unsafe_get("$model_name.$_"));
		defined($v) && (($query || {})->{'_' . $_} == 1)
		    ? ($_ => $v) : ();
	    }
		keys(%{get_all_fields()->{$model_name}}),
	)});
    my($res) =  {
	s => 'Created',
	n => 1,
	map(
	  ($_ => _value_db_to_query($model_name, $_, $model->unsafe_get($_))),
	  @{$model->get_keys},
	),
    };
    $res->{c} =  _get_row_count($self, $res, $model_name);
    return $res;
}

sub _handle_delete_button {
    my($self, $query, $model_name) = @_;
    return unless $query;
    if (my $row = _get_nth_row(@_)) {
	$row->delete;
    }
    return {s => 'Deleted'};
}

sub _handle_first_button {
    my($self, $query) = @_;
    return unless $query;
    return {
	%$query,
        n => 1,
    };
}

sub _handle_next_button {
    my($self, $query) = @_;
    return unless $query;
    return {
	%$query,
        n => $query->{n} + 1 <= $query->{c} ? $query->{n} + 1
	    : $query->{c} > 0 ? $query->{c}
	    : 1,
    };
}

sub _handle_last_button {
    my($self, $query) = @_;
    return unless $query;
    return {
	%$query,
        n =>  $query->{c} > 0 ? $query->{c} : 1,
    };
}

sub _handle_prev_button {
    my($self, $query) = @_;
    return unless $query;
    return {
	%$query,
        n =>  $query->{n} > 1 ? $query->{n} - 1 : 1,
    };
}

sub _handle_search_button {
    my($self, $query, $model_name) = @_;
    my($res) = {n => 1};
    foreach my $field (keys(%{get_all_fields()->{$model_name}})) {
	my($value) = _value_form_to_query($model_name, $field,
					  $self->unsafe_get("$model_name.$field"));
	next unless defined($value);
	next unless (($query || {})->{'_' . $field} || 0) == 1; 
	$res->{$field} = $value; 
    }
    $res->{c} =  _get_row_count($self, $res, $model_name);
    return $res;
}

sub _handle_update_button {
    my($self, $query, $model_name) = @_;
    if (my $row = _get_nth_row(@_)) {
	$row->update({map(
	    {
		my($v) = _value_form_to_db($model_name, $_,
					   $self->unsafe_get("$model_name.$_"));
		defined($v) ? ($_ => $v) : ();
	    }
	    @{$row->get_keys}
	)});
	my($res) = {
	    s => 'Updated',
	    n => 1,
	    map(
		{
		    my($v) = _value_db_to_query($model_name, $_, $row->get($_));
		    defined($v) ? ($_ => $v) : ();
		}
		@{$row->get_keys}
	    ),
	};
	$res->{c} =  _get_row_count($self, $res, $model_name);
	return $res;
    }
    return;
}

sub _value_db_to_query {
    my($model_name, $field, $value) = @_;
    my($t) = get_all_fields()->{$model_name}->{$field}->{type};
    $value = $t->to_sql_param($value)
	if (b_use($t)->isa('Bivio::Type::Enum'));
    return $value;
}

sub _value_db_to_form {
    my($model_name, $field, $value) = @_;
    return unless defined($value);
    my($t) = get_all_fields()->{$model_name}->{$field}->{type};
    $value = $t->to_xml($value) if $t eq 'Bivio::Type::DateTime';
    $value = $t->to_literal($value) if $t->isa('Bivio::Type::EnumSet');
    return $value;
}

sub _value_form_to_db {
    my($model_name, $field, $value) = @_;
    return unless defined($value);
    my($t) = get_all_fields()->{$model_name}->{$field}->{type};
    return $t->from_literal($value) if $t eq 'Bivio::Type::DateTime';
    return $t->from_literal($value) if $t->isa('Bivio::Type::EnumSet');
    return $value;
}

sub _value_form_to_query {
    my($model_name, $field, $value) = @_;
    return _value_db_to_query($model_name, $field,
			      _value_form_to_db($model_name, $field, $value));
}
sub _value_query_to_db {
    my($model_name, $field, $value) = @_;
    return unless defined($value);
    my($t) =  get_all_fields()->{$model_name}->{$field}->{type};
    return  b_use($t)->from_int($value)
	if b_use($t)->isa('Bivio::Type::Enum');
    return $value;
}


1;
