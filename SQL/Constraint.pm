# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::Constraint;
use strict;
$Bivio::SQL::Constraint::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::Constraint - enum of contraints on SQL fields

=head1 SYNOPSIS

    use Bivio::SQL::Constraint;
    Bivio::SQL::Constraint->new();

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::SQL::Constraint::ISA = qw(Bivio::Type::Enum);

=head1 DESCRIPTION

C<Bivio::SQL::Constraint> defines a list of database constraints.
They are used as attributes in the property info passed to
L<Bivio::SQL::Support::new|Bivio::SQL::Support/"new">.

=over 4

=item NONE

no constraints

=item PRIMARY_KEY

the field is one of the fields which forms the primary key

=item NOT_NULL

may not be null

=item NOT_NULL_UNIQUE

may not be null and must be unique

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    NONE => [0],
    PRIMARY_KEY => [1],
    NOT_NULL => [1],
    NOT_NULL_UNIQUE => [1],
);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
