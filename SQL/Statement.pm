# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::SQL::Statement;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_S) = __PACKAGE__->use('SQL.Support');
my($_N) = __PACKAGE__->use('Type.Number');

sub AND {
    my($proto) = shift;
    # Return a list of predicates joined by AND.
    return _combine_predicates($proto, 'AND', @_);
}

sub CROSS_JOIN {
    my($proto, @joins) = @_;
    # Return a CROSS JOIN (i.e. the default join when no join is specified).
    my($joins) = [@joins];
    return {
        joins => $joins,
        build => sub {
            return join(',', map({$_->{build}->(@_)} @$joins));
        },
    };
}

sub DISTINCT {
    my($proto, $column) = @_;
    return {
        distinct => $column,
	columns => [$column],
        build => sub {
            return join(' ', 'DISTINCT', _build_select_column($column, @_));
        },
    };
}

sub EQ {
    my($proto, $left, @right) = @_;
    # Return an EQ predicate.
    # If I<right> is an array_ref, treat right as a value, not a column.
    # Multiple right values are each compared against left.
    if (@right == 1) {
	my($right) = @right;
	return $proto->IS_NULL($left)
	    if ref($right) eq 'ARRAY' && @$right == 1 && !defined($right->[0]);
	return _static_equivalence('=', '', $left, $right);
    }
    return $proto->AND(map({_static_equivalence('=', 'IN', $left, $_)} @right));
}

sub GT {
    my($proto, $left, $right) = @_;
    # Return a Greater Than predicate.
    return _static_compare('>', $left, $right);
}

sub GTE {
    my($proto, $left, $right) = @_;
    # Return a Greater Than or Equal predicate.
    return _static_compare('>=', $left, $right);
}

sub ILIKE {
    # Return a ILIKE predicate.
    return _like(ILIKE => @_);
}

sub IN {
    # Return an IN predicate.
    return _in('', @_);
}

sub IS_NOT_NULL {
    my($proto, $column) = @_;
    # Return an IS NOT NULL predicate
    return {
        column => $column,
        build => sub {
	    my($col) = _build_column($column, @_);
            return {
	        models => [$col->{model_name}],
		sql_string => $col->{sql_string} . ' IS NOT NULL',
	    };
        },
    };
}

sub IS_NULL {
    my($proto, $column) = @_;
    # Return an IS NULL predicate
    return {
        column => $column,
        build => sub {
	    my($col) = _build_column($column, @_);
            return {
	        models => [$col->{model_name}],
		sql_string => $col->{sql_string} . ' IS NULL',
	    };
        },
    };
}

sub LEFT_JOIN_ON {
    my($proto, $left_table, $right_table, $join_predicate) = @_;
    # Return a LEFT JOIN ON join.
    $join_predicate = _parse_predicate($proto, $join_predicate);
    return {
        left_table => $left_table,
        right_table => $right_table,
        join_predicate => $join_predicate,
        build => sub {
            return
                'LEFT JOIN ' . _build_model($right_table, @_) .
                ' ON (' . $join_predicate->{build}->(@_)->{sql_string} . ')';
        },
    };
}

sub LIKE {
    # Return a LIKE predicate.
    return _like(LIKE => @_);
}

sub LT {
    my($proto, $left, $right) = @_;
    # Return a Less Than predicate.
    return _static_compare('<', $left, $right);
}

sub LTE {
    my($proto, $left, $right) = @_;
    # Return a Less Than or Equal predicate.
    return _static_compare('<=', $left, $right);
}

sub NE {
    my($proto, $left, $right) = @_;
    # Return an != predicate.
    # If I<right> is an array_ref, treat right as a value, not a column.
    return _static_compare('!=', $left, $right);
}

sub NOT_IN {
    # Return an NOT_IN predicate.
    return _in(' NOT', @_);
}

sub NOT_LIKE {
    # Return a NOT_LIKE predicate.
    return _like('NOT LIKE', @_);
}

sub OR {
    my($proto) = shift;
    # Return a list of predicates joined by OR.
    return _combine_predicates($proto, 'OR', @_);
}

sub PARENS {
    my($proto, $predicate) = @_;
    # Return a single predicate grouped inside parentheses.
    return {
        predicate => $predicate,
        build => sub {
	    my($pred) = $predicate->{build}->(@_);
            return {
	        models => $pred->{models},
		sql_string => '(' . $pred->{sql_string} . ')',
	    };
        },
    }
}

