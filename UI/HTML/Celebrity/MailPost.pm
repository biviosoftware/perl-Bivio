# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Celebrity::MailPost;
use strict;
$Bivio::UI::HTML::Celebrity::MailPost::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Celebrity::MailPost - post a message

=head1 SYNOPSIS

    use Bivio::UI::HTML::Celebrity::MailPost;
    Bivio::UI::HTML::Celebrity::MailPost->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::Celebrity::MailPost::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Celebrity::MailPost> allows a user to post
a message to a club.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

=cut

sub create_content {
    my($self) = @_;
    $self->put(page_heading => 'Compose Mail Message');

    my($to_chooser) = Bivio::UI::HTML::Widget::Select->new({
        field => 'to',
        choices => ['Bivio::Biz::Model::MailToList'],
        list_id_field => 'id',
        list_display_field => 'name',
    });
    # Create a page for non-users (0) and one for users (1)
    my(%mode_map) = ();
    $mode_map{0} = $self->form('MailPostForm', [
    # ['field', 'label', 'description', 'example text', options]
	['to', 'MAIL_TO', undef, undef, {widget => $to_chooser}],
	['from', 'MAIL_FROM_NAME', undef, 'mary@aol.com', {size => 60}],
	['subject', 'MAIL_SUBJECT', undef, undef, {size => 60}],
	['text', 'MAIL_TEXT', undef, undef, {cols => 60, label_align => 'NE'}],
    ]);
    $mode_map{1} = $self->form('MailPostForm', [
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

    my($realm_owner) = $req->get('auth_realm')->get('owner');
    my($realm_name) =  $realm_owner->get('display_name');
    my($topic) = 'Compose Mail Message to ' .$realm_name;
    $self->put(page_topic => $topic);
    $self->put(page_heading => 'Foo');

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
