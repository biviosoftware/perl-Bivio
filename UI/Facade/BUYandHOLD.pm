# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::BUYandHOLD;
use strict;
$Bivio::UI::Facade::BUYandHOLD::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Facade::BUYandHOLD - Women's Financial Network Investment Club Exchange

=head1 SYNOPSIS

    use Bivio::UI::Facade::BUYandHOLD;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::UI::Facade::BUYandHOLD::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::UI::Facade::BUYandHOLD> is the specification for
Women's Financial Network Investment Club Exchange.

=cut

#=IMPORTS
use Bivio::UI::HTML::Widget;
use Bivio::UI::HTML::BUYandHOLD::Home;

#=VARIABLES
__PACKAGE__->new({
    clone => 'Prod',
    uri => 'ic',
    is_production => 1,
    'Bivio::UI::Color' => {
	initialize => sub {
	    my($fc) = @_;
	    #
	    # Links
	    #
            $fc->value(page_link_hover => -1);
	    $fc->value(page_vlink => 0x003300);

	    #
	    # Text
	    #
	    # Basic emphasized text
	    $fc->value(page_heading => 0x336633);
            $fc->value(realm_name =>  0x333399);

	    #
	    # Table
	    #
	    $fc->value(table_heading => 0x336633);
            $fc->value(table_even_row_bg => -1);
            $fc->value(table_odd_row_bg => 0xFFFFCC);
	    $fc->value(table_separator => 0xcccccc);
            $fc->value(summary_line => 0x339933);
	    return;
	},
    },
    'Bivio::UI::Font' => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->value(default => [
		# The size is ok here as long as we aren't using it in a style
		'family=arial,sans-serif', 'size=2',
	    ]);
	    return;
	},
    },
    'Bivio::UI::HTML' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;
	    my($name) = 'BUYandHOLD Investment Clubs';

	    # Some required strings.  Any logo icon will do.
	    $fc->group(logo_icon => 'bivio');
	    $fc->group(site_name => $name);
	    $fc->group(home_alt_text => $name.' home');
	    $fc->group(page_left_margin => 0);
	    $fc->group(table_default_align => 'left');
	    $fc->group(scene_show_profile => 0);
	    $fc->group(realm_chooser_button => 'go_small');

	    # Special BUYandHOLD page
	    $fc->group(home_page => Bivio::UI::HTML::BUYandHOLD::Home->new);
	    $fc->group(descriptive_page_width => 480);

	    $fc->group(scene_header => Bivio::UI::HTML::Widget::Grid->new({
		cell_align => 'n',
		space => 2,
		values => [
		    [
			Bivio::UI::HTML::Widget->join([
			    '<a href="http://www.buyandhold.com/bh/en/'
			    .'investmentclubs/index.html"><img src="'
			    .'http://www.buyandhold.com/bh/en/investmentclubs'
			    .'/images/invest_clubs.gif'
#			    .'/i/muri/invest_clubs.gif'
                            .'" width="156" height="18"'
			    .'border="0"></a>'])->put(
			    cell_colspan => 2,
			),
		    ],
		    [
			Bivio::UI::HTML::Widget->join(
			    [[\&_chooser]],
			)->put(
			    cell_width => '65%',
			    cell_align => 'n',
			    cell_nowrap => 1,
			    cell_end => 0,
			),
			Bivio::UI::HTML::Widget->link(
			    Bivio::UI::HTML::Widget->image(
				'bivio_power',
				'bivio - accounting, reports, taxes, and'
				.' administration for your investment club',
			    ),
			    'http://www.bivio.com',
			)->put(
			    cell_align => 'n',
			),
		    ],
		],
	    }));

	    $fc->group(copyright_widget =>
		    Bivio::UI::HTML->get_standard_copyright);

	    $fc->group(content_widget => Bivio::UI::HTML::Widget->indirect(
			    ['page_scene']
		   ));

	    # These are required names, which are checked by page.
	    $fc->group(page_widget => $fc->widget_from_template([<DATA>]));
	    # Avoid irrelevant perl warnings/errors
	    close(DATA);

	    $fc->group(header_widget => $fc->get_standard_header);
	    $fc->group(logo_widget => $fc->get_standard_logo);
	    $fc->group(head_widget => $fc->get_standard_head);
	    $fc->group(header_height => $fc->get_standard_header_height);

	    $fc->group(text_menu_base_offset => 0);
	    $fc->group(image_menu_left_cell => 0);

	    $fc->group(logo_icon_width_as_html => ' width=0');
	    return;
	},
    },
});

=head1 METHODS

=cut

#=PRIVATE METHODS

