# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Support;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::Die;
use Bivio::HTML;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;
use Bivio::Type::DateTime;
use Bivio::Type;

# C<Bivio::SQL::Support> contains common attributes and routines for
# L<Bivio::SQL::Support|Bivio::SQL::PropertySupport> and
# L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>.
#
#
# All of these attributes should be treated as read-only.  They are made
# available via L<Bivio::Collection::Attributes|Bivio::Collection::Attributes>
# for simplicity and code re-use.
#
#
# auth_id : hash_ref
#
# Column which identifies the auth_id field.  On some Support instances,
# this may not be defined.
#
# columns : hash_ref
#
# All columns in the model.  For forms, this includes I<visible> and
# I<hidden>.  For other models, this includes I<other>, I<primary_key>,
# etc.
#
# column_names : array_ref
#
# List of names in I<columns>.  This list is sorted.
#
# primary_key_names : array_ref
#
# List of primary key column names, which uniquely identify a row
# or value. This list is in order that they were declared by
# the Model.
#
# primary_key : array_ref
#
# List of primary key columns.  Same order as I<primary_key_names>.
#
# version : int
#
# Version of this support declaration.
#
#
#
# These attributes apply to fields (INCOMPLETE!)
#
#
# in_list : boolean
#
# Used by ListFormModel to indicate a column is in the list.
#
# in_select : boolean
#
# Used by ListModel to indicate a column is in the select.
# Can be used to force C<LEVEL> to be in select.
#
# is_searchable : boolean [0]
#
# True, if the PropertyModel column should be included in the global search
# index.
#
# sort_order : boolean
#
# Default order by option.
# True means ascending (normal) and false means descending.
# NOT NORMALLY USED.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_LQ) = b_use('SQL.ListQuery');
my($_C) = b_use('SQL.Constraint');
my($_QP) = qr{[a-z][a-z0-9_]+};
my($_QUAL_PREFIX) = qr{^($_QP)\.}os;
# Make minimal assumptions about what this looks like so that
# Model.TupleTag can use for fields or slots
my($_COLUMN_RE) = qr{(?:^|\.)(@{[b_use('Type.TupleSlotLabel')->VALID_CHAR_REGEX]}+)$}os;
my($_QUAL_FIELD) = qr{^($_QP)\.(\w+)$_COLUMN_RE}os;
my($_QUAL_SUFFIX) = qr{(_\d+)$}s;

sub clone {
    # Always a singleton
    return shift;
}

sub extract_column_name {
    my($self, $column) = @_;
    return ($column =~ $_COLUMN_RE)[0];
}

sub extract_model_prefix {
    my($proto, $column) = @_;
    return $column =~ m{^(.+)\.\w+$} ? $1 : undef;
}

sub extract_qualified_prefix {
    my($proto, $field) = @_;
    return (
	$proto->parse_qualified_field($field)
        || b_die($field, ': must be a qualified column with prefix')
    )->{prefix};
}

sub get_column_constraint {
    # Returns the constraint of the column.
    return shift->get_column_info(@_, 'constraint');
}

sub get_column_info {
    my($self, $name, $attr) = @_;
    # Returns I<attr> for I<column> or all attrs if attr not defined.
    my($col) = $self->get('columns')->{$name};
    Bivio::Die->die(
	$name, ': no such column in ', $self->unsafe_get('table_name')
    ) unless $col;
    return $col
	unless defined($attr);
    Bivio::Die->die($name, '.', $attr, ': no such attribute')
        unless exists($col->{$attr});
    return $col->{$attr};
}

sub get_column_name {
    my($self, $name) = @_;
    # Returns the name of the column.  This maps all aliases (including
    # main column names) to the original column name.
    my($col) = $self->get('column_aliases')->{$name};
    Bivio::Die->die($name, ': no such column alias')
        unless $col;
    return $col->{name};
}

sub get_column_type {
    # Returns the type of the column.  May be a
    # L<Bivio::Type|Bivio::Type> or a
    # L<Bivio::Biz::Model|Bivio::Biz::Model>.  The latter may only be
    # used for non-database fields.
    return shift->get_column_info(@_, 'type');
}

sub has_columns {
    my($columns) = shift->get('columns');
    # Does the model have the specified columns
    my($n);
    foreach $n (@_) {
	return 0 unless exists($columns->{$n});
    }
    return 1;
}

