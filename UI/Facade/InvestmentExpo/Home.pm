# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::InvestmentExpo::Home;
use strict;
$Bivio::UI::Facade::InvestmentExpo::Home::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Facade::InvestmentExpo::Home::VERSION;

=head1 NAME

Bivio::UI::Facade::InvestmentExpo::Home - start a club home page

=head1 SYNOPSIS

    use Bivio::UI::Facade::InvestmentExpo::Home;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::Facade::InvestmentExpo::Home::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::Facade::InvestmentExpo::Home>

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="new"></a>

=head2 create_content() : Bivio::UI::Widget

Creates a tax 99 page contents.

=cut

sub create_content {
    my($self) = @_;
    return Bivio::UI::HTML::Widget::Grid->new({
	pad => 5,
	expand => 1,
	values => [
	    [$_VS->vs_string($_VS->vs_join(<<'EOF'), 'page_text')
Investment Expo presents a wealth of useful information.  How can you best
follow what you've learned at the Expo?  By starting an investment club with
friends, family, co-workers, or fellow Expo attendees.  It's a great way to
learn with others, achieve your goals, and invest successfully.
<p>
What are investment clubs?  Clubs are investing partnerships of 10 to 100
people. Investment decisions are made collectively, and everyone gets a
fair chance to participate.  Members can join at different dollar levels
(often investing $10 to $100 per month).
<p>
We've teamed up with bivio, the leading investment club Website, to make
it easy to start an investment club. You can use these free online tools
to do your accounting, file club taxes, and keep in touch with club members.
To get started, follow these three simple steps.
<p>
&nbsp;<br>
EOF
		     ->put(cell_colspan => 2)],
	    [$_VS->vs_image('one', 'Sign up'),
	     $_VS->vs_string('Sign up', 'page_heading')],
	    [' ',
	    $_VS->vs_string($_VS->vs_join(<<'EOF'), 'page_text')],
Use bivio to organize your club. The first step is to
<a href="/pub/register" target=_top>register with bivio</a>.
<p>
As part of registering, <b>create a club</b> on bivio. Each club gets
its own Club Site&#153;. You'll need to pick a name for your
club--don't worry, you can change it later.
<p>
Then, once you are logged in, <b>add other member(s)</b> to your
Club Site. Make sure you enter their email addresses, so they will
receive messages sent to your club.
<p>
Your Club Site will be very useful when moving on to the next two steps.
You'll be able to share draft partnership agreements in the Files area,
discuss the partnership agreement in the Mail area, and enter information
required by the government in the Roster.
<br>
&nbsp;
EOF
	    [$_VS->vs_image('two', 'Get Legal'),
	     $_VS->vs_string('Get Legal', 'page_heading')],
	    [' ',
	    $_VS->vs_string($_VS->vs_join(<<'EOF'), 'page_text')],
You should establish a <b>partnership agreement</b>. We recommend the
<a href="/goto?x=http://www.better-investing.org/clubs/sample-pa.html" target=_top>sample partnership agreement</a>
supplied by the NAIC&#153;. All members must sign a copy of your partnership
agreement.
<p>
Most clubs also establish <b>bylaws</b>. These are working rules,
e.g. we meet on the third Thursday of every month. You do not need
bylaws to operate your club.
<p>
US clubs must obtain an
<a href="/hp/tax-id.html" target=_top>Employer Identification Number</a>
(EIN). Fill out
<a href="/mr/irs/fss4.pdf">Form SS-4</a> and mail it in to the IRS.
<p>
Some US states and counties request you register. Once your club is
actually doing business, you may want to contact your Secretary of
State to find out if you need to register.
<br>
&nbsp;
EOF
	    [$_VS->vs_image('three', 'Start Investing'),
	     $_VS->vs_string('Start Investing', 'page_heading')],
	    [' ',
	    $_VS->vs_string($_VS->vs_join([<<'EOF',
You're now ready to open a <b>brokerage account</b>.  Visit
EOF
		$_VS->vs_link_goto('Gomez.com',
			'http://www.gomez.com/scorecards/index.asp?'
			.'topcat_id=3&subSect=finance'),
		<<'EOF',
, a site which rates all brokers.
<p>
Finally, all you need is <b>money to invest</b>. The
<a href="/hp/valuation-date.html" target=_top>Valuation Date</a>
is usually set a few days before Member Payments are accepted.
This way all members buy in at the same
<a href="/hp/unit-value.html" target=_top>Unit Value</a>.
<p>
You are now ready to start investing together. The Web is a fabulous
resource. Use it to find interesting leads and to research them.
<p>
Good luck! You are sure to have a fascinating journey when you Invest with
your friends&#153;.
<a href="/pub/register" target=_top><b>Register now</b></a>!
<br>
&nbsp;
EOF
	    ]), 'page_text')],
	],
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
