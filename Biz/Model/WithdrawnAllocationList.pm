# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::WithdrawnAllocationList;
use strict;
$Bivio::Biz::Model::WithdrawnAllocationList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::WithdrawnAllocationList - withdrawal tax allocations

=head1 SYNOPSIS

    use Bivio::Biz::Model::WithdrawnAllocationList;
    Bivio::Biz::Model::WithdrawnAllocationList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::AllocationList>

=cut

use Bivio::Biz::Model::AllocationList;
@Bivio::Biz::Model::WithdrawnAllocationList::ISA = ('Bivio::Biz::Model::AllocationList');

=head1 DESCRIPTION

C<Bivio::Biz::Model::WithdrawnAllocationList> withdrawal tax allocations

=cut

#=IMPORTS
use Bivio::Biz::Accounting::Tax;
use Bivio::Biz::Model::User;
use Bivio::SQL::Connection;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::EntryType;
use Bivio::Type::TaxCategory;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');

=head1 METHODS

=cut

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

Returns rows.

=cut

sub internal_load_rows {
    my($self, $query, $where, $params, $sql_support) = @_;
    my($fields) = $self->{$_PACKAGE} = {
	user => Bivio::Biz::Model::User->new($self->get_request),
    };

    my($req) = $self->get_request;
    my($realm) = $req->get('auth_realm')->get('owner');
    my($date) = $req->get('report_date');
    $date = Bivio::Type::Date->to_local_date($date);

    # get tax year start
    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $date);

    # get the withdrawal allocations, ordered by date

    my($date_param) = Bivio::Type::DateTime->from_sql_value(
	    'realm_transaction_t.date_time');
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT $date_param,
                entry_t.amount, entry_t.tax_category,
                member_entry_t.user_id
            FROM realm_transaction_t, entry_t, member_entry_t
            WHERE realm_transaction_t.realm_transaction_id
                = entry_t.realm_transaction_id
            AND entry_t.entry_id=member_entry_t.entry_id
            AND entry_t.entry_type=?
            AND realm_transaction_t.date_time
                BETWEEN $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE
            AND realm_transaction_t.realm_id=?
            ORDER BY realm_transaction_t.date_time",
	    [Bivio::Type::EntryType::MEMBER_WITHDRAWAL_DISTRIBUTION->as_int,
		    $start_date, $date,
		    $realm->get('realm_id')]);

    my($withdrawals) = {};
    while (my $row = $sth->fetchrow_arrayref) {
	my($date, $amount, $tax, $user_id) = @$row;
	$tax = Bivio::Type::TaxCategory->from_int($tax);

	my($key) = $date.$user_id;
	unless (exists($withdrawals->{$key})) {
	    $withdrawals->{$key} = _create_row($self, $date, $user_id);
	}
	$withdrawals->{$key}->{$tax->get_short_desc} = $amount;
    }

    # sort by name
    my(@sorted) = sort({
	return $a->{name} cmp $b->{name};
    } values(%$withdrawals));

    $self->internal_calculate_net_profit(\@sorted);

    return \@sorted;
}

#=PRIVATE METHODS

# _create_row(string date, string amount, int tax, string user_id) : hash_ref
#
# Creates a record for the specified user.
#
sub _create_row {
    my($self, $date, $user_id) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($user) = $fields->{user};
    $user->unauth_load(user_id => $user_id) || die("no user $user_id");

    my($row) = {
	name => $user->format_last_first_middle.' ('
	.Bivio::Type::Date->to_literal($date).')',
	net_profit => 0,
	units => undef,
    };

    for (my($i) = 0; $i < Bivio::Type::TaxCategory->get_count; $i++) {
	my($tax) = Bivio::Type::TaxCategory->from_int($i);
	next if $tax == Bivio::Type::TaxCategory::NOT_TAXABLE();
	$row->{$tax->get_short_desc} = 0;
    }
    return $row;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
