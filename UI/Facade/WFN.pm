# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::WFN;
use strict;
$Bivio::UI::Facade::WFN::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Facade::WFN - Women's Financial Network Investment Club Exchange

=head1 SYNOPSIS

    use Bivio::UI::Facade::WFN;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::UI::Facade::WFN::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::UI::Facade::WFN> is the specification for
Women's Financial Network Investment Club Exchange.

=cut

#=IMPORTS
use Bivio::UI::HTML::Widget;

#=VARIABLES
__PACKAGE__->new({
    clone => 'Prod',
    uri => 'aristau',
    is_production => 0,
    'Bivio::UI::Color' => {
	initialize => sub {
	    my($fc) = @_;
            $fc->value(page_link_hover => -1);
	    $fc->regroup([qw(
	            page_link
	            page_vlink
	            page_alink
	            line_above_menu
	            detail_chooser
	            form_field_label_in_text
	            celebrity_box
	            profile_box
	            description_label
	            task_list_label_no_link
                    realm_name
            )],
		    0x333399);
	    $fc->regroup([qw(
	            task_list_heading
	            page_heading
                    table_heading
            )],
		    0x336633);

	    #
	    # Table
	    #
            $fc->value(summary_line => 0x339933);
	    $fc->value(table_separator => 0xcccccc);
            $fc->value(table_odd_row_bg => 0xFFFFCC);
            $fc->value(table_even_row_bg => -1);

	    return;
	},
    },
    'Bivio::UI::Font' => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->value(default => ['class=content']);
	    return;
	},
    },
    'Bivio::UI::HTML' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;
	    my($name) = 'WFN Investment Club Exchange';

	    # Some required strings
	    $fc->group(logo_icon => 'wfn');
	    $fc->group(site_name => $name);
	    $fc->group(home_alt_text => $name.' home');

	    $fc->group(page_left_margin => 0);
	    $fc->group(table_default_align => 'left');
	    $fc->group(scene_show_profile => 1);
	    $fc->group(scene_header => undef);

	    # Home page isn't special
	    $fc->group(home_page => '');
	    $fc->group(descriptive_page_width => 450);

	    $fc->group(content_widget => Bivio::UI::HTML::Widget->join(
		    Bivio::UI::HTML::Widget->indirect(
			    ['page_image_menu']
		    ),
		    Bivio::UI::HTML::Widget->indirect(
			    ['page_text_menu']
		    ),
		    Bivio::UI::HTML::Widget->indirect(
			    ['page_scene']
		    ),
		   ));

	    $fc->group(realm_widget => Bivio::UI::HTML::Widget->string(
		    [sub {my($source) = @_;
			  my($o) = $source->get('auth_realm')->unsafe_get(
				  'owner');
			  return $o ? $o->get('display_name') : undef;
		      }],
		    'realm_name'
		   )->put(undef_value => $name));

	    $fc->group(login_widget => Bivio::UI::HTML::Widget->director(
		    ['auth_user'],
		    {},
		    Bivio::UI::HTML::Widget->link(
			    Bivio::UI::HTML::Widget->image(
				    'shared_signout',
				    'Sign off from '.$name,
				   ),
			    'LOGOUT'
			   ),
		    Bivio::UI::HTML::Widget->link(
			    Bivio::UI::HTML::Widget->image(
				    'shared_sign',
				    'Sign on to '.$name,
				   ),
			    'LOGIN'
			   ),
		   ));

	    $fc->group(register_widget => Bivio::UI::HTML::Widget->link(
		    Bivio::UI::HTML::Widget->image(
			    'shared_join',
			    'Register with '.$name,
			   ),
		    'USER_CREATE'
		   ));

	    $fc->group(help_widget => Bivio::UI::HTML::Widget->link(
		    Bivio::UI::HTML::Widget->image(
			    'shared_help',
			    'Get help using '.$name,
			   ),
		    ['->format_help_uri'],
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
	    $fc->group(image_menu_separator_width => 1);

	    $fc->group(logo_icon_width_as_html => ' width=0');
	    return;
	},
    },
});

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
__DATA__

