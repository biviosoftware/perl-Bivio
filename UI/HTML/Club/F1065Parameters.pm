# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::F1065Parameters;
use strict;
$Bivio::UI::HTML::Club::F1065Parameters::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Club::F1065Parameters::VERSION;

=head1 NAME

Bivio::UI::HTML::Club::F1065Parameters - IRS 1065 parameters

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::F1065Parameters;
    Bivio::UI::HTML::Club::F1065Parameters->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::F1065Parameters::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::F1065Parameters> IRS 1065 parameters

=cut

#=IMPORTS
use Bivio::UI::HTML::Club::ReportPage;
use Bivio::Societas::UI::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::Societas::UI::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content()

Returns the form.

=cut

sub create_content {
    my($self) = @_;
    return $_VS->vs_director(['show_countries'], {
	0 => _create_form($self, 0),
	1 => _create_form($self, 1),
    });
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Renders the page.

=cut

sub execute {
    my($self, $req) = @_;

    $req->put(
    	    # don't show preferences, messes up the target_realm_owner
	    want_preferences_render => 0,
	    show_countries => $req->get(
		    'Bivio::Biz::Model::ForeignTaxCountryList')
	    ->get_result_set_size() > 0 ? 1 : 0,
	   );

    $self->SUPER::execute($req);
    return;
}

#=PRIVATE METHODS

# _create_form(boolean show_countries) : Bivio::UI::Widget
#
# Returns the form, which optional shows the foreign country list.
#
sub _create_form {
    my($self, $show_countries) = @_;

    return $_VS->vs_form('F1065ParametersForm', [
	['TaxId.tax_id', undef, <<'EOF', '12-3456789'],
Partnership's identifying number
EOF
	['Club.start_date', undef, <<'EOF', undef, {allow_undef => 1}],
The date the club began as a partnership
EOF
	['Address.street1', undef, <<'EOF', undef,
Partnership's address and ZIP code
EOF
	    {label_in_text => 'Address'}],
	['Address.street2'],
	['Address.city'],
	['Address.state', undef, undef, 'NY, CA, CO', {size => 2}],
	['Address.zip', undef, undef, '12345, 12345-6789'],
	['Tax1065.irs_center', undef, <<'EOF'],
Select the IRS Center where the partnership files its return
EOF
	['Tax1065.partnership_type', undef,
	    <<'EOF',
Schedule B 1. Most investment clubs are formed as general partnerships. Members in a general partnership do not have liability protection.
EOF
	    undef, {show_unknown => 0}],
	['Tax1065.partner_is_partnership', undef, <<'EOF'],
Schedule B 2.
EOF
	['Tax1065.partnership_is_partner', undef, <<'EOF'],
Schedule B 3.
EOF
	['Tax1065.consolidated_audit', undef, <<'EOF'],
Schedule B 4. We recommend that you choose Consolidated Audit, so that the tax treatment of partnership items is determined at the partnership level, rather than in a separate proceeding.
EOF
    ],
	    $show_countries ? (
    [
	'RealmInstrument.name',
	['country_code', undef, <<'EOF',

Select the country for any investment which received foreing taxes.
EOF
	    undef, {enum_sort => 'get_short_desc'}],
    ],
		   ) : (),
    {
	header => Bivio::UI::HTML::Club::ReportPage
	->get_heading_with_one_date('page_heading'),
    });
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
