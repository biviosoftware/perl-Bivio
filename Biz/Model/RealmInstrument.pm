# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::RealmInstrument;
use strict;
$Bivio::Biz::Model::RealmInstrument::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmInstrument - interface to realm_instrument_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmInstrument;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmInstrument::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmInstrument> is the create, read, update,
and delete interface to the C<realm_instrument_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Connection;
use Bivio::SQL::Constraint;
use Bivio::Type::Boolean;
use Bivio::Type::DateTime;
use Bivio::Type::EntryType;
use Bivio::Type::Line;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
use Bivio::Type::Text;
use Bivio::Type::TaxCategory;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<average_cost_method> and I<drp_plan> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{average_cost_method} = 0
	    unless defined($values->{average_cost_method});
    $values->{drp_plan} = 0 unless defined($values->{drp_plan});
    return $self->SUPER::create($values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_instrument_t',
	columns => {
            realm_instrument_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            instrument_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
            realm_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
            account_number => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::NONE()],
            average_cost_method => ['Bivio::Type::Boolean',
    		Bivio::SQL::Constraint::NOT_NULL()],
            drp_plan => ['Bivio::Type::Boolean',
    		Bivio::SQL::Constraint::NOT_NULL()],
            remark => ['Bivio::Type::Text',
    		Bivio::SQL::Constraint::NONE()],
        },
	other => [
#	    [qw(realm_id RealmOwner.realm_id)],
	    [qw(instrument_id Instrument.instrument_id)],
	],
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