<HTML>
<HEAD>
	<TITLE>WFN Women's Financial Network Financial Planning & More for Women</TITLE>
	<META name=description content="WFN.com Women's Financial Network: Financial services Web site for women. financial planning, investing, banking, budgeting, brokerage, certified advisors, tax planning, insurance, loans, debt management, retirement planning, investment clubs, networking, offered in a comfortable environment for women.">
	<META name=keywords content="women finance,womens finances,financial planning,finance,retirement planning,financial advisor,banking,investing,money,womens network,budgeting,financial network for women,WFN,Women's Financial Network,www.WFN.com,wfn.com,women,brokerage,estate planning,online banking,life insurance,401k,IRA,pension plan,business,single mom,college,saving for education,portfolio,stock quotes,mutual funds,bonds,investing guide,entrepreneur,resources,parenting,taxes,bill payment,credit cards,savings,roth IRA,mortgage,home loan,loans,auto loan,social security,rent,auto insurance,renter's insurance">
	<LINK REL="stylesheet" HREF="http://www.wfn.com/css/shared_style.css" TYPE="text/css">
	<SCRIPT LANGUAGE="Javascript">
	
	function launchWindow(winLaunch)
	{
		if(winLaunch=="taf")
		{
			msgWindow=window.open ("http://www.wfn.com/pages/page.asp?pageID=72&SID=8&SendTo=%2Fpages%2FFinances%2Easp%3FpageID%3D64%26SID%3D1","displayWindow","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no,width=482,height=522,left=50,top=50")
		}else if(winLaunch=="si")
		{
			if (navigator.platform.match(/MAC/gi) && navigator.appName.match(/EXPLORER/gi)) 
			{
				var searchStr = document.location.search + "&SendTo=%2Fpages%2FFinances%2Easp%3FpageID%3D64%26SID%3D1"//document.location.search;
				document.location="http://www.wfn.com/pages/SignInFull.asp?pageID=177&SID=8" + searchStr;
			}
			else
			{
				msgWindow=window.open ("http://www.wfn.com/pages/page.asp?pageID=73&SID=8&SendTo=%2Fpages%2FFinances%2Easp%3FpageID%3D64%26SID%3D1","displayWindow","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width=442,height=432,left=50,top=50")
			}
		}else if(winLaunch=="so")
		{
			window.location = ("http://www.wfn.com/asp/members/signOut.asp?pageID=64&SID=1&SendTo=%2Fpages%2FFinances%2Easp%3FpageID%3D64%26SID%3D1")
		}
	}
	function launchJoinWFN()
	{
		window.location = ("http://www.wfn.com/pages/page.asp?pageID=74&SID=8&SendTo=%2Fpages%2FFinances%2Easp%3FpageID%3D64%26SID%3D1")
	}
	</SCRIPT>
</HEAD>
<BODY LEFTMARGIN=0 TOPMARGIN=0 LINK="#333399" VLINK="#333399" ALINK="#333399" BGCOLOR="#FFFFFF">

<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0>
	<TR>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=148 HEIGHT=1></TD>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=87 HEIGHT=1></TD>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=301 HEIGHT=1></TD>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=39 HEIGHT=1></TD>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=85 HEIGHT=1></TD>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=70 HEIGHT=1></TD>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=1 HEIGHT=1></TD>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=2 HEIGHT=1></TD>
	</TR>
	<TR>
		<TD COLSPAN=2 BGCOLOR=#FFFFFF>
			<A HREF="http://www.wfn.com/">
				<IMG SRC="http://www.wfn.com/images/shared/shared_logo_money_women_finance_wfn.gif" WIDTH=235 HEIGHT=98 BORDER=0></A></TD>
		
		<TD COLSPAN=6 BACKGROUND="http://www.wfn.com/images/shared/shared_bannercell.gif"><SCRIPT LANGUAGE="JavaScript">
<!--
var axel = Math.random() + "";
var ord = axel * 1000000000000000000;
document.write ("<a href=\"http://ad.doubleclick.net/jump/wfn.com/saveinvest;cat=finance;cat=business;cat=personal_finance;cat=mutual_funds;cat=finance_banking;ord=" + ord + "\"><img src=\"http://ad.doubleclick.net/ad/wfn.com/saveinvest;cat=finance;cat=business;cat=personal_finance;cat=mutual_funds;cat=finance_banking;ord=" + ord + "\" BORDER=0 WIDTH=468 HEIGHT=60></a>");
// -->
</SCRIPT></TD>
		
	</TR>
	<TR>
		<TD COLSPAN=5 ROWSPAN=3 BGCOLOR=#FFFFFF>
<SCRIPT LANGUAGE="Javascript">
	var useSrc;
    today = new Date();
    switchValue = (today.getSeconds() % 3);
    
    if(switchValue==0)
    {
		seqChar="a"
    }else if(switchValue==1){
		seqChar="b"
    }else{
		seqChar="c"
    }


	useSrc="http://www.wfn.com/images/finances/fin_img6" + seqChar + ".jpg";

    document.write("<IMG SRC=\"" + useSrc + "\" WIDTH=660 HEIGHT=61><BR></TD>");
   
