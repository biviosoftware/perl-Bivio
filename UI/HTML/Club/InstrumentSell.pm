# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::InstrumentSell;
use strict;
$Bivio::UI::HTML::Club::InstrumentSell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::InstrumentSell - sell an instrument

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::InstrumentSell;
    Bivio::UI::HTML::Club::InstrumentSell->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::InstrumentSell::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::InstrumentSell>

=cut

#=IMPORTS
use Bivio::Type::Date;
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
    $self->put_heading('CLUB_ACCOUNTING_INVESTMENT_SELL');
    return $self->join(
	    # a dynamic heading
	    Bivio::UI::HTML::Widget::String->new({
		value => ['realm_inst_name'],
	    }),
	    ' (page 1 / 2)<p>',
	    $self->form('Bivio::Biz::Model::InstrumentSellForm', [
	    ['RealmTransaction.date_time', undef, <<'EOF'],
Enter the date of the sale.
EOF
	    ['RealmAccountEntry.realm_account_id', undef, <<'EOF', undef,
Select the account which received the money from the sale.
EOF
		    {
			choices => [
				'Bivio::Biz::Model::RealmValuationAccountList',
			       ],
			list_display_field => 'RealmAccount.name',
			list_id_field => 'RealmAccount.realm_account_id',
		    }
	    ],
	    ['Entry.amount', 'Total Amount', <<'EOF'],
Enter the total amount of the sale excluding commission,
which is entered below.  The per share price will be computed
from this value.
EOF
	    ['RealmInstrumentEntry.count', undef, <<'EOF'],
Enter the number of shares or bonds sold.
EOF
	    ['commission', undef, <<'EOF'],
Enter the broker's commission charge for the sale.
EOF
	    ['RealmTransaction.remark', undef, <<'EOF'],
Enter any notes associated with the sale.
EOF
    ],
    ));
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Loads the target member, processes any form errors and renders the page.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    # hack to redirect to sell form 2
    if ($req->get('form_model')->in_error) {
	my($errors) = $req->get('form_model')->get_errors;
	if ($errors->{redirect}) {
	    $req->server_redirect($req->get('task')->get('next'),
		    $req->get('auth_realm'),
		    $req->get('query'),
		    $req->get('form'));
	    # does not return
	}
    }

    # set the dynamic heading and call the super class
    my($realm_inst) = $req->get('Bivio::Biz::Model::RealmInstrument');
    my($realm) = $req->get('auth_realm')->get('owner');
    my($shares_owned) = $realm->get_number_of_shares(Bivio::Type::Date->now)
	    ->{$realm_inst->get('realm_instrument_id')} || 0;
    $req->put(realm_inst_name => $realm_inst->get_name
	    .", $shares_owned shares owned");
    $self->SUPER::execute($req);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
