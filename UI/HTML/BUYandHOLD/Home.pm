# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::BUYandHOLD::Home;
use strict;
$Bivio::UI::HTML::BUYandHOLD::Home::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::BUYandHOLD::Home - start a club home page

=head1 SYNOPSIS

    use Bivio::UI::HTML::BUYandHOLD::Home;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::BUYandHOLD::Home::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::BUYandHOLD::Home>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="new"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Creates a tax 99 page contents.

=cut

sub create_content {
    my($self) = @_;
    return Bivio::UI::HTML::Widget::Grid->new({
	pad => 5,
	expand => 1,
	values => [
	    [$self->image('one', 'Sign up'),
	     $self->string('Sign up', 'page_heading')],
	    [' ',
	    $self->string($self->join(<<'EOF'), 'page_text')],
Use bivio to organize your club. The first step is to
<a href="http://www.bivio.com/pub/register" target=_blank>register with bivio</a>.
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
	    [$self->image('two', 'Get Legal'),
	     $self->string('Get Legal', 'page_heading')],
	    [' ',
	    $self->string($self->join(<<'EOF'), 'page_text')],
You should establish a <b>partnership agreement</b>. We recommend the
<a href="/goto?x=http://www.better-investing.org/clubs/sample-pa.html" target=_blank>sample partnership agreement</a>
supplied by the NAIC&#153;. All members must sign a copy of your partnership
agreement.
<p>
Most clubs also establish <b>bylaws</b>. These are working rules,
e.g. we meet on the third Thursday of every month. You do not need
bylaws to operate your club.
<p>
US clubs must obtain an
<a href="http://www.bivio.com/hp/tax-id.html" target=_blank>Employer Identification Number</a>
(EIN). Fill out
<a href="http://www.bivio.com/mr/irs/fss4.pdf">Form SS-4</a> and mail it in to the IRS.
<p>
Some US states and counties request you register. Once your club is
actually doing business, you may want to contact your Secretary of
State to find out if you need to register.
<br>
&nbsp;
EOF
	    [$self->image('three', 'Start Investing'),
	     $self->string('Start Investing', 'page_heading')],
	    [' ',
	    $self->string($self->join(<<'EOF'), 'page_text')],
You're now ready to open a <b>brokerage account</b> with
<a href="/goto?x=http://www.buyandhold.com/Buy?request%3Drr.refBy%26ref%3DBIVIO">BUYandHOLD.com</a>.
<p>
Finally, all you need is <b>money to invest</b>. The
<a href="http://www.bivio.com/hp/valuation-date.html" target=_blank>Valuation Date</a>
is usually set a few days before Member Payments are accepted.
This way all members buy in at the same
<a href="http://www.bivio.com/hp/unit-value.html" target=_blank>Unit Value</a>.
<p>
You are now ready to start investing together. The Web is a fabulous resource. Use it to find interesting leads and to research them.
<p>
Good luck! You are sure to have a fascinating journey when you Invest with
your friends&#153;.
<a href="http://www.bivio.com/pub/register" target=_blank><b>Register now</b></a>!
<br>
&nbsp;
EOF
	    ],
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
