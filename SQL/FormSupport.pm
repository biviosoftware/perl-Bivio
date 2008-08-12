# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::FormSupport;
use strict;
use Bivio::Base 'SQL.Support';
use Bivio::Biz::Model;
use Bivio::IO::Trace;
use Bivio::Type::PrimaryId;

# C<Bivio::SQL::FormSupport> is the meta-data model for
# L<Bivio::Biz::FormModel>s.  This module does not execute SQL.
#
#
# See also L<Bivio::SQL::Support|Bivio::SQL::Support> for more attributes.
#
#
# auth_id : array_ref
#
# A field or field identity which must be equal to
# request's I<auth_id> attribute.
#
# file_fields : array_ref
#
# The columns which are L<Bivio::Type::FileField|Bivio::Type::FileField>
# type.  C<undef> if no file fields.
#
# file_field_names : array_ref
#
# Names of I<file_fields> columns.
#
# has_secure_data : boolean
#
# One of the fields contains secure_data
# (L<Bivio::Type::is_secure_data|Bivio::Type/"is_secure_data">).
#
# hidden : array_ref
#
# List of columns which are to be sent to and returned from the user, unmodified.
#
# hidden_field_names : array_ref
#
# Names of I<hidden> columns.
#
# in_list : array_ref
#
# List of columns for which I<in_list> is true.
#
# in_list_field_names : array_ref
#
# Names of I<in_list> columns.
#
# list_class : string
#
# If set, fields are repeatable.  Primary key fields of the list model are
# added, automatically as hidden fields.
#
# It may be the simple model name or full ListModel on declaration.
# Will be prefixed with C<Bivio::Biz::ListModel::> and loaded
# dynamically.
#
# These fields are also added to I<hidden>.
#
# other : array_ref
#
# A list of fields and field identities.  These are not output
# with the form.  They are used for internal communication between
# the form and the UI.
#
# primary_key : array_ref
#
# The list of fields and field identities that uniquely identifies a
# form.
#
# require_context : boolean
#
# True if the form expects to have context when operating.
#
# require_validate : boolean
#
# True if the form requires validate to be called even on direct execution.
#
# version : int
#
# The version of this particular combination of fields.  It will be
# set in all outgoing forms.  It should be changed whenever the
# declaration changes.  It is used to reject an out-of-date form.
#
# visible : array_ref
#
# List of columns to be made visible to the user.
#
# visible_field_names : array_ref
#
# Names of I<visible> columns.
#
#
#
#
# default_value : any [undef]
#
# Specifies the default value.  Currently doesn't handle reference types
# properly.
#
# in_list : boolean
#
# True if the field is repeatable.
# See L<Bivio::Biz::ListFormModel|Bivio::Biz::ListFormModel>.
# All these columns are in I<in_list> global attribute.
#
# is_file_field : boolean
#
# True if the field is a file field.
#
# is_visible : boolean
#
# True if the field is visible.
#
# form_name : string
#
# Let's you specify form names explicitly for special cases, e.g.
# incoming mail via b-sendmail-agent.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_CLASSES) = [qw(auth_id visible hidden primary_key other)];

sub extract_column_from_classes {
    my($proto, $decls, $column_name) = @_;
    foreach my $c (map(@{$decls->{$_} || []}, @$_CLASSES)) {
	if (ref($c)) {
	    return $c
		if $c->{name} eq $column_name;
	}
	else {
	    return {name => $c}
		if $c eq $column_name;
	}
    }
    Bivio::Die->die($column_name, ': not found in ', $decls);
    # DOES NOT RETURN
}

sub get_column_name_for_html {
    # (self, string) : string
    # Returns the name of the column for an HTML form.
    my($columns) = shift->get('columns');
    my($name) = shift;
    my($col) = $columns->{$name};
    die("$name: no such column") unless $col;
    return $col->{form_name};
}

sub new {
    # (proto, hash_ref) : SQL.FormSupport
    # Creates a SQL support instance from a declaration.  A I<decl> is a list of
    # keyed categories.  The keys are described below.  The values are either an
    # array_ref, a string (except I<version>), or a hash.
    # The array_ref may contain strings
    # (property fields), hash_refs (local fields),
    # or array_refs of strings (field identities).
    #
    # A I<property model field> is composed of a
    # table qualifier and the column name.  The first field in a field identity is
    # a property of the form model.
    #
    # A I<local field> is defined as a hash_ref containing one or more
    # of the following attributes:
    #
    #
    # name : string (required)
    #
    # name : array_ref (required)
    #
    # is a perl identifier (\w+) or a property model field identifier (\w+.\w+).
    # If the I<name> is an array_ref, the first element is the property name.
    #
    # type : Bivio::Type
    #
    # The type of the local field.  You may override the type of a
    # property model field with this field.
    #
    # constraint : Bivio::SQL::Constraint
    #
    # The constraint of the local field.  You may override the constraint of a
    # property model field with this field.
    #
    #
    # The types of the property fields will be extracted from the property
    # models corresponding to the table names unless overridden
    my($proto, $decl) = @_;
    my($attrs) = {
	# All columns by qualified name
	columns => {},
	# All models by qualified name
	models => {},
	# All fields and field identities by qualified name
	column_aliases => {},
	# Columns which have no corresponding property model field
	local_columns => [],
	map(($_ => $decl->{$_} ? 1 : 0), qw(require_validate require_context)),
	has_secure_data => 0,
    };
    $proto->init_common_attrs($attrs, $decl);

    # Modify the declarations to include the list model primary key
    _init_list_class($attrs, $decl);

    _init_column_classes($attrs, $decl);

    # Finish up by creating in_list_columns
    _init_list_columns($attrs, $decl);

    return $proto->SUPER::new($attrs);
}

