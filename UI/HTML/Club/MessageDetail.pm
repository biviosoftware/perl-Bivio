# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::MessageDetail;
use strict;
$Bivio::UI::HTML::Club::MessageDetail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::MessageDetail - the message detail view.

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::MessageDetail;
    Bivio::UI::HTML::Club::MessageDetail->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::MessageDetail::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::MessageDetail> shows the body of a mail message.
It provides links to MIME parts (such as attached GIF, JPEG files).

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Model::MailMessage;
use Bivio::Biz::Model::MessageList;
use Bivio::DieCode;
use Bivio::UI::HTML::ActionButtons;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Format::DateTime;
use Bivio::UI::HTML::Widget::ActionBar;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Format::ReplySubject;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_FILE_CLIENT);


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::MessageDetail



=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields ->{mime_uri} = Bivio::UI::HTML::Widget::Indirect->new({
 	      value => 0,
	      cell_rowspan => 1,
	      cell_compact => 1,
	      cell_align => 'N',
 	    });
    $fields->{content} = Bivio::UI::HTML::Widget::Join->new({
	values => [
	    '<center>by ',
	    Bivio::UI::HTML::Widget::Link->new({
		href => ['->format_mailto',
		    ['Bivio::Biz::Model::MailMessage', 'from_email'],
		    ['reply_subject'],
		],
		value => Bivio::UI::HTML::Widget::String->new({
		    value => ['Bivio::Biz::Model::MailMessage', 'from_name'],
		}),
	    }),
	    ' on ',
	    ['Bivio::Biz::Model::MailMessage', 'dttm',
		'Bivio::UI::HTML::Format::DateTime'],
	    ' GMT</center><p>',
	    ['Bivio::Biz::Model::MailMessage', '->get_body'],
	    $fields->{mime_uri},
	],
    });
    $fields->{content}->initialize;
    $fields->{mime_uri}->initialize;
    $fields->{action_bar} = Bivio::UI::HTML::Widget::ActionBar->new({
	values => Bivio::UI::HTML::ActionButtons->get_list(
	    'club_compose_message', 'club_reply_message'),
    });
    $fields->{action_bar}->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute()

Executes the view.


=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($list) = $req->get('Bivio::Biz::Model::MessageList');
    $req->die(Bivio::DieCode::NOT_FOUND) if $list->get_result_set_size() < 1;
    $list->next_row;
    my($mail_message) = $list->get_model('MailMessage');
    my($subject) = $mail_message->get('subject');
    my @mimen = $mail_message->get_num_mime_parts();
    if( int(@mimen) != 0){
	my @urls;
	my $i = 1;
	foreach my $ext (@mimen){
	    push(@urls,
		    Bivio::UI::HTML::Widget::Link->new({
			href  => $req->format_uri(
				Bivio::Agent::TaskId::CLUB_COMMUNICATIONS_MESSAGE_ATTACHMENT(),
				"att=".$ext),
			value => Bivio::UI::HTML::Widget::String->new({
			    value => 'Attachment '.$i++}),
			}));
	    push(@urls, "<BR>");
	}
	my($mime_urls) = Bivio::UI::HTML::Widget::Join->new({
	values => \@urls});
	$mime_urls->initialize;
	$fields->{mime_uri}->put(value => $mime_urls);
    }

    my($reply_subject) =
	    Bivio::UI::HTML::Format::ReplySubject->get_widget_value($subject);
    $req->put(
	    page_subtopic => substr($subject, 0, 60),
	    page_heading => $subject,
	    page_content => $fields->{content},
	    page_action_bar => $fields->{action_bar},
	    page_type => Bivio::UI::PageType::DETAIL(),
	    list_model => $list,
	    list_uri => $req->format_uri(
		    Bivio::Agent::TaskId::CLUB_COMMUNICATIONS_MESSAGE_LIST(),
		    undef),
	    detail_uri => $req->format_uri(
		    Bivio::Agent::TaskId::CLUB_COMMUNICATIONS_MESSAGE_DETAIL(),
		    undef),
	    reply_subject => $reply_subject,
	    );
    Bivio::UI::HTML::Club::Page->execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
