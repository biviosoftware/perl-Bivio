# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::Eklubs;
use strict;
$Bivio::UI::Facade::Eklubs::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Facade::Eklubs - eklubs full co-brand

=head1 SYNOPSIS

    use Bivio::UI::Facade::Eklubs;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::UI::Facade::Eklubs::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::UI::Facade::Eklubs> is the main eklubsuction and default Facade.

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->new({
    clone => 'Prod',
    is_production => 0,
    uri => 'cimo',
    'Bivio::UI::Color' => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->regroup(footer_line => 0x000000);
            $fc->value(page_link_hover => 0xc0c0c0);
	    $fc->value(page_link => 0x336699);
	    $fc->value(page_vlink => 0x336699);
	    $fc->value(page_heading => 0x336699);
            $fc->value(realm_name => 0xFF0300);
            $fc->value(image_menu_bg => 0x84a4c4);
            $fc->value(summary_line => 0x6600CC);
	    return;
	},
    },
    'Bivio::UI::Font' => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->value(default => [
		'family=arial', 'size=x-small',
	    ]);
	    $fc->group(help_log_button => ['bold']);
	    return;
	}
    },
    'Bivio::UI::HTML' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;

	    # Some required strings and values
	    $fc->group(logo_icon => 'logo');
	    $fc->group(site_name => 'eklubs');
	    $fc->group(home_alt_text => 'eklubs home');

	    $fc->group(want_secure => 0);
	    $fc->group(page_left_margin => 20);
	    $fc->group(table_default_align => 'center');
	    $fc->group(scene_show_profile => 1);
	    $fc->group(scene_header => undef);

	    # Home page isn't special
	    $fc->group(home_page => '');
	    $fc->group(descriptive_page_width => 600);

	    # This one is used dynamically by ImageMenu in header_widget
	    # widget.  It is not a required field.  Only if you are using
	    # ImageMenu.
	    my($icon) = $fc->get_facade->get('Bivio::UI::Icon');
	    $fc->group(text_menu_base_offset =>
		    $icon->get_width('logo_full') + $icon->get_width('grad'));

	    $fc->group(image_menu_left_cell =>
		    Bivio::UI::HTML::Widget->image('grad', ''));

	    $fc->group(image_menu_separator_width => 1);
	    $fc->group(text_menu_left_cell => undef);

	    # Used by standard header
	    $fc->group(logo_width_as_html =>
		    $icon->get_width_as_html('logo_full'));

	    # These are required names, which are checked by page.
	    Bivio::UI::HTML::Widget->load_class('Page');
	    $fc->group(page_widget => Bivio::UI::HTML::Widget::Page->new({
		head => $fc->get_standard_head(),
		style => $fc->get_standard_style(),
		body => Bivio::UI::HTML::Widget->join([
		    _header(),
		    Bivio::UI::HTML::Widget->indirect(['page_scene']),
		    _footer(),
		]),
	    }));
	    $fc->group(header_widget => _header());
	    $fc->group(header_height => $icon->get_height('logo_full')
		    + $icon->get_height('tag')
		    + $icon->get_height('power_grad') + 100
		   );
	    $fc->group(logo_widget => $fc->get_standard_logo);
	    $fc->group(head_widget => $fc->get_standard_head);
	    return;
	},
    },
});

=head1 METHODS

=cut

#=PRIVATE METHODS

