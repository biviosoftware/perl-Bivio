# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML;
use strict;
$Bivio::UI::HTML::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
use Bivio::UI::HTML::Widget;
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

#=VARIABLES
# HTML uses all of these
Bivio::UI::Facade->register(['Bivio::UI::Icon', 'Bivio::UI::Color',
    'Bivio::UI::Font']);

=head1 METHODS

=cut

=for html <a name="get_header"></a>

=head2 static get_header() : Bivio::UI::HTML::Widget

Returns the widget used to render the page header.

=cut

sub get_header {
    my($proto) = @_;
    return Bivio::UI::HTML::Widget->indirect(
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

=head2 static get_logo() : Bivio::UI::HTML::Widget

Returns the widget which renders the logo.

=cut

sub get_logo {
    my($proto) = @_;
    return Bivio::UI::HTML::Widget->indirect(
	    [__PACKAGE__, '->get_value', 'logo_widget']);
}

=for html <a name="get_standard_body"></a>

=head2 static get_standard_body() : Bivio::UI::HTML::Widget

Returns a Join widget which can be passed to
I<body> attribute of
L<Bivio::UI::HTML::Widget::Page|Bivio::UI::HTML::Widget::Page>.

=cut

sub get_standard_body {
    my($proto) = @_;
    return Bivio::UI::HTML::Widget->join([
	$proto->get_standard_header(),
	Bivio::UI::HTML::Widget->indirect(['page_scene']),
	$proto->get_standard_footer(),
    ]);
    return;
}

=for html <a name="get_standard_copyright"></a>

=head2 static get_standard_copyright() : Bivio::UI::HTML::Widget

Returns standard copyright text which should be wrapped in a
string.

=cut

sub get_standard_copyright {
    my($year) = (gmtime(time))[5] + 1900;
    return Bivio::UI::HTML::Widget->string(
	    Bivio::UI::HTML::Widget->join([
		"Copyright &copy; $year, bivio Inc."
		." <i>All Rights Reserved.</i>\n<br>"
		."Use of this Web site constitutes acceptance"
		." of the bivio\n",
		Bivio::UI::HTML::Widget->link(
			Bivio::UI::Label->get_simple(
				'USER_AGREEMENT_TEXT'),
			'USER_AGREEMENT_TEXT',
		       ),
	    ]),
	    'copyright_and_disclaimer');
    return;
}

=for html <a name="get_standard_footer"></a>

=head2 static get_standard_footer() : Bivio::UI::HTML::Widget

Returns a standard footer widget.

Requires Request attributes: I<support_email>.

Requires Bivio::UI::Color attributes: I<footer_menu>

Requires Bivio::UI::Font attributes: I<copyright_and_disclaimer>,
I<footer_menu>

=cut

sub get_standard_footer {
    my($proto) = @_;
    my($spacer) = Bivio::UI::HTML::Widget->join(['&nbsp;'])->put(
	cell_width => 20,
    );

    # Create list of links
    my($links) = [];
    foreach my $t ('Home:HTTP_DOCUMENT',
	    'Safe & Private:GENERAL_PRIVACY',
	    'Contact:GENERAL_CONTACT') {
	my($label, $task) = split(/:/, $t);
	push(@$links, Bivio::UI::HTML::Widget->link(
		$label, $task, 'footer_menu'),
		$spacer);
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
		' ',
	    ],
	    [
		Bivio::UI::HTML::Widget->clear_dot(undef, 1)->put(
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
		Bivio::UI::HTML::Widget->director(
			['edit_preferences_rendered'],
			{
			    0 => 0,
			    1 => Bivio::UI::HTML::Widget->clear_dot(undef, 1),
			})->put(
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
		$proto->get_standard_copyright->put(
		    cell_align => 'right',
		    cell_expand => 1,
		),
	    ],
	],
    });
}

=for html <a name="get_standard_head"></a>

=head2 static get_standard_head() : Bivio::UI::HTML::Widget

Returns a Title widget which can be passed to
I<head> attribute of
L<Bivio::UI::HTML::Widget::Page|Bivio::UI::HTML::Widget::Page>.

Requires Request attributes: I<page_subtopic>, I<page_topic>,
I<auth_realm>.

Requires Bivio::UI::HTML::Widget::Page attributes: I<site_name>

=cut

sub get_standard_head {
    Bivio::UI::HTML::Widget->load_class('Title');
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

=head2 static get_standard_header() : Bivio::UI::HTML::Widget

Returns a widget which renders a logo, an ImageMenu, RealmChooser,
etc.  The standard bivio setup.  We'll modify this as we go.

=cut

sub get_standard_header {
    my($proto) = @_;
    # The header is different for each realm type
    Bivio::UI::HTML::Widget->load_class(qw(RealmChooser Grid));
    my($realm_info) = Bivio::UI::HTML::Widget::RealmChooser->new({
	pad_left => ['Bivio::UI::Icon', '->get_width', 'grad_y'],
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
		$proto->get_logo()->put(
			cell_rowspan => 5,
			cell_align => 'sw',
			cell_width_as_html => [
			    __PACKAGE__, '->get_value',
			    'logo_icon_width_as_html'],
		       ),
		$realm_info,
	    ],
	    [
		Bivio::UI::HTML::Widget->clear_dot(5, 1)->put(
		    cell_nowrap => 1,
		    cell_align => 'right',
		    cell_colspan => 2,
		),
	    ],
	    [
		Bivio::UI::HTML::Widget->image('grad_g', '')->put(
			cell_bgcolor => 'stripe_above_menu',
		       ),
		Bivio::UI::HTML::Widget->join([
		    Bivio::UI::HTML::Widget->link(
			    Bivio::UI::HTML::Widget->image(
				    'help_off',
				    'Get help using bivio',
				   ),
			    ['->format_help_uri'],
			   ),
		    Bivio::UI::HTML::Widget->director(
			    ['auth_user'],
			    {},
			    Bivio::UI::HTML::Widget->link(
				Bivio::UI::HTML::Widget->image(
				    'logout_off',
				    'Sign off from bivio',
				       ),
				'LOGOUT'
			       ),
			    Bivio::UI::HTML::Widget->link(
				Bivio::UI::HTML::Widget->image(
				    'login_square_off',
				    'Sign on to bivio',
				       ),
				    'LOGIN'
				   ),
			   ),
		])->put(
			cell_bgcolor => 'stripe_above_menu',
			cell_align => 'right',
		       ),
	    ],
	    [
		Bivio::UI::HTML::Widget->image('grad_1px', '')->put(
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
    return Bivio::UI::HTML::Widget->join('<a name="top"></a>',
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

=head2 static get_standard_logo() : Bivio::UI::HTML::Widget

Returns the Logo widget which fits in with everything else.

=cut

sub get_standard_logo {
    my($proto) = @_;
    return Bivio::UI::HTML::Widget->director(
	    ['super_user_id'],
	    {},
	    Bivio::UI::HTML::Widget->string(['auth_user', 'name'],
		    'substitute_user'),
	    Bivio::UI::HTML::Widget->link(
		    Bivio::UI::HTML::Widget->image(
			    [__PACKAGE__, '->get_value', 'logo_icon'],
			    [__PACKAGE__, '->get_value', 'home_alt_text'],
			   ),
		    '/'),
	   );
}

=for html <a name="get_standard_page"></a>

=head2 static get_standard_page() : Bivio::UI::HTML::Widget::Page

Returns a Page widget combined of a L<get_standard_head|"get_standard_head">
and L<get_standard_body|"get_standard_body">.

=cut

sub get_standard_page {
    my($proto) = @_;
    Bivio::UI::HTML::Widget->load_class('Page');
    return Bivio::UI::HTML::Widget::Page->new({
	head => $proto->get_standard_head(),
	body => $proto->get_standard_body(),
	style => $proto->get_standard_style(),
    });
}

=for html <a name="get_standard_style"></a>

=head2 static get_standard_style() : Bivio::UI::HTML::Widget

Returns the standard widget for style.

=cut

sub get_standard_style {
    Bivio::UI::HTML::Widget->load_class('Style');
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
    	    header_height logo_icon site_name home_alt_text)) {
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

    # This one is used dynamically by ImageMenu in header_widget
    # widget.  It is not a required field.  Only if you are using
    # ImageMenu.
    my($icon) = $self->get_facade->get('Bivio::UI::Icon');
    $self->group(text_menu_base_offset => 
	    $icon->get_width($self->get_value('logo_icon'))
	    + $icon->get_width('grad_y'));

    $self->group(image_menu_left_cell => 
	    Bivio::UI::HTML::Widget->image('grad_y', ''));;

    $self->group(image_menu_separator_width => 1);
    $self->group(text_menu_left_cell => undef);

    # Used by standard header
    $self->group(logo_icon_width_as_html =>
	    $self->get_facade->get('Bivio::UI::Icon')
	    ->get_width_as_html($self->get_value('logo_icon')));
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
	if (ref($v) eq 'CODE') {
	    $v = &$v($self);
	}

	# If result of sub is widget or config is widget, call initialize.
	if (UNIVERSAL::isa($v, 'Bivio::UI::HTML::Widget')) {
	    $v->initialize;
	}
    }
    $value->{value} = $v;
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
			' not a Bivio::UI::HTML::Widget, on line ', $line_num)
			    unless UNIVERSAL::isa($w,
				    'Bivio::UI::HTML::Widget');
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
    return Bivio::UI::HTML::Widget->join(\@new);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
