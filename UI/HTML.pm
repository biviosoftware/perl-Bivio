# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML;
use strict;
$Bivio::UI::HTML::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::VERSION;

=head1 NAME

Bivio::UI::HTML - named html components

=head1 SYNOPSIS

    use Bivio::UI::HTML;
    Bivio::UI::HTML->new();

=cut

=head1 EXTENDS

L<Bivio::UI::FacadeComponent>

=cut

use Bivio::UI::FacadeComponent;
use Bivio::UI::Widget;
@Bivio::UI::HTML::ISA = ('Bivio::UI::FacadeComponent');

=head1 DESCRIPTION

C<Bivio::UI::HTML> manages the HTML widgets and bits of pieces for
the HTML part of a Facade.

=cut

=head1 CONSTANTS

=cut

=for html <a name="UNDEF_CONFIG"></a>

=head2 UNDEF_CONFIG() : string

Returns C<undef> which is uninterpreted
by L<internal_initialize_value|"internal_initialize_value">.

Some configuration can't be C<undef> and will be checked
in L<initialize_complete|"initialize_complete">.

=cut

sub UNDEF_CONFIG {
    return undef;
}

#=IMPORTS
use Bivio::Die;
use Bivio::UI::Facade;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

# HTML uses all of these
Bivio::UI::Facade->register(['Bivio::UI::Icon', 'Bivio::UI::Color',
    'Bivio::UI::Font']);

=head1 METHODS

=cut

=for html <a name="get_data_disclaimer"></a>

=head2 static get_data_disclaimer() : Bivio::UI::Widget

Returns the data disclaimer widget (which is a director)

=cut

sub get_data_disclaimer {
    my($proto) = @_;
    # Only render csi data if accounting page
    return $_VS->vs_director(
	    [sub {
		 # Some tasks don't have uris; always have names
		 return shift->get('task_id')->get_name =~ /ACCOUNTING/
			 ? 1 : 0;
	     }],
	    {
		0 => 0,
		1 => Bivio::UI::HTML::Widget::Grid->new({
		    values => [[
			$_VS->vs_clear_dot(1, 1)->put(cell_width => '50%'),
			$_VS->vs_template_as_string(
				    <<'EOF', 'data_disclaimer')
<{vs_clear_dot(480, 10)}><br>
Historical data and daily updates provided by
<{vs_link('Commodity Systems, Inc. (CSI)', 'http://www.csidata.com', 0)}>.
Data and information is provided for informational purposes only, and is not
intended for trading purposes. Neither vs_site_name() nor its data or content
providers shall be liable for any errors or delays in the content, or
for any actions taken in reliance thereon.
EOF
				->put(cell_align => 'center'),
			$_VS->vs_clear_dot(1, 1)->put(cell_width => '50%'),
			],
		    ],
		}),
	    });
}

=for html <a name="get_header"></a>

=head2 static get_header() : Bivio::UI::Widget

Returns the widget used to render the page header.

=cut

sub get_header {
    my($proto) = @_;
    return $_VS->vs_indirect(
	    [__PACKAGE__, '->get_value', 'header_widget']);
}

=for html <a name="get_header_height"></a>

=head2 get_header_height() : array_ref

Widget value which returns L<get_header|"get_header">'s height in pixels.

=cut

sub get_header_height {
    return [__PACKAGE__, '->get_value', 'header_height'];
}

=for html <a name="get_logo"></a>

=head2 static get_logo() : Bivio::UI::Widget

Returns the widget which renders the logo.

=cut

sub get_logo {
    my($proto) = @_;
    return $_VS->vs_indirect(
	    [__PACKAGE__, '->get_value', 'logo_widget']);
}

=for html <a name="get_standard_body"></a>

=head2 get_standard_body() : Bivio::UI::Widget

Returns a Join widget which can be passed to
I<body> attribute of
L<Bivio::UI::HTML::Widget::Page|Bivio::UI::HTML::Widget::Page>.

The attribute I<header_widget> and I<footer_widget>
must be defined on I<self>.

=cut

sub get_standard_body {
    my($self) = @_;
    return $_VS->vs_join([
	$self->get_value('header_widget'),
	$_VS->vs_indirect(['page_scene']),
	$self->get_value('footer_widget'),
    ]);
    return;
}