sub SELECT_AS {
    my($proto, $column, $alias) = @_;
    # Return the select object
    return {
	columns => [$column],
        build => sub {
            return _build_select_column($column, @_) . ' AS ' . $alias;
        },
    }
}

sub SELECT_LITERAL {
    my($proto, $literal) = @_;
    # Return the select of a literal
    return {
	columns => [$literal],
        build => sub {$literal},
    }
}

sub build_decl_for_sql_support {
    my($self) = @_;
    # Return columns for ListModel
    return {
        other => $self->[$_IDI]->{select}->{column_names},
	# HACK: but I don't know what to do about it yet
	primary_key => $self->[$_IDI]->{select}->{column_names},
    }
	if $self->[$_IDI]->{select};
    return {};
}

sub build_for_list_support_prepare_statement {
    my($self, $support, $other_stmt, $_where, $_params) = @_;
    # Return FROM/WHERE clause and parameter array for _prepare_statement
    _merge_statements($self, $other_stmt);

    my($fields) = $self->[$_IDI];
    my($pred_params) = [];
    my(@stmt) = ();

    # get rid of extraneous spaces
    $_where = join(' ', split(' ', $_where))
	if $_where;
    my($predicate) = $fields->{where}->{build}->($support, $pred_params);
    my($where) = join(' AND ', grep($_, $predicate->{sql_string}, $_where));
    unshift(@stmt, WHERE => $where)
	if $where;

    foreach my $model (@{$predicate->{models}}) {
	_add_model($self, $model);
    }

    my($fr_params) = [];
    if (%{$fields->{from}}) {
	my(@select) = $fields->{select}
	     ? (SELECT => $fields->{select}->{build}->($support, $fr_params))
	     : ();
	my(@from);
	if ($support->unsafe_get('decl_from')) {
	    push(@from, $support->get('decl_from'));
	}
	else {
	    foreach my $model (
	        $fields->{select} ? () : keys(%{$support->get('models')}),
            ) {
                _add_model($self, $model);
            }
	    push(@from, FROM => $self->CROSS_JOIN(
		 map($fields->{from}->{$_},
		     sort(keys(%{$fields->{from}}))),
	         )->{build}->($support, $fr_params));
	}
	unshift(@stmt,
	    @select,
	    @from,
	);
    }

    return (join(' ', @stmt), [@$fr_params, @$pred_params, @{$_params || []}]);
}

sub build_select_for_sql_support {
    my($self, $support) = @_;
    # Build SELECT clause.
    my($fields) = $self->[$_IDI];
    return join(' ',
        'SELECT', $fields->{select}->{build}->($support, []))
	if $fields->{select};
    return $support->unsafe_get('select');
}

sub config {
    my($self, $config) = @_;
    # Parse and apply config data
    foreach my $method (keys %$config) {
	$self->$method(@{$config->{$method}});
    }
    return;
}

sub from {
    my($self, @joins) = @_;
    # Add the join(s) to the FROM clause.
    # TODO: Generalize to any type of JOIN.
    #   Currently only accepts LEFT_JOIN_ON and a simple table name.
    # May also just be a table.
    my($models) = $self->[$_IDI]->{_models};
    foreach my $join (@joins) {
	unless (ref($join)) {
	    _add_model($self, $join);
	    next;
	}
	my($left_table) = $join->{left_table};
	my($right_table) = $join->{right_table};
	Bivio::Die->die($right_table, ': is already left joined with ',
            $models->{$right_table}->{_joined_from},
        ) if exists($models->{$right_table})
	    && exists($models->{$right_table}->{_joined_from});
	my($right) = _add_model($self, $right_table, $join);
	_add_model($self, $left_table)->{joins}->{$right_table} = $right;
	$right->{_joined_from} = $left_table;

	delete($self->[$_IDI]->{from}->{$right_table});
    }
    return $self;
}

sub new {
    my($proto) = @_;
    # Return a new instance.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {
        from => {},
        select => undef,
        where => $self->AND(),
        _models => {},
    };
    return $self;
}

sub select {
    my($self, @columns) = @_;
    # Add item to SELECT clause.
    my($columns) = [map({_parse_select_column($_)} @columns)];
    $self->[$_IDI]->{select} = {
	columns => $columns,
	column_names => [map({@{$_->{columns}}} @$columns)],
	build => sub {
	    return join(',', map({$_->{build}->(@_)} @$columns));
	},
    };
    return $self;
}

