# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::InvestmentExpo;
use strict;
$Bivio::UI::Facade::InvestmentExpo::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Facade::InvestmentExpo - www.investmentexpo.com (ollon for now)

=head1 SYNOPSIS

    use Bivio::UI::Facade::InvestmentExpo;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::UI::Facade::InvestmentExpo::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::UI::Facade::InvestmentExpo> is a full co-brand for
www.investmentexpo.com.

=cut

#=IMPORTS
use Bivio::UI::Facade::InvestmentExpo::Home;
use Bivio::UI::Facade::InvestmentExpo::LeftMenu;

#=VARIABLES
__PACKAGE__->new({
    clone => 'Prod',
    is_production => 0,
    uri => 'ollon',
    'Bivio::UI::Color' => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->value(page_link => 0x003366);
	    $fc->value(page_vlink => 0x003366);
            $fc->value(page_link_hover => 0x0099CC);
	    $fc->value(celebrity_disclaimer => 0x0099CC);
	    $fc->value(page_heading => 0x003366);
            $fc->value(realm_name => 0x669999);
            $fc->value(image_menu_bg => -1);
            $fc->value(summary_line => 0x6600CC);
            $fc->value(table_even_row_bg => 0xCCCC99);
	    $fc->regroup(text_menu_font => 0x999933);
	    $fc->group(left_menu_selected => 0x999933);
	    return;
	},
    },
    'Bivio::UI::Font' => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->value(default => [
		'family=verdana,arial,helvetica,sans-serif', 'size=x-small',
	    ]);
	    $fc->regroup(text_menu_selected =>
		    ['color=page_link', 'bold']);
	    $fc->value(realm_name => ['bold', 'size=large']);

	    # Fixed size to match the investmentexpo site
	    $fc->group(left_menu_normal => ['bold', 'size=xx-small']);
	    $fc->group(left_menu_selected => ['bold', 'size=xx-small']);
	    return;
	}
    },
    'Bivio::UI::HTML' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;

	    # Some required strings and values
	    $fc->group(logo_icon => 'ielogosm');
	    $fc->group(site_name => 'Investment Expo 2000');
	    $fc->group(home_alt_text => 'Investment Expo 2000');

	    $fc->group(page_left_margin => 0);
	    $fc->group(table_default_align => 'center');
	    $fc->group(scene_show_profile => 1);
	    $fc->group(scene_header => undef);

	    # Home page is special
	    $fc->group(home_page =>
		    Bivio::UI::Facade::InvestmentExpo::Home->new);
	    $fc->group(descriptive_page_width => 480);

	    # This one is used dynamically by ImageMenu in header_widget
	    # widget.  It is not a required field.  Only if you are using
	    # ImageMenu.
	    $fc->group(text_menu_base_offset => 0);
	    $fc->group(image_menu_left_cell => 0);

	    $fc->group(text_menu_left_cell =>
		    Bivio::UI::HTML::Widget->image('subarrow'));

	    $fc->group(image_menu_separator_width => 1);

	    # These are required names, which are checked by page.
	    Bivio::UI::HTML::Widget->load_class('Page');
	    $fc->group(page_widget => Bivio::UI::HTML::Widget::Page->new({
		head => $fc->get_standard_head(),
		style => $fc->get_standard_style(),
		# This is only on the "standard" scene widgets, not
		# report or tax pages.
		background => 'investbkgrd',
		body => _body($fc),
	    }));
	    $fc->group(header_widget => _header($fc));
	    my($icon) = $fc->get_facade->get('Bivio::UI::Icon');
	    $fc->group(header_height => $icon->get_height('ielogosm')
		    + $icon->get_height('acct_on') + 100);
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
		# have to have clear_dots for Netscape to render properly.
		# 124 is the width of the background vertical bar.
		# This forces the left nav to fit in this space.
		Bivio::UI::HTML::Widget->clear_dot(124),
		# 16 is the no man's land margin
	        Bivio::UI::HTML::Widget->clear_dot(16),
		Bivio::UI::HTML::Widget::Grid->new({
		    cell_expand => 1,
		    values => [[
			_logo($html)->put(cell_align => 'nw'),
			Bivio::UI::HTML::Widget->clear_dot(20),
			_realm_name()->put(
				cell_expand => 1,
				cell_align => 'left'),
			]],
		}),
	    ],
	    [
		Bivio::UI::Facade::InvestmentExpo::LeftMenu->new->put(
			cell_align => 'nw',
			cell_rowspan => 3,),
		Bivio::UI::HTML::Widget->blank_cell,
		Bivio::UI::HTML::Widget->indirect(['page_image_menu'])->put(
			cell_align => 'nw'),
	    ],
	    [
		Bivio::UI::HTML::Widget->blank_cell,
		Bivio::UI::HTML::Widget->indirect(['page_text_menu'])->put(
			cell_align => 'nw'),
	    ],
	    [
		Bivio::UI::HTML::Widget->blank_cell,
		Bivio::UI::HTML::Widget->indirect(['page_scene'])->put(
			cell_align => 'nw'),
	    ],
	    [
		# Must be less than 124 wide.
		Bivio::UI::HTML::Widget->link(
			Bivio::UI::HTML::Widget->image('bivio_power'),
			'http://www.bivio.com')->put(cell_align => 'sw'),
		Bivio::UI::HTML::Widget->blank_cell,
		_footer(),
	    ],
	],
    });
    return;
}

