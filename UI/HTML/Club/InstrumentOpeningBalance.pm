# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::InstrumentOpeningBalance;
use strict;
$Bivio::UI::HTML::Club::InstrumentOpeningBalance::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::InstrumentOpeningBalance - initial shares form UI

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::InstrumentOpeningBalance;
    Bivio::UI::HTML::Club::InstrumentOpeningBalance->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::InstrumentOpeningBalance::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::InstrumentOpeningBalance> initial shares form UI

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content()

Returns the form.

=cut

sub create_content {
    my($self) = @_;
    return $self->form('Bivio::Biz::Model::InstrumentOpeningBalanceForm', [
	    ['RealmTransaction.date_time', 'Purchase Date', <<'EOF'],
The date the block of shares was purchased.
EOF
	    ['Instrument.ticker_symbol', 'Ticker', $self->join(<<'EOF',
The ticker symbol of the investment.  If the investment you purchased
is not available in our database, you may add a
EOF
		    $self->link('CLUB_ACCOUNTING_LOCAL_INSTRUMENT'),
		    ".\n",
		   )],
	    ['paid', 'Total Paid', <<'EOF'],
The cost basis of the block of shares.
EOF
	    ['RealmInstrumentEntry.count', 'Shares', <<'EOF'],
The number of shares in the block.
EOF
    ],
    {
	header => $_PACKAGE->join(<<'EOF')
Use this form to record the number of shares and the associated cost for
a block of shares owned prior to using bivio club accounting.
EOF
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
