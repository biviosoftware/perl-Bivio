# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Setup::Page;
use strict;
$Bivio::UI::HTML::Setup::Page::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Setup::Page - renders the html page for club application

=head1 SYNOPSIS

    use Bivio::UI::HTML::Setup::Page;
    $req->put(page_content => $my_widget);
    Bivio::UI::HTML::Setup::Page->execute($req);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Setup::Page::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Setup::Page> implements the "frame" of the page
for clubs.  Here's a mockup:

 +------------+
 |            | header
 +------------+
 |            | error (if defined)
 +------------+
 |            | title
 +------------+
 |            | *page_content* | *page_actions*
 +------------+
 |            | footer
 +------------+

The C<page_content> and C<page_actions> are rendered via
L<Bivio::UI::HTML::Widget::Indirect|Bivio::UI::HTML::Widget::Indirect>.

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Request;
use Bivio::Agent::TaskId;
use Bivio::UI::HTML::Format::DateTime;
use Bivio::UI::HTML::Widget::ActionBar;
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Image;
use Bivio::UI::HTML::Widget::Indirect;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::Page;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::TextTabMenu;
use Bivio::UI::HTML::Widget::Title;
use Bivio::UI::Icon;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SELF);

=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::UI::HTML::Setup::Page

Returns the singleton for this page.

=cut

sub get_instance {
    $_SELF || &_initialize;
    return $_SELF;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req)

Renders this page including I<content> and writes the reply.
Requires that the content be passed as the 'page_content' arg of the
request.

=cut

sub execute {
    my($proto, $req) = @_;
    my($self) = $proto->get_instance;
    my($fields) = $self->{$_PACKAGE};
    $fields->{content}->put('value', $req->get('page_content'));
    my($buffer) = '';
    $req->put(page_topic => $req->get('task_id')->get_short_desc);
    $fields->{widget}->render($req, \$buffer);
    $req->get('reply')->print($buffer);
    return;
}

#=PRIVATE METHODS

# _initialize
#
# Creates $_SELF and initializes.
#
sub _initialize {
    return if $_SELF;
    $_SELF = Bivio::UI::HTML::Setup::Page->new();
    my($blank_cell) = Bivio::UI::HTML::Widget::Join->new({
	values => ['&nbsp;']});
    my($fields) = $_SELF->{$_PACKAGE} = {
	content => Bivio::UI::HTML::Widget::Indirect->new({
	    value => 0,
	    cell_expand => 1,
	}),
	blank_cell => $blank_cell,
    };
    # Initialize widgets which are not part of hierarchy, but
    # are added in on demand.
    my($v);
    foreach $v (@{$fields}{'blank_cell'}) {
	$v->initialize;
    }
    $fields->{widget} = Bivio::UI::HTML::Widget::Page->new({
	head => Bivio::UI::HTML::Widget::Title->new({
	    values => [
		['page_topic'],
	    ],
	}),
	body => Bivio::UI::HTML::Widget::Grid->new({
	    expand => 1,
	    values => [
		[
		    Bivio::UI::HTML::Widget::Link->new({
			href => '/test-site',
			value => Bivio::UI::HTML::Widget::Image->new({
			    src => ['Bivio::UI::Icon', 'bivio'],
			    alt => 'bivio home',
			}),
			cell_align => 'sw',
		    }),
		    Bivio::UI::HTML::Widget::String->new({
			value => 'Welcome to bivio',
			string_font => 'italic',
			cell_expand => 1,
			cell_align => 's',
		    }),
		    Bivio::UI::HTML::Widget::String->new({
			value => [start_time => 0,
				'Bivio::UI::HTML::Format::DateTime'],
			cell_align => 'se',
			string_font => 'time',
		    }),
		],
		[
		    $blank_cell,
		],
		[
		    Bivio::UI::HTML::Widget::Director->new({
			control => ['->unsafe_get', 'page_error'],
			values => {},
			cell_expand => 1,
			cell_align => 'center',
			undef_value => $blank_cell,
			default_value => Bivio::UI::HTML::Widget::String->new({
			    value => ['page_error'],
			    string_font => 'error',
			}),
		    }),
		],
		[
		    $blank_cell,
		],
		[
		    Bivio::UI::HTML::Widget::Grid->new({
			pad => 5,
			expand => 1,
			cell_expand => 1,
			values => [
			    [
				Bivio::UI::HTML::Widget::String->new({
				    cell_bgcolor => 'heading_bg',
				    cell_expand => 1,
				    cell_align => 'left',
				    value => ['page_heading'],
				    string_font => 'page_heading',
				}),
			    ],
			],
		    }),
		],
		[
		    $blank_cell,
		],
		[
		    $fields->{content},
		],
	    ],
	}),
    });
    $fields->{widget}->initialize;
    return;
}


=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