=for html <a name="get_standard_copyright"></a>

=head2 static get_standard_copyright() : Bivio::UI::Widget

Returns standard copyright text which should be wrapped in a
string.

=cut

sub get_standard_copyright {
    my($year) = (gmtime(time))[5] + 1900;
    return $_VS->vs_string(
	    $_VS->vs_join([
		"Copyright &copy; $year, bivio Inc."
		." <i>All Rights Reserved.</i>\n<br>"
		."Use of this Web site constitutes acceptance"
		." of the bivio\n",
		$_VS->vs_link(
			Bivio::UI::Label->get_simple(
				'USER_AGREEMENT_TEXT'),
			'USER_AGREEMENT_TEXT',
		       ),
	    ]),
	    'copyright_and_disclaimer');
    return;
}

=for html <a name="get_standard_footer"></a>

=head2 static get_standard_footer() : Bivio::UI::Widget

Returns a standard footer widget.

Requires Request attributes: I<support_email>.

Requires Bivio::UI::Color attributes: I<footer_menu>

Requires Bivio::UI::Font attributes: I<copyright_and_disclaimer>,
I<footer_menu>

=cut

sub get_standard_footer {
    my($proto) = @_;
    my($spacer) = $_VS->vs_join(['&nbsp;'])->put(
	cell_width => 20,
    );

    # Create list of links
    my($links) = [];
    foreach my $t ('Home:HTTP_DOCUMENT',
	    'Safe & Private:GENERAL_PRIVACY',
	    'Contact:GENERAL_CONTACT') {
	my($label, $task) = split(/:/, $t);
	push(@$links, $_VS->vs_link(
		$label, $task, 'footer_menu'),
		$spacer);
    }
    push(@$links, $_VS->vs_link(['support_email'], 'MAIL_SUPPORT', 'footer_menu'));

    # Create grid
    $_VS->vs_load_class('Grid', 'EditPreferences');
    return Bivio::UI::HTML::Widget::Grid->new({
	expand => 1,
	values => [
	    [
		' ',
	    ],
	    [
		$_VS->vs_clear_dot(undef, 1)->put(
			cell_expand => 1,
			cell_bgcolor => 'footer_line',
		       ),
	    ],
	    [
		Bivio::UI::HTML::Widget::EditPreferences->new->put(
			cell_expand => 1,
		),
	    ],
	    [
		# Only render second line if the the EditPreferences
		# widget actually rendered something.
		$_VS->vs_director(
			['edit_preferences_rendered'],
			{
			    0 => 0,
			    1 => $_VS->vs_clear_dot(undef, 1),
			})->put(
				cell_expand => 1,
				cell_bgcolor => 'footer_line',
			       ),
	    ],
	    [
		$_VS->vs_toggle_secure(),
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
		    cell_expand => 1,
		    values => [[
			$_VS->vs_link_static_site(
				$_VS->vs_image('truste_mark', 'TRUSTe'),
				'hm/private.html')->put(
					cell_align => 'n',
					cell_expand => 1),
			$proto->get_standard_copyright->put(
				cell_align => 'right',
				cell_nowrap => 1),
		    ]],
		}),
	    ],
	    [
		$proto->get_data_disclaimer()->put(cell_expand => 1),
	    ],
	],
    });
}

=for html <a name="get_standard_head"></a>

=head2 static get_standard_head() : Bivio::UI::Widget

Returns a Title widget which can be passed to
I<head> attribute of
L<Bivio::UI::HTML::Widget::Page|Bivio::UI::HTML::Widget::Page>.

Requires Request attributes: I<page_subtopic>, I<page_topic>,
I<auth_realm>.

Requires Bivio::UI::HTML::Widget::Page attributes: I<site_name>

=cut

sub get_standard_head {
    $_VS->vs_load_class('Title');
    return Bivio::UI::HTML::Widget::Title->new({
	values => [
	    ['page_subtopic'],
	    ['page_topic'],
	    [sub {
		 my($source) = @_;
		 my($realm) = $source->get('auth_realm');
		 return $realm->get('type')
			 eq Bivio::Auth::RealmType::GENERAL()
			? $source->get(__PACKAGE__)->get_value('site_name')
			: $realm->get('owner_name');
	     }],
	],
    });
}

