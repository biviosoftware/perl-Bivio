# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
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
    my($self, @joins) = @_;
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
    my($self, $column) = @_;
    return {
        distinct => $column,
	columns => [$column],
        build => sub {
            return join(' ', 'DISTINCT', _build_column($column, @_));
        },
    };
}

=for html <a name="EQ"></a>

=head2 static EQ(string left, string right) : hash_ref

=head2 static EQ(string left, array_ref right) : hash_ref

Return an EQ predicate.
If I<right> is an array_ref, treat right as a value, not a column.

=cut

sub EQ {
    my($proto, $left, $right) = @_;
    return _static_compare('=', $left, $right);
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
    my($proto, $column, $match) = @_;
    return {
        column => $column,
        match => $match,
        build => sub {
            return _build_column($column, @_) . ' ILIKE ' . "'$match'";
        },
    };
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
            return _build_column($column, @_) . ' IS NOT NULL';
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
            return _build_column($column, @_) . ' IS NULL';
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
                ' ON (' . $join_predicate->{build}->(@_) . ')';
        },
    };
}

=for html <a name="LIKE"></a>

=head2 static LIKE(string column, string match) : hash_ref

Return a LIKE predicate.

=cut

sub LIKE {
    my($proto, $column, $match) = @_;
    return {
        column => $column,
        match => $match,
        build => sub {
            return _build_column($column, @_) . ' LIKE ' . "'$match'";
        },
    };
}

=for html <a name="LT"></a>

=head2 static LT(string left, string right) : hash_ref

=head2 static LT(string left, array_ref right) : hash_ref

Return a Less Than predicate.

=cut

sub LT {
    my($self, $left, $right) = @_;
    return _static_compare('<=', $left, $right);
}

=for html <a name="LTE"></a>

=head2 static LTE(string left, string right) : hash_ref

=head2 static LTE(string left, array_ref right) : hash_ref

Return a Less Than or Equal predicate.

=cut

sub LTE {
    my($self, $left, $right) = @_;
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
            return '(' . $predicate->{build}->(@_) . ')';
        },
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
        other => $self->[$_IDI]->{select}->{columns},
	# HACK: but I don't know what to do about it yet
	primary_key => $self->[$_IDI]->{select}->{columns},
    }
	if $self->[$_IDI]->{select};
    return {};
}

=for html <a name="build_for_internal_load_rows"></a>

=head2 build_for_internal_load_rows(Bivio::SQL::Support support) : (string, array_ref)

Return FROM and WHERE clauses for internal_load_rows

=cut

sub build_for_internal_load_rows {
    my($self, $support) = @_;
    _merge_statements($self, $support->get_statement());
    my($fields) = $self->[$_IDI];
    my($params) = [];

    my($where) = $fields->{where};
    return ($where->{build}->($support, $params), $params)
        unless scalar(keys %{$fields->{from}});

    foreach my $model (keys %{$support->get('models')}) {
        _add_model($self, $model);
    }

    my($join) = $self->CROSS_JOIN(
        map({$fields->{from}->{$_}}
            sort keys %{$fields->{from}}));

    return (
        join(' ', 'FROM', $join->{build}->($support, $params),
            'WHERE', $where->{build}->($support, $params)),
	$params);
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
BAD: Assumes LEFT JOIN

=cut

sub from {
    my($self, @joins) = @_;
    my($models) = $self->[$_IDI]->{_models};
    foreach my $join (@joins) {
	my($left_table) = $join->{left_table};
	my($right_table) = $join->{right_table};

	Bivio::Die->die($right_table, ': is already left joined with ',
            $models->{$right_table}->{_joined_from},
        )
            if exists $models->{$right_table}
                && exists $models->{$right_table}->{_joined_from};

	my($left) = _add_model($self, $left_table);
	my($right) = _add_model($self, $right_table, $join);

	$left->{joins}->{$right_table} = $right;
	$right->{_joined_from} = $left_table;

	delete $self->[$_IDI]->{from}->{$right_table};
    }
    return;
}

=for html <a name="select"></a>

=head2 select(any select_item)

Add item to SELECT clause.

=cut

sub select {
    my($self, $select_item) = @_;
    $self->[$_IDI]->{select} = $select_item;
    return;
}

=for html <a name="where"></a>

=head2 where(any predicate, ...)

Add I<predicate>s to WHERE clause.  This condition will be ANDed
with any other existing conditions.

=cut

sub where {
    my($self, @predicates) = @_;
    foreach my $predicate (grep({$_} @predicates)) {
        push(@{$self->[$_IDI]->{where}->{predicates}},
            _parse_predicate($self, $predicate));
    }
    return;
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

# _build_column(string column, Bivio::SQL::Support support) : string
#
# Build column name
#
sub _build_column {
    my($column, $support) = @_;
    my($func, $model, $index, $field, $paren)
	= $column =~ /^(\w+\()?(\w+?)(_\d+)?\.(\w+)(\)?)$/;
    $func ||= '';
    $index ||= '';
    $paren ||= '';
    return $func
        . Bivio::Biz::Model->get_instance($model)->get_info('table_name')
	. "$index.$field$paren";
}

# _build_model(string model, Bivio::SQL::Support support) : string
#
# Return the sql table name for the model
#
sub _build_model {
    my($model_name, $support) = @_;
    my($model, $index) = $model_name =~ /^(\w+?)(_\d+)?$/;
    my($table) = Bivio::Biz::Model->get_instance($model)
	->get_info('table_name');
    return $table
	. ($index ? " $table$index" : '');
#    return $support->get('models')->{$model}->{sql_name};
}

# _build_value(string column, string value, Bivio::SQL::Support support) : string
#
# Build placeholder and add value to I<params>.
#
sub _build_value {
    my($column, $value, $support, $params) = @_;
#    my($col_type) = $support->get_column_info($column)->{type};
    my($func, $model, $index, $field) = $column =~ /^(\w+\()?(\w+?)(_\d+)?\.(\w+)\)?$/;
    my($t) = ($func || '') =~ /^(length|count)\(/i ? 'Bivio::Type::Number'
	: Bivio::Biz::Model->get_instance($model)->get_field_type($field);
    push(@$params, $t->to_sql_param($value));
    return $t->to_sql_value('?');
}

# _combine_predicates(proto, string conjunctive, any predicate, ...) : hash_ref
#
# Combines the predicates with the conjunctive (AND or OR).
# OR values are wappred in parenthesis.
#
sub _combine_predicates {
      my($proto, $conjunctive) = (shift, shift);
      my($p) = [map(_parse_predicate($proto, $_), @_)];
      return {
          predicates => $p,
          build => sub {
              my($str) = join(" $conjunctive ",
  		grep($_, map($_->{build}->(@_), @$p)));
              return $conjunctive eq 'OR' ? "($str)" : $str;
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
            return @$values
		? _build_column($column, @_)
		. "$modifier IN ("
		. join(',', map(_build_value($column, $_, @_), @$values))
		. ')'
		: $modifier ? 'TRUE' : 'FALSE';
        },
    };
}

# _merge_statements(self, Bivio::SQL::Statement)
#
# Merge statement data
#
sub _merge_statements {
    my($self, $other) = @_;
    return unless $other;

    # TODO: more needs to be done here.
    $self->where($other->[$_IDI]->{where});
    return;
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
                ? _build_value($left, shift(@$right), @_)
                : _build_column($right, @_);
            return "$_left$comp$_right";
        },
    };
}

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
