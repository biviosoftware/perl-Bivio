# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Celebrity::MailReply;
use strict;
$Bivio::UI::HTML::Celebrity::MailReply::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Celebrity::MailReply - reply to a message

=head1 SYNOPSIS

    use Bivio::UI::HTML::Celebrity::MailReply;
    Bivio::UI::HTML::Celebrity::MailReply->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::Celebrity::MailReply::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Celebrity::MailReply> allows a user to reply to
a message to a club.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Create form

=cut

sub create_content {
    my($self) = @_;
    $self->put(page_topic => 'Reply To Mail Message',
            page_heading => 'Reply To Mail Message');

    my($to_chooser) = Bivio::UI::HTML::Widget::Select->new({
        field => 'to',
        choices => ['Bivio::Biz::Model::MailToList'],
        list_id_field => 'id',
        list_display_field => 'name',
    });
    # Create a page for non-users (0) and one for users (1)
    my(%mode_map) = ();
    $mode_map{0} = $self->form('MailReplyForm', [
        # ['field', 'label', 'description', 'example text', options]
	['from', 'MAIL_FROM_NAME', undef, undef, {size => 60}],
	['to', 'MAIL_TO', undef, undef, {widget => $to_chooser}],
	['subject', 'MAIL_SUBJECT', undef, undef, {size => 60}],
	['text', 'MAIL_TEXT', undef, undef, {cols => 60, label_align => 'NE'}],
    ]);
    $mode_map{1} = $self->form('MailReplyForm', [
        # ['field', 'label', 'description', 'example text', options]
	['to', 'MAIL_TO', undef, undef, {widget => $to_chooser}],
	['cc', 'MAIL_CC', undef, undef, {size => 60}],
	['subject', 'MAIL_SUBJECT', undef, undef, {size => 60}],
	['text', 'MAIL_TEXT', undef, undef, {cols => 60, label_align => 'NE'}],
	['att1', 'MAIL_ATT'],
	['att2', 'MAIL_ATT'],
	['att3', 'MAIL_ATT'],
    ]);
    return $self->director(['is_user'], \%mode_map);
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req) : 


=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($is_user) = defined($req->get('auth_user')) || 0;
    $req->put( is_user => $is_user );
    $self->SUPER::execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