sub union_hack {
    my($self, @stmt) = @_;
    # Add I<stmt>s to WHERE clause.  The statement has to be completely empty
    # at this point.
    Bivio::Die->die('statement must be empty to union')
	 if @{$self->[$_IDI]->{where}->{predicates}};
    $self->[$_IDI]->{where} = {
	statements => [@stmt],
	build => sub {
	    my($support, $params) = @_;
	    return {
		models => [],  #TODO: capture models?
	        sql_string => join(
		    ' UNION ',
		    map({
		        my($s, $p) =
		            $_->build_for_list_support_prepare_statement($support);
		        push(@$params, @$p);
		        $s =~ s/^(?:FROM .*?)?WHERE //;
		        $s;
		    } @stmt),
	        ),
	    };
	},
    };
    return $self;
}

sub where {
    my($self, @predicates) = @_;
    # Add I<predicate>s to WHERE clause.  This condition will be ANDed
    # with any other existing conditions.
    foreach my $predicate (
        map({_parse_predicate($self, $_)} grep({$_} @predicates))
    ) {
        push(@{$self->[$_IDI]->{where}->{predicates}}, $predicate);
    }
    return $self;
}

sub _add_model {
    my($self, $model, $join) = @_;
    # Add model to _models and from (if new).
    # Return the hash_ref representation.
    my($models) = $self->[$_IDI]->{_models};
    my($joins) = {};
    my($build_model) = $join
	? $join
	: {build => sub {_build_model($model, @_)}};
    $self->[$_IDI]->{from}->{$model} = $models->{$model} = {
        joins => $joins,
	build_model => $build_model,
        build => sub {
            return
                join(' ', $build_model->{build}->(@_),
                    map({$_->{build}->(@_)}
                        map({$joins->{$_}} sort keys %$joins)));
        },
    }
        unless exists $models->{$model};

    return $models->{$model};
}

sub _build_column {
    my($cn) = _parse_column_name(@_);
    return {
	map(($_ => $cn->{$_}), qw(model_name sql_string)),
    };
}

sub _build_column_info {
    my($cn) = _parse_column_name(@_);
    # TODO: Merge _build_column and _build_column_info
    return {
	map(($_ => $cn->{$_}),
	    qw(column_name model_name model type name sql_string)),
    }
}

sub _build_model {
    return $_S->parse_model_name(@_)->{model_from_sql};
}

sub _build_select_column {
    my($i) = _build_column_info(@_);
    return $i->{type}->from_sql_value($i->{sql_string});
}

sub _build_value {
    my($column, $value, $support, $params) = @_;
    my($cn) = _parse_column_name($column);
    my($v, $e) = $cn->{type}->from_literal($value);
    Bivio::Die->die($value, ': invalid value for ', $column, ': ', $e)
        if $e;
    push(@$params, $cn->{type}->to_sql_param($v));
    return $cn->{type}->to_sql_value('?');
}

sub _combine_predicates {
      my($proto, $conjunctive) = (shift, shift);
    # Combines the predicates with the conjunctive (AND or OR).
    # OR values are wrapped in parenthesis.
      my($p) = [map(_parse_predicate($proto, $_), @_)];
      return {
          predicates => $p,
          build => sub {
	      my($preds) = [map($_->{build}->(@_), @$p)];
              my($str) = join(" $conjunctive ",
  		grep($_, map($_->{sql_string}, @$preds)));
              return {
		  models => [map({@{$_->{models}}} @$preds)],
	          sql_string => $conjunctive eq 'OR' ? "($str)" : $str,
	      };
          },
      };
}

sub _in {
    my($modifier, undef, $column, $values) = @_;
    # Create "IN" or "NOT IN" clause
    return {
        column => $column,
        values => $values,
        build => sub {
	    my($col) = _build_column($column, @_);
            return {
	        models => [$col->{model_name}],
		sql_string => @$values
		    ? $col->{sql_string}
		    . "$modifier IN ("
		    . join(',', map(_build_value($column, $_, @_), @$values))
		    . ')'
		    : $modifier ? 'TRUE' : 'FALSE',
	    };
        },
    };
}

