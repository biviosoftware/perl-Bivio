# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MemberAllocation;
use strict;
$Bivio::Biz::Model::MemberAllocation::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MemberAllocation - member tax allocation info

=head1 SYNOPSIS

    use Bivio::Biz::Model::MemberAllocation;
    Bivio::Biz::Model::MemberAllocation->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MemberAllocation::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MemberAllocation> member tax allocation info.
This model caches member allocations performed by the MemberAllocationList.

=cut

#=IMPORTS
use Bivio::SQL::Connection;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');

=head1 METHODS

=cut

=for html <a name="delete_for_year"></a>

=head2 delete_for_year(string date)

Deletes all existing member allocations for the year of the specified
date.

=cut

sub delete_for_year {
    my($self, $date) = @_;

    my($start_date, $end_date) = Bivio::Biz::Accounting::Tax
	    ->get_date_boundary_for_year($date);

    Bivio::SQL::Connection->execute("
            DELETE FROM member_allocation_t
            WHERE allocation_date
                BETWEEN $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE
            AND realm_id=?",
	    [$start_date, $end_date, $self->get_request->get('auth_id')]);

    return;
}

=for html <a name="exists_for_year"></a>

=head2 exists_for_year(int year) : boolean

Returns whether allocations have been recorded for the specified year.

=cut

sub exists_for_year {
    my($self, $year) = @_;
    my($req) = $self->get_request;

    my($sth) = Bivio::SQL::Connection->execute("
            SELECT COUNT(*)
            FROM member_allocation_t
            WHERE TO_CHAR(allocation_date, 'YYYY')=?
            AND realm_id=?",
	    [$year, $req->get('auth_id')]);
    my($exists) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	my($count) = $row->[0];
	$exists = $count ? 1 : 0;
    }
    return $exists;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'member_allocation_t',
	columns => {
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
            user_id => ['PrimaryId', 'PRIMARY_KEY'],
	    allocation_date => ['Date', 'PRIMARY_KEY'],
            tax_category => ['TaxCategory', 'PRIMARY_KEY'],
            amount => ['Amount', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
	other => [
	    [qw(user_id User.user_id)],
	],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
