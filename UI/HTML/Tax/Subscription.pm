# Copyright (c) 2001 bivio Inc.  All Rights reserved.
# $Id$
package Bivio::UI::HTML::Tax::Subscription;
use strict;
$Bivio::UI::HTML::Tax::Subscription::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Tax::Subscription::VERSION;

=head1 NAME

Bivio::UI::HTML::Tax::Subscription - shows subscriptions including tax-only

=head1 RELEASE SCOPE

Societas

=head1 SYNOPSIS

    use Bivio::UI::HTML::Tax::Subscription;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Tax::Subscription::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Tax::Subscription>

=cut

#=IMPORTS
use Bivio::Societas::UI::ViewShortcuts;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_VS) = 'Bivio::Societas::UI::ViewShortcuts';

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::Widget::Director

Returns widget which renders this page.

=cut

sub create_content {
    my($self) = @_;
    $self->put_heading('CLUB_ACCOUNTING_TAXES_SUBSCRIPTION');
    return $_VS->vs_join([
	'<p>',
	$_VS->vs_string('AccountSync', 'table_heading'),
	' ',
	$_VS->vs_link('subscribe now', 'CLUB_ADMIN_EC_SUBSCRIBE_ACCOUNT_SYNC'),
	$_VS->vs_string('
AccountSync[tm] is an electronic link between your brokerage account
and bivio. Any activity in your account is automatically and securely
transmitted to bivio, including member deposits, stock purchases and
sales, interest, stock splits, mergers, dividends, spin-offs and
more.

Each day, AccountSync automatically and electronically records any
brokerage activity into your bivio books.  AccountSync is a real life
saver - especially when complex transactions occur such as stock
mergers and spin-offs.  You\'ll never have to do the math by hand
again, and you\'ll avoid mistakes. Only $89 per year. '),
	$_VS->vs_link('[learn more]', '/hm/account-sync.html'),
	'<p>',
	$_VS->vs_string('Club Accounting', 'table_heading'),
	' ',
	$_VS->vs_link('subscribe now',
	    'CLUB_ADMIN_EC_SUBSCRIBE_BASIC_SERVICE'),
	$_VS->vs_string('
The leading accounting solution for investment clubs, including daily
club valuations, performance reports, IRS taxes and more for $59 per
year. '),
	$_VS->vs_link('[learn more]', '/hm/club-accounting.html'),
	'<p>',
	$_VS->vs_string('Taxes 2001', 'table_heading'),
	' ',
	$_VS->vs_link('subscribe now', 'CLUB_ADMIN_EC_SUBSCRIBE_TAX_SEASON'),
	$_VS->vs_string('
Special $19 Offer.  Want to use bivio during the tax season only?
We are offering a special $19 subscription for the period January
1st to April 15th 2002.  If your club disbanded during 2001, or you
use bivio for its IRS tax features only, this offer is for you.'),
    ]);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