# _footer() : Bivio::UI::HTML::Widget
#
# Returns footer widget.
#
sub _footer {
    # Create list of links
    my($links) = [];
    foreach my $t ('Home:http://www.investmentexpo.com',
	    'Shows:http://www.investmentexpo.com/shows.html',
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
#	    [
#		Bivio::UI::HTML::Widget::EditPreferences->new->put(
#			cell_expand => 1,
#		),
#		Bivio::UI::HTML::Widget->toggle_secure()->put(
#			cell_align => 'right'),
#	    ],
	    [
#		Bivio::UI::HTML::Widget->blank_cell,
		Bivio::UI::HTML::Widget::Grid->new({
		    cell_align => 'center',
		    cell_expand => 1,
		    values => [
			$links,
		    ],
		}),
	    ],
	    [
		Bivio::UI::HTML::Widget->clear_dot(1, 10),
	    ],
	    [
		Bivio::UI::HTML->get_standard_copyright->put(
		    cell_align => 'center',
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
    Bivio::UI::HTML::Widget->load_class('Grid');
    return Bivio::UI::HTML::Widget::Grid->new({
	expand => 1,
	values => [
	    [
		_logo($html)->put(cell_align => 'nw', cell_expand => 1),
	    ],
	    [
		Bivio::UI::HTML::Widget->indirect(['page_image_menu'])->put(
			cell_align => 'nw'),
	    ],
	    [
		Bivio::UI::HTML::Widget->indirect(['page_text_menu'])->put(
			cell_align => 'nw'),
	    ],
	],
    });
}

# _logo(Bivio::UI::HTML html) : Bivio::UI::HTML::Widget
#
# Returns the logo widget which points to investmentexpo home page.
#
sub _logo {
    my($html) = @_;
    return Bivio::UI::HTML::Widget->link(
	    Bivio::UI::HTML::Widget->image(
		    $html->get_value('logo_icon'),
		    $html->get_value('home_alt_text'),
		   ),
	    'http://www.investmentexpo.com');
}

# _realm_name()
#
# Returns the realm name rendering widget
#
sub _realm_name {
    return Bivio::UI::HTML::Widget->string([
	sub {
	    my($req) = shift->get_request;
	    my($o) = $req->get('auth_realm')->unsafe_get('owner');
	    return defined($o) ? $o->get('display_name') : '';
	}],
	   'realm_name');
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