sub init_column {
    my($proto, $attrs, $qual_col, $class, $is_alias) = @_;
    # B<INTERNAL USE ONLY>
    #
    # Initializes I<qual_col> which is of the form C<Model_N.column> or
    # C<Model.column> in I<attr>'s C<columns> if not already defined.
    # Also updates I<class> and C<models> I<attrs>.
    # Only modifies C<models> if I<is_alias>.
    #
    # Always returns a column hash_ref, but for I<is_alias> is not stored in
    # I<attrs>.
    my($columns) = $attrs->{columns};
    my($col) = $columns->{$qual_col};
    unless ($col) {
	my($cn) = $proto->parse_column_name($qual_col);
	my($model);
	$model = $attrs->{models}->{$cn->{model_name}} ||= {
	    name => $cn->{model_name},
	    instance => $cn->{model},
	    model_from_sql => $cn->{model_from_sql},
#TODO: don't know what is wrong here:
# ListFormModel which uses a ListModel with all local fields dies
# unless we exclude models ending in List
	    sql_name => $cn->{model_name} =~ /List$/ ? '' : $cn->{model_sql},
	    column_names_referenced => [],
	};
	push(@{$model->{column_names_referenced}}, $cn->{column_name});
	$col = {
	    # Keep these attributes in synch with FormSupport::_init_list_class
	    # Bivio::SQL::Support attributes
	    map(($_ => $cn->{$_}),
		qw(name type constraint sql_name column_name)),
	    sort_order => $_LQ->get_sort_order_for_type($cn->{type}),
	    model => $model,
	    in_list => 0,
	    in_select => 1,
	};
	$columns->{$qual_col} = $col
	    unless $is_alias;
    }
    _add_to_class($attrs, $class, $col)
	unless $is_alias;
    return $col;
}

sub init_column_classes {
    my($proto, $attrs, $decl, $classes) = @_;
    # Initialize the column classes.
    # Returns the beginnings of the where clause (alias field identities)
    #
    # Supports outer joins for aliases.  The alias must end with "(+)".
    my($column_aliases) = $attrs->{column_aliases};
    my($where) = '';
    # Initialize all columns and put into appropriate column classes
    foreach my $class (@$classes) {
	$attrs->{$class} = [];
	my($list) = $decl->{$class};
	next unless $list;
	# auth_id, parent_id, and date always need to be wrapped.  They
	# single entity.
	$list = [$list] if $class =~ /^date$|_id$/;
	Bivio::Die->die(
	    $class, ': is not an ARRAY; forgot square brackets?',
	) unless ref($list) eq 'ARRAY';
	foreach my $decl (@$list) {
	    my(@aliases) = ref($decl) eq 'ARRAY' ? @$decl : ($decl);
	    my($col) = _init_column_from_decl($proto, $attrs, shift(@aliases),
	        $class, 0);
	    Bivio::IO::Alert->warn(
		$attrs->{class}, ' ', $col->{name},
		': column initialized, but already an alias of ',
		$column_aliases->{$col->{name}}->{name},
		'; check ListModel fields, if this is a ListFormModel; If this is a subclass, use the main name in the equivalence',
	    ) if $column_aliases->{$col->{name}}
		&& $column_aliases->{$col->{name}}->{name} ne $col->{name};
	    $column_aliases->{$col->{name}} = $col;

	    # manually handle left joins, record aliases
	    my(@equivs) = ();
	    foreach my $alias (@aliases) {
		if (ref($alias)) {
		    push(@equivs, $alias);
		    next;
		}
                # Creates a temporary column just to get sql_name and
                # to make sure "model" is created if need be.
		my($outer_join) = $alias =~ s/\Q(+)\E$// ? '(+)' : '';
		my($alias_col) = $proto->init_column(
		    $attrs, $alias, $class, 1);
		if ($outer_join) {
		    $where .= ' and '.$col->{sql_name}.'='
			    .$alias_col->{sql_name}.$outer_join;
		}
		else {
		    push(@equivs, $alias);
		}
		# All aliases point to main column.  They don't exist
		# outside of this context.
		$column_aliases->{$alias} = $col;
	    }
	    # pass aliases config to Statement
	    my($stmt) = $attrs->{statement};
	    $stmt->where($stmt->EQ($col->{name}, @equivs))
		if scalar(@equivs);
	}
    }
    return $where;
}

