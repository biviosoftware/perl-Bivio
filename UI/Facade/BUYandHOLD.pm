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

#=VARIABLES
__PACKAGE__->new({
    clone => 'Prod',
    uri => 'muri',
    is_production => 0,
    'Bivio::UI::Color' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;
	    $fc->create_group(-1, qw(
		    list_form_even_row_bg
		    list_form_odd_row_bg
	    ));
	    $fc->create_group(0xFFFFFF, qw(
                    page_bg
		    image_menu_separator
		    celebrity_box_title
		    profile_box_title
		    celebrity_box_text_bg
		    profile_box_text_bg
            ));
	    $fc->create_group(0x990000, qw(
		    error
		    warning
	    ));
	    $fc->create_group(0x000000, qw(
    		    page_text
            ));
	    $fc->create_group(0x009999, qw(
		    stripe_above_menu
		    celebrity_disclaimer
		    decor_disclaimer
		    tax_disclaimer
            ));
	    $fc->create_group(0x333399, qw(
		    footer_menu
	            page_vlink
	            page_alink
	            page_link
	            user_name
	            line_above_menu
	            action_bar_border
	            detail_chooser
	            form_field_label_in_text
	            text_menu_font
	            celebrity_box
	            profile_box
	            description_label
	            task_list_label
            ));
	    $fc->create_group(0x336633, qw(
	            task_list_heading
	            page_heading
                    table_heading
            ));
            $fc->create_group(0xEEEEEE, qw(
                    icon_text_ia
            ));
            $fc->create_group(0x339933, qw(
                    summary_line
            ));
	    $fc->create_group(0xcccccc, qw(
	            table_separator
            ));
            $fc->create_group(0xFFFFFF, qw(
                    table_even_row_bg
            ));
            $fc->create_group(0xFFFFCC, qw(
                    table_odd_row_bg
            ));
            $fc->create_group(0x333399, qw(
                    realm_name
            ));
            $fc->create_group(0xFFCC33, qw(
                    image_menu_bg
                    text_menu_line
            ));
	    return;
	},
    },
    'Bivio::UI::Font' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;
	    my($ss) = 'arial,sans-serif';
	    $fc->create_group([$ss, 'celebrity_box_title', 'size=2'],
		    'celebrity_box_title');
	    $fc->create_group([$ss, 'profile_box_title', 'strong', 'size=2'],
		    'profile_box_title');
	    $fc->create_group([$ss, 'celebrity_disclaimer', 'size=1', ],
		    'celebrity_disclaimer');
	    $fc->create_group([$ss, undef, 'size=1', ],
		    'decor_disclaimer');
	    $fc->create_group([$ss, 'detail_chooser', 'strong', 'size=2'],
		    'detail_chooser');
	    $fc->create_group([$ss, 'error', 'big', 'strong', 'size=2'], qw(
		    error_icon
	            substitute_user
            ));
	    $fc->create_group([$ss, 'footer_menu', 'size=1', ],
		    'footer_menu');
	    $fc->create_group([$ss, 'page_heading', 'size=1', ],
		    'checked_icon');
	    $fc->create_group([$ss, 'page_heading', 'strong', 'size=2'],
		    'page_heading');
	    $fc->create_group([$ss, 'realm_name', 'strong', 'size=2'],
		    'realm_name');
	    $fc->create_group([$ss, 'tax_disclaimer', 'i', 'size=2'],
		    'tax_disclaimer');
	    $fc->create_group([$ss, 'text_menu_font', 'strong', 'size=2'], qw(
		    prev_next_bar_link
		    text_menu_selected
            ));
	    $fc->create_group([$ss, 'text_menu_font', 'size=2'],
		    'text_menu_normal');
	    $fc->create_group([$ss, 'user_name', 'size=3', ],
		    'user_name');
	    $fc->create_group([$ss, undef, 'size=1', ], qw(
		    celebrity_box_text
		    profile_box_text
		    report_footer
		    time
            ));
	    $fc->create_group([$ss, 'table_heading',
		'strong', 'size=2'], qw(
		    table_heading
		    normal_table_heading
	    ));
	    $fc->create_group([$ss, undef, 'size=2'], qw(
		    form_submit
                    message_subject
                    prev_next_bar_text
            ));
	    $fc->create_group([$ss, 'description_label', 'strong', 'size=2'],
		    'description_label');
	    $fc->create_group([$ss, 'error', 'b', 'size=2'], qw(
		    error
		    form_field_error
		    warning
            ));
	    $fc->create_group([$ss, 'error', 'i', 'size=2'],
		    'form_field_error_label');
	    $fc->create_group([$ss, 'error', 'size=1', ],
		    'list_error',
		    'checkbox_error');
	    $fc->create_group([$ss, 'form_field_label_in_text', 'strong', 'size=2'],
		    'form_field_label_in_text');
	    $fc->create_group([$ss, 'icon_text_ia', 'size=2'],
		    'icon_text_ia');
	    $fc->create_group([$ss, 'page_text', 'size=2'],
		    'realm_chooser_text');
	    $fc->create_group([$ss, 'task_list_label', 'size=2'],
		    'task_list_label');
	    $fc->create_group([$ss, 'task_list_heading', 'strong', 'size=2'],
		    'task_list_heading');
	    $fc->create_group([$ss, undef, 'b', 'size=2'],
		    'label_in_text');
	    $fc->create_group([$ss, undef, 'i', 'size=2'],
		    'italic');
	    $fc->create_group([$ss, undef, 'size=1', ], qw(
		    file_tree_bytes
		    list_action
		    lookup_button
            ));
	    $fc->create_group([$ss, undef, 'strong', 'size=2'], qw(
                    action_bar_string
                    strong
                    table_row_title
            ));
	    $fc->create_group([$ss, undef, 'size=2'], qw(
		    form_field_description
		    form_field_label
		    table_cell
		    number_cell
                    action_button
	    	    form_field_example
		    report_page_heading
	            radio
                    descriptive_page
                    page_legend
                    checkbox
            ));
	    # Set by template
	    $fc->create_group([undef, undef],
                    'copyright_and_disclaimer');
	    return;
	},
    },
    'Bivio::UI::HTML' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;
	    my($name) = 'BUYandHOLD Investment Clubs';

	    # Some required strings
	    $fc->create_group('band', 'logo_icon');
	    $fc->create_group($name, 'site_name');
	    $fc->create_group($name.' home', 'home_alt_text');
	    $fc->create_group(0, 'page_left_margin');
	    $fc->create_group('left', 'table_default_align');
	    $fc->create_group(0, 'scene_show_profile');
	    $fc->create_group('go_small', 'realm_chooser_button');
	    $fc->create_group(Bivio::UI::HTML::Widget::Grid->new({
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
				'bivio_powered',
				'bivio - accounting, reports, taxes, and'
				.' administration for your investment club',
			    ),
			    'http://www.bivio.com',
			)->put(
			    cell_align => 'n',
			),
		    ],
		],
	    }),
		    'scene_header');

	    $fc->create_group(Bivio::UI::HTML->get_standard_copyright,
		    'copyright_widget');

	    $fc->create_group(Bivio::UI::HTML::Widget->indirect(
			    ['page_scene']
		   ),
		    'content_widget');

	    # These are required names, which are checked by page.
	    $fc->create_group($fc->widget_from_template([<DATA>]),
		    'page_widget');
	    # Avoid irrelevant perl warnings/errors
	    close(DATA);

	    $fc->create_group($fc->get_standard_header, 'header_widget');
	    $fc->create_group($fc->get_standard_logo, 'logo_widget');
	    $fc->create_group($fc->get_standard_head, 'head_widget');
	    $fc->create_group($fc->get_standard_header_height,
		    'header_height');

	    $fc->create_group(0, 'text_menu_base_offset');
	    $fc->create_group(0, 'image_menu_left_cell');

	    $fc->create_group(' width=0', 'logo_icon_width_as_html');
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
		['/hm/start.html', 'Start a Club'],
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