// -->
</SCRIPT>
		<TD COLSPAN=3>
		
			<$login_widget><BR>
		
		</TD>
	</TR>
	<TR>
		<TD COLSPAN=3 BGCOLOR=#FFFFFF>
			<$register_widget></TD>
	</TR>
	<TR>
		<TD COLSPAN=3>
			<A HREF="javascript:launchWindow('taf')"><IMG SRC="http://www.wfn.com/images/shared/shared_tell.gif" WIDTH=73 HEIGHT=19 BORDER=0></A></TD>
	</TR>


	<TR>
		<TD COLSPAN=6 BGCOLOR=#FF9900>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=730 HEIGHT=6></TD>
		<TD BGCOLOR=#999999>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=1 HEIGHT=1></TD>
		<TD BGCOLOR=#FFFFFF>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=2 HEIGHT=1></TD>
	</TR>
</TABLE>
<!----------Finances Nav Start---------------->
<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 WIDTH=148 ALIGN="LEFT" VALIGN="TOP">
	<TR>
		<TD COLSPAN=3>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=1&SID=1"><IMG SRC="http://www.wfn.com/images/shared/shared_finances_green.gif" WIDTH=148 HEIGHT=38 BORDER=0></A><BR>
			</TD>
	</TR>
	<TR>
		<TD COLSPAN=3 BACKGROUND="http://www.wfn.com/images/finances/fin_yellow_fade.jpg">
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=21&SID=1"><IMG SRC="http://www.wfn.com/images/shared/shared_viewoff.gif" WIDTH=148 HEIGHT=25 BORDER=0></A><BR>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=22&SID=1"><IMG SRC="http://www.wfn.com/images/shared/shared_payoff.gif" WIDTH=148 HEIGHT=22 BORDER=0></A><BR>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=23&SID=1"><IMG SRC="http://www.wfn.com/images/shared/shared_saveon.gif" WIDTH=148 HEIGHT=22 BORDER=0></A><BR>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=24&SID=1"><IMG SRC="http://www.wfn.com/images/shared/shared_findoff.gif" WIDTH=148 HEIGHT=22 BORDER=0></A><BR>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=25&SID=1"><IMG SRC="http://www.wfn.com/images/shared/shared_getoff.gif" WIDTH=148 HEIGHT=22 BORDER=0></A><BR>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=26&SID=1"><IMG SRC="http://www.wfn.com/images/shared/shared_manageoff.gif" WIDTH=148 HEIGHT=22 BORDER=0></A><BR>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=27&SID=1"><IMG SRC="http://www.wfn.com/images/shared/shared_planoff.gif" WIDTH=148 HEIGHT=22 BORDER=0></A><BR>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=28&SID=1"><IMG SRC="http://www.wfn.com/images/shared/shared_advisoroff_long.gif" WIDTH=148 HEIGHT=22 BORDER=0></A><BR>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN=3>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=2&SID=2"><IMG SRC="http://www.wfn.com/images/shared/shared_milestones_blue_vert.gif" WIDTH=148 HEIGHT=24 BORDER=0></A><BR>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=56&SID=7"><IMG SRC="http://www.wfn.com/images/shared/shared_buyers.gif" WIDTH=148 HEIGHT=24 BORDER=0></A><BR>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=59&SID=7"><IMG SRC="http://www.wfn.com/images/shared/shared_workbook.gif" WIDTH=148 HEIGHT=24 BORDER=0></A><BR>
			<A HREF="http://www.wfn.com/pages/page.asp?pageID=57&SID=7"><IMG SRC="http://www.wfn.com/images/shared/shared_dear.gif" WIDTH=148 HEIGHT=24 BORDER=0></A><BR>
		</TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=119 HEIGHT=52><BR>
			

<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" HEIGHT=50 WIDTH=119 BORDER=0><BR>


			</TD>
		<TD BGCOLOR=#999999>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=1 HEIGHT=1><BR></TD>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=28 HEIGHT=1></TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=119 HEIGHT=30><BR>
		</TD>
		<TD BGCOLOR=#999999>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=1 HEIGHT=1><BR>
		</TD>
		<TD>
			<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=28 HEIGHT=1>
		</TD>
	</TR>
</TABLE>
<!----------Finances Nav End---------------->



