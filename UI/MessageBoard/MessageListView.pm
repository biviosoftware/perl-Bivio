# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::MessageBoard::MessageListView;
use strict;
$Bivio::UI::MessageBoard::MessageListView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::MessageBoard::MessageListView - a list of messages

=head1 SYNOPSIS

    use Bivio::UI::MessageBoard::MessageListView;
    Bivio::UI::MessageBoard::MessageListView->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::ListView>

=cut

use Bivio::UI::HTML::ListView;
@Bivio::UI::MessageBoard::MessageListView::ISA = qw(Bivio::UI::HTML::ListView);

=head1 DESCRIPTION

C<Bivio::UI::MessageBoard::MessageListView>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Mail::MessageList;
use Bivio::IO::Trace;
use Bivio::UI::HTML::Link;
use Bivio::UI::HTML::ListCellRenderer;
use Bivio::UI::HTML::ModelRefRenderer;
use Bivio::UI::HTML::Presentation;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_UP_LINK) = Bivio::UI::HTML::Link->new(
	Bivio::UI::HTML::Presentation::NAV_UP(),
	'', '', '', '');
my($_DOWN_LINK) = Bivio::UI::HTML::Link->new(
	Bivio::UI::HTML::Presentation::NAV_DOWN(),
	'', '', '', '');
my($_NAV_LINKS) = [$_UP_LINK, $_DOWN_LINK];

my($_COMPOSE_LINK) = Bivio::UI::HTML::Link->new('compose',
	'"/i/compose.gif" border=0',
	'mailto:bogus@localhost', 'Compose',
	'Compose a new message to the club');
my($_ACTION_LINKS) = [$_COMPOSE_LINK];

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::MessageBoard::MessageListView

Creates a MessageListView.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::HTML::ListView::new($proto, 'list');
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_action_links"></a>

=head2 get_action_links(Model model, Request req)

Returns the compose action link.

=cut

sub get_action_links {
    return $_ACTION_LINKS;
}

=for html <a name="get_default_model"></a>

=head2 get_default_model() : Model

Returns the default model ready for rendering.

=cut

sub get_default_model {
    #NOTE: could cache this
    return Bivio::Biz::Mail::MessageList->new();
}

=for html <a name="get_default_renderer"></a>

=head2 get_default_renderer(FieldDescriptor type) : ListCellRenderer

Returns a default renderer for the specified field type.

=cut

sub get_default_renderer {
    my($self, $type) = @_;

    if ($type->get_type() == Bivio::Biz::FieldDescriptor::MODEL_REF()) {

	return Bivio::UI::HTML::ListCellRenderer->new(
		Bivio::UI::HTML::ModelRefRenderer->new('detail'));
    }

    # let super class handle it
    return &Bivio::UI::HTML::ListView::get_default_renderer($self, $type);
}

=for html <a name="get_nav_links"></a>

=head2 get_nav_links(Model model, Request req) : array

Returns the up and down nav links.

=cut

sub get_nav_links {
    my($self, $model, $req) = @_;

    #TODO: get this from user preferences
    my($page_size) = 15;

    my($size) = $model->get_result_set_size();
    my($index) = $model->get_index();
    $index = 0 if $index >= $size;

    my($next_items);
    if ($index + $page_size > $size) {
	$next_items = 0;
    }
    elsif ($index + 2 * $page_size > $size) {
	$next_items = $size - $index - $page_size;
    }
    else {
	$next_items = $page_size;
    }

    if ($next_items > 0) {
	$_DOWN_LINK->set_icon(Bivio::UI::HTML::Link::SCROLL_DOWN_ICON());
	$_DOWN_LINK->set_description("Next $next_items messages");
	$_DOWN_LINK->set_url(&_make_path($self, $req)
		.&_index($index + $page_size, $req));
    }
    else {
	$_DOWN_LINK->set_icon(Bivio::UI::HTML::Link::SCROLL_DOWN_IA_ICON());
	$_DOWN_LINK->set_description("No more messages");
	$_DOWN_LINK->set_url('');
    }

    my($prev_items);
    if ($index == 0 ){
	$prev_items = 0;
    }
    elsif ($index < $page_size) {
	$prev_items = $index;
    }
    else {
	$prev_items = $page_size;
    }

    if ($prev_items > 0) {
	$_UP_LINK->set_icon(Bivio::UI::HTML::Link::SCROLL_UP_ICON());
	$_UP_LINK->set_description("Previous $prev_items messages");
	$_UP_LINK->set_url(&_make_path($self, $req)
		.&_index($index - $prev_items, $req));
    }
    else {
	$_UP_LINK->set_icon(Bivio::UI::HTML::Link::SCROLL_UP_IA_ICON());
	$_UP_LINK->set_description("No previous messages");
	$_UP_LINK->set_url('');
    }

    return $_NAV_LINKS;
}

#=PRIVATE METHODS

# _index(int index, Request req) : string
#
# Returns the finder params with the specified index.

sub _index {
    my($index, $req) = @_;

    my($fp) = $req->get_model_args()->clone();
    $fp->put('index', $index);
    return '?'.$fp->to_string();
}

# _make_path(View view, Request req) : string
#
# Creates a path string to the specified view using the current club,
# and controller from the request.

sub _make_path {
    my($view, $req) = @_;

    return '/'.$req->get_target_name().'/'.$req->get_controller_name()
	    .'/'.$view->get_name();
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
