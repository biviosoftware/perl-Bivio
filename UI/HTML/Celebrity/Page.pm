# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Celebrity::Page;
use strict;
$Bivio::UI::HTML::Celebrity::Page::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Celebrity::Page - renders the html for Celebrity areas

=head1 SYNOPSIS

    use Bivio::UI::HTML::Celebrity::Page;
    $req->put(page_content => $my_widget);
    Bivio::UI::HTML::Celebrity::Page->execute($req);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Page>

=cut

use Bivio::UI::HTML::Page;
@Bivio::UI::HTML::Celebrity::Page::ISA = ('Bivio::UI::HTML::Page');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Celebrity::Page> configures and executes Celebrity pages.
A celebrity page has a picture with some additional information.

=cut

=head1 CONSTANTS

=cut

use Bivio::Auth::RealmType;

=for html <a name="REALM_TYPE"></a>

=head2 REALM_TYPE : Bivio::Auth::RealmType

Returns this pages realm type.

=cut

sub REALM_TYPE {
    return Bivio::Auth::RealmType::GENERAL();
}

#=IMPORTS
use Bivio::UI::HTML::Widget::ToolBar;
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::ClearDot;
use Bivio::UI::HTML::Widget::Image;

#=VARIABLES
# Maps realm owner names to instances of this class
my($_NAV_BAR_MAP);
my($_MAP);
_initialize();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string realm_owner, string title, hash_ref icon, string text) : Bivio::UI::HTML::Celebrity::Page

Creates the static instance of a celebrity page.  Caller
must supply the I<title>, I<icon>, and I<text>
that appears in the "about" box.
If I<text> is an array_ref, will be converted to a Join.

=cut

sub new {
    my($proto, $realm_owner, $title,  $icon, $text) = @_;
    Carp::croak($realm_owner, ': duplicate celebrity realm')
		if $_MAP->{$realm_owner};
    # Convert text to a widget if necessary.  If it is just a string,
    # will render properly in the String widget.
    $text = Bivio::UI::HTML::Widget::Join->new({values => $text})
		if ref($text) eq 'ARRAY';

    # Look up the icon
    my($picture) = Bivio::UI::Icon->get_widget_value($icon->{name});
    $picture->{width} = $icon->{width} if $icon->{width};
    $picture->{height} = $icon->{height} if $icon->{height};

    # Render the frame that contains the content.
    my($frame) = Bivio::UI::HTML::Widget::Grid->new({
	values => [[
	    Bivio::UI::HTML::Widget::Grid->new({
		cell_align => 'nw',
		space => 5,
		cell_expand => 1,
		expand => 1,
		values => [
		    [
			Bivio::UI::HTML::Widget::String->new({
			    value => ['celebrity_page_heading'],
			    string_font => 'page_heading',
			}),
		    ],
		    [
			['page_tool_bar'],
		    ],
		    [
			['page_content'],
		    ],
		],
	    }),
	    Bivio::UI::HTML::Widget::ClearDot->new({
		width => 10,
		height => 1,
	    }),
	    Bivio::UI::HTML::Widget::Grid->new({
		cell_width => $picture->{width},
		cell_align => 'ne',
		bgcolor => 'celebrity_box',
		pad => 1,
		values => [
		    [
			Bivio::UI::HTML::Widget::String->new({
			    value => $title,
			    string_font => 'celebrity_box_title',
			    cell_align => 'center',
			}),
		    ],
		    [
			Bivio::UI::HTML::Widget::Image->new({
			    src => $picture,
			    alt => $title,
			}),
		    ],
		    [
			Bivio::UI::HTML::Widget::Grid->new({
			    cell_align => 'n',
			    pad => 5,
			    bgcolor => 'celebrity_box_text_bg',
			    values => [[
				Bivio::UI::HTML::Widget::String->new({
				    string_font => 'celebrity_box_text',
				    value => $text,
				}),
			    ]],
			}),
		    ],
		],
	    }),
	]],
    });
    return $_MAP->{$realm_owner} = Bivio::UI::HTML::Page::new($proto, $frame);
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req)

Looks up celebrity's realm name in page map.

=cut

sub execute {
    my($proto, $req) = @_;
    my($owner_name) = $req->get('auth_realm')->get('owner_name');
    # Not NOT_FOUND, because the realm should be configured
    # if it got here.
    Bivio::IO::Alert->die($owner_name, ': unknown celebrity realm')
		unless defined($_MAP->{$owner_name});
    my($page_type) = $req->unsafe_get('page_type')
	    || Bivio::UI::PageType::NONE();
    my($page_heading) = $req->unsafe_get('page_heading');
    $req->put(
	    celebrity_page_heading => $page_heading,
	    page_heading => '',
	    page_type => $page_type,
	    tool_bar_nav => $_NAV_BAR_MAP->{$page_type});
    $_MAP->{$owner_name}->SUPER::execute($req);
    return;
}

=for html <a name="internal_menu_cfg"></a>

=head2 internal_menu_cfg() : array_ref

Returns menu configuration

=cut

sub internal_menu_cfg {
    return undef;
}

=for html <a name="internal_task_to_topic"></a>

=head2 internal_task_to_topic() : hash_ref

Returns task to topic map

=cut

sub internal_task_to_topic {
    return undef;
}

#=PRIVATE METHODS

