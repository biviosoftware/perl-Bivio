# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Celebrity::MessageDetail;
use strict;
$Bivio::UI::HTML::Celebrity::MessageDetail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Celebrity::MessageDetail - the view of messages for a celebrity.

=head1 SYNOPSIS

    use Bivio::UI::HTML::Celebrity::MessageDetail;
    Bivio::UI::HTML::Celebrity::MessageDetail->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Celebrity::MessageDetail::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Celebrity::MessageDetail> is an HTML widget that displays
a message list.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::UI::HTML::ActionButtons;
use Bivio::UI::HTML::Widget::ToolBar;
use Bivio::Biz::Model::MessageList;
use Bivio::UI::HTML::Celebrity::Page;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Table;
use Bivio::UI::HTML::Widget::DateTime;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Celebrity::MessageDetail

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    $fields->{content} = Bivio::UI::HTML::Widget::Join->new({
	values => [['Bivio::Biz::Model::MailMessage', '->get_body']],
    });
    $fields->{content}->initialize;

    $fields->{tool_bar} = Bivio::UI::HTML::Widget::ToolBar->new({
	values => Bivio::UI::HTML::ActionButtons->get_list(
		'celebrity_compose_message', 'celebrity_reply_message'),
    });
    $fields->{tool_bar}->initialize;

    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute()


=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($list) = $req->get('Bivio::Biz::Model::MessageList');
    $req->die(Bivio::DieCode::NOT_FOUND())
	    unless $list->set_cursor(0);
    my($mail_message) = $list->get_model('MailMessage');
    my($subject) = $mail_message->get('subject');
#TODO: Handle mime parts
    my($reply_subject) =
	    Bivio::UI::HTML::Format::ReplySubject->get_widget_value($subject);
    $req->put(
	    page_subtopic => substr($subject, 0, 60),
	    page_heading => $subject,
	    page_content => $fields->{content},
	    page_tool_bar => $fields->{tool_bar},
	    page_type => Bivio::UI::PageType::DETAIL(),
#	    want_page_search => 1,
	    list_model => $req->get('Bivio::Biz::Model::MessageList'),
	    list_uri => $req->format_uri(
		    Bivio::Agent::TaskId::CELEBRITY_MESSAGE_LIST(),
		    undef),
	    detail_uri => $req->format_uri($req->get('task_id'), undef),
	    reply_subject => $reply_subject,
	   );
    Bivio::UI::HTML::Celebrity::Page->execute($req);
    return;

}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
