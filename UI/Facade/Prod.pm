# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::Prod;
use strict;
$Bivio::UI::Facade::Prod::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Facade::Prod::VERSION;

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
my($_W) = 'Bivio::UI::HTML::Widget';
my($_SELF) = __PACKAGE__->new({
    clone => undef,
    is_production => 1,
    # Bivio::UI::HTML sort of assumes this facade (and children) has this uri
    uri => 'www',
    'Bivio::UI::Color' => {
	initialize => sub {
	    my($fc) = @_;

	    #
	    # Links
	    #
	    $fc->group(page_link => 0x006666);
	    $fc->group(['page_vlink', 'page_alink'] => 0x006666);
            $fc->group(page_link_hover => 0xCC9900);

	    #
	    # Text
	    #
	    $fc->group(page_text => 0x000000);
	    $fc->group([qw(
                    page_bg
		    profile_box_title
		    celebrity_box_text_bg
		    profile_box_text_bg
            )],
		    0xFFFFFF);

	    # Basic emphasized text
	    $fc->group([qw(
	            page_heading
                    checked_icon
	            form_field_label_in_text
	            task_list_heading
	            task_list_label_no_link
	            detail_chooser
		    footer_line
	            celebrity_box
	            profile_box
	            description_label
            )],
	       0x006666);

	    # Disclaimers are brighter
	    $fc->group([qw(
		    celebrity_disclaimer
		    decor_disclaimer
		    tax_disclaimer
                    home_login_box
            )],
	       0x009999);

	    $fc->group(['error', 'warning', 'realm_notice_list'] => 0x990000);
            $fc->group(['realm_name'] => 0xFF6633);

	    # These are links, so don't set the color
	    $fc->group([qw(
		    footer_menu
	            user_name
	            text_menu_font
	            task_list_label_link
            )],
		    -1);

	    # Not really used
            $fc->group(icon_text_ia => 0xEEEEEE);

	    #
	    # Table
	    #
	    $fc->group(table_heading => -1);

	    # This is not websafe, but it will round down to 0xCCCCCC
	    # on systems that have only 256 colors.
            $fc->group(table_even_row_bg => 0xE4E4E4);
	    # List forms don't get stripes in the default view
	    $fc->group(table_odd_row_bg => -1);
	    $fc->group(list_form_even_row_bg => -1);
	    $fc->group(list_form_odd_row_bg => -1);
	    $fc->group(table_separator => 0x000000);
            $fc->group(summary_line => 0x66CC66);

	    # Home page shading
            $fc->group([qw(
		    mail_home_list_odd_bg
		    mail_home_list_even_bg
	    )],
	       0xFFFFFF);

	    #
	    # Image menu in header
	    #
            $fc->group(line_above_menu => 0x006666);
	    $fc->group(stripe_above_menu => 0x009999);
	    $fc->group(image_menu_separator => 0xFFFFFF);
            $fc->group([qw(
                  image_menu_bg
                  text_menu_line
                  home_login_bg
            )],
		    0xFFCC33);

	    # Club Index
	    $fc->group(club_index_change_plus => 0x00CC33);
	    $fc->group(club_index_change_zero => 0x000000);
	    $fc->group(club_index_change_minus => 0xFF0033);
	    return;
	},
    },
    'Bivio::UI::Font' => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->group(default => [
		'family=arial,sans-serif',
		'size=x-small',
	    ]);
	    $fc->group(profile_box_title => ['bold']);
	    $fc->group(celebrity_disclaimer => ['smaller']);
	    $fc->group(decor_disclaimer => ['smaller']);
	    $fc->group(realm_notice_list => ['bold']);
	    $fc->group(detail_chooser => ['bold']);
	    $fc->group(['error_icon', 'substitute_user'] =>
		    ['color=error', 'larger', 'bold']);
	    $fc->group(footer_menu => []);
	    $fc->group(checked_icon => ['smaller']);
	    $fc->group(page_heading => ['bold']);
	    $fc->group(realm_name => ['bold']);
	    $fc->group(report_page_realm_name =>
		    ['larger', 'bold', 'color=realm_name']);
	    $fc->group(tax_disclaimer => ['italic']);
	    $fc->group(['prev_next_bar_link', 'text_menu_selected'] =>
		    ['color=text_menu_font', 'bold']);
	    $fc->group(text_menu_normal => ['color=text_menu_font']);
	    $fc->group(user_name => ['larger']);
	    $fc->group([qw(
		    celebrity_box_text
		    profile_box_text
		    copyright_and_disclaimer
                    data_disclaimer
		    report_footer
		    time
            )],
		   ['smaller']);
	    $fc->group([qw(
                    table_heading
		    normal_table_heading
            )],
		    ['color=table_heading', 'bold'],
		   );
	    $fc->group([qw(
		    form_submit
                    message_subject
                    prev_next_bar_text
            )],
		   []);
	    $fc->group(description_label => ['bold']);
	    $fc->group([qw(
		    error
		    form_field_error
		    warning
            )],
		   ['color=error', 'bold']);
	    $fc->group(form_field_error_label => ['color=error', 'italic']);
	    $fc->group(['list_error', 'checkbox_error'] =>
		   ['color=error', 'smaller']);
	    $fc->group(form_field_label_in_text => ['bold']);
	    $fc->group(icon_text_ia => []);
	    $fc->group(realm_chooser_text => ['color=page_text']);
	    $fc->group(task_list_label_link => []);
	    $fc->group(task_list_label_no_link => []);
	    $fc->group(task_list_heading => ['bold']);
	    $fc->group(label_in_text => ['bold']);
	    $fc->group(italic => ['italic']);
	    $fc->group([qw(
                    filtrum_top_holdings_heading
                    register_now
                    learn_more
            )],
		    ['larger', 'bold']);
	    $fc->group([qw(
		    file_tree_bytes
		    list_action
		    lookup_button
                    instrument_ticker_symbol
	    	    form_field_example
                    help_hint
            )],
		   ['smaller']);
	    $fc->group([qw(
                    action_bar_string
                    strong
                    table_row_title
                    instrument_name
            )],
		   ['bold']);
	    $fc->group([qw(
		    form_field_description
		    form_field_label
		    table_cell
		    number_cell
                    action_button
		    report_page_heading
	            radio
                    descriptive_page
                    page_legend
                    checkbox
                    page_text
                    input_field
                    search_field
                    mailto
                    link
            )],
		   []);

	    # Home page fonts don't scale
	    $fc->group(home_login_field_label => ['size=xx-small']);
	    $fc->group(home_login_site_header => ['bold']);
	    $fc->group(home_date => ['size=large']);
	    $fc->group(club_index_today => ['size=small']);
	    $fc->group(club_index_change_plus => ['size=x-small']);
	    $fc->group(club_index_change_zero => ['size=x-small']);
	    $fc->group(club_index_change_minus => ['size=x-small']);
	    $fc->group(mail_home_list_cell => ['size=x-small']);
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
	    $fc->group(site_name => 'bivio');
	    $fc->group(logo_icon => 'bivio');
	    $fc->group(home_alt_text => 'bivio home');

	    $fc->initialize_standard_support;
	    $fc->value(want_secure => 1);

	    # Used by standard_page/body.
	    $fc->group(footer_widget => $fc->get_standard_footer);

	    # These are required names, which are checked by page.
	    $fc->group(header_widget => $fc->get_standard_header);
	    $fc->group(header_height => $fc->get_standard_header_height);
	    $fc->group(logo_widget => $fc->get_standard_logo);
	    $fc->group(head_widget => $fc->get_standard_head);
	    $fc->group(page_widget => $fc->get_standard_page);
	    foreach my $r (Bivio::Type::RealmName->CELEBRITY_CLUBS) {
		$fc->group('mail_home_list_'.$r =>
			$_W->load_and_new('MailHomeList', {realm_name => $r}));
	    }

	    # Home page widgets
	    Bivio::IO::ClassLoader->simple_require(
		    'Bivio::Biz::Util::Filtrum');
	    $fc->group(filtrum_holdings => $_W->join([
		[sub {${Bivio::Biz::Util::Filtrum->realm_file(
			'holdings_file');}}],
	    ]));
	    $fc->group(club_index => $_W->join([
		[sub {${Bivio::Biz::Util::Filtrum->realm_file(
			'club_index_file')}}],
	    ]));
	    $fc->group(home_login => $_W->load_and_new('HomeLogin'));
	    $fc->group(home_login_image =>
		    $_W->load_and_new('HomeLoginImage'));
	    $fc->group(home_date_clubs => $_W->load_and_new('HomeDateClubs'));
	    $fc->group(toggle_secure_widget => $_W->toggle_secure);
	    $fc->group(register_button_widget => $_W->director(
	    [sub {shift->get_request->get('user_state')
			  == Bivio::Type::UserState::JUST_VISITOR() ? 1 : 0}],
	    {
		0 => '',
		1 => $_W->link($_W->image('register', 'Sign up!'),
		       'USER_CREATE'),
	    }));
	    return;
	},
    },
});

Bivio::UI::Font->initialize_children($_SELF);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