# _chooser(Bivio::Agent::Request req) : string
#
# Widget value which returns the chooser
#
sub _chooser {
    return Bivio::UI::HTML::Widget::RealmChooser->render_buyandhold(
	    shift->get_request,
	    [
		['http://www.buyandhold.com/bh/en/investmentclubs/index.html',
			 'Intro'],
		['/', 'Start a Club'],
		@{Bivio::UI::HTML::Widget::RealmChooser
			    ->get_celebrity_columns},
		['http://www.fool.com/partners/buyandhold/investmentclub'
		    .'/investmentclubintroduction.htm',
		    'Motley Fool Investment Club Guide'],
	    ]);
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
__DATA__
<html>

	
<head>
<meta http-equiv="content-type" content="text/html;charset=iso-8859-1">
<meta name="generator" content="Adobe GoLive 4">
<title>Investment Clubs</title>
<script language="JavaScript"><!--
function Start(page) {

OpenWin = this.open(page, "CtrlWindow", 

"toolbar=no,menubar=no,location=no,scrollbars=yes,resize=yes,width=480,height=365");

}
// -->
		</script>
<meta name="Author">
</head>
<body text="black" bgcolor="#ffffff" link="#003300" vlink="#006600" alink="#003300" background="http://www.buyandhold.com/bh/en/images/bak1.gif" topmargin="0" leftmargin="0" rightmargin="0">
<table cellspacing="0" cellpadding="0" border="0" width="100%" height="100%">
  <tr height="1"> 
    <td bgcolor="#003300" height="1" width="1%"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="2" width="5"></td>
    <td width="99%" height="1" bgcolor="#003300"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="5" width="2"></td>
    <td bgcolor="#004000" height="1" width="0%"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="2" width="5"></td>
  </tr>
  <tr height="826"> 
    <td bgcolor="#003300" width="1%"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="7" width="6"></td>
    <td valign="top" width="99%" height="98%"> 
      <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr> 
          <td align="left"><a href="http://www.buyandhold.com/index.html"><img src="http://www.buyandhold.com/bh/en/images/bandhcell1.gif" width="271" height="53" border="0"></a></td>
          <td align="right" valign="top"><img src="http://www.buyandhold.com/bh/en/images/top_nav_right.gif" height="44" width="320" align="top" border="0" usemap="#cell2b3df1ee6"><map name="cell2b3df1ee6"><area href="http://www.buyandhold.com/bh/en/Buy?request=reg.newReg" coords="17,4,108,20" shape="rect" alt="Open an Account"><area href="http://www.buyandhold.com/bh/en/Buy?request=system.logout" coords="149,4,189,19" shape="rect" alt="Account Logout" title="Account Logout"><area href="http://www.buyandhold.com/bh/en/contact/index.html" coords="240,4,299,19" shape="rect" title="Contact Us" alt="Contact Us"><area href="http://www.buyandhold.com/bh/en/sitemap/index.html" coords="196,3,236,19" shape="rect" title="SiteMap" alt="SiteMap"><area href="http://www.buyandhold.com/bh/en/Buy?request=acct.viewAcct" coords="113,4,146,19" shape="rect" title="Account Login" alt="Account Login"></map></td>
        </tr>
        <tr> 
          <td colspan="2" align="left" valign="top"><img src="http://www.buyandhold.com/bh/en/images/becausenav.gif" hspace="6" height="12" width="390" align="top"></td>
        </tr>
      </table>
      <table cellspacing="0" cellpadding="0" border="0" width="600" align="left">
        <tr valign="top"> 
          <td width="110" align="left" > 
            <table border="0" cellpadding="0" cellspacing="0" width="110" bgcolor="white" align="left">
              <tr> 
                <td><!--#include virtual=/Cart--> <a href="http://www.buyandhold.com/bh/en/Buy?request=reg.newReg"><img height="17" width="109" src="http://www.buyandhold.com/bh/en/images/open_an_acc.gif" border="0" hspace="4"></a></td>
              </tr>
              <tr> 
                <td><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="6" hspace="2"><a href="http://www.buyandhold.com/bh/en/tour/index.html"><font face="Arial,Helvetica,sans-serif" size="1"><b>Guided 
                  Tour</b></font></a></td>
              </tr>
              <tr> 
                <td><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="6" hspace="2"><a href="http://www.buyandhold.com/Buy?request=acct.viewAcct"><font face="Arial,Helvetica,sans-serif" size="1"><b>View 
                  Your Account</b></font></a></td>
              </tr>
              <tr> 
                <td><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="6" hspace="2"><a href="http://www.buyandhold.com/Buy?request=scart.viewCart"><font face="Arial,Helvetica,sans-serif" size="1"><b>Shop 
                  for Stocks</b></font><img src="http://www.buyandhold.com/bh/en/images/tinycarticon.gif" hspace="1" border="0" height="15" width="15" align="toptext"></a></td>
              </tr>
              <tr> 
                <td><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="8" hspace="2"><a href="http://www.buyandhold.com/bh/en/research/index.html"><font face="Arial,Helvetica,sans-serif" size="1"><b>Research 
                  Stocks</b></font></a></td>
              </tr>
              <tr height="2"> 
                <td height="2"><a href="http://www.buyandhold.com/bh/en/education/index.html"><font face="Arial,Helvetica,sans-serif" size="1"><b><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="6" hspace="2">Educate 
                  Yourself</b></font></a></td>
              </tr>
              <tr height="2"> 
                <td height="2"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="15" width="6" border="0" hspace="2"><a href="http://www.buyandhold.com/bh/en/parents_kids/index.html"><font size="1" face="Arial,Helvetica,sans-serif"><b>Parents 
                  &amp; Kids</b></font></a></td>
              </tr>
              <tr height="2"> 
                <td height="2"><a href="http://www.buyandhold.com/bh/en/education/index.html"><font face="Arial,Helvetica,sans-serif" size="1"><b><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="6" hspace="2"></b></font></a><font face="Arial,Helvetica,sans-serif" size="1"><a href="http://www.buyandhold.com/bh/en/goals/index.html"><b>Set 
                  Your Goals</b></a></font></td>
              </tr>
              <tr height="2"> 
                <td height="2"><img src="http://www.buyandhold.com/bh/en/images/greenarrow.gif" border="0" height="15" width="6" hspace="2"><font face="Arial,Helvetica,sans-serif" size="1"><a href="http://www.buyandhold.com/bh/en/goals/index.html"><b>Investment 
                  Clubs </b></a></font></td>
              </tr>
              <tr height="2"> 
                <td height="2"><a href="http://www.buyandhold.com/bh/en/financial/index.html"><font face="Arial,Helvetica,sans-serif" size="1"><b><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="6" hspace="2">Financial 
                  Services </b></font></a></td>
              </tr>
              <tr height="2"> 
                <td height="2"><a href="http://www.buyandhold.com/bh/en/marketplace/index.html"><font face="Arial,Helvetica,sans-serif" size="1"><b><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="15" width="6" border="0" hspace="2">Marketplace</b></font></a></td>
              </tr>
              <tr height="2"> 
                <td height="2"><font face="Arial,Helvetica,sans-serif" size="1"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="6" hspace="2"></font><a href="http://www.buyandhold.com/bh/en/strategy/index.html"><font face="Arial,Helvetica,sans-serif" size="1"><b>Our 
                  Strategy</b></font></a></td>
              </tr>
              <tr> 
                <td><a href="http://www.buyandhold.com/bh/en/about/index.html"><font face="Arial,Helvetica,sans-serif" size="1"><b><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="15" width="6" border="0" hspace="2"></b></font><b><font face="Arial,Helvetica,sans-serif" size="1">About 
                  Us</font></b></a></td>
              </tr>
              <tr> 
                <td><font face="Arial,Helvetica,sans-serif" size="1"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="6" hspace="2"></font><a href="http://www.buyandhold.com/bh/en/help/helpdesk/index.html"><font face="Arial,Helvetica,sans-serif" size="1"><b>Helpdesk</b></font></a></td>
              </tr>
              <tr> 
                <td><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="6" hspace="2"><a href="http://www.buyandhold.com/index.html"><font face="Arial,Helvetica,sans-serif" size="1"><b>Home</b></font></a></td>
              </tr>
              <tr height="2"> 
                <td valign="top" height="2"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" border="0" height="15" width="6" hspace="2"></td>
              </tr>
              <tr> 
                <td valign="top"> 
                  <form method="post" action="http://www.buyandhold.com/bh/en/search97cgi/s97_cgi">
                    <table border="0" cellpadding="0" cellspacing="2" width="110">
                      <tr> 
                        <td width="110" align="left" valign="top"> 
                          <input type="hidden" name="ResultTemplate" value="bnh2.hts">
                          <img src="http://www.buyandhold.com/bh/en/images/search_bandh.gif" align="top" border="0" width="103" height="28"><br>
                        </td>
                      </tr>
                      <tr> 
                        <td width="110" bgcolor="#ffffcc"> 
                          <input type="text" name="QueryText" size="8" maxlength="150">
                          <input type="IMAGE" src="http://www.buyandhold.com/bh/en/images/go_small.gif" border="0" width="15" height="15" align="absmiddle" name="IMAGE">
                        </td>
                      </tr>
                    </table>
                  </form>
                </td>
              </tr>
              <tr height="2"> 
                <td align="center" valign="top" height="2"><br>
                  <font face="Arial,Helvetica,sans-serif" size="2"> </font></td>
              </tr>
            </table>
          </td>
          <td width="3" vspace="10" align="left" ><img height="311" width="1" src="http://www.buyandhold.com/bh/en/images/ojlinevert.gif"></td>
          <td width=4><img src="/i/dot.gif" width=4 height=1></td>
<td cellpadding="4" cellspacing="4" ><$content_widget>            <p><img src="http://www.buyandhold.com/bh/en/images/ojlinehoriz.gif" width="220" height="1"><br>
              <font size="1" face="Arial,Helvetica,Geneva,Swiss,SunSans-Regular"><br>
<$copyright_widget> 
              </font> <br>
            </p>
          </td>
        </tr>
      </table>
    </td>
    <td  bgcolor="#003300" width="0%"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="2" width="5"></td>
  </tr>
  <tr height="2"> 
    <td bgcolor="#003300" height="2" width="1%"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="2" width="5"></td>
    <td bgcolor="#003300" width="99%" height="2"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="5" width="2"></td>
    <td bgcolor="#003300" height="2" width="0%"><img src="http://www.buyandhold.com/bh/en/images/spacer.gif" height="2" width="5"></td>
  </tr>
</table>
</body>
</html>
