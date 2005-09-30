# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AdmMailBulletin;
use strict;
$Bivio::Biz::Action::AdmMailBulletin::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::AdmMailBulletin::VERSION;

=head1 NAME

Bivio::Biz::Action::AdmMailBulletin - sends the bulletin

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::AdmMailBulletin;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::AdmMailBulletin::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::AdmMailBulletin>

=cut

=head1 CONSTANTS

=cut

=for html <a name="BULLETIN_ID_KEY"></a>

=head2 BULLETIN_ID_KEY : string

Returns the request key for the bulletin ID.

=cut

sub BULLETIN_ID_KEY {
    return __PACKAGE__ . 'bulletin_id';
}

=for html <a name="TEST_MODE"></a>

=head2 TEST_MODE : string

Returns the request key for the test mode.

=cut

sub TEST_MODE {
    return __PACKAGE__ . 'test_mode';
}

#=IMPORTS
use Bivio::Biz::Model;
use Bivio::IO::File;
use Bivio::IO::Trace;
use Bivio::MIME::Type;
use Bivio::Mail::Outgoing;
use Bivio::Type::Email;
use Bivio::UI::Text;
use Sys::Hostname ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req)

Mails the bulletin to email addresses defined by subclass.
Only sends to local addresses in dev mode.

=cut

sub execute {
    my($proto, $req) = @_;
    my($bulletin) = Bivio::Biz::Model->new($req, 'Bulletin')->load({
        bulletin_id => $req->get(BULLETIN_ID_KEY()),
    });

    if ($req->get(TEST_MODE())) {
        _send_bulletin($proto, $bulletin,
            Bivio::UI::Text->get_value('support_email', $req));
        $bulletin->cascade_delete;
        return;
    }
    my($host) = Sys::Hostname::hostname();

    foreach my $email (@{$proto->internal_get_recipients($req)}) {
        next unless Bivio::Type::Email->is_valid($email)
            && ! Bivio::Type::Email->is_ignore($email);

        # avoid accidentally sending to real email address in dev mode
        next unless $req->get('is_production')
            || $email =~ /\@localhost/
            || $email =~ /\@\Q$host/;

        _send_bulletin($proto, $bulletin, $email);
    }
    return;
}

=for html <a name="get_body"></a>

=head2 static get_body(Bivio::Biz::Model bulletin, string email) : string_ref

Returns the text/plain or text/html message body. Subclasses may override
this method to provide dynamic content.

=cut

sub get_body {
    my($proto, $bulletin, $email) = @_;
    my($content) = $bulletin->get('body');
    return \$content;
}

=for html <a name="internal_get_recipients"></a>

=head2 abstract static internal_get_recipients(Bivio::Agent::Request req) : array_ref

Returns an array of email addresses to receive the bulletin.
Invalid and ignore email addresses will be filtered out.

=cut

$_ = <<'}'; # emacs
sub internal_get_recipients {
}

#=PRIVATE SUBROUTINES

# _add_attachments(proto, Bivio::Mail::Outgoing msg, Bivio::Biz::Model bulletin)
#
# Adds any attachments to the message, from the REALM_DATA location.
#
sub _add_attachments {
    my($proto, $msg, $bulletin) = @_;

    my($list) = Bivio::Biz::Model->new($bulletin->get_request,
        'AdmBulletinAttachmentList')->load_all;
    while ($list->next_row) {
        $msg->attach(Bivio::IO::File->read($list->get('filename')),
            Bivio::MIME::Type->from_extension($list->get('filename')),
           $list->get('name'));
    }
    return;
}

# _send_bulletin(proto, Bivio::Biz::Model bulletin, string email)
#
# Sends the bulletin to the specified email address.
#
sub _send_bulletin {
    my($proto, $bulletin, $email) = @_;
    _trace($email) if $_TRACE;
    my($req) = $bulletin->get_request;
    my($site_name) = Bivio::UI::Text->get_value('site_name', $req);
    my($support_email) = Bivio::UI::Text->get_value('support_email', $req);
    my($msg) = Bivio::Mail::Outgoing->new();
    $msg->set_recipients($email);
    $msg->set_envelope_from($support_email);
    $msg->set_header('From', qq!"$site_name" <$support_email>!);
    $msg->set_header('To', $email);
    $msg->set_header('Subject', $bulletin->get('subject'));
    my($body) = $proto->get_body($bulletin, $email);

    if ($bulletin->has_attachments) {
        $msg->set_content_type('multipart/mixed');
        $msg->attach($body, $bulletin->get('body_content_type'));
        _add_attachments($proto, $msg, $bulletin);
    }
    else {
        $msg->set_content_type($bulletin->get('body_content_type'));
        $msg->set_body($body);
    }
    $msg->enqueue_send($req);
    return;
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
