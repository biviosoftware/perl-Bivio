# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::MessageBoard::DetailView;
use strict;
$Bivio::UI::MessageBoard::DetailView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::MessageBoard::DetailView - a message detail view

=head1 SYNOPSIS

    use Bivio::UI::MessageBoard::DetailView;
    my($list) = Bivio::Biz::ListModel::MailMessage->new();
    $list->load('club' => 100, 'id' => 20);
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
use Bivio::Agent::TaskId;
use Bivio::Biz::ListModel::MailMessage;
use Bivio::UI::HTML::Presentation;

#=VARIABLES
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
# my($_NAV_LINKS) = [$_BACK_LINK, $_PREV_LINK, $_NEXT_LINK];
my($_COMPOSE_LINK) = Bivio::UI::HTML::Link->new('compose',
	'"/i/compose.gif" border=0',
	'', 'Compose',
	'Compose a new message to the club');
my($_REPLY_LINK) = Bivio::UI::HTML::Link->new('reply',
	'"/i/reply.gif" border=0',
	'', 'Reply',
	'Reply to this message to the club');
my($_ACTION_LINKS) = [$_COMPOSE_LINK, $_REPLY_LINK];

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::AgentRequest req)

=cut

sub execute {
    my($self, $req) = @_;
    $self->activate->render(
	    Bivio::Biz::ListModel::MailMessage->load_from_request($req), $req);
    return;
}

=for html <a name="get_action_links"></a>

=head2 get_action_links(Model model, Request req)

Returns the compose action link. This is part of the
L<Bivio::UI::HTML::LinkSupport> interface and is used by the parent
presentation when rendering.

=cut

sub get_action_links {
    my($self, $list, $req) = @_;

    $req->task_ok(Bivio::Agent::TaskId::CLUB_MAIL_FORWARD)
	    || return [];
    # set the url to the club's name
    $_COMPOSE_LINK->set_url($req->format_mailto());

    # set the mailto subject on the reply
    my($message) = $list->get_selected_item();
    if ($message) {
	my($subject) = $message->get('subject');
	unless ($subject =~ /\bre:/i) {
	    $subject = 'Re: '. $subject;
	}
	$_REPLY_LINK->set_url($req->format_mailto(undef, $subject));
    }
    else {
#TODO: should this be undef?
	$_REPLY_LINK->set_url('');
    }
    return $_ACTION_LINKS;
}

=for html <a name="get_nav_links"></a>

=head2 get_nav_links(Model model, Request req) : array

Returns the prev and next nav links. This is part of the
L<Bivio::UI::HTML::LinkSupport> interface and is used by the parent
presentation when rendering.

=cut

sub get_nav_links {
    my($self, $model, $req) = @_;

    my(@links) = ();
    my($selected_index) = $model->get_selected_index();
    my($prev) = $selected_index != -1
	    ? $model->get_query_at($selected_index - 1)
		    : undef;
    if ($prev) {
	$_PREV_LINK->set_icon(Bivio::UI::HTML::Link::PREV_ICON());
	$_PREV_LINK->set_description('Previous message');
	$_PREV_LINK->set_url($req->format_uri(undef, $prev));
    }
    else {
	$_PREV_LINK->set_icon(Bivio::UI::HTML::Link::PREV_IA_ICON());
	$_PREV_LINK->set_description('No previous message');
	$_PREV_LINK->set_url('');
    }

    my($next) = $selected_index != -1
	    ? $model->get_query_at($selected_index + 1)
		    : undef;
    if ($next) {
	$_NEXT_LINK->set_icon(Bivio::UI::HTML::Link::NEXT_ICON());
	$_NEXT_LINK->set_description('Next message');
	$_NEXT_LINK->set_url($req->format_uri(undef, $next));
    }
    else {
	$_NEXT_LINK->set_icon(Bivio::UI::HTML::Link::NEXT_IA_ICON());
	$_NEXT_LINK->set_description('No more messages');
	$_NEXT_LINK->set_url('');
    }
    push(@links, $_PREV_LINK, $_NEXT_LINK);

#TODO: This is weird.  Basically, shouldn't need to do this, because
#      if you can see detail, can see whole list.  Worst case if we
#      don't have this is that we render an invalid link.
#    if ($req->task_ok(Bivio::Agent::TaskId::CLUB_MESSAGE_LIST)) {
#TODO: don't show back if invalid index specified, fix 0,1 bug
#TODO: Is a query always valid here?
	my($query) = {%{$req->get('query')}};
	delete($query->{mail_message_id});
# TODO: Shouldn't be here?
#    delete($query->{club_id});
	$query->{index}++ if defined($query->{index});

	my($back_url) = $req->format_uri(
		Bivio::Agent::TaskId::CLUB_MESSAGE_LIST, $query);

	$_BACK_LINK->set_url($back_url);
	push(@links, $_BACK_LINK);
#    }
    return \@links;
}

=for html <a name="render"></a>

=head2 render(MessageList list, Request req)

Draws the selected message body.

=cut

sub render {
    my($self, $list, $req) = @_;
    my($message) = $list->get_selected_item();
    if ($message) {
	my($from_person, $from_email) = $message->get('from_name', 'from_email');
	my($url) = $from_email ? "<a href=mailto:\"$from_email\">$from_person</a>" : $from_person;
	$req->get_reply->print('<H1>From: ' . $url . "</H1>");
	$req->get_reply->print('<pre>'.${$message->get_body}.'</pre>');
    }
    else {
	$req->get_reply->print(
		'<font color="red">Could not find message.</font>');
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
