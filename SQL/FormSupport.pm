# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::FormSupport;
use strict;
$Bivio::SQL::FormSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::FormSupport - sql support for ListModels

=head1 SYNOPSIS

    use Bivio::SQL::FormSupport;
    Bivio::SQL::FormSupport->new($decl);

=cut

=head1 EXTENDS

L<Bivio::SQL::Support>

=cut

use Bivio::SQL::Support;
@Bivio::SQL::FormSupport::ISA = ('Bivio::SQL::Support');

=head1 DESCRIPTION

C<Bivio::SQL::FormSupport> is the meta-data model for
L<Bivio::Biz::FormModel>s.  This module does not execute SQL.

=head1 ATTRIBUTES

See also L<Bivio::SQL::Support|Bivio::SQL::Support> for more attributes.

=over 4

=item auth_id : array_ref (required)

A field or field identity which must be equal to
request's I<auth_id> attribute.

=item file_fields : array_ref

The columns which are L<Bivio::Type::FileField|Bivio::Type::FileField>
type.  C<undef> if no file fields.

=item hidden : array_ref

List of columns which are to be sent to and returned from the user, unmodified.

=item other : array_ref

A list of fields and field identities.  These are not output
with the form.  They are used for internal communication between
the form and the UI.

=item primary_key : array_ref (required)

The list of fields and field identities that uniquely identifies a
form.

=item require_context : boolean

True if the form expects to have context when operating.

=item version : int

The version of this particular combination of fields.  It will be
set in all outgoing forms.  It should be changed whenever the
declaration changes.  It is used to reject an out-of-date form.

=item visible : array_ref

List of columns to be made visible to the user.

=back

=head1 COLUMN ATTRIBUTES

=over 4

=item is_file_field : boolean

True if the field is a file field.

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Biz::PropertyModel;
use Bivio::Type::PrimaryId;
use Bivio::Util;
use Carp();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref decl) : Bivio::SQL::FormSupport

Creates a SQL support instance from a declaration.  A I<decl> is a list of
keyed categories.  The keys are described below.  The values are either an
array_ref, a string (except I<version>), or a hash.
The array_ref may contain strings
(property fields), hash_refs (local fields),
or array_refs of strings (field identities).

A I<property model field> is composed of a
table qualifier and the column name.  The first field in a field identity is
a property of the form model.

A I<local field> is defined as a hash_ref containing one or more
of the following attributes:

=over 4

=item name : string (required)

=item name : array_ref (required)

is a perl identifier (\w+) or a property model field identifier (\w+.\w+).
If the I<name> is an array_ref, the first element is the property name.

=item type : Bivio::Type

The type of the local field.  You may override the type of a
property model field with this field.

=item constraint : Bivio::SQL::Constraint

The constraint of the local field.  You may override the constraint of a
property model field with this field.

=back

The types of the property fields will be extracted from the property
models corresponding to the table names unless overridden

=cut

sub new {
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
	require_context => $decl->{require_context} ? 1 : 0,
	has_field_field => 0,
    };
    $proto->init_version($attrs, $decl);
    _init_column_classes($attrs, $decl);
    return &Bivio::SQL::Support::new($proto, $attrs);
}

=head1 METHODS

=cut

=for html <a name="get_column_name_for_html"></a>

=head2 get_column_name_for_html(string name) : string

Returns the name of the column for an HTML form.

=cut

sub get_column_name_for_html {
    my($columns) = shift->get('columns');
    my($name) = shift;
    my($col) = $columns->{$name};
    Carp::croak("$name: no such column") unless $col;
    return $col->{form_name};
}

#=PRIVATE METHODS

# _init_column_classes(hash_ref attrs, hash_ref decl)
#
# Initialize the column classes (auth_id, visible, hidden, etc.)
#
sub _init_column_classes {
    my($attrs, $decl) = @_;
    my($column_aliases) = $attrs->{column_aliases};
    __PACKAGE__->init_column_classes($attrs, $decl,
	    [qw(auth_id visible hidden primary_key other)]);

    # auth_id must be at most one column.
    Carp::croak('too many auth_id fields') if int(@{$attrs->{auth_id}}) > 1;
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
    foreach my $col (@{$attrs->{visible}}, @{$attrs->{hidden}}) {
	$attrs->{column_aliases}->{$i} = $col;
	# Can't just use a number here
	$col->{form_name} = 'f'.$i++;
	if ($col->{is_file_field} = UNIVERSAL::isa($col->{type},
		'Bivio::Type::FileField') ? 1 : 0) {
	    $attrs->{file_fields} = [] unless $attrs->{file_fields};
	    push(@{$attrs->{file_fields}}, $col);
	}
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
