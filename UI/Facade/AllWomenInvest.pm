# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::AllWomenInvest;
use strict;
$Bivio::UI::Facade::AllWomenInvest::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
use Bivio::UI::Facade::AllWomenInvest::TopMenu;

#=VARIABLES
__PACKAGE__->new({
    clone => 'Prod',
    is_production => 0,
    uri => 'bumpliz',
    'Bivio::UI::Color' => {
	initialize => sub {
	    my($fc) = @_;
	    # purple: 0xBF9FC6 (bottom)
	    # green: 0x72C4BE (top right, and green line in logo)
	    # dark purple: 0x824191 (line)
	    # pale yellow: 0xEDF3CB
	    # Logo colors:
	    # purple: 0x551F80 (All in logo)
	    # yello: 0xF4CB04 (Women in logo)
	    # green: 0x74C398 (Invest in logo)
	    #
	    # My colors:
	    # green bg: 0x82D4CE
	    # yellow bg: 0xFFDB33
	    # purple bg: 0xCFAFD6  ? 0xDFBFE6
	    #
	    # purple block: 0x660099

	    # Standard colors for the links, but we don't highlight links.
	    # It looks too ugly.
	    $fc->value(page_link => 0x0000FF);
	    $fc->value(page_vlink => 0x0000FF);
            $fc->value(page_link_hover => 0xFF00FF);
	    $fc->value(page_heading => 0x660099);
#	    $fc->value(page_heading => 0x824191);
            $fc->value(realm_name => -1);

	    # Brighter purple
	    $fc->value(celebrity_disclaimer => 0xA261B1);
            $fc->value(summary_line => 0xA261B1);

	    # purple bg
#            $fc->value(table_even_row_bg => 0xDFBFE6);

	    # Left to right is 0, 1, 2
	    $fc->group(top_menu_bg_0 => 0x82D4CE);
	    $fc->group(top_menu_bg_1 => 0x82D4CE); # 0xFFDB33);
	    $fc->group(top_menu_bg_2 => 0x82D4CE); #0xDFBFE6);
	    $fc->group(top_menu_selected => 0x800080);
	    $fc->group(top_menu_normal => 0x0000FF);
	    return;
	},
    },
    'Bivio::UI::Font' => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->value(default => [
		'family=arial,sans-serif', 'size=x-small',
	    ]);
	    $fc->value(realm_name => ['bold', 'size=large']);
	    $fc->group(top_menu_normal => []);
	    $fc->group(top_menu_selected => []);
	    return;
	}
    },
    'Bivio::UI::HTML' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;

	    # Some required strings and values
	    $fc->group(logo_icon => 'awi3');
	    $fc->group(site_name => 'AllWomenInvest');
	    $fc->group(home_alt_text => 'AllWomenInvest - '
		    .'Unleashing the financial power of women');

	    $fc->group(page_left_margin => 20);
	    $fc->group(table_default_align => 'center');
	    $fc->group(scene_show_profile => 1);
	    $fc->group(scene_header => undef);

	    # Home page is special
	    $fc->group(home_page =>
		    Bivio::UI::Facade::AllWomenInvest::Home->new);
	    $fc->group(descriptive_page_width => 480);

	    # These are required names, which are checked by page.
	    Bivio::UI::HTML::Widget->load_class('Page');
	    $fc->group(page_widget => Bivio::UI::HTML::Widget::Page->new({
		head => $fc->get_standard_head(),
		style => $fc->get_standard_style(),
		body => _body($fc),
	    }));
	    $fc->group(header_widget => _header($fc));
	    my($icon) = $fc->get_facade->get('Bivio::UI::Icon');
	    $fc->group(header_height => $icon->get_height('awi3'));
	    $fc->group(logo_widget => _logo($fc));
	    $fc->group(head_widget => $fc->get_standard_head);
	    return;
	},
    },
});

=head1 METHODS

=cut

#=PRIVATE METHODS

