# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Transaction;
use strict;
$Bivio::Type::Transaction::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
#$_ = $Bivio::Type::Transaction::VERSION;

=head1 NAME

Bivio::Type::Transaction - set of transaction types

=head1 SYNOPSIS

    use Bivio::Type::Transaction;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::Transaction::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::Transaction> set of transaction types. Transaction types
are higher level than entry types. Multiple entry types can be used
for a single transaction type. For example, a investment purchase
(INSTRUMENT_BUY) can be made up of cost basis, commission and fee.

The following entry types are defined:

=over 4

=item UNKNOWN

invalid type

=item CASH_OPENING_BALANCE

Account opening balance

=item CASH_DIVIDEND

Account dividend

=item CASH_EXPENSE

Expense

=item CASH_INCOME

Income

=item CASH_INTEREST

Interest

=item CASH_TRANSFER

Transfer

=item MEMBER_OPENING_BALANCE

Member opening balance

=item MEMBER_PAYMENT

Payment

=item MEMBER_PAYMENT_FEE

Fee

=item MEMBER_PARTIAL_WITHDRAWAL

Partial withdrawal

=item MEMBER_FULL_WITHDRAWAL

Full withdrawal

=item INSTRUMENT_OPENING_BALANCE

Investment opening balance

=item INSTRUMENT_BUY

Purchased

=item INSTRUMENT_SELL

Sold

=item INSTRUMENT_DISTRIBUTION_CASH

Distribution

=item INSTRUMENT_DISTRIBUTION_CHARGES_PAID_BY_COMPANY

Charges paid from dividends

=item INSTRUMENT_DISTRIBUTION_RETURN_OF_CAPITAL

Return of capital

=item INSTRUMENT_DISTRIBUTION_INVESTMENT

Reinvested

=item INSTRUMENT_SPLIT

Split

=item INSTRUMENT_MERGER

Merger

=item INSTRUMENT_SPINOFF

Spin-off

=item INSTRUMENT_TRANSFER

Transfer

=item INSTRUMENT_SHARES_AS_CASH

Cash in lieu

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
	UNKNOWN => [
		0,
		'unknown',
	       ],
	CASH_OPENING_BALANCE => [
		1,
		'Opening balance',
	       ],
	CASH_DIVIDEND => [
		2,
		'Account dividend',
	       ],
	CASH_EXPENSE => [
		3,
		'Expense',
	       ],
	CASH_INCOME => [
		4,
		'Income',
	       ],
	CASH_INTEREST => [
		5,
		'Interest',
	       ],
	CASH_TRANSFER => [
		6,
		'Transfer',
	       ],

	MEMBER_OPENING_BALANCE => [
		101,
		'Opening balance',
	       ],
	MEMBER_PAYMENT => [
		102,
		'Payment',
	       ],
	MEMBER_PAYMENT_FEE => [
		103,
		'Fee',
	       ],
	MEMBER_PARTIAL_WITHDRAWAL => [
		104,
		'Partial withdrawal'
	       ],
	MEMBER_FULL_WITHDRAWAL => [
		105,
		'Full withdrawal'
	       ],

	INSTRUMENT_OPENING_BALANCE => [
		201,
		'Opening balance',
	       ],
	INSTRUMENT_BUY => [
		202,
		'Purchased',
	       ],
	INSTRUMENT_SELL => [
		203,
		'Sold',
		],
	INSTRUMENT_DISTRIBUTION_CASH => [
		204,
		'Distribution',
		],
	INSTRUMENT_DISTRIBUTION_CHARGES_PAID_BY_COMPANY => [
		205,
		'Charges paid from dividends',
		],
	INSTRUMENT_DISTRIBUTION_RETURN_OF_CAPITAL => [
		206,
		'Return of capital',
		],
	INSTRUMENT_DISTRIBUTION_INVESTMENT => [
		207,
		'Reinvested',
		],
	INSTRUMENT_SPLIT => [
		208,
		'Split',
		],
	INSTRUMENT_MERGER => [
		209,
		'Merger',
		],
	INSTRUMENT_SPINOFF => [
		210,
		'Spin-off',
		],
	INSTRUMENT_SHARES_AS_CASH => [
		211,
		'Cash in lieu',
	       ],
	);

=head1 METHODS

=cut

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : 0

Not continuous.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
