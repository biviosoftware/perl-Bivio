# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::PortfolioIncomeList;
use strict;
$Bivio::Biz::Model::PortfolioIncomeList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::PortfolioIncomeList::VERSION;

=head1 NAME

Bivio::Biz::Model::PortfolioIncomeList - lists portfolio income entries

=head1 SYNOPSIS

    use Bivio::Biz::Model::PortfolioIncomeList;
    Bivio::Biz::Model::PortfolioIncomeList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::PortfolioIncomeList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::PortfolioIncomeList> lists portfolio income entries

=cut

#=IMPORTS
use Bivio::Biz::Accounting::Tax;
use Bivio::Type::DateTime;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');

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
	    Bivio::Type::EntryType::CASH_INCOME()->as_sql_param,
            'AND',
            'Entry.class', '=',
	    Bivio::Type::EntryClass::CASH()->as_sql_param,
	    'AND',
	    'Entry.tax_basis', '=', '1',
	    'AND',
	    'RealmTransaction.date_time', 'BETWEEN',
	    $_SQL_DATE_VALUE, 'AND', $_SQL_DATE_VALUE,
	],
    };
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Adds dynamic start/end dates to the SQL parameters.

=cut

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;
    my($end_date) = $self->get_request->get('report_date');

    # get tax year start
    my($start_date) = Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
	    $end_date);

    push(@$params, $start_date, $end_date);
    return '';
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
