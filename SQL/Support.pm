# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::Support;
use strict;
$Bivio::SQL::Support::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::Support - common interface to Support and ListSupport

=head1 SYNOPSIS

    use Bivio::SQL::Support;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::SQL::Support::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::SQL::Support> contains common attributes and routines for
L<Bivio::SQL::Support|Bivio::SQL::PropertySupport> and
L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>.

=head1 ATTRIBUTES

All of these attributes should be treated as read-only.  They are made
available via L<Bivio::Collection::Attributes|Bivio::Collection::Attributes>
for simplicity and code re-use.

=over 4

=item auth_id : hash_ref

Column which identifies the auth_id field.  On some Support instances,
this may not be defined.

=item column_names : array_ref

List of the columns.

=item primary_key_names : array_ref

List of primary key column names, which uniquely identify a row
or value.

=item primary_key_types : array_ref

List of primary key types in the order of I<primary_key_names>.

=item version : int

Version of this support declaration.

=back

=cut

#=IMPORTS
use Carp ();

#=VARIABLES


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::SQL::Support

Pass through "new".

=cut

sub new {
    return Bivio::Collection::Attributes::new(@_);
}

=head1 METHODS

=cut

=for html <a name="get_column_constraint"></a>

=head2 get_column_constraint(string name) : Bivio::SQL::Constraint

Returns the constraint of the column.

=cut

sub get_column_constraint {
    my($columns) = shift->get('columns');
    my($name) = shift;
    my($col) = $columns->{$name};
    Carp::croak("$name: no such column") unless $col;
    return $col->{constraint};
}

=for html <a name="get_column_name"></a>

=head2 get_column_name(string name) : string

Returns the name of the column.  This maps all aliases (including
main column names) to the original column name.

=cut

sub get_column_name {
    my($column_aliases) = shift->get('columns_aliases');
    my($name) = shift;
    my($col) = $column_aliases->{$name};
    Carp::croak("$name: no such column alias") unless $col;
    return $col->{name};
}

=for html <a name="get_column_type"></a>

=head2 get_column_type(string name) : Bivio::Type

Returns the type of the column.

=cut

sub get_column_type {
    my($columns) = shift->get('columns');
    my($name) = shift;
    my($col) = $columns->{$name};
    Carp::croak("$name: no such column") unless $col;
    return $col->{type};
}

=for html <a name="has_columns"></a>

=head2 has_columns(string column_name, ...) : boolean

Does the model have the specified columns

=cut

sub has_columns {
    my($columns) = shift->get('columns');
    my($n);
    foreach $n (@_) {
	return 0 unless exists($columns->{$n});
    }
    return 1;
}

=for html <a name="init_column"></a>

=head2 static init_column(hash_ref attrs, string qual_col, string class, boolean is_alias) : hash_ref

B<INTERNAL USE ONLY>

Initializes I<qual_col> which is of the form C<Model_N.column> or
C<Model.column> in I<attr>'s C<columns> if not already defined.
Also updates I<class> and C<models> I<attrs>.
Only modifies C<models> if I<is_alias>.

Always returns a column hash_ref, but for I<is_alias> is not stored in
I<attrs>.

=cut

sub init_column {
    my(undef, $attrs, $qual_col, $class, $is_alias) = @_;
    my($columns) = $attrs->{columns};
    my($col);
    unless ($col = $columns->{$qual_col}) {
	my($qual_model, $column) = $qual_col =~ m!^(\w+(?:_\d+)?)\.(\w+)$!;
	Carp::croak("$qual_col: invalid qualified column name")
		    unless $qual_model && $column;
	my($model);
	unless ($model = $attrs->{models}->{$qual_model}) {
	    my($package) = 'Bivio::Biz::PropertyModel::'.$qual_model;
	    $package =~ s!((?:_\d+)?)$!!;
	    my($qual_index) = $1;
	    # Make sure package is loaded
	    Bivio::Util::my_require($package);
	    my($instance) = $package->get_instance;
	    $model = $attrs->{models}->{$qual_model} = {
		name => $qual_model,
		instance => $instance,
		sql_name => $instance->get_info('table_name') . $qual_index,
	    };
	}
	my($type) = $model->{instance}->get_field_type($column);
	$col = {
	    # Bivio::SQL::Support attributes
	    name => $qual_col,
	    type => $type,
	    constraint => $model->{instance}->get_field_constraint($column),

	    # Other attributes
	    column_name => $column,
	    model => $model,
	    sql_name => $model->{sql_name}.'.'.$column,
	};
	$columns->{$qual_col} = $col unless $is_alias;
    }
    push(@{$attrs->{$class}}, $col) unless $is_alias;
    return $col;
}

=for html <a name="init_column_classes"></a>

=head2 init_column_classes(hash_ref attrs, hash_ref decl, array_ref classes) : string