# _footer() : Bivio::UI::HTML::Widget
#
# Returns footer widget.
#
sub _footer {
    # Create list of links
    my($links) = [];
    foreach my $t ('HOME:HTTP_DOCUMENT',
#	    'ABOUT EKLUBS:ABOUT_US',
	    'SAFE & PRIVATE:GENERAL_PRIVACY',
#	    'REGISTER:USER_CREATE',
#	    'START A CLUB:GENERAL_CONTACT'
#	    'TOUR:TOUR'
	    'CONTACT:GENERAL_CONTACT',
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
    Bivio::UI::HTML::Widget->load_class('Grid');
    return Bivio::UI::HTML::Widget::Grid->new({
	expand => 1,
	values => [
	    [
		' ',
	    ],
	    [
		Bivio::UI::HTML::Widget->clear_dot(undef, 3)->put(
			cell_expand => 1,
			cell_bgcolor => 'footer_line',
		       ),
	    ],
	    [
		Bivio::UI::HTML::Widget->toggle_secure(),
		Bivio::UI::HTML::Widget::Grid->new({
		    cell_align => 'center',
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
		Bivio::UI::HTML->get_standard_copyright->put(
		    cell_align => 'right',
		    cell_expand => 1,
		),
	    ],
	],
    });
    return;
}

# _header() : Bivio::UI::HTML::Widget
#
# Returns the header widget.
#
sub _header {
    # The header is different for each realm type
    Bivio::UI::HTML::Widget->load_class(qw(RealmChooser Grid));
    my($realm_info) = Bivio::UI::HTML::Widget::RealmChooser->new({
	pad_left => 0,
	cell_rowspan => 1,
    });
    $realm_info->put(cell_nowrap => 1, cell_align => 'left',
	    cell_colspan => 2, cell_expand => 1);
    my($top_menu) = Bivio::UI::HTML::Widget->indirect(
	    ['page_image_menu'])->put(
		    cell_align => 'nw',
		    cell_bgcolor => 'image_menu_bg',
		    cell_colspan => 2,
		    cell_align => 'left',
		   );
    my($sub_menu) = Bivio::UI::HTML::Widget->indirect(
	    ['page_text_menu']);
    my($top_part) = Bivio::UI::HTML::Widget::Grid->new({
	cell_expand => 1,
	expand => 1,
	values => [
	    [
		Bivio::UI::HTML::Widget->director(
			['super_user_id'],
			{},
			Bivio::UI::HTML::Widget->string(['auth_user', 'name'],
				'substitute_user'),
			Bivio::UI::HTML::Widget->link(
				Bivio::UI::HTML::Widget->image(
				    'logo_full',
				    ['Bivio::UI::HTML', '->get_value',
					'home_alt_text'],
				       ),
				'/'))->put(
				cell_rowspan => 2,
				cell_align => 'sw',
				cell_width_as_html => [
				    'Bivio::UI::Icon', '->get_width_as_html',
				    'logo_full'],
			       ),
		$realm_info,
	    ],
	    [
		Bivio::UI::HTML::Widget::Grid->new({
		    cell_align => 'sw',
		    values => [[
			Bivio::UI::HTML::Widget->image('dashed_line', '')
				    ->put(
					    cell_align => 'sw',
					   ),
			Bivio::UI::HTML::Widget->join([
			    '&nbsp;',
			    Bivio::UI::HTML::Widget->link(
				    'help',
				    ['->format_help_uri'],
				    'help_log_button',
				   ),
			    '&nbsp;',
			    '&nbsp;',
			    Bivio::UI::HTML::Widget->director(
				    ['auth_user'],
				    {
				    },
				    Bivio::UI::HTML::Widget->link(
					    'logout',
					    'LOGOUT',
					    'help_log_button',
					   ),
				    Bivio::UI::HTML::Widget->link(
					    'login',
					    'LOGIN',
					    'help_log_button',
					   ),
				   ),
			    '&nbsp;',
			])->put(
				cell_align => 'sw',
				cell_nowrap => 1,
			       ),
			   ]],
		    }),
	    ],
	    [
		Bivio::UI::HTML::Widget->image('tag',
			'The Easy way to invest'
		       )->put(
			       cell_colspan => 2,
			      ),
	    ],
	    [
		Bivio::UI::HTML::Widget->link(
			Bivio::UI::HTML::Widget->image('power_grad',
				'powered by bivio'),
			'http://www.bivio.com'),
		$top_menu,
	    ],
	],
    });

    # The top is used by the standard_footer.
#TODO: Make link '_top' dynamic.
    # We set _top, because the header is used in a frame.
    return Bivio::UI::HTML::Widget->join('<a name="top"></a>',
	    $top_part, $sub_menu);
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
