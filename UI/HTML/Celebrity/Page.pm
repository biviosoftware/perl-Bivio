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
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::ClearDot;
use Bivio::UI::HTML::Widget::Image;

#=VARIABLES
# Maps realm owner names to instances of this class
my($_MAP);
_initialize();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string realm_owner, string title, string icon, array_ref text, string disclaimer) : Bivio::UI::HTML::Celebrity::Page

Creates the static instance of a celebrity page.  Caller
must supply the I<title>, I<icon>, and I<text>
that appears in the "about" box.
If I<text> is an array_ref, will be converted to a Join.

=cut

sub new {
    my($proto, $realm_owner, $title,  $icon, $text, $disclaimer) = @_;
    Carp::croak($realm_owner, ': duplicate celebrity realm')
		if $_MAP->{$realm_owner};
    # Convert text to a widget if necessary.  If it is just a string,
    # will render properly in the String widget.
    $text = Bivio::UI::HTML::Widget::Join->new({values => $text})
		if ref($text) eq 'ARRAY';
    $disclaimer = Bivio::UI::HTML::Widget::String->new({
	cell_align => 'center',
	value => Bivio::UI::HTML::Widget::Join->new({
	    values => [$disclaimer],
	}),
	string_font => 'celebrity_disclaimer',
    });
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
			['celeb_page_action_bar'],
		    ],
		    [
			['page_content'],
		    ],
		    [
			['celeb_page_action_bar'],
		    ],
		    [
			' ',
		    ],
		    [
			Bivio::UI::HTML::Widget::Grid->new({
			    values => [[
				Bivio::UI::HTML::Widget::ClearDot->new({
				    height => 1,
				    width => 20,
				}),
				$disclaimer,
				Bivio::UI::HTML::Widget::ClearDot->new({
				    width => 20,
				    height => 1,
				}),
			    ]],
			}),
		    ],
		],
	    }),
	    Bivio::UI::HTML::Widget::ClearDot->new({
		width => 10,
		height => 1,
	    }),
	    Bivio::UI::HTML::Widget::Grid->new({
		cell_width => ['Bivio::UI::Icon', '->get_width', $icon],
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
			    src => $icon,
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

=head2 static execute(Bivio::Agent::Request req) : boolean

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
    my($action_bar) = $req->unsafe_get('page_action_bar');
    $req->put(
	    celebrity_page_heading => $page_heading,
	    page_heading => '',
	    page_action_bar => undef,
	    celeb_page_action_bar => $action_bar,
	    page_type => $page_type,
	   );
    return $_MAP->{$owner_name}->SUPER::execute($req);
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
    #
    # Syntax:
    # proxy_name
    # box title
    # box icon
    # box text
    # disclaimer
    __PACKAGE__->new(
	    'ask_candis',
	    'Candis King',
	    'candis_king',
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
	    <<'EOF',
Disclaimer: statements are opinions expressed by Candis King. These statements
are not intended to replace professional advice. When in doubt, follow the
advice of your local tax advisor or accountant who is familiar with your
particular circumstances.
EOF
	   );
    __PACKAGE__->new(
	    'trez_talk',
	    'Jerry & Rip',
	    name => 'jerry_rip',
	    [<<'EOF'],
Jerry Dressel and Rip West will answer your questions about club
accounting and taxes.
<p>
Investment club treasurers have been relying on them for years,
via the <a href="http://www.better-investing.org">NAIC</a> and
<a href="http://www.fool.com">Motley Fool</a> message boards.
Now you can find their sound advice right here at "Trez Talk"
on bivio.
<p>
Jerry is a pilot for Northwest Airlines who keeps himself busy teaching
accounting courses for fellow investors. Though Rip "has failed retirement
three times" he's had a lot more success as a financial planner, investment
advisor, and accountant, having launched his own CPA firm back in the 1950s.
Both have worked extensively with computers, and they have decades of
investment club experience between them.
EOF
	    <<'EOF',
Disclaimer: statements are opinions expressed by Rip West and Jerry Dressel
and are not official statements from either bivio or the IRS. These statements
are not intended to replace professional tax or accounting advice.
When in doubt, follow the advice of your local tax advisor or accountant
who is familiar with your particular circumstances.
EOF
	   );
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
