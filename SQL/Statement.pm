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
    my($proto, @predicates) = @_;
    my($predicates) = [map({_parse_predicate($proto, $_)} @predicates)];
    return {
        predicates => $predicates,
        build => sub {
            return join(' AND ', map({$_->{build}->(@_)} @$predicates));
        },
    }
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

    return;
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

=for html <a name="IN"></a>

=head2 static IN(string column, array_ref list) : hash_ref

Return an IN predicate.

=cut

sub IN {
    my($proto, $column, $values) = @_;
    return {
        column => $column,
        values => $values,
        build => sub {
            return _build_column($column, @_) . ' IN (' .
                join(',', map({_build_value($column, $_, @_)} @$values)) . ')';
        },
    };
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

=for html <a name="new"></a>

=head2 static new(Bivio::SQL::Support support) : Bivio::SQL::Statement

Return a new instance.

=cut

sub new {
    my($proto, $support) = @_;
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {
        from => {},
        where => $self->AND(),
        _models => {},
	_sql_support => $support,
	_params => [],
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="build_for_internal_load_rows"></a>

=head2 build_for_internal_load_rows() : (string, array_ref)

Return FROM and WHERE clauses for internal_load_rows

=cut

sub build_for_internal_load_rows {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    my($support) = $fields->{_sql_support};
    my($params) = $fields->{_params};

    my($where) = $fields->{where};
    return ($where->{build}->($support, $params), $fields->{_params})
        unless scalar(keys %{$fields->{from}});

    foreach my $model (keys %{$fields->{_sql_support}->get('models')}) {
        _add_model($self, $model);
    }

    my($join) = $self->CROSS_JOIN(
        map({$fields->{from}->{$_}}
            sort keys %{$fields->{from}}));

    #TODO: The trailing AND avoids a bug in ListSupport (or somewhere).
    # Should be removed once ListSupport (and kin) have been gutted of
    # their vile string manipulations.
    return (
        join(' ', 'FROM', $join->{build}->($support, $params),
            'WHERE', $where->{build}->($support, $params), 'AND '),
	$fields->{_params});
}

=for html <a name="from"></a>

=head2 from(any join)

Add the join to the FROM clause.

=cut

sub from {
    my($self, $join) = @_;
    my($models) = $self->[$_IDI]->{_models};
    my($left_table) = $join->{left_table};
    my($right_table) = $join->{right_table};

    Bivio::Die->die($right_table, ': is already left joined with ',
        $models->{$right_table}->{_joined_from},
    )
        if exists $models->{$right_table}
            && exists $models->{$right_table}->{_joined_from};

    my($left) = _add_model($self, $left_table);
    $left->{joins}->{$right_table} = $join;

    my($right) = _add_model($self, $right_table);
    $right->{_joined_from} = $left_table;

    delete $self->[$_IDI]->{from}->{$right_table};
    return;
}

=for html <a name="where"></a>

=head2 where(any predicate)

Add I<predicate> to WHERE clause.  This condition will be ANDed
with any other existing conditions.

=cut

sub where {
    my($self, $predicate) = @_;
    push(@{$self->[$_IDI]->{where}->{predicates}},
        _parse_predicate($self, $predicate))
	if $predicate;
    return;
}

#=PRIVATE SUBROUTINES

# _add_model(self, string model) : hash_ref
#
# Add model to _models and from (if new).
# Return the hash_ref representation.
#
sub _add_model {
    my($self, $model) = @_;
    my($models) = $self->[$_IDI]->{_models};
    my($joins) = {};
    $self->[$_IDI]->{from}->{$model} = $models->{$model} = {
        build => sub {
            return
                join(' ', _build_model($model, @_),
                    map({$_->{build}->(@_)}
                        map({$joins->{$_}} sort keys %$joins)));
        },
        joins => $joins,
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
    return $support->get_column_info($column)->{sql_name};
}

# _build_model(string model, Bivio::SQL::Support support) : string
#
# Return the sql table name for the model
#
sub _build_model {
    my($model, $support) = @_;
    return $support->get('models')->{$model}->{sql_name};
}

# _build_value(string column, string value, Bivio::SQL::Support support) : string
#
# Build placeholder and add value to I<params>.
#
sub _build_value {
    my($column, $value, $support, $params) = @_;
    my($col_type) = $support->get_column_info($column)->{type};
    push(@$params, $col_type->to_sql_param($value));
    return $col_type->to_sql_value('?');
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
                ? _build_value($left, shift @$right, @_)
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
