# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Celebrity::MessageList;
use strict;
$Bivio::UI::HTML::Celebrity::MessageList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Celebrity::MessageList - the view of messages for a celebrity.

=head1 SYNOPSIS

    use Bivio::UI::HTML::Celebrity::MessageList;
    Bivio::UI::HTML::Celebrity::MessageList->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Celebrity::MessageList::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Celebrity::MessageList> is an HTML widget that displays
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

=head2 static new() : Bivio::UI::HTML::Celebrity::MessageList

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{content} = Bivio::UI::HTML::Widget::Table->new({
	source => ['Bivio::Biz::Model::MessageList'],
	expand => 1,
	headings => [
	    Bivio::UI::HTML::Widget::String->new({
		value => 'Topic',
		column_expand => 1,
		column_align => 'sw',
	    }),
	    'Date',
	],
	cells => [
	    Bivio::UI::HTML::Widget::Link->new({
		href => ['->format_uri_for_this'],
		value => Bivio::UI::HTML::Widget::String->new({
		    value => ['MailMessage.subject'],
	        }),
	    }),
            Bivio::UI::HTML::Widget::DateTime->new({
		value => ['MailMessage.date_time'],
		mode => 'DATE',
	    }),
	],
    });
    $fields->{content}->initialize;
    $fields->{tool_bar} = Bivio::UI::HTML::Widget::ToolBar->new({
	values => Bivio::UI::HTML::ActionButtons->get_list(
		'celebrity_compose_message'),
    });
    $fields->{tool_bar}->initialize;

    $fields->{heading} = Bivio::UI::HTML::Widget::Join->new({
	values => [
	    'Messages from ',
	    Bivio::UI::HTML::Widget::DateTime->new({
		value => ['message_list_start'],
		mode => 'DATE',
	    }),
	    ' to ',
	    Bivio::UI::HTML::Widget::DateTime->new({
		value => ['message_list_end'],
		mode => 'DATE',
	    }),
	],
    });
    $fields->{heading}->initialize;
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
    my($length) = $list->get_result_set_size;
    my($heading) = '';
    if ($length > 0) {
	$list->set_cursor(0);
	$req->put(message_list_start => $list->get('MailMessage.date_time'));
	$list->set_cursor($length - 1);
	$req->put(message_list_end => $list->get('MailMessage.date_time'));
	$heading = $fields->{heading};
    }
    $req->put(
	    page_subtopic => undef,
	    page_heading => $heading,
	    page_content => $fields->{content},
	    page_tool_bar => $fields->{tool_bar},
	    page_type => Bivio::UI::PageType::LIST(),
#	    want_page_search => 1,
	    list_model => $req->get('Bivio::Biz::Model::MessageList'),
	    list_uri => $req->format_uri($req->get('task_id'), undef),
	    detail_uri => $req->format_uri(
		    Bivio::Agent::TaskId::CELEBRITY_MESSAGE_DETAIL(),
		    undef)
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