sub init_common_attrs {
    my($proto, $attrs, $decl) = @_;
    # B<INTERNAL USE ONLY>
    #
    # Validates C<version> in I<decl> is syntactically correct and
    # sets in I<attrs>.
    #
    # Also initializes I<as_string_fields>.
    Bivio::Die->die(
	$decl->{class},
	' does not have a declared version--did you forget to ',
	'declare version in internal_initialize?')
    unless $decl->{version};
    Bivio::Die->die(
	$decl->{version},
	': version not declared or invalid (not positive integer)'
    ) unless $decl->{version} =~ /^\d+$/;
    $attrs->{version} = $decl->{version};
#TODO: Validate the list
    $attrs->{as_string_fields} = $decl->{as_string_fields}
	if $decl->{as_string_fields};
    $attrs->{statement} ||= Bivio::SQL::Statement->new();
    $attrs->{class} = $decl->{class};
    return;
}

sub init_model_primary_key_maps {
    my($proto, $attrs) = @_;
    # B<INTERNAL USE ONLY>
    #
    # Initializes C<primary_key_map> for C<models> in I<attrs>.
    #
    # Primary key names are put in the C<other> category if they are not already
    # in C<column_aliases> of I<attrs>
    # Ensure that (qual) columns defined for all (qual) models and their
    # primary keys and initialize primary_key_map.
    my($n);
    foreach $n (keys(%{$attrs->{models}})) {
	my($m) = $attrs->{models}->{$n};
	$m->{primary_key_map} = {};
	my($pk);
	foreach $pk (@{$m->{instance}->get_info('primary_key_names')}) {
	    my($cn) = $m->{name}.'.'.$pk;
	    $attrs->{column_aliases}->{$cn} = $proto->init_column(
		    $attrs, $cn, 'other', 0)
		    unless $attrs->{column_aliases}->{$cn};
	    $m->{primary_key_map}->{$pk} = $attrs->{column_aliases}->{$cn};
	}
    }
    return;
}

sub init_type {
    my($proto, $col, $type_cfg) = @_;
    if ($type_cfg =~ /^(.*)\.(.*)$/) {
	my($model, $field) = ($1, $2);
	$type_cfg = $field !~ /^[a-z]/ ? $proto->use($type_cfg)
	    : Bivio::Biz::Model->get_instance($model)->get_field_type($field);
    }
    $col->{type} = UNIVERSAL::isa($type_cfg, 'Bivio::UNIVERSAL')
	? $type_cfg
	: Bivio::Type->get_instance($type_cfg);
    $col->{sort_order} = $_LQ->get_sort_order_for_type($col->{type});
    return;
}

sub is_qualified_model_name {
    my(undef, $name) = @_;
    return $name && $name =~ /$_QUAL_PREFIX\w+$|^\w+$_QUAL_SUFFIX/os ? 1 : 0;
}

sub iterate_end {
    my($self, $iterator) = @_;
    # Terminates the iterator.
    $iterator->finish;
    return;
}

sub iterate_next {
    my($self, $model, $iterator, $row, $converter) = @_;
    # I<iterator> was returned by L<iterate_start|"iterate_start">.
    # I<row> is the resultant values by field name.
    # I<converter> is optional and is the name of a
    # L<Bivio::Type|Bivio::Type> method, e.g. C<to_html>.
    #
    # Returns false if there is no next.
    my($start_time) = Bivio::Type::DateTime->gettimeofday();
    my($r) = $iterator->fetchrow_arrayref;
    Bivio::SQL::Connection->increment_db_time($start_time);
    unless ($r) {
	# End
	%$row = ();
	$iterator->finish;
	return 0;
    }

    # Convert values
    my($attrs) = $self->internal_get;
    my($cols) = $attrs->{select_columns};
    for (my $i = $#$r; $i >= 0; $i--) {
	my($c) = $cols->[$i];
	my($t) = $c->{type};
	my($v) = $t->from_sql_column($r->[$i]);
	$row->{$c->{name}} = $converter ? $t->$converter($v) : $v;
    }
    return 1;
}

sub new {
    # Pass through "new".
    return shift->SUPER::new(@_);
}