sub _like {
    my($predicate, $proto, $column, $match) = @_;
    # Build a LIKE or ILIKE predicate.
    # If column is a Bivio::Type::Enum, do an in-memory search on short_desc
    # and subsitute an IN.
    my($col_info) = _build_column_info($column);
    # be nice to user, substite * for %
    $match =~ s/\*/\%/g;
    if ($col_info->{type}->isa('Bivio::Type::Enum')) {
        $match =~ s/([^_%]+)/quotemeta($1)/ge;
	$match =~ s/%/\.\*/g;
	$match =~ s/_/./g;
	my($re) = $predicate =~ /ILIKE/ ? qr/$match/i : qr/$match/;
	my($m) = $predicate =~ /^NOT/ ? 'NOT_IN' : 'IN';
	return $proto->$m(
	    $column,
	    [grep($_->get_short_desc() =~ $re,
		  $col_info->{type}->get_list())]),
    }
    else {
	return {
            build => sub {
		my($support, $params) = @_;
		push(@$params, $match);
		return {
		    models => [$col_info->{model_name}],
		    sql_string => $col_info->{sql_string} . " $predicate ?",
	        };
            },
	};
    };
}

sub _merge_statements {
    my($self, $other) = @_;
    # Merge statement data
    return unless $other && $other != $self;

    # merge WHERE
    $self->where($other->[$_IDI]->{where});

    # merge FROM
    # TODO: more needs to be done here.
    foreach my $model (keys %{$other->[$_IDI]->{from}}) {
	$self->[$_IDI]->{from}->{$model} = $self->[$_IDI]->{_models}->{$model}
	    = $other->[$_IDI]->{from}->{$model}
		unless exists $self->[$_IDI]->{_models}->{$model};
    }

#     foreach my $model (keys %{$other->[$_IDI]->{_models}}) {
#         unless (grep($_ eq $model, keys %{$self->[$_IDI]->{_models}})) {
#             Bivio::Die->die('failed to merge model: ', $model);
#         }
#     }

    return;
}

sub _parse_column_name {
    my($name) = @_;
    my($func, $qual_col) = $name =~ /^(\w+)\((.+)\)$/s;
    my($cn) = $_S->parse_column_name($qual_col || $name);
    $cn->{name} = $name;
    $cn->{sql_string} = $func ? "$func($cn->{sql_name})" : $cn->{sql_name};
    $cn->{type} = $_N
	if $func && $func =~ /^(?:length|count|sum)$/;
    return $cn;
}

sub _parse_predicate {
    my($proto, $predicate) = @_;
    # Parse a literal predicate, according to the following defaults:
    # 1) Unspecified predicates are EQ
    # 2) Unspecified lists of predicates are joined by AND
    return $predicate
        if ref($predicate) eq 'HASH';
    Bivio::Die->die($predicate, ': not an array reference')
        unless ref($predicate) eq 'ARRAY';
    return $proto->EQ(@$predicate)
        unless ref($predicate->[0]);
    return $proto->AND(map({_parse_predicate($proto, $_)} @$predicate));
}

sub _parse_select_column {
    my($column) = @_;
    return $column
	if ref($column) eq 'HASH';
    my($columns) = [$column];
    return {
	columns => $columns,
	build => sub {
	    return _build_select_column($column, @_);
	},
    };
}

sub _static_compare {
    my($comp, $left, $right) = @_;
    # Return a comparison predicate.
    return {
        left => $left,
        right => $right,
        build => sub {
            my($_left) = _build_column($left, @_);
            my($_right) = ref($right) eq 'ARRAY'
                ? _build_value($left, $right->[0], @_)
                : _build_column($right, @_);
            return {
		models => [
	            $_left->{model_name},
		    (ref($_right) eq 'HASH'
		        ? $_right->{model_name} : ()),
		],
	        sql_string => $_left->{sql_string} . $comp
		    . (ref($_right) eq 'HASH'
		        ? $_right->{sql_string} : $_right),
	    };
        },
    };
}

sub _static_equivalence {
    my($comp, $modifier, $left, $right) = @_;
    # Return an equivalence predicate.  Use =/!= for single values.
    # Use IN/NOT IN for multiple values
    if (ref($right) eq 'ARRAY' && scalar(@$right) > 1) {
	return _in($modifier, undef, $left, $right);
    }
    else {
	return _static_compare($comp, $left, $right);
    }
}

1;