sub _init_column_classes {
    # (hash_ref, hash_ref) : undef
    # Initialize the column classes (auth_id, visible, hidden, etc.)
    my($attrs, $decl) = @_;
    my($column_aliases) = $attrs->{column_aliases};
    __PACKAGE__->init_column_classes($attrs, $decl, $_CLASSES);

    # auth_id must be at most one column.
    die('too many auth_id fields') if int(@{$attrs->{auth_id}}) > 1;
    # Will set to undef if no auth_id.
    $attrs->{auth_id} = $attrs->{auth_id}->[0];

    # Ensure that (qual) columns defined for all (qual) models and their
    # primary keys and initialize primary_key_map.
    __PACKAGE__->init_model_primary_key_maps($attrs);

    # These lists are sorted in keeping with other Support modules
    $attrs->{primary_key_names} = [map {$_->{name}} @{$attrs->{primary_key}}];
    $attrs->{primary_key_types} = [map {$_->{type}} @{$attrs->{primary_key}}];

    $attrs->{column_names} = [sort(keys(%{$attrs->{columns}}))];

    # Assign form_name to each of the fields that can be in the form
    # Add it as an alias for easy input parsing.
    my($i) = 0;
    $attrs->{file_fields} = undef;
#TODO: These must agree with FormModel
    my(%form_names) = (Bivio::Biz::FormModel->VERSION_FIELD() => 1,
	    Bivio::Biz::FormModel->CONTEXT_FIELD() => 1,
	    Bivio::Biz::FormModel->TIMEZONE_FIELD() => 1,);
    foreach my $col (@{$attrs->{visible}}, @{$attrs->{hidden}}) {
	if ($col->{form_name}) {
	    # Check syntax of user designated fields
	    die($col->{name}, ': duplicate form name (',
		    $col->{form_name}, ')') if $form_names{$col->{form_name}};
	    die($col->{name}, q{: form name cannot be fNN. You probably have a field in both the 'visible' and 'hidden' sections of your form definition.  OR, you may be trying to edit the primary key field of a ListFormModel's ListModel.})
		    if $col->{form_name} =~ /^f\d+/;
	    $form_names{$col->{form_name}} = 1;
	}
	else {
	    # Can't just use a number here
	    $col->{form_name} = 'f'.$i++;
	}
	$attrs->{column_aliases}->{$col->{form_name}} = $col;
	if ($col->{is_file_field} = UNIVERSAL::isa($col->{type},
		'Bivio::Type::FileField') ? 1 : 0) {
	    $attrs->{file_fields} = [] unless $attrs->{file_fields};
	    push(@{$attrs->{file_fields}}, $col);
	}
	$attrs->{has_secure_data} = 1 if $col->{type}->is_secure_data;
	# Defaults to false and overwritten below
	$col->{is_hidden} = 0;
    }

    # Reset is_visible for visible fields.
    foreach my $col (@{$attrs->{visible}}) {
	$col->{is_visible} = 1;
    }

    # Map field name lists
    $attrs->{visible_field_names} = [sort(map {
	$_->{name}
    } @{$attrs->{visible}})];

    $attrs->{hidden_field_names} = [sort(map {
	$_->{name}
    } @{$attrs->{hidden}})];

    $attrs->{file_field_names} = [sort(map {
	$_->{name}
    } @{$attrs->{file_fields}})]
		if $attrs->{file_fields};
    return;
}

sub _init_list_class {
    # (hash_ref, hash_ref) : undef
    # Initialize the list_class and primary_key attributes by copying
    # list_class's primary_key to this model.
    my($attrs, $decl) = @_;
    # No list
    return unless $decl->{list_class};

    my($lm) = Bivio::Biz::Model->get_instance($decl->{list_class});
    $attrs->{list_class} = ref($lm);

    # Set the primary_key by copying the list_class's primary key
    $decl->{hidden} = [] unless $decl->{hidden};
    foreach my $col (@{$lm->get_info('primary_key')}) {
	# Copy all the attributes, because list_class may override
	# the attributes or have local fields.
	my($c) = {
	    name => $col->{name},
	    type => $col->{type},
	    constraint => $col->{constraint},
	    in_list => 1,
	};
	push(@{$decl->{hidden}}, $c);
    }
    return;
}

sub _init_list_columns {
    # (hash_ref, hash_ref) : undef
    # Initialize in_list and in_list_field_names
    my($attrs, $decl) = @_;

    $attrs->{in_list} = [];
    $attrs->{in_list_field_names} = [];
    foreach my $cn (@{$attrs->{column_names}}) {
	my($col) = $attrs->{columns}->{$cn};
	next unless $col->{in_list};
	push(@{$attrs->{in_list}}, $col);
	push(@{$attrs->{in_list_field_names}}, $cn);
    }
    return;
}

1;
