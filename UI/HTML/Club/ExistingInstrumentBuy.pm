# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ExistingInstrumentBuy;
use strict;
$Bivio::UI::HTML::Club::ExistingInstrumentBuy::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::ExistingInstrumentBuy - buying an instrument

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ExistingInstrumentBuy;
    Bivio::UI::HTML::Club::ExistingInstrumentBuy->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::ExistingInstrumentBuy::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ExistingInstrumentBuy>

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;

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
    $self->put_heading('CLUB_ACCOUNTING_INVESTMENT_BUY');
    return $self->form('Bivio::Biz::Model::InstrumentBuyForm', [
	    ['RealmTransaction.date_time', undef, <<'EOF'],
Enter the date of the purchase.  This is normally called the
<b>Transaction Date</b>.
Do not enter the settlement date (when the money was actually transferred from
your account) which is typically three business days after
the transaction date.
EOF
	    ['RealmAccountEntry.realm_account_id', undef, <<'EOF', undef,
Select the account from which money was withdrawn to fund the purchase.
EOF
		    {
			choices => [
				'Bivio::Biz::Model::RealmValuationAccountList',
			       ],
			list_display_field => 'RealmAccount.name',
			list_id_field => 'RealmAccount.realm_account_id',
		    }
	    ],
	    ['Entry.amount', 'Total Cost', <<'EOF'],
Enter the total cost of the purchase excluding commission and fees,
which are entered below.  The per share price will be computed
from this value.
EOF
	    ['RealmInstrumentEntry.count', undef, <<'EOF'],
Enter the number of shares or bonds purchased.
EOF
	    ['commission', undef, <<'EOF'],
Enter the broker's commission charge for the purchase. This value is added to
the cost basis of the investment.
EOF
	    ['admin_fee', undef, <<'EOF'],
Enter the administration fee associated with the purchase. Use this field
to record an expense which is not part of the investment's cost basis.
An example service fee would be the start up cost of a DRP investment.
EOF
	    ['RealmTransaction.remark', undef, <<'EOF'],
Enter any notes associated with the purchase.
EOF
    ],
    {
	header => $self->join(
	    "Use this form to record the purchase of additional shares of ",
	    Bivio::UI::HTML::Widget::String->new({
		value => ['name'],
		string_font => 'label_in_text',
	    })
	),
    });
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Loads the page heading.

=cut

sub execute {
    my($self, $req) = @_;
    my($realm_inst) = $req->get('Bivio::Biz::Model::RealmInstrument');
    $req->put(name => $realm_inst->get_name);
    $self->SUPER::execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
