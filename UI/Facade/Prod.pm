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
    'Bivio::UI::Color' => {
	initialize => sub {
	    my($comp) = @_;
	    $comp->create_group(-1, qw(
		    table_odd_row_bg
		    list_form_even_row_bg
		    list_form_odd_row_bg
	    ));
	    $comp->create_group(0xFFFFFF, qw(
                    page_bg
		    image_menu_separator
		    report_page_heading_bg
		    celebrity_box_title
		    profile_box_title
		    celebrity_box_text_bg
		    profile_box_text_bg
            ));
	    $comp->create_group(0x990000, qw(
		    error
		    warning
	    ));
	    $comp->create_group(0x000000, qw(
    		    page_text
	            table_separator
            ));
	    $comp->create_group(0x009999, qw(
		    stripe_above_menu
		    celebrity_disclaimer
		    decor_disclaimer
		    tax_disclaimer
            ));
	    $comp->create_group(0x006666, qw(
		    footer_menu
	            page_vlink
	            page_alink
	            page_link
	            user_name
	            line_above_menu
	            action_bar_border
	            detail_chooser
	            page_heading
	            form_field_label_in_text
	            text_menu_font
	            celebrity_box
	            profile_box
	            description_label
	            task_list_heading
	            task_list_label
            ));
            $comp->create_group(0xEEEEEE, qw(
                    icon_text_ia
            ));
            $comp->create_group(0x66CC66, qw(
                    summary_line
            ));
	    # This is not websafe, but it will round down to 0xCCCCCC
	    # on systems that have only 256 colors.
            $comp->create_group(0xE4E4E4, qw(
                    table_even_row_bg
            ));
            $comp->create_group(0xFF6633, qw(
                    realm_name
            ));
            $comp->create_group(0xFFCC33, qw(
                    top_menu_bg
                    text_menu_line
            ));
	    return;
	},
    },
    'Bivio::UI::Font' => {
	initialize => sub {
	    my($comp) = @_;
	    my($ss) = 'verdana,arial,sans-serif';
	    $comp->create_group([$ss, 'celebrity_box_title'],
		    'celebrity_box_title');
	    $comp->create_group([$ss, 'profile_box_title'],
		    'profile_box_title');
	    $comp->create_group([$ss, 'celebrity_disclaimer', 'small'],
		    'celebrity_disclaimer');
	    $comp->create_group([$ss, 'decor_disclaimer', 'small'],
		    'decor_disclaimer');
	    $comp->create_group([$ss, 'detail_chooser', 'strong'],
		    'detail_chooser');
	    $comp->create_group([$ss, 'error', 'big', 'strong'], qw(
		    error_icon
	            substitute_user
            ));
	    $comp->create_group([$ss, 'footer_menu', 'small'],
		    'footer_menu');
	    $comp->create_group([$ss, 'page_heading', 'big', 'strong'],
		    'report_page_heading');
	    $comp->create_group([$ss, 'page_heading', 'small'],
		    'checked_icon');
	    $comp->create_group([$ss, 'page_heading', 'strong'],
		    'page_heading');
	    $comp->create_group([$ss, 'realm_name', 'strong'],
		    'realm_name');
	    $comp->create_group([$ss, 'tax_disclaimer', 'i'],
		    'tax_disclaimer');
	    $comp->create_group([$ss, 'text_menu_font', 'strong'], qw(
		    prev_next_bar_link
		    text_menu_selected
            ));
	    $comp->create_group([$ss, 'text_menu_font'],
		    'text_menu_normal');
	    $comp->create_group([$ss, 'user_name', 'big'],
		    'user_name');
	    $comp->create_group([$ss, undef, 'small'], qw(
		    celebrity_box_text
		    profile_box_text
		    copyright_and_disclaimer
		    report_footer
		    time
            ));
	    $comp->create_group([$ss, undef, 'strong'], qw(
		    table_heading
		    normal_table_heading
	    ));
	    $comp->create_group([$ss, undef], qw(
		    form_submit
                    message_subject
                    prev_next_bar_text
            ));
	    $comp->create_group([undef, 'description_label', 'strong'],
		    'description_label');
	    $comp->create_group([undef, 'error', 'b'], qw(
		    error
		    form_field_error
		    warning
            ));
	    $comp->create_group([undef, 'error', 'i'],
		    'form_field_error_label');
	    $comp->create_group([undef, 'error', 'small'],
		    'list_error',
		    'checkbox_error');
	    $comp->create_group([undef, 'form_field_label_in_text', 'strong'],
		    'form_field_label_in_text');
	    $comp->create_group([undef, 'icon_text_ia'],
		    'icon_text_ia');
	    $comp->create_group([undef, 'task_list_label'],
		    'task_list_label');
	    $comp->create_group([undef, 'task_list_heading', 'strong'],
		    'task_list_heading');
	    $comp->create_group([undef, undef, 'b'],
		    'label_in_text');
	    $comp->create_group([undef, undef, 'i'],
		    'italic');
	    $comp->create_group([undef, undef, 'small'], qw(
		    file_tree_bytes
		    list_action
		    lookup_button
            ));
	    $comp->create_group([undef, undef, 'strong'], qw(
                    action_bar_string
                    strong
                    table_row_title
            ));
	    $comp->create_group([undef, undef], qw(
		    form_field_description
		    form_field_label
		    table_cell
		    number_cell
                    action_button
	    	    form_field_example
	            radio
            ));
	    return;
	}
    },
    'Bivio::UI::Icon' => {
	# No initialization
	initialize => sub {},
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
