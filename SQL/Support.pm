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

C<Bivio::SQL::Support> is common attributes and routines for
L<Bivio::SQL::Support|Bivio::SQL::PropertySupport> and
L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>.

=head1 ATTRIBUTES

All of these attributes should be treated as read-only.  They are made
available via L<Bivio::Collection::Attributes|Bivio::Collection::Attributes>
for simplicity and code re-use.

=over 4

=item column_names : array_ref

List of the columns.

=item primary_key_names : array_ref

List of primary key column names, which uniquely identify a row.

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

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
