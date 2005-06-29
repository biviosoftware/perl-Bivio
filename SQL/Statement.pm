# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::SQL::Statement;
use strict;
$Bivio::SQL::Statement::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::SQL::Statement::VERSION;

=head1 NAME

Bivio::SQL::Statement - SQL statement abstraction

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::SQL::Statement;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::SQL::Statement::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::SQL::Statement> is an experimental module, currently used to support
L<Bivio::Biz::ListModel|Bivio::Biz::ListModel>.  It will eventually be an
abstraction for an SQL statement.  Currently, implements abstraction for the
where clause.

This

=head1 ATTRIBUTES

=over 4

=item params : array_ref [[]]

Returns parameters to use with I<where>.

=item where : string []

Where clause.  Do not modify directly, use
L<append_where_and|"append_where_and">.  Includes the leading ' AND '.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::SQL::Statement

Instantiates empty where.

=cut

sub new {
    return shift->SUPER::new({
	params => [],
	where => '',
    });
}

=head1 METHODS

=cut

=for html <a name="append_where_and"></a>

=head2 append_where_and(string where, array_ref params) : self

Appends I<sql> to the where clause as an clause.  I<params> may be
C<undef> or an array of parameters to pass.

=cut

sub append_where_and {
    my($self, $where, $params) = @_;
    my($w) = $self->get('where');
    $self->put(where => "$w AND ($where)");
    push(@{$self->get('params')}, @$params)
	if $params;
    return $self;
}

=for html <a name="insert_params"></a>

=head2 insert_params(array_ref params) : self

Put I<params> at front of I<params> list.

=cut

sub insert_params {
    my($self, $params) = @_;
    unshift(@{$self->get('params')}, @$params);
    return $self;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
