# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Label;
use strict;
$Bivio::UI::Label::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Label - a mapping of IDs to labels

=head1 SYNOPSIS

    use Bivio::UI::Label;
    Bivio::UI::Label->get_simple($value);

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::UI::Label::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::UI::Label> a list of labels to be used in the text.
The label is looked up with I<from_any> and I<get_short_desc>
is used as the name.

=cut

#=IMPORTS

#=VARIABLES
_compile(
#TODO: Should these be dynamically looked up?
    # Common labels
    NONE => [' '],
    PHONE => ['Phone', undef, 'Phone.phone'],
    TAX_ID => ['Tax ID', undef, 'TaxId.tax_id'],
    EMAIL => ['Email', undef, 'Email.email', 'RealmInvite.email'],
    PASSWORD => ['Password', undef, 'RealmOwner.password'],
    OLD_PASSWORD => ['Old Password'],
    NEW_PASSWORD => ['New Password'],
    CONFIRM_NEW_PASSWORD => ['Confirm New'],
    LOGIN => ['Login'],

    # Address labels
    ADDRESS => ['Address'],
    STREET1 => ['Street1', undef, 'Address.street1'],
    STREET2 => ['Street2', undef, 'Address.street2'],
    CITY => ['City', undef, 'Address.city'],
    STATE => ['State', undef, 'Address.state'],
    ZIP => ['Zip', undef, 'Address.zip'],
    COUNTRY => ['Country', undef, 'Address.country'],

    # Club labels
    CLUB_DISPLAY_NAME => ['Name'],
    CLUB_NAME => ['Club ID'],
    CLUB_USER_TITLE => ['Privileges', undef, 'RealmUser.title'],
    CLUB_USER_CREATION_DATE_TIME => ['Joined', undef,
	'RealmUser.creation_date_time'],

    # User labels
    USER_DISPLAY_NAME => ['Name', undef, 'RealmOwner.display_name'],
    USER_NAME => ['User ID', undef, 'name_or_email'],
    USER_FIRST_NAME => ['First Name', undef, 'User.first_name'],
    USER_MIDDLE_NAME => ['Middle Name', undef, 'User.middle_name'],
    USER_LAST_NAME => ['Last Name', undef, 'User.last_name'],

    # Accounting labels
    TRANSACTION_DATE => ['Transaction Date', undef,
	'RealmTransaction.date_time'],
    VALUATION_DATE => ['Valuation Date', undef,
	'MemberEntry.valuation_date'],
    MULTIPLE_PAYMENT => ['Enter Member Payments'],
    MULTIPLE_FEE => ['Enter Member Fees'],
    AMOUNT => ['Amount', undef, 'Entry.amount'],
    ACCOUNT => ['Account', undef, 'RealmAccountEntry.realm_account_id'],
    REMARK => ['Remark', undef, 'RealmTransaction.remark'],
    DEFAULT_REMARK => ['Default Remark'],
    MEMBER_SPECIFIC_REMARK => ['Member Specific Remark'],
    REALM_INSTRUMENT_NAME => ['Full Name', undef, 'RealmInstrument.name'],
    SHARES => ['Shares', undef, 'RealmInstrumentEntry.count'],
    COMMISSION => ['Commission'],
    ADMIN_FEE => ['Service Fee'],
    TICKER => ['Ticker', undef, 'Instrument.ticker_symbol',
	'RealmInstrument.ticker_symbol', 'ticker_symbol'],
    INSTRUMENT_TYPE => ['Category', undef, 'RealmInstrument.instrument_type'],
    LOCAL_INSTRUMENTS => ['Unlisted Investments'],
    PRICE_PER_SHARE => ['Price/Share', undef,
	   'RealmInstrumentValuation.price_per_share'],
    NAME_TICKER => ['Name'],
    FED_TAX_FREE => ['Federal Tax Free', undef,
	'RealmInstrument.fed_tax_free'],
    VALUATION_SEARCH_DATE => ['Date'],
    IMPORT_USER_INFO => ['Import User Information'],
    WANT_SSN => ['Social Security Numbers'],
    WANT_PHONE => ['Telephone Numbers'],
    WANT_ADDRESS => ['Addresses'],

    # NCA Import
    NCADATA => ['NCADATA.DAT'],

    # Menu Titles
    CLUB_ADMIN => ['Administration'],
    CLUB_ACCOUNTING => ['Accounting'],
    CLUB_COMMUNICATIONS => ['Communications'],

    REALM_CHOOSER => ['Select Area'],

    # Tasks
    CLUB_LEGACY_INVITE => ['Bring Members On-line'],
    CLUB_LEGACY_SECURITY_RECONCILIATION => ['Identify Listed Investments'],
    CLUB_ACCOUNTING_CLEAR => ['Clear On-line Accounting'],
    CLUB_LEGACY_UPLOAD => ['Import Club Accounting'],
    CLUB_ADMIN_TOOLS => ['Administration Tools'],
    CLUB_ADMIN_INVITE => ['Add Members'],
    CLUB_HOME => ['Your Club Area'],
    USER_HOME => ['Your Personal Area'],
    CLUB_ACCOUNTING_PAYMENT => ['Payments'],
    CLUB_ACCOUNTING_FEE => ['Fees'],
    LOGOUT => ['Logout'],
    CLUB_ACCOUNTING_LOCAL_VALUATION_DATES => ['Change Past Valuations'],
    GENERAL_PRIVACY => ['Safe and Private'],
    USER_AGREEMENT_TEXT => ['Terms of Service'],
    CLUB_ACCOUNTING_LOCAL_INSTRUMENT => ['New Unlisted Investment'],
    CLUB_ACCOUNTING_INVESTMENT_BUY => ['Record Purchase'],
    CLUB_ACCOUNTING_INVESTMENT_SELL => ['Record Sale'],
    CLUB_ADMIN_ADD_MEMBER => ['Add Member'],
    CLUB_ADMIN_INVITE_GUEST => ['Invite Guest'],
);

=head1 METHODS

=cut

=for html <a name="get_simple"></a>

=head2 static get_simple(any value) : string

Returns the "simple" name we use for this label.
You can use any part of the label to do the lookup.

=cut

sub get_simple {
    my($proto, $value) = @_;
    return $proto->from_any($value)->get_short_desc;
}

#=PRIVATE METHODS

# _compile(array cfg)
#
# Inserts numeric ID into the list.
#
sub _compile {
    my(@cfg) = @_;
    my($i) = 1;
    my($skip) = 1;
    foreach my $c (@cfg) {
	next if $skip;
	unshift(@$c, $i++);
    }
    continue {
	$skip = !$skip;
    }
    __PACKAGE__->compile(@cfg);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
