# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::MessageBoard::ListView;
use strict;
$Bivio::UI::MessageBoard::ListView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::MessageBoard::ListView - a list of messages

=head1 SYNOPSIS

    use Bivio::UI::MessageBoard::ListView;
    my($list) = Bivio::Biz::ListModel::MailMessage->new();
    $list->load('club' => 100);
    my($view) = Bivio::UI::MessageBoard::ListView->new();
    $view->render($list, $req);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::ListView>

=cut

use Bivio::UI::HTML::ListView;
@Bivio::UI::MessageBoard::ListView::ISA = qw(Bivio::UI::HTML::ListView);

=head1 DESCRIPTION

C<Bivio::UI::MessageBoard::ListView> renders the
L<Bivio::Biz::ListModel::MailMessage> model.

=cut

#=IMPORTS
use Bivio::Biz::ListModel::MailMessage;
use Bivio::IO::Trace;
use Bivio::UI::HTML::Link;
use Bivio::UI::HTML::ListCellRenderer;
use Bivio::UI::HTML::ModelRefRenderer;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_COMPOSE_LINK) = Bivio::UI::HTML::Link->new('compose',
	'"/i/compose.gif" border=0',
	'', 'Compose',
	'Compose a new message to the club');
my($_ACTION_LINKS) = [$_COMPOSE_LINK];
my($_QUERY_FIELDS) = [qw(mail_message_id index sort)];

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::MessageBoard::ListView

Creates a ListView.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::HTML::ListView::new($proto);
    # use a model ref renderer to the 'detail' view for the first col
    $self->set_column_renderer(0, Bivio::UI::HTML::ListCellRenderer->new(
		Bivio::UI::HTML::ModelRefRenderer->new(
			Bivio::Agent::TaskId->CLUB_MESSAGE_DETAIL)));
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
    my($self, $model, $req) = @_;
    # Make sure user is allowed to forward email to the club.
    $req->task_ok(Bivio::Agent::TaskId::CLUB_MAIL_FORWARD)
	    || return [];
    # set the url to the club's name
    $_COMPOSE_LINK->set_url($req->format_mailto());

    return $_ACTION_LINKS;
}

=for html <a name="execute"></a>

=head2 execute(Bivio::AgentRequest req)

=cut

sub execute {
    my($self, $req) = @_;
    $self->activate->render(
	    Bivio::Biz::ListModel::MailMessage->load_from_request($req), $req);
    return;
}

#TODO: Re-integrate this
#=for html <a name="get_title"></a>
#
#=head2 get_title() : string
#
#Returns a suitable title of the model.
#
#=cut
#
#sub get_title {
#    my($self) = @_;
#    my($fields) = $self->{$_PACKAGE};
#
#    # detail view of the selected message
#    if ($fields->{selected}) {
#	return $fields->{selected}->get('subject');
#    }
#
#    return 'No Messages' if $self->get_row_count() == 0;
#
#    # otherwise show the range of messages displayed
#    my($index) = $self->get_index();
#    return 'Messages '.($index + 1)
#	    .' - '.($index + $self->get_row_count())
#	    .' / '.$self->get_result_set_size();
#}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