Initialize the column classes.
Returns the beginnings of the where clause (alias field identities)

=cut

sub init_column_classes {
    my($proto, $attrs, $decl, $classes) = @_;
    my($column_aliases) = $attrs->{column_aliases};
    my($where) = '';
    # Initialize all columns and put into appropriate column classes
    foreach my $class (@$classes) {
	$attrs->{$class} = [];
	my($list) = $decl->{$class};
	next unless $list;
	# auth_id is only one that is syntactically different
	$list = [$list] if $class eq 'auth_id';
	foreach my $decl (@$list) {
	    my(@aliases, $first, $col);
	    if (ref($decl) eq 'HASH') {
		$col = _init_column_from_hash($attrs, $decl, $class,
			\@aliases);
		$first = $col->{name};
	    }
	    else {
		# case: [] or Model.name
		@aliases = ref($decl) ? @$decl : ($decl);
		# First column is the official name.  The rest are aliases.
		$first = shift(@aliases);
		$col = $proto->init_column($attrs, $first, $class, 0);
	    }
	    $column_aliases->{$first} = $col;
	    my($alias);
	    foreach $alias (@aliases) {
		# Creates a temporary column just to get sql_name and
		# to make sure "model" is created if need be.
		my($alias_col) = $proto->init_column(
			$attrs, $alias, $class, 1);
#TODO: Shouldn't allow where to be created for local columns
		$where .= ' and '.$col->{sql_name}.'='.$alias_col->{sql_name};
		# All aliases point to main column.  They don't exist
		# outside of this context.
		$column_aliases->{$alias} = $col;
	    }
	}
    }
    return $where;
}

=for html <a name="init_model_primary_key_maps"></a>

=head2 static init_model_primary_key_maps(hash_ref attrs)

B<INTERNAL USE ONLY>

Initializes C<primary_key_map> for C<models> in I<attrs>.

Primary key names are put in the C<other> category if they are not already
in C<column_aliases> of I<attrs>

=cut

sub init_model_primary_key_maps {
    my($proto, $attrs) = @_;
    # Ensure that (qual) columns defined for all (qual) models and their
    # primary keys and initialize primary_key_map.
    my($n);
    foreach $n (keys(%{$attrs->{models}})) {
	my($m) = $attrs->{models}->{$n};
	$m->{primary_key_map} = {};
	my($pk);
	foreach $pk (@{$m->{instance}->get_info('primary_key_names')}) {
	    my($cn) = $m->{name}.'.'.$pk;
	    $proto->init_column($attrs, $cn, 'other', 0)
		    unless $attrs->{column_aliases}->{$cn};
	    $m->{primary_key_map}->{$cn} = $attrs->{column_aliases}->{$cn};
	}
    }
    return;
}

=for html <a name="init_version"></a>

=head2 static init_version(hash_ref attrs, hash_ref decl)

B<INTERNAL USE ONLY>

Validates C<version> in I<decl> is syntactically correct and
sets in I<attrs>.

=cut

sub init_version {
    my($proto, $attrs, $decl) = @_;
    Carp::croak("version: not declared or invalid (not positive integer)")
		unless $decl->{version} && $decl->{version} =~ /^\d+$/;
    $attrs->{version} = $decl->{version};
    return;
}

#=PRIVATE METHODS

# _init_column_from_hash(hash_ref attrs, hash_ref decl, string class, array_ref aliases) : hash_ref
#
# Initializes the column from a hash reference of (name, type, constraint).
#
sub _init_column_from_hash {
    my($attrs, $decl, $class, $aliases) = @_;
    my($col, $first);
    # case: "{ name => }"
    if (ref($first = $decl->{name})) {
	# case: "{name => [a, b]}"
	@$aliases = @$first;
	$first = shift(@$aliases);
    }
    if ($first =~ /\./) {
	# case: "{name => Model.column}"
	$col = __PACKAGE__->init_column($attrs, $first, $class, 0);
    }
    else {
	# case: "{name => local_field}"
	Carp::croak($first, ': declared at least twice')
		    if $attrs->{columns}->{$first};
	Carp::croak('type and constraint must be defined')
		    unless $decl->{type} && $decl->{name};
	$col = {name => $first};
	push(@{$attrs->{local_columns}}, $col);
    }
    # Override or define new, but only set if set
    if ($decl->{type}) {
	Carp::croak($decl->{type}, ': not a Bivio::Type')
		    unless UNIVERSAL::isa($decl->{type}, 'Bivio::Type');
	$col->{type} = $decl->{type};
    }
    if ($decl->{constraint}) {
	Carp::croak($decl->{constraint}, ': not a Bivio::SQL::Constraint')
		    unless UNIVERSAL::isa($decl->{constraint},
			    'Bivio::SQL::Constraint');
	$col->{constraint} = $decl->{constraint};
    }
    return $col;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