=for html <a name="get_standard_header"></a>

=head2 get_standard_header() : Bivio::UI::Widget

Returns a widget which renders a logo, an ImageMenu, RealmChooser,
etc.  The standard bivio setup.  We'll modify this as we go.

=cut

sub get_standard_header {
    my($self) = @_;
    # The header is different for each realm type
    $_VS->vs_load_class(qw(RealmChooser Grid));
    my($realm_info) = $self->get_value('realm_chooser');
    $realm_info->put(cell_nowrap => 1, cell_align => 'left',
	    cell_colspan => 2, cell_expand => 1);
    my($top_menu) = $_VS->vs_indirect(
	    ['page_image_menu'])->put(
		    cell_align => 'nw',
		    cell_bgcolor => 'image_menu_bg',
		    cell_colspan => 2,
		    cell_align => 'left',
		   );
    my($sub_menu) = $_VS->vs_indirect(
	    ['page_text_menu']);
    my($top_part) = Bivio::UI::HTML::Widget::Grid->new({
	cell_expand => 1,
	expand => 1,
	values => [
	    [
		$self->get_logo()->put(
			cell_rowspan => 5,
			cell_align => 'sw',
			cell_width_as_html => [
			    __PACKAGE__, '->get_value',
			    'logo_icon_width_as_html'],
		       ),
		$realm_info,
	    ],
	    [
		$_VS->vs_clear_dot(5, 1)->put(
		    cell_nowrap => 1,
		    cell_align => 'right',
		    cell_colspan => 2,
		),
	    ],
	    [
		$_VS->vs_image('grad_g', '')->put(
			cell_bgcolor => 'stripe_above_menu',
		       ),
		$_VS->vs_join([
		    $self->get_value('want_help')
		    ? $_VS->vs_link($_VS->vs_image('help_off'), ['->format_help_uri'])
		    : $_VS->vs_join(''),
		    $_VS->vs_director(
			    ['auth_user'],
			    {},
			    $_VS->vs_link($_VS->vs_image('logout_off'), 'LOGOUT'),
			    $_VS->vs_link($_VS->vs_image('login_square_off'), 'LOGIN'),
			   ),
		])->put(
			cell_bgcolor => 'stripe_above_menu',
			cell_align => 'right',
		       ),
	    ],
	    [
		$_VS->vs_image('grad_1px', '')->put(
		    cell_bgcolor => 'line_above_menu',
		    cell_colspan => 2,
		    height => 1,
		    width => 0,
		),
	    ],
	    [
		$top_menu,
	    ],
	],
    });

    # The top is used by the standard_footer.
#TODO: Make link '_top' dynamic.
    # We set _top, because the header is used in a frame.
    return $_VS->vs_join('<a name="top"></a>',
	    $top_part, $sub_menu);
}

=for html <a name="get_standard_header_height"></a>

=head2 get_standard_header_height() : int

Returns the height of L<get_standard_header|"get_standard_header">.

=cut

sub get_standard_header_height {
    my($self) = @_;
    return $self->get_facade->get('Bivio::UI::Icon')->get_height(
	    $self->get_value('logo_icon')) + 70;
}

=for html <a name="get_standard_logo"></a>

=head2 static get_standard_logo() : Bivio::UI::Widget

Returns the Logo widget which fits in with everything else.

=cut

sub get_standard_logo {
    my($proto) = @_;
    return $_VS->vs_director(
	    ['super_user_id'],
	    {},
	    $_VS->vs_string(['auth_user', 'name'],
		    'substitute_user'),
	    $_VS->vs_link(
		    $_VS->vs_image(
			    [__PACKAGE__, '->get_value', 'logo_icon'],
			    [__PACKAGE__, '->get_value', 'home_alt_text'],
			   ),
		    '/'),
	   );
}

=for html <a name="get_standard_page"></a>

=head2 get_standard_page() : Bivio::UI::HTML::Widget::Page

Returns a Page widget combined of a L<get_standard_style|"get_standard_style">
L<get_standard_body|"get_standard_body">.

Uses I<head_widget>.

=cut

sub get_standard_page {
    my($self) = @_;
    $_VS->vs_load_class('Page');
    return Bivio::UI::HTML::Widget::Page->new({
	head => $self->get_value('head_widget'),
	body => $self->get_standard_body(),
	style => $self->get_standard_style(),
    });
}