# _body(Bivio::UI::HTML html) : Bivio::UI::HTML::Widget::Grid
#
# Returns the body widget.  Must be synchronized with _header().
#
sub _body {
    my($html) = @_;
    Bivio::UI::HTML::Widget->load_class('Grid');
    return Bivio::UI::HTML::Widget::Grid->new({
	expand => 1,
	values => [
	    [
		_header($html),
	    ],
	    [
		Bivio::UI::HTML::Widget->indirect(['page_scene'])->put(
			cell_align => 'nw'),
	    ],
	    [
		_footer($html),
	    ],
	],
    });
    return;
}

# _footer(Bivio::UI::HTML html) : Bivio::UI::HTML::Widget
#
# Returns footer widget.
#
sub _footer {
    my($html) = @_;
    # Create list of links
    my($links) = [];
    foreach my $t ('Home:http://www.allwomeninvest.com',
	    'Shows:http://www.allwomeninvest.com/shows.html',
	    'Safe & Private:GENERAL_PRIVACY',
	   ) {
	my($label, $task) = split(/:/, $t, 2);
	push(@$links, Bivio::UI::HTML::Widget->link(
		$label, $task, 'footer_menu'),
		'&nbsp;|&nbsp;');
    }
    push(@$links, Bivio::UI::HTML::Widget->mailto(['support_email'])->put(
	    string_font => 'footer_menu',
	   ));

    # Create grid
    Bivio::UI::HTML::Widget->load_class('Grid', 'EditPreferences');
    return Bivio::UI::HTML::Widget::Grid->new({
	expand => 1,
	values => [
	    [
		Bivio::UI::HTML::Widget->clear_dot(1, 10),
	    ],
	    [
		Bivio::UI::HTML::Widget->clear_dot(undef, 1)->put(
			cell_expand => 1,
			cell_bgcolor => 'footer_line',
		       ),
	    ],
	    [
		Bivio::UI::HTML::Widget->toggle_secure(),
		Bivio::UI::HTML::Widget::Grid->new({
		    cell_align => 'center',
		    cell_expand => 1,
		    values => [
			$links,
		    ],
		}),
		Bivio::UI::HTML::Widget->link('top', '#top', 'footer_menu'),
	    ],
	    [
		' ',
	    ],
	    [
		Bivio::UI::HTML::Widget->link(
			Bivio::UI::HTML::Widget->image('bivio_power'),
			'http://www.bivio.com')->put(cell_align => 'sw'),
		$html->get_standard_copyright->put(
		    cell_align => 'right',
		    cell_expand => 1,
		),
	    ],
	],
    });
    return;
}

# _header(Bivio::UI::HTML html) : Bivio::UI::HTML::Widget
#
# Returns header widget.  Must be synchronized with _body().
#
sub _header {
    my($html) = @_;
    Bivio::UI::HTML::Widget->load_class('Grid', 'RealmChooser');
    return Bivio::UI::HTML::Widget::Grid->new({
	expand => 1,
	values => [
	    [
		_logo($html)->put(
			cell_align => 'nw',
			cell_rowspan => 2),
		Bivio::UI::HTML::Widget::RealmChooser->new({
		    pad_left => 10,
		    cell_nowrap => 1,
		    cell_align => 'nw'}),
		Bivio::UI::HTML::Widget->blank_cell->put(cell_expand => 1),
	    ],
	    [
		Bivio::UI::Facade::AllWomenInvest::TopMenu->new({
		    cell_align => 'nw'}),
		Bivio::UI::HTML::Widget->blank_cell->put(cell_expand => 1),
	    ],
	],
    });
}

# _logo(Bivio::UI::HTML html) : Bivio::UI::HTML::Widget
#
# Returns the logo widget which points to allwomeninvest home page.
#
sub _logo {
    my($html) = @_;
    return Bivio::UI::HTML::Widget->link(
	    Bivio::UI::HTML::Widget->image(
		    $html->get_value('logo_icon'),
		    $html->get_value('home_alt_text'),
		   ),
	    'http://www.allwomeninvest.com');
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
