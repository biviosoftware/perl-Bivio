# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Celebrity::MailList;
use strict;
$Bivio::UI::HTML::Celebrity::MailList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Celebrity::MailList - the view of messages for a celebrity.

=head1 SYNOPSIS

    use Bivio::UI::HTML::Celebrity::MailList;
    Bivio::UI::HTML::Celebrity::MailList->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Celebrity::MailList::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Celebrity::MailList> is an HTML widget that displays
a message list.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::UI::HTML::Widget::ActionBar;
use Bivio::Biz::Model::MailList;
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

=head2 static new() : Bivio::UI::HTML::Celebrity::MailList

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{content} = $self->table('MailList',
	    [
		[
		    'Mail.subject', {
			column_heading => 'CELEBRITY_MAIL_SUBJECT',
			column_expand => 1,
			column_align => 'W',
			heading_align => 'SW',
			wf_list_link => 'THIS_DETAIL',
		    },
		],
		[
		    'Mail.date_time', {
			column_nowrap => 1,
		    },
		],
	    ],
	    {expand => 1},
	);
    $fields->{content}->initialize;
    $fields->{action_bar} = $self->action_bar('celebrity_post_message');
    $fields->{action_bar}->initialize;

    $fields->{heading} = $self->join(
	    'Messages from ',
	    $self->date_time(['message_list_start'], 'DATE'),
	    ' to ',
	    $self->date_time(['message_list_end'], 'DATE'),
	   );
    $fields->{heading}->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() : boolean


=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($list) = $req->get('Bivio::Biz::Model::MailList');
    my($length) = $list->get_result_set_size;
    my($heading) = '';
    if ($length > 0) {
	$list->set_cursor(0);
	$req->put(message_list_start => $list->get('Mail.date_time'));
	$list->set_cursor($length - 1);
	$req->put(message_list_end => $list->get('Mail.date_time'));
	$heading = $fields->{heading};
    }
    $req->put(
	    page_subtopic => undef,
	    page_heading => $heading,
	    page_content => $fields->{content},
	    page_action_bar => $fields->{action_bar},
	    page_type => Bivio::UI::PageType::LIST(),
#	    want_page_search => 1,
	    list_model => $list,
	    list_uri => $req->format_uri($req->get('task_id'), undef),
	    detail_uri => $req->format_uri(
		    Bivio::Agent::TaskId::CELEBRITY_MESSAGE_DETAIL(),
		    undef)
	   );
    return Bivio::UI::HTML::Celebrity::Page->execute($req);

}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
