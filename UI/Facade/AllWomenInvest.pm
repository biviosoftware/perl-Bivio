# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::AllWomenInvest;
use strict;
$Bivio::UI::Facade::AllWomenInvest::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Facade::AllWomenInvest::VERSION;

=head1 NAME

Bivio::UI::Facade::AllWomenInvest - www.allwomeninvest.com (bumpliz for now)

=head1 SYNOPSIS

    use Bivio::UI::Facade::AllWomenInvest;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::UI::Facade::AllWomenInvest::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::UI::Facade::AllWomenInvest> is a full co-brand for
www.allwomeninvest.com.

=cut

#=IMPORTS
use Bivio::UI::Facade::AllWomenInvest::Home;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

__PACKAGE__->new({
    clone => 'Prod',
    is_production => 1,
    uri => 'allwomeninvest',
    'Bivio::UI::Font' => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->regroup(footer_menu => ['smaller']);
	},
    },
    'Bivio::UI::HTML' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;

	    # Some required strings and values
	    $fc->group(logo_icon => 'dot');
	    $fc->group(site_name => 'AllWomenInvest');
	    $fc->group(home_alt_text => 'AllWomenInvest - '
		    .'Unleashing the financial power of women');

	    $fc->initialize_standard_support;
	    $fc->value(want_secure => 0);
	    # Home page is special
	    $fc->value(home_page =>
		    Bivio::UI::Facade::AllWomenInvest::Home->new);

	    # These are required names, which are checked by page.
	    _header($fc);
	    _footer($fc);
	    $fc->group(head_widget => $fc->get_standard_head);
	    $fc->group(page_widget => $fc->get_standard_page);
	    $fc->group(logo_widget => $fc->get_standard_logo);
	    return;
	},
    },
});

=head1 METHODS

=cut

#=PRIVATE METHODS

# _footer(Bivio::UI::HTML html) : Bivio::UI::Widget
#
# Sets footer_widget.
#
sub _footer {
    my($html) = @_;
    # Create list of links
    my($links) = [];
    foreach my $t (
	    'About AWI:http://www.allwomeninvest.com/about_awi.htm',
	    'Contact AWI:http://www.allwomeninvest.com/contact_us.htm',
	    'Investment Club:http://www.allwomeninvest.com/investment_club.htm',
	    'Email Us:mailto:info@allwomeninvest.com',
	   ) {
	my($label, $task) = split(/:/, $t, 2);
	push(@$links, $_VS->vs_link($label, $task, 'footer_menu'),
		'&nbsp;|&nbsp;');
    }
    # Delete last separator
    pop(@$links);

    # Create grid
    $_VS->vs_load_class('Grid', 'EditPreferences');
    $html->group(footer_widget => Bivio::UI::HTML::Widget::Grid->new({
	expand => 1,
	values => [
	    [
		$_VS->vs_clear_dot(1, 10),
		],
	    [
		$_VS->vs_clear_dot(undef, 1)->put(
			cell_expand => 1,
			cell_bgcolor => 'footer_line',
		       ),
	    ],
	    [
		# Match the top
		'&nbsp;&nbsp;&nbsp;',
		Bivio::UI::HTML::Widget::Grid->new({
		    cell_align => 'center',
		    cell_expand => 1,
		    values => [
			$links,
		    ],
		}),
		$_VS->vs_link('top', '#top', 'footer_menu'),
	    ],
	    [
		' ',
	    ],
	    [
		Bivio::UI::HTML::Widget::Grid->new({
		    expand => 1,
		    cell_expand => 1,
		    values => [
			[
			    $_VS->vs_link($_VS->vs_image('bivio_power'),
				    'http://www.bivio.com')
				    ->put(cell_align => 'sw'),
			    $html->get_standard_copyright->put(
				    cell_align => 'right',
				    cell_expand => 1,
				   ),
			],
		    ],
		}),
	    ],
	],
    }));
    return;
}

# _header(Bivio::UI::HTML html) : Bivio::UI::Widget
#
# Sets header_widget and header_height.
#
sub _header {
    my($html) = @_;
    my($hdr) = $html->get_standard_header();
    # Insert before <a name=top>...
    splice(@{$hdr->get('values')}, 1, 0, _logo($html));
    $html->group(header_widget => $hdr);
    $html->group(header_height =>
	    $html->get_standard_header_height
	    + $html->get_facade->get('Bivio::UI::Icon')
	    ->get_height('header_010'));
    return;
}

# _logo(Bivio::UI::HTML html) : Bivio::UI::Widget
#
# Returns the logo widget which points to allwomeninvest home page.
#
sub _logo {
    my($html) = @_;
    return $_VS->vs_join($_VS->vs_link(
	    $_VS->vs_image('header_010', $html->get_value('home_alt_text')),
	        'http://www.allwomeninvest.com'),
	    '<br><table border=0 width=604 cellspacing=0 cellpadding=2>',
	    '<tr><td width="100%" valign="middle" bgcolor="#4D1F7D">',
	    $_VS->vs_image('Unleasing_ani',
	        'Unleashing the financial power of women (tm)',''),
	    '<td></tr></table><br>');

}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
