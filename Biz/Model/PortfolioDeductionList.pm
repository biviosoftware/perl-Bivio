# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::PortfolioDeductionList;
use strict;
$Bivio::Biz::Model::PortfolioDeductionList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::PortfolioDeductionList - lists portfolio income entries

=head1 SYNOPSIS

    use Bivio::Biz::Model::PortfolioDeductionList;
    Bivio::Biz::Model::PortfolioDeductionList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::PortfolioDeductionList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::PortfolioDeductionList> lists portfolio expense entries

=cut

#=IMPORTS
use Bivio::Biz::Accounting::Tax;
use Bivio::Biz::Model::RealmInstrument;
use Bivio::SQL::Connection;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;
use Bivio::Type::TaxCategory;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	auth_id => [qw(RealmTransaction.realm_id)],
	primary_key => [
	    [qw(Entry.entry_id)],
	],
#	order_by => [qw(
#	    RealmTransaction.date_time
#            RealmTransaction.remark
#        )],
	other => [qw(
	    RealmTransaction.date_time
            RealmTransaction.remark
            Entry.amount
            Entry.entry_type
            Entry.class
	    Entry.tax_basis
	    ),
	    [qw(Entry.realm_transaction_id
                RealmTransaction.realm_transaction_id)],
	],
	where => [
	    'Entry.entry_type', '=',
	    Bivio::Type::EntryType::CASH_EXPENSE()->as_sql_param,
            'and',
            'Entry.class', '=',
	    Bivio::Type::EntryClass::CASH()->as_sql_param,
	    'and',
	    'Entry.tax_basis', '=', '1',
	],
    };
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

Returns rows.

=cut

sub internal_load_rows {
    my($self, $query, $where, $params, $sql_support) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $self->get_request;

    my($rows) = $self->SUPER::internal_load_rows($query, $where, $params,
	    $sql_support);

    # get any investment fees
    my($names) = {};
    my($realm_inst) = Bivio::Biz::Model::RealmInstrument->new($req);
    my($date_param) = Bivio::Type::DateTime->from_sql_value(
	    'realm_transaction_t.date_time');
    my($date_value) = Bivio::Type::DateTime->to_sql_value('?');
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT realm_transaction_t.realm_transaction_id,
                $date_param,
                entry_t.entry_id, entry_t.amount, entry_t.entry_type,
                entry_t.class, entry_t.tax_basis,
                realm_instrument_entry_t.realm_instrument_id
            FROM realm_transaction_t, entry_t, realm_instrument_entry_t
            WHERE realm_transaction_t.realm_transaction_id
                =entry_t.realm_transaction_id
            AND entry_t.entry_id=realm_instrument_entry_t.entry_id
            AND entry_t.tax_category=?
            AND realm_transaction_t.date_time >= $date_value
            AND realm_transaction_t.date_time <= $date_value
            AND realm_transaction_t.realm_id=?
            ORDER BY realm_transaction_t.date_time",
	    [Bivio::Type::TaxCategory->MISC_EXPENSE->as_int,
		    $fields->{start_date}, $fields->{end_date},
		    $req->get('auth_id')]);
    while (my $row = $sth->fetchrow_arrayref) {
	my($txn_id, $date, $entry_id, $amount, $type, $class,
		$basis, $inst_id) = @$row;

	unless (exists($names->{$inst_id})) {
	    $realm_inst->load(realm_instrument_id => $inst_id);
	    $names->{$inst_id} = "Investment fee: ".$realm_inst->get_name;
	}
	my($remark) = $names->{$inst_id};
	push(@$rows, {
	    'RealmTransaction.realm_transaction_id' => $txn_id,
	    'RealmTransaction.date_time' => $date,
	    'RealmTransaction.remark' => $remark,
	    'Entry.entry_id' => $entry_id,
	    'Entry.amount' => $amount,
	    'Entry.entry_type' => Bivio::Type::EntryType->from_int($type),
	    'Entry.class' => Bivio::Type::EntryClass->from_int($class),
	    'Entry.tax_basis' => $basis,
	});
    }

    # change the sign on all the amounts
    foreach my $row (@$rows) {
	$row->{'Entry.amount'} = Bivio::Type::Amount->neg(
		$row->{'Entry.amount'});
	$row->{'RealmTransaction.remark'} ||= '';
    }

    # sort the account and investment entries by date and remark
    my(@sorted) = sort({
	# date
	my($r) = Bivio::Type::DateTime->compare(
		$a->{'RealmTransaction.date_time'},
		$b->{'RealmTransaction.date_time'});
	return $r unless $r == 0;

	# description
	$r = $a->{'RealmTransaction.remark'}
	cmp $b->{'RealmTransaction.remark'};
	return $r;
    } @$rows);

    return \@sorted;
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Returns the where clause and params associated as the result of a
"search" or other "pre_load".

=cut

sub internal_pre_load {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE} = {};
    my($req) = $self->get_request;
    my($end_date) = $req->get('report_date');

    # get tax year start
    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $end_date);

    $fields->{start_date} = $start_date;
    $fields->{end_date} = $end_date;
    my($start) = Bivio::Type::DateTime->to_sql_value("'$start_date'");
    my($end) = Bivio::Type::DateTime->to_sql_value("'$end_date'");
    return "realm_transaction_t.date_time >= $start and ".
	    "realm_transaction_t.date_time <= $end\n".
		    'order by realm_transaction_t.date_time, '.
			    'realm_transaction_t.remark';
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