<table align=left border=0 cellpadding=0 cellspacing=0 width="100%">
<tr><td width=583 valign=top><table border=0 cellpadding=0 cellspacing=0 width=583 align="left"><tr>
<td valign=top><img src="/i/dot.gif" width=358 height=3><br>
<$realm_widget><br>
</td>
<td bgcolor=#ffffff align="right" valign="top" width="1%"><$help_widget></td>
<td bgcolor=#999999 width=1><img height=1 src="/i/dot.gif" width=1></td>
</tr></table></td>
<td width="1%"><img height=1 src="/i/dot.gif" width=1></td>
</tr><tr>
<td colspan=2 align=left valign=top><$content_widget></td>
</tr><tr>
<td width="1%" align="left">
<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 WIDTH=582 ALIGN="RIGHT">
	<TR>
		<TD WIDTH=3>
		<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=3 HEIGHT=1><BR>
		</TD>
		<TD ALIGN="CENTER" VALIGN="BOTTOM" WIDTH=358 HEIGHT=31>
		&nbsp;<BR>
        <FONT CLASS="footer">
        <A HREF="http://www.wfn.com/pages/page.asp?pageID=47&SID=6"><FONT CLASS="footer">about WFN</FONT></A>
         |
        <A HREF="http://www.wfn.com/pages/page.asp?pageID=48&SID=6"><FONT CLASS="footer">management team</FONT></A>
         | 
        <A HREF="http://www.wfn.com/pages/page.asp?pageID=114&SID=6"><FONT CLASS="footer">privacy policy</FONT></A>
        <BR>
        <A HREF="http://www.wfn.com/pages/page.asp?pageID=51&SID=6"><FONT CLASS="footer">press releases</FONT></A>
         | 
        <A HREF="http://www.wfn.com/pages/page.asp?pageID=197&SID=7"><FONT CLASS="footer">glossary</FONT></A>
         | 
        <A HREF="http://www.wfn.com/pages/AboutUs.asp?pageID=273&SID=6"><FONT CLASS="footer">WFN in the news</FONT></A>
         <BR> 
        <A HREF="http://www.wfn.com/pages/page.asp?pageID=176&SID=2"><FONT CLASS="footer">book center</FONT></A>
         | 
        <A HREF="http://www.wfn.com/pages/page.asp?pageID=156&SID=10"><FONT CLASS="footer">site map</FONT></A>
         | 
        <A HREF="http://www.wfn.com/pages/page.asp?pageID=53&SID=6"><FONT CLASS="footer">contact us</FONT></A>
        </FONT>
		</TD>
		<TD WIDTH=220 ALIGN="RIGHT">
        <IMG SRC="http://www.wfn.com/clr.gif" WIDTH=220 HEIGHT=28><BR>
		</TD>
		<TD BGCOLOR="#FFFFFF" WIDTH=1 ALIGN="RIGHT">
		<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=1 HEIGHT=1><BR>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=3>
		<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=3 HEIGHT=1><BR>
		</TD>
		<TD ALIGN="CENTER" VALIGN="BOTTOM" WIDTH=358 HEIGHT=31>
		<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=358 HEIGHT=8><BR>
		<FONT FACE="arial,helvetica" SIZE="1" COLOR="#666666">
		<A HREF="http://www.wfn.com/pages/page.asp?pageID=115&SID=6"><FONT CLASS="copyfoot">&copy;2000 WFN Women's Financial Network, Inc.</FONT></A><BR>
		</TD>
		<TD WIDTH=220 ALIGN="RIGHT">
        <IMG SRC="http://www.wfn.com/clr.gif" WIDTH=220 HEIGHT=28><BR>
		</TD>
		<TD BGCOLOR="#FFFFFF" WIDTH=1 ALIGN="RIGHT">
		<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=1 HEIGHT=1><BR>
		</TD>
	</TR>

	<TR>
		<TD COLSPAN=3 WIDTH=581>
		<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=581 HEIGHT=25 BORDER=0><BR>
		</TD>
		<TD BGCOLOR="#FFFFFF" WIDTH=1>
		<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=1 HEIGHT=1><BR>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=3>
		<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=3 HEIGHT=1><BR>
		</TD>
		<TD COLSPAN=2 ALIGN=LEFT>
		<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=81 HEIGHT=45 ALIGN=LEFT><SCRIPT LANGUAGE="JavaScript">
<!--
var xxxx = Math.random() + "";
var xxx = axel * 1000000000000000000;
document.write ("<a href=\"http://ad.doubleclick.net/jump/wfn.com/saveinvest;cat=finance;cat=business;cat=personal_finance;cat=mutual_funds;cat=finance_banking;ord=" + ord + "\"><img src=\"http://ad.doubleclick.net/ad/wfn.com/saveinvest;cat=finance;cat=business;cat=personal_finance;cat=mutual_funds;cat=finance_banking;ord=" + ord + "\" BORDER=0 WIDTH=468 HEIGHT=60></a>");
// -->
</SCRIPT></TD>
		<TD BGCOLOR="#FFFFFF" WIDTH=1>
		<IMG SRC="http://www.wfn.com/images/shared/spacer.gif" WIDTH=1 HEIGHT=1><BR>
		</TD>
	</TR>
	
</TABLE>
</TD><TD><td width="1%"><img height=1 src="/i/dot.gif" width=1>
		 </TD>
	</TR>
</TABLE>
</BODY>
</HTML>
