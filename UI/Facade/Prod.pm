# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::Prod;
use strict;
$Bivio::UI::Facade::Prod::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Facade::Prod - main production and default facade

=head1 SYNOPSIS

    use Bivio::UI::Facade::Prod;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::UI::Facade::Prod::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::UI::Facade::Prod> is the main production and default Facade.

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->new({
    clone => undef,
    is_production => 1,
    'Bivio::UI::Color' => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->create_group(-1, qw(
		    table_odd_row_bg
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
	            table_separator
            ));
	    $fc->create_group(0x009999, qw(
		    stripe_above_menu
		    celebrity_disclaimer
		    decor_disclaimer
		    tax_disclaimer
            ));
	    # These are links, so don't set the color
	    $fc->create_group(-1, qw(
		    footer_menu
	            user_name
	            text_menu_font
	            task_list_label_link
            ));
	    $fc->create_group(0x006666, qw(
	            page_link
	            page_vlink
	            page_alink
	            line_above_menu
		    footer_line
	            detail_chooser
	            page_heading
	            form_field_label_in_text
	            celebrity_box
	            profile_box
	            description_label
	            task_list_heading
	            task_list_label_no_link
            ));
            $fc->create_group(0xEEEEEE, qw(
                    icon_text_ia
            ));
            $fc->create_group(0xCC9900, qw(
                    page_link_hover
            ));
            $fc->create_group(0x66CC66, qw(
                    summary_line
            ));
	    # This is not websafe, but it will round down to 0xCCCCCC
	    # on systems that have only 256 colors.
            $fc->create_group(0xE4E4E4, qw(
                    table_even_row_bg
            ));
            $fc->create_group(0xFF6633, qw(
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
	initialize => sub {
	    my($fc) = @_;
	    my($ss) = 'verdana,arial,sans-serif';
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
	    $fc->create_group([$ss, 'footer_menu', 'small'],
		    'footer_menu');
	    $fc->create_group([$ss, 'page_heading', 'small'],
		    'checked_icon');
	    $fc->create_group([$ss, 'page_heading', 'strong'],
		    'page_heading');
	    $fc->create_group([$ss, 'realm_name', 'strong'],
		    'realm_name');
	    $fc->create_group([$ss, 'tax_disclaimer', 'i'],
		    'tax_disclaimer');
	    $fc->create_group([$ss, 'text_menu_font', 'strong'], qw(
		    prev_next_bar_link
		    text_menu_selected
            ));
	    $fc->create_group([$ss, 'text_menu_font'],
		    'text_menu_normal');
	    $fc->create_group([$ss, 'user_name', 'big'],
		    'user_name');
	    $fc->create_group([$ss, undef, 'small'], qw(
		    celebrity_box_text
		    profile_box_text
		    copyright_and_disclaimer
		    report_footer
		    time
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
    'Bivio::UI::Icon' => {
	# No initialization
	initialize => sub {},
    },
    'Bivio::UI::HTML' => {
	initialize => sub {
	    my($fc) = @_;

	    # Some required strings and values
	    $fc->create_group('bivio', 'logo_icon', 'site_name');
	    $fc->create_group('bivio home', 'home_alt_text');

	    $fc->create_group(20, 'page_left_margin');
	    $fc->create_group('center', 'table_default_align');
	    $fc->create_group(1, 'scene_show_profile');
	    $fc->create_group(undef, 'scene_header');

	    $fc->initialize_standard_support;

	    # These are required names, which are checked by page.
	    $fc->create_group($fc->get_standard_page, 'page_widget');
	    $fc->create_group($fc->get_standard_header, 'header_widget');
	    $fc->create_group($fc->get_standard_logo, 'logo_widget');
	    $fc->create_group($fc->get_standard_head, 'head_widget');
	    $fc->create_group($fc->get_standard_header_height,
		    'header_height');
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
