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
	    $fc->regroup(0x0, qw(
		    footer_line
            ));
            $fc->set_group_value(qw(
                    realm_name
            ),
		    0xFF0300);
            $fc->set_group_value(qw(
                    image_menu_bg
            ),
		   0x84a4c4, );
            $fc->set_group_value(qw(
                    page_link_hover
            ),
		    0xc0c0c0);
	    $fc->set_group_value(qw(
	            page_link
            ),
		    0x336699);
	    return;
	},
    },
    'Bivio::UI::Font' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;
	    my($ss) = undef;
	    $fc->create_group([$ss, 'celebrity_box_title'],
		    'celebrity_box_title');
	    $fc->create_group([$ss, 'profile_box_title', 'strong'],
		    'profile_box_title');
	    $fc->create_group([$ss, 'celebrity_disclaimer', 'small'],
		    'celebrity_disclaimer');
	    $fc->create_group([$ss, 'decor_disclaimer', 'small'],
		    'decor_disclaimer');
	    $fc->create_group([$ss, 'detail_chooser', 'strong'],
		    'detail_chooser');
	    $fc->create_group([$ss, 'error', 'big', 'strong'], qw(
		    error_icon
	            substitute_user
            ));
	    $fc->create_group([$ss, 'footer_menu', 'size=-2'],
		    'footer_menu');
	    $fc->create_group([$ss, 'page_heading', 'small'],
		    'checked_icon');
	    $fc->create_group([$ss, 'page_heading', 'strong'],
		    'page_heading');
	    $fc->create_group([$ss, 'realm_name', 'strong'],
		    'realm_name');
	    $fc->create_group([$ss, 'tax_disclaimer', 'i'],
		    'tax_disclaimer');
	    $fc->create_group([$ss, 'text_menu_font', 'class=body', 'strong'],
		    qw(
		    prev_next_bar_link
		    text_menu_selected
                    help_log_button
            ));
	    $fc->create_group([$ss, 'text_menu_font', 'class=body',],
		    'text_menu_normal');
	    $fc->create_group([$ss, 'user_name', 'big'],
		    'user_name');
	    $fc->create_group([$ss, undef, 'small'], qw(
		    celebrity_box_text
		    profile_box_text
		    report_footer
		    time
            ));
	    $fc->create_group([$ss, undef, 'size=-2'], qw(
		    copyright_and_disclaimer
            ));
	    $fc->create_group([$ss, undef, 'strong'], qw(
		    table_heading
		    normal_table_heading
	    ));
	    $fc->create_group([$ss, undef], qw(
		    form_submit
                    message_subject
                    prev_next_bar_text
            ));
	    $fc->create_group([undef, 'description_label', 'strong'],
		    'description_label');
	    $fc->create_group([undef, 'error', 'b'], qw(
		    error
		    form_field_error
		    warning
            ));
	    $fc->create_group([undef, 'error', 'i'],
		    'form_field_error_label');
	    $fc->create_group([undef, 'error', 'small'],
		    'list_error',
		    'checkbox_error');
	    $fc->create_group([undef, 'page_text'],
		    'help_sign_button');
	    $fc->create_group([undef, 'form_field_label_in_text', 'strong'],
		    'form_field_label_in_text');
	    $fc->create_group([undef, 'icon_text_ia'],
		    'icon_text_ia');
	    $fc->create_group([undef, 'page_text'],
		    'realm_chooser_text');
	    $fc->create_group([undef, 'task_list_label_link'],
		    'task_list_label_link');
	    $fc->create_group([undef, 'task_list_label_no_link'],
		    'task_list_label_no_link');
	    $fc->create_group([undef, 'task_list_heading', 'strong'],
		    'task_list_heading');
	    $fc->create_group([undef, undef, 'b'],
		    'label_in_text');
	    $fc->create_group([undef, undef, 'i'],
		    'italic');
	    $fc->create_group([undef, undef, 'small'], qw(
		    file_tree_bytes
		    list_action
		    lookup_button
            ));
	    $fc->create_group([undef, undef, 'strong'], qw(
                    action_bar_string
                    strong
                    table_row_title
            ));
	    $fc->create_group([undef, undef], qw(
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
	    return;
	}
    },
    'Bivio::UI::HTML' => {
	clone => undef,
	initialize => sub {
	    my($fc) = @_;

	    # Some required strings and values
	    $fc->create_group('logo', 'logo_icon');
	    $fc->create_group('eklubs', 'site_name');
	    $fc->create_group('eklubs home', 'home_alt_text');

	    $fc->create_group(20, 'page_left_margin');
	    $fc->create_group('center', 'table_default_align');
	    $fc->create_group(1, 'scene_show_profile');
	    $fc->create_group(undef, 'scene_header');

	    # This one is used dynamically by ImageMenu in header_widget
	    # widget.  It is not a required field.  Only if you are using
	    # ImageMenu.
	    my($icon) = $fc->get_facade->get('Bivio::UI::Icon');
	    $fc->create_group($icon->get_width('logo_full')
		    + $icon->get_width('grad'),
		    'text_menu_base_offset');

	    $fc->create_group(Bivio::UI::HTML::Widget->image('grad', ''),
		    'image_menu_left_cell');

	    # Used by standard header
	    $fc->create_group($icon->get_width_as_html('logo_full'));

	    # These are required names, which are checked by page.
	    Bivio::UI::HTML::Widget->load_class('Page');
	    $fc->create_group(Bivio::UI::HTML::Widget::Page->new({
		head => $fc->get_standard_head(),
		style => _style(),
		body => Bivio::UI::HTML::Widget->join([
		    _header(),
		    Bivio::UI::HTML::Widget->indirect(['page_scene']),
		    _footer(),
		]),
	    }),
		    'page_widget');
	    $fc->create_group(_header(), 'header_widget');
	    $fc->create_group($icon->get_height('logo_full')
		    + $icon->get_height('tag')
		    + $icon->get_height('power_grad') + 100,
		   'header_height');
	    $fc->create_group($fc->get_standard_logo, 'logo_widget');
	    $fc->create_group($fc->get_standard_head, 'head_widget');
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

# _style() : Bivio::UI::HTML::Widget
#
# Returns style widget.
#
sub _style {
    return Bivio::UI::HTML::Widget->join([
	"<style>\n",
	"<!-- a:hover {\n",
	['Bivio::UI::Color', '->format_html', 'page_link_hover', 'color:'],
	"}\n",
	"td,a:link,p,body {\n",
	"font-family : Arial;\n",
	"font-size : x-small;\n",
	"font-style : normal;\n",
	"}\n",
	"-->\n",
	"</style>\n",
    ]);
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