# _initialize()
#
# Creates the celebrity pages.
#
sub _initialize {
    return if $_MAP;
    $_MAP = {};
    _initialize_nav_bar_map();
    #
    # Syntax:
    # proxy_name
    # box title
    # box icon
    # box text
    __PACKAGE__->new(
	    'ask_candis',
	    'Candis King',
	    {
#TODO: Program to get size of jpgs
		name => 'candis_king.jpg',
		width => 150,
		height => 189,
	    },
	    [<<'EOF'],
Feel free to ask Candis King your nuts-and-bolts questions about bivio,
investing, and the investment club experience.
<p>
Well known in club circles, Candis has traveled the US teaching investment
classes, and is a frequent writer for publications ranging from the
Motley Fool to the Armchair Millionaire.
<p>
A telecom industry veteran, the mother of two says her only regret in life
is not having joined a club sooner.  Though enthusiastic about her clubs,
she's willing to take the bad with the good.  "We've committed just about
every investment mistake there is," she says, "but we've learned from them,
and so our experience has been overwhelmingly positive."
EOF
	   );
    __PACKAGE__->new(
	    'trez_talk',
	    'Jerry & Rip',
	    {
#TODO: Program to get size of jpgs
		name => 'jerry_rip.jpg',
		width => 170,
		height => 109,
	    },
	    [<<'EOF'],
Jerry Dressel and Rip West are America's leading experts in
investment club accounting.  When they talk, E.F. Hutton listens.
<p>
Fire your questions at Trez Talk and you'll get more than
your money's worth!
EOF
	   );
    return;
}

#TODO: Move back to Page
# _initialize_nav_bar_map() : Bivio::UI::HTML::Widget
#
# Returns the nav bar buttons.
#
sub _initialize_nav_bar_map {
    # Already initialized?
    return if $_NAV_BAR_MAP;

    my($spacer) = Bivio::UI::HTML::Widget::ClearDot->as_html(4, 1);
    $_NAV_BAR_MAP = {
	Bivio::UI::PageType::NONE() => undef,
	Bivio::UI::PageType::REPORT() => undef,
	Bivio::UI::PageType::LIST() => Bivio::UI::HTML::Widget::Join->new({
	    pad => 2,
	    values => [
		# Page Up
		Bivio::UI::HTML::Widget::Director->new({
		    control => ['list_model', '->has_prev'],
		    values => {
			0 => Bivio::UI::HTML::Widget::Image->new({
			    src => ['Bivio::UI::Icon', 'scroll_up_w_ia'],
			    alt => 'No previous page',
			}),
			1 => Bivio::UI::HTML::Widget::Link->new({
			    href => ['list_model',
				'->format_uri_for_prev_page'],
			    value => Bivio::UI::HTML::Widget::Image->new({
				src => ['Bivio::UI::Icon', 'scroll_up_w_off'],
				alt => 'Previous page',
			    }),
			}),
		    },
		}),
		$spacer,
		# Page Down
		Bivio::UI::HTML::Widget::Director->new({
		    control => ['list_model', '->has_next'],
		    values => {
			0 => Bivio::UI::HTML::Widget::Image->new({
			    src => ['Bivio::UI::Icon', 'scroll_down_w_ia'],
			    alt => 'No next page',
			}),
			1 => Bivio::UI::HTML::Widget::Link->new({
			    href => ['list_model',
				'->format_uri_for_next_page'],
			    value => Bivio::UI::HTML::Widget::Image->new({
				src => ['Bivio::UI::Icon', 'scroll_down_w_off'],
				alt => 'Next page',
			    }),
			}),
		    },
		}),
	    ],
	}),
	Bivio::UI::PageType::DETAIL() => Bivio::UI::HTML::Widget::Join->new({
	    values => [
		# Back to list
		Bivio::UI::HTML::Widget::Link->new({
		    href => ['list_model', '->format_uri_for_this_page'],
		    value => Bivio::UI::HTML::Widget::Image->new({
			src => ['Bivio::UI::Icon', 'back_w_off'],
			alt => 'Back to list',
		    }),
		}),
		$spacer,
		# Previous
		Bivio::UI::HTML::Widget::Director->new({
		    control => ['list_model', '->has_prev'],
		    values => {
			0 => Bivio::UI::HTML::Widget::Image->new({
			    src => ['Bivio::UI::Icon', 'scroll_up_w_ia'],
			    alt => 'This is the first item in list',
			}),
			1 => Bivio::UI::HTML::Widget::Link->new({
			    href => ['list_model',
				'->format_uri_for_prev'],
			    value => Bivio::UI::HTML::Widget::Image->new({
				src => ['Bivio::UI::Icon', 'scroll_up_w_off'],
				alt => 'Previous in list',
			    }),
			}),
		    },
		}),
		$spacer,
		# Next
		Bivio::UI::HTML::Widget::Director->new({
		    control => ['list_model', '->has_next'],
		    values => {
			0 => Bivio::UI::HTML::Widget::Image->new({
			    src => ['Bivio::UI::Icon', 'scroll_down_w_ia'],
			    alt => 'This is the last item in list',
			}),
			1 => Bivio::UI::HTML::Widget::Link->new({
			    href => ['list_model',
				'->format_uri_for_next'],
			    value => Bivio::UI::HTML::Widget::Image->new({
				src => ['Bivio::UI::Icon', 'scroll_down_w_off'],
				alt => 'Next in list',
			    }),
			}),
		    },
		}),
	    ],
	}),
    };
    foreach my $w (values(%$_NAV_BAR_MAP)) {
	$w->initialize if $w;
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