sub parse_column_name {
    my($proto, $qual_col) = @_;
    my($qual_model, $field) = $qual_col =~ m{^(.+)\.(\w+)$};
    my($m) = $proto->parse_model_name($qual_model);
    return {
	%$m,
	column_name => $field,
	constraint => $m->{model}->get_field_constraint($field),
	name => $qual_col,
	sql_name => "$m->{model_sql}.$field",
	type => $m->{model}->get_field_type($field),
    };
}

sub parse_model_name {
    my($proto, $qual_model) = @_;
    my($model) = $qual_model;
    my($prefix) = lc($model =~ s/$_QUAL_PREFIX//o ? "_$1" : '');
    my($suffix) = $model =~ s/$_QUAL_SUFFIX//o ? $1 : '';
    $model = Bivio::Biz::Model->get_instance($model);
    my($table) = lc($model->get_info('table_name'));
    my($sql) = "$table$suffix$prefix";
    return {
	model => $model,
	model_name => $qual_model,
	table_name => $table,
	model_from_sql => $sql eq $table ? $sql : "$table $sql",
	model_sql => $sql,
    };
}

sub parse_qualified_field {
    my(undef, $name) = @_;
    my($res) = [($name || '') =~ $_QUAL_FIELD];
    return !@$res ? undef
	: {map(($_ => shift(@$res)), qw(prefix model field))};
}

sub _add_to_class {
    my($attrs, $class, $col) = @_;
    # Adds to class if not already in class.
    return if grep($col->{name} eq $_->{name}, @{$attrs->{$class}});
    push(@{$attrs->{$class}}, $col);
    return;
}

sub _init_column_from_decl {
    my($proto, undef, $decl) = @_;
    return shift->init_column(@_)
	unless ref($decl) eq 'HASH';
    return _init_column_from_hash(@_);
}

sub _init_column_from_hash {
    my(undef, $attrs, $decl, $class, $is_alias) = @_;
    # Initializes the column from a hash reference of (name, type, constraint).
    # $is_alias is unused; it is a placeholder to match init_column args
    my($col);
    my($col_name) = $decl->{name};
    if (ref($decl->{name}) eq 'ARRAY') {
	# case: "{name => [a, b]}"
	Bivio::Die->die('Invalid attempt to alias. Use [{}, ...] instead');
    }
    if ($col_name =~ /\./) {
	# case: "{name => Model.column}"
	$col = __PACKAGE__->init_column($attrs, $col_name, $class, 0);
	# in_select is set to true by init_column.  Only turn off
	# if set explicitly.
	$col->{in_select} = 0 if defined($decl->{in_select})
		&& !$decl->{in_select};
    }
    else {
	# case: "{name => local_field}"
	Bivio::Die->die($col_name, ': column declared at least twice')
	    if $attrs->{columns}->{$col_name};
	foreach my $x (qw(type name)) {
	    Bivio::Die->die($x, ': must be defined for "', $col_name, '"')
		unless $decl->{$x};
	}
	$col = {name => $col_name};
	push(@{$attrs->{local_columns}}, $col);
	$attrs->{columns}->{$col_name} = $col;
	$col->{in_select} = $decl->{in_select} || $decl->{select_value}
	    ? 1 : 0;
	$col->{sql_name} = $col->{name} if $col->{in_select};
    }
    __PACKAGE__->init_type($col, $decl->{type}) if $decl->{type};
    $col->{sort_order} = $decl->{sort_order} ? 1 : 0
	    if exists($decl->{sort_order});
    $col->{sql_name} = $decl->{sql_name}
	if exists($decl->{sql_name});
    $col->{constraint} = $_C->from_any($decl->{constraint})
	if $decl->{constraint};
    $col->{in_list} = $decl->{in_list} ? 1 : 0;
    $col->{null_set_primary_field} = $decl->{null_set_primary_field}
	if exists $decl->{null_set_primary_field};
    $col->{select_value} = $decl->{select_value}
        if $decl->{select_value};

    # Syntax checked in FormSupport.  Not used by other Model types.
    $col->{form_name} = $decl->{form_name} if $decl->{form_name};
    $col->{default_value} = exists($decl->{default_value})
        ? $decl->{default_value} : undef;
    _add_to_class($attrs, $class, $col);
    return $col;
}

1;
