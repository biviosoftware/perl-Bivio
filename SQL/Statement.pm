# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::SQL::Statement;
use strict;
$Bivio::SQL::Statement::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::SQL::Statement::VERSION;

=head1 NAME

Bivio::SQL::Statement - smart SQL statement builder

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::SQL::Statement;

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::SQL::Statement::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::SQL::Statement>

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="AND"></a>

=head2 static AND(any predicate, ... ) : hash_ref

Return a list of predicates joined by AND.

=cut

sub AND {
    my($proto) = shift;
    return _combine_predicates($proto, 'AND', @_);
}

=for html <a name="CROSS_JOIN"></a>

=head2 static CROSS_JOIN(any join, ...) : hash_ref

Return a CROSS JOIN (i.e. the default join when no join is specified).

=cut

sub CROSS_JOIN {
    my($proto, @joins) = @_;
    my($joins) = [@joins];
    return {
        joins => $joins,
        build => sub {
            return join(',', map({$_->{build}->(@_)} @$joins));
        },
    };
}

=for html <a name="DISTINCT"></a>

=head2 static DISTINCT(string column) : hash_ref



=cut

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

=for html <a name="EQ"></a>

=head2 static EQ(string left, list right) : hash_ref

=head2 static EQ(string left, array_ref right) : hash_ref

Return an EQ predicate.
If I<right> is an array_ref, treat right as a value, not a column.
Multiple right values are each compared against left.

=cut

sub EQ {
    my($proto, $left, @right) = @_;
    if (scalar(@right) == 1) {
	return _static_equivalence('=', '', $left, shift(@right));
    }
    else {
	return $proto->AND(map({_static_equivalence('=', 'IN', $left, $_)}
	    @right));
    }
}

=for html <a name="GT"></a>

=head2 static GT(string left, string right) : hash_ref

=head2 static GT(string left, array_ref right) : hash_ref

Return a Greater Than predicate.

=cut

sub GT {
    my($proto, $left, $right) = @_;
    return _static_compare('>', $left, $right);
}

=for html <a name="GTE"></a>

=head2 static GTE(string left, string right) : hash_ref

=head2 static GTE(string left, array_ref right) : hash_ref

Return a Greater Than or Equal predicate.

=cut

sub GTE {
    my($proto, $left, $right) = @_;
    return _static_compare('>=', $left, $right);
}

=for html <a name="ILIKE"></a>

=head2 static ILIKE(string column, string match) : hash_ref

Return a ILIKE predicate.

=cut

sub ILIKE {
    return _like(ILIKE => @_);
}

=for html <a name="IN"></a>

=head2 static IN(string column, array_ref list) : hash_ref

Return an IN predicate.

=cut

sub IN {
    return _in('', @_);
}

=for html <a name="IS_NOT_NULL"></a>

=head2 static IS_NOT_NULL(string column) : hash_ref

Return an IS NOT NULL predicate

=cut