=for html <a name="get_standard_style"></a>

=head2 static get_standard_style() : Bivio::UI::Widget

Returns the standard widget for style.

=cut

sub get_standard_style {
    $_VS->vs_load_class('Style');
    return Bivio::UI::HTML::Widget::Style->new;
}

=for html <a name="get_value"></a>

=head2 get_value(string name, Bivio::Collection::Attributes facade_or_req) : any

Returns the value which may be a widget or a string.

Values MUST be found or the request terminates.

=cut

sub get_value {
    my($proto, $name, $req) = @_;

    # Lookup name
    my($v) = $proto->internal_get_value($name, $req);
    Bivio::Die->die('unable to find: ', $name) unless $v;

    return $v->{value};
}

=for html <a name="initialization_complete"></a>

=head2 initialization_complete()

Verifies certain names exist.

=cut

sub initialization_complete {
    my($self) = @_;
    my(@bad);
    foreach my $n (qw(page_widget header_widget logo_widget head_widget
    	    header_height logo_icon site_name home_alt_text
            want_secure page_left_margin table_default_align
            home_page descriptive_page_width scene_show_profile
            request_attrs want_bulletin want_help want_public_search
            want_ads)) {
	push(@bad, $n) unless defined($self->get_value($n));
    }
    Bivio::Die->die($self, ': missing names: ', \@bad)
		if @bad;
    $self->SUPER::initialization_complete();
    return;
}

=for html <a name="initialize_standard_support"></a>

=head2 initialize_standard_support()

Initializes Page groups for standard widgets.

=cut

sub initialize_standard_support {
    my($self) = @_;

    # Fund attributes
    $self->group(club_or_fund => 'club');
    $self->group(want_ads => 1);
    $self->group(want_bulletin => 1);
    $self->group(want_help => 1);
    $self->group(want_public_search => 1);
    $self->group(want_secure => 0);
    $self->group(want_tos => 1);

    # Home page isn't special
    $self->group(home_page => '');
    $self->group(descriptive_page_width => 600);

    $self->group(page_left_margin => 20);
    $self->group(table_default_align => 'center');
    $self->group(scene_show_profile => 1);
    $self->group(scene_header => undef);

    # May be overridden.
    my($uri) = $self->get_facade->unsafe_get('uri');
    my($attrs) = {};

    # Fix up the uri for this facade.  "www" is the prod facade's uri
    if ($uri && $uri ne 'www') {
	my($http_host) = Bivio::Agent::Request->get_current->get('http_host');
	$http_host =~ s/^(?:www\.)?/$uri./;
	$attrs->{http_host} = $http_host;
    }
    $self->group(request_attrs => $attrs);

    # This one is used dynamically by ImageMenu in header_widget
    # widget.  It is not a required field.  Only if you are using
    # ImageMenu.
    my($icon) = $self->get_facade->get('Bivio::UI::Icon');
    $self->group(text_menu_base_offset => 
	    $icon->get_width($self->get_value('logo_icon'))
	    + $icon->get_width('grad_y'));

    $self->group(image_menu_left_cell => 
	    $_VS->vs_image('grad_y', ''));;
    $self->group(realm_chooser => $_VS->vs_new('RealmChooser', {
	pad_left => ['Bivio::UI::Icon', '->get_width', 'grad_y'],
    }));
    $self->group(image_menu_separator_width => 1);
    $self->group(text_menu_left_cell => undef);

    # Used by standard header
    $self->group(logo_icon_width_as_html =>
	    $self->get_facade->get('Bivio::UI::Icon')
	    ->get_width_as_html($self->get_value('logo_icon')));

    # Widgets used in headers of all pages
    $self->group(home_login_image =>
		    $_VS->vs_new('HomeLoginImage'));
    my($mld_alt) = 'Enroll with Merrill Lynch and get $100';
    my($mld_uri) = 'http://www.mldirect.ml.com/publish/public/'
	    .'offer.asp?medium=BIV0001';
    my($buyandhold_uri) = 'http://www.buyandhold.com/'
	    .'Buy?request=rr.refBy&ref=BIVIO'
	    .'&dest=/bh/en/advert/closed/bivio/bivio.html';
    $self->group(north_banner_widget =>
	    $_VS->vs_new('Advertizement', {
		values => [
		    # weight icon alt uri
		    [1, 'ad_mld_2_468x60', $mld_alt, $mld_uri],
		    [1, 'ad_mld_3_468x60', $mld_alt, $mld_uri],
		    [1, 'ad_mld_4_468x60', $mld_alt, $mld_uri],
		    [1, 'ad_buyandhold_468x60_facedrip',
			'BUYandHOLD', $buyandhold_uri],
		    [1, 'ad_buyandhold_468x60_drips1',
			'BUYandHOLD', $buyandhold_uri],
		    [1, 'ad_investware_tk4banner4', 'InvestWare',
			'http://investware.com/tk4pro.stm'],
		    [1, 'ad_investware_databanner', 'InvestWare',
			'http://www.investware.com/data.stm'],
		    [1, 'ad_bivio_cfo', 'Learn about AccountKeeper',
			'/hm/account-keeper.html'],
		    [1, 'ad_bivio_stop', 'Learn about AccountSync',
			'/hm/account-sync.html'],
		]}));
    $self->group(toggle_secure_widget => $_VS->vs_toggle_secure);
    $self->group(register_button_widget => $_VS->vs_director(
	    [sub {shift->get_request->get('user_state')
			  == Bivio::Type::UserState::JUST_VISITOR() ? 1 : 0}],
	    {
		0 => '',
		1 => $_VS->vs_link($_VS->vs_image('register', 'Sign up!'),
			'USER_CREATE'),
	    }));
    return;
}

