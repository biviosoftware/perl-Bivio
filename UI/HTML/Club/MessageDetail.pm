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
use Bivio::IO::Trace;
use Bivio::DieCode;
use Bivio::UI::HTML::Format::DateTime;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::MessageDetail



=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{content} = Bivio::UI::HTML::Widget::Grid->new({
	values => [
		[
		  Bivio::UI::HTML::Widget::String->new({
		      value => 'The mail message, here.',
		  }),
		],
	],
    });
    $fields->{content}->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() : 

Executes the view.


=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($req->get('query')) && defined($req->get('query')->{pk})) {
	my($mail_message_id) = $req->get('query')->{pk};
	my($mail_message) = Bivio::Biz::Model::MailMessage->new($req);
	$mail_message->load(mail_message_id => $mail_message_id);
	$fields->{message} = $mail_message;
	$req->put(page_subtopic => undef,
		page_heading => $mail_message->get('subject'),
		page_content => $self,
		name => $mail_message->get('subject'));
	Bivio::UI::HTML::Club::Page->execute($req);
	return;
    }
    $req->die(Bivio::DieCode::NOT_FOUND);
}

=for html <a name="render"></a>

=head2 render() : 

Renders the body of the email message. Just calls get_body on
the mail message and renders whatever the result is. MailMessage
get_body returns whatever is in the file server for that mail
message. It does not parse sub MIME parts.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($mail_message) = $fields->{message};
    my($body) = $mail_message->get_body();
    $$buffer .= '<center>';
    my($msg) = $source->get('Bivio::Biz::Model::MailMessage');
    $$buffer .= '<center>by '.
	    $msg->get('from_name')
		    .' on '
	    .Bivio::UI::HTML::Format::DateTime->get_widget_value(
		    $msg->get('dttm')).' GMT</center><p>';
    $$buffer .= $$body;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