sub IS_NOT_NULL {
    my($proto, $column) = @_;
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

=for html <a name="IS_NULL"></a>

=head2 static IS_NULL(string column) : hash_ref

Return an IS NULL predicate

=cut

sub IS_NULL {
    my($proto, $column) = @_;
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

=for html <a name="LEFT_JOIN_ON"></a>

=head2 static LEFT_JOIN_ON(string left_table, string right_table, any join_predicate) : hash_ref

Return a LEFT JOIN ON join.

=cut

sub LEFT_JOIN_ON {
    my($proto, $left_table, $right_table, $join_predicate) = @_;
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

=for html <a name="LIKE"></a>

=head2 static LIKE(string column, string match) : hash_ref

Return a LIKE predicate.

=cut

sub LIKE {
    return _like(LIKE => @_);
}

=for html <a name="LT"></a>

=head2 static LT(string left, string right) : hash_ref

=head2 static LT(string left, array_ref right) : hash_ref

Return a Less Than predicate.

=cut

sub LT {
    my($proto, $left, $right) = @_;
    return _static_compare('<', $left, $right);
}

=for html <a name="LTE"></a>

=head2 static LTE(string left, string right) : hash_ref

=head2 static LTE(string left, array_ref right) : hash_ref

Return a Less Than or Equal predicate.

=cut

sub LTE {
    my($proto, $left, $right) = @_;
    return _static_compare('<=', $left, $right);
}

=for html <a name="NE"></a>

=head2 static NE(string left, string right) : hash_ref

=head2 static NE(string left, array_ref right) : hash_ref

Return an != predicate.
If I<right> is an array_ref, treat right as a value, not a column.

=cut

sub NE {
    my($proto, $left, $right) = @_;
    return _static_compare('!=', $left, $right);
}

=for html <a name="NOT_IN"></a>

=head2 static NOT_IN(string column, array_ref list) : hash_ref

Return an NOT_IN predicate.

=cut

sub NOT_IN {
    return _in(' NOT', @_);
}

=for html <a name="NOT_LIKE"></a>

=head2 static NOT_LIKE(string column, string match) : hash_ref

Return a NOT_LIKE predicate.

=cut

sub NOT_LIKE {
    return _like('NOT LIKE', @_);
}

=for html <a name="OR"></a>

=head2 OR(any predicate, ... ) : hash_ref

Return a list of predicates joined by OR.

=cut

sub OR {
    my($proto) = shift;
    return _combine_predicates($proto, 'OR', @_);
}

=for html <a name="PARENS"></a>

=head2 static PARENS(any predicate, ... ) : hash_ref

Return a single predicate grouped inside parentheses.

=cut

sub PARENS {
    my($proto, $predicate) = @_;
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

=for html <a name="SELECT_AS"></a>

=head2 static SELECT_AS(any column, string alias) : hash_ref

Return the select object

=cut

sub SELECT_AS {
    my($proto, $column, $alias) = @_;
    return {
	columns => [$column],
        build => sub {
            return _build_select_column($column, @_) . ' AS ' . $alias;
        },
    }
}

=for html <a name="SELECT_LITERAL"></a>

=head2 static SELECT_LITERAL(string literal) : hash_ref

Return the select of a literal

=cut

sub SELECT_LITERAL {
    my($proto, $literal) = @_;
    return {
	columns => [$literal],
        build => sub {$literal},
    }
}

=for html <a name="new"></a>

=head2 static new() : Bivio::SQL::Statement

Return a new instance.

=cut

sub new {
    my($proto) = @_;
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {
        from => {},
        select => undef,
        where => $self->AND(),
        _models => {},
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="build_decl_for_sql_support"></a>

=head2 build_decl_for_sql_support() : hash_ref

Return columns for ListModel

=cut

sub build_decl_for_sql_support {
    my($self) = @_;
    return {
        other => $self->[$_IDI]->{select}->{column_names},
	# HACK: but I don't know what to do about it yet
	primary_key => $self->[$_IDI]->{select}->{column_names},
    }
	if $self->[$_IDI]->{select};
    return {};
}

=for html <a name="build_for_list_support_prepare_statement"></a>

=head2 build_for_list_support_prepare_statement(Bivio::SQL::Support support, Bivio::SQL::Statement other_stmt, string where, array_ref params) : (string, array_ref)

Return FROM/WHERE clause and parameter array for _prepare_statement

=cut

sub build_for_list_support_prepare_statement {
    my($self, $support, $other_stmt, $_where, $_params) = @_;
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

=for html <a name="build_select_for_sql_support"></a>

=head2 build_select_for_sql_support(Bivio::SQL::ListSupport support) : string

Build SELECT clause.

=cut

sub build_select_for_sql_support {
    my($self, $support) = @_;
    my($fields) = $self->[$_IDI];
    return join(' ',
        'SELECT', $fields->{select}->{build}->($support, []))
	if $fields->{select};
    return $support->unsafe_get('select');
}

=for html <a name="config"></a>

=head2 config(hash_ref config)

Parse and apply config data

=cut

sub config {
    my($self, $config) = @_;
    foreach my $method (keys %$config) {
	$self->$method(@{$config->{$method}});
    }
    return;
}

=for html <a name="from"></a>

=head2 from(any join, ...)

Add the join(s) to the FROM clause.
TODO: Generalize to any type of JOIN.  Currently only accepts LEFT_JOIN_ON
and a simple table name  May also just be a table.

=cut

sub from {
    my($self, @joins) = @_;
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

=for html <a name="select"></a>

=head2 select(any select_item)

Add item to SELECT clause.

=cut

sub select {
    my($self, @columns) = @_;
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

=for html <a name="union_hack"></a>

=head2 union_hack(Bivio::SQL::Statement stmt, ...)

Add I<stmt>s to WHERE clause.  The statement has to be completely empty
at this point.

=cut

sub union_hack {
    my($self, @stmt) = @_;
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

=for html <a name="where"></a>

=head2 where(any predicate, ...)

Add I<predicate>s to WHERE clause.  This condition will be ANDed
with any other existing conditions.

=cut

sub where {
    my($self, @predicates) = @_;
    foreach my $predicate (
        map({_parse_predicate($self, $_)} grep({$_} @predicates))
    ) {
        push(@{$self->[$_IDI]->{where}->{predicates}}, $predicate);
    }
    return $self;
}

#=PRIVATE SUBROUTINES

# _add_model(self, string model, hash_ref join) : hash_ref
#
# Add model to _models and from (if new).
# Return the hash_ref representation.
#
sub _add_model {
    my($self, $model, $join) = @_;
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

# _build_column(string column) : hash_ref
#
# Build column name.
# Understands 'Model.field', 'Model_#.field', and 'FUNC(Model.field)'
#
sub _build_column {
    my($column) = @_;
    my($func, $model_ref, $field, $paren)
	= $column =~ /^(\w+\()?(\w+(?:_\d+)?)\.(\w+)(\)?)$/;
    my($model, $index)
	= $model_ref =~ /^(\w+?)(_\d+)?$/;
    $func ||= '';
    $index ||= '';
    $paren ||= '';
    return {
        model_name => $model_ref,
        sql_string => $func
            . Bivio::Biz::Model->get_instance($model)->get_info('table_name')
	    . "$index.$field$paren",
    };
}

# TODO: Merge _build_column and _build_column_info
# _build_column_info(string column) : hash_ref
#
# Build column information.
# Understands 'Model.field', 'Model_#.field', and 'FUNC(Model.field)'
# Returns a hash_ref with the following information:
#   column_name  (:string 'field')
#   model        (:Bivio::Biz::Model)
#   name         (:string 'Model_#.field')
#   sql_string   (:string)
#   type         (:Bivio::Type)
#
sub _build_column_info {
    my($column) = @_;
    my($func, $model_ref, $field, $paren)
	= $column =~ /^(\w+\()?(\w+(?:_\d+)?)\.(\w+)(\)?)$/;
    my($model_name, $index)
	= $model_ref =~ /^(\w+?)(_\d+)?$/;
    $func ||= '';
    $index ||= '';
    $paren ||= '';
    my($model) = Bivio::Biz::Model->get_instance($model_name); 
    return {
        column_name => $field,
	model_name => $model_ref,
	model => $model,
	name => $column,
	sql_string => $func
            . $model->get_info('table_name') . "$index.$field$paren",
        type => $model->get_field_type($field),
    }
}

# _build_model(string model) : string
#
# Return the sql table name for the model.
# Understands 'Model' and 'Model_#'
#
sub _build_model {
    my($model_name) = @_;
    my($model, $index) = $model_name =~ /^(\w+?)(_\d+)?$/;
    my($table) = Bivio::Biz::Model->get_instance($model)
	->get_info('table_name');
    $index ||= '';
    return $table
        . ($index ? " $table$index" : '');
}

# _build_value(string column, string value, Bivio::SQL::Support support) : string
#
# Build placeholder and add value to I<params>.
#
sub _build_value {
    my($column, $value, $support, $params) = @_;
    my($func, $model, $index, $field) = $column =~ /^(\w+\()?(\w+?)(_\d+)?\.(\w+)\)?$/;
    my($t) = ($func || '') =~ /^(length|count)\(/i ? 'Bivio::Type::Number'
	: Bivio::Biz::Model->get_instance($model)->get_field_type($field);
    my($v, $e) = $t->from_literal($value);
    Bivio::Die->die($column, $value, $e) if $e;
    push(@$params, $t->to_sql_param($v));
    return $t->to_sql_value('?');
}

# _build_select_column(string column) : string
#
# Build select column name with appropriate type conversion.
#
sub _build_select_column {
    my($i) = _build_column_info(@_);
    return $i->{type}->from_sql_value($i->{sql_string});
}

# _combine_predicates(proto, string conjunctive, any predicate, ...) : hash_ref
#
# Combines the predicates with the conjunctive (AND or OR).
# OR values are wrapped in parenthesis.
#
sub _combine_predicates {
      my($proto, $conjunctive) = (shift, shift);
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

# _in(string modifier, proto, string column, any values) : hash_ref
#
# Create "IN" or "NOT IN" clause
#
sub _in {
    my($modifier, undef, $column, $values) = @_;
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

# _like(string predicate, proto, string column, string match) : hash_ref
#
# Build a LIKE or ILIKE predicate.
# If column is a Bivio::Type::Enum, do an in-memory search on short_desc
# and subsitute an IN.
#
sub _like {
    my($predicate, $proto, $column, $match) = @_;
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

# _merge_statements(self, Bivio::SQL::Statement)
#
# Merge statement data
#
sub _merge_statements {
    my($self, $other) = @_;
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

# _parse_select_column(hash_ref column) : hash_ref
# _parse_select_column(string column) : hash_ref
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

# _parse_predicate(proto, any predicate) : 
#
# Parse a literal predicate, according to the following defaults:
# 1) Unspecified predicates are EQ
# 2) Unspecified lists of predicates are joined by AND
#
sub _parse_predicate {
    my($proto, $predicate) = @_;
    return $predicate
        if ref($predicate) eq 'HASH';
    Bivio::Die->die($predicate, ': not an array reference')
        unless ref($predicate) eq 'ARRAY';
    return $proto->EQ(@$predicate)
        unless ref($predicate->[0]);
    return $proto->AND(map({_parse_predicate($proto, $_)} @$predicate));
}

# _static_compare(string comp, string left, string right) : hash_ref
#
# Return a comparison predicate.
#
sub _static_compare {
    my($comp, $left, $right) = @_;
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

# _static_equivalence(string $cmp, string $modifier, $left, $right) : hash_ref
#
# Return an equivalence predicate.  Use =/!= for single values.
# Use IN/NOT IN for multiple values
#
sub _static_equivalence {
    my($comp, $modifier, $left, $right) = @_;
    if (ref($right) eq 'ARRAY' && scalar(@$right) > 1) {
	return _in($modifier, undef, $left, $right);
    }
    else {
	return _static_compare($comp, $left, $right);
    }
}

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