=for html <a name="internal_initialize_value"></a>

=head2 internal_initialize_value(hash_ref value)

There are three types of values at this time: strings,
subs, and widgets.  Widgets are initialized by this module.
They do not have parents. subs are executed and either return
a string or a widget, which becomes the value.

We check to make sure that the "widget" is truly a widget.

=cut

sub internal_initialize_value {
    my($self, $value) = @_;

    my($v) = $value->{config};

    if (ref($v)) {
	# If is code, call with $self as param
	$v = &$v($self) if ref($v) eq 'CODE';

	# If result of sub is widget or config is widget, call initialize.
	$v->initialize if UNIVERSAL::isa($v, 'Bivio::UI::Widget');
    }
    $value->{value} = $v;
    return;
}

=for html <a name="setup_request"></a>

=head2 setup_request(Bivio::Agent::Request req)

Initializes facade-based attributes.

=cut

sub setup_request {
    my($self, $req) = @_;
    $req->put(%{$self->get_value('request_attrs')});
    return;
}

=for html <a name="widget_from_template"></a>

=head2 widget_from_template(array_ref lines) : Bivio::UI::HTML::Join

Creates a Join from the lines.

Replaces tags of the form (/E<lt>\$\w+E<gt>/):

    <$content_widget>

in I<lines> with the widget identified by the name (content_widget
in this case).

All names must exist and map to widgets.

=cut

sub widget_from_template {
    my($self, $lines) = @_;

    # Initialize with a value so ref() check below is cleaner
    my(@new) = ('');

    # Go through each line replacing tags in order
    for (my($line_num) = 1; @$lines; $line_num++) {

	foreach my $tok (split(/(?=<\$\w+>)/, shift(@$lines))) {
	    if ($tok =~ s/^<\$(\w+)>//) {
		my($name) = $1;

		# Make sure name exists
		my($w) = $self->get_value($name);
		Bivio::Die->die($self, ': <$', $name, '> not defined'
			.', on line ', $line_num)
			    unless defined($w);

		# Make sure name is a widget
		Bivio::Die->die($self, ': <$', $name, '>: value ', $w,
			' not a Bivio::UI::Widget, on line ', $line_num)
			    unless UNIVERSAL::isa($w,
				    'Bivio::UI::Widget');
		push(@new, $w);
	    }

	    # Can we just concatenate with previous value?
	    if (ref($new[$#new]).ref($tok) eq '') {
		# Two strings in a row
		$new[$#new] .= $tok;
	    }
	    else {
		# A widget is involved
		push(@new, $tok);
	    }
	}
    }
    return $_VS->vs_join(\@new);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
