# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::MessageBoard::DetailView;
use strict;
$Bivio::UI::MessageBoard::DetailView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::MessageBoard::DetailView - a message detail view

=head1 SYNOPSIS

    use Bivio::UI::MessageBoard::DetailView;
    my($list) = Bivio::Biz::Mail::MessageList->new();
    $list->find(Bivio::Biz::FindParams->new({club => 100, id => 20});
    my($view) = Bivio::UI::MessageBoard::DetailView->new();
    $view->render($list, $req);

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::MessageBoard::DetailView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::MessageBoard::DetailView> shows the body of a message with links
to next and previous messages. It uses a MessageList model because it needs
to know the next/prev links and provide a way back to the original list.

=cut

#=IMPORTS
use Apache::Util();
use Bivio::Biz::Mail::MessageList;
use Bivio::IO::Trace;
use Bivio::UI::HTML::Presentation;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_BACK_LINK) = Bivio::UI::HTML::Link->new(
	Bivio::UI::HTML::Presentation::NAV_BACK(),
	Bivio::UI::HTML::Link::BACK_ICON(),
	'', '', 'Back to the message list');
my($_PREV_LINK) = Bivio::UI::HTML::Link->new(
	Bivio::UI::HTML::Presentation::NAV_LEFT(),
	'', '', '', '');
my($_NEXT_LINK) = Bivio::UI::HTML::Link->new(
	Bivio::UI::HTML::Presentation::NAV_RIGHT(),
	'', '', '', '');
my($_NAV_LINKS) = [$_BACK_LINK, $_PREV_LINK, $_NEXT_LINK];
my($_COMPOSE_LINK) = Bivio::UI::HTML::Link->new('compose',
	'"/i/compose.gif" border=0',
	'mailto:bogus@localhost', 'Compose',
	'Compose a new message to the club');
my($_REPLY_LINK) = Bivio::UI::HTML::Link->new('reply',
	'"/i/reply.gif" border=0',
	'', 'Reply',
	'Reply to this message to the club');
my($_ACTION_LINKS) = [$_COMPOSE_LINK, $_REPLY_LINK];

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::MessageBoard::DetailView

Creates a new message detail view.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::HTML::ListView::new($proto, 'detail');
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_action_links"></a>

=head2 get_action_links(Model model, Request req)

Returns the compose action link. This is part of the
L<Bivio::UI::HTML::LinkSupport> interface and is used by the parent
presentation when rendering.

=cut

sub get_action_links {
    my($self, $list, $req) = @_;

    # set the mailto subject on the reply
    my($message) = $list->get_selected_message();
    if ($message) {
	my($url) = 'mailto:'.$message->get('from_email').'?subject=';
	my($subject) = $message->get('subject');

	if ($subject =~ /^Re:/i) {
	}
	else {
	    $subject = 'Re: '.$subject;
	}
	$subject = Apache::Util::escape_uri($subject);

	$_REPLY_LINK->set_url($url.$subject);
    }
    else {
	$_REPLY_LINK->set_url('');
    }
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

=for html <a name="get_nav_links"></a>

=head2 get_nav_links(Model model, Request req) : array

Returns the prev and next nav links. This is part of the
L<Bivio::UI::HTML::LinkSupport> interface and is used by the parent
presentation when rendering.

=cut

sub get_nav_links {
    my($self, $model, $req) = @_;

    my($prev) = $model->get_prev_message_id();
    if ($prev) {
	$_PREV_LINK->set_icon(Bivio::UI::HTML::Link::PREV_ICON());
	$_PREV_LINK->set_description('Previous message');
	$_PREV_LINK->set_url($req->make_path().'?'.$prev);
    }
    else {
	$_PREV_LINK->set_icon(Bivio::UI::HTML::Link::PREV_IA_ICON());
	$_PREV_LINK->set_description('No previous message');
	$_PREV_LINK->set_url('');
    }

    my($next) = $model->get_next_message_id();
    if ($next) {
	$_NEXT_LINK->set_icon(Bivio::UI::HTML::Link::NEXT_ICON());
	$_NEXT_LINK->set_description('Next message');
	$_NEXT_LINK->set_url($req->make_path().'?'.$next);
    }
    else {
	$_NEXT_LINK->set_icon(Bivio::UI::HTML::Link::NEXT_IA_ICON());
	$_NEXT_LINK->set_description('No more messages');
	$_NEXT_LINK->set_url('');
    }

    #TODO: don't show back if invalid index specified, fix 0,1 bug

    my($fp) = $req->get_model_args()->clone();
    $fp->remove('id');
    $fp->put('index', $fp->get('index') + 1) if $fp->get('index');
    $fp->remove('club');

    my($back_url) = $req->make_path('list').'?'.$fp->to_string();

    $_BACK_LINK->set_url($back_url);

    return $_NAV_LINKS;
}

=for html <a name="render"></a>

=head2 render(MessageList list, Request req)

Draws the selected message body.

=cut

sub render {
    my($self, $list, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    #TODO: need to render from_name, date etc.

    my($message) = $list->get_selected_message();
    if ($message) {
	$req->print('<pre>'.${$message->get_body()}.'</pre>');
    }
    else {
	$req->print('<font color="red">Could not find message.</font>');
    }
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
