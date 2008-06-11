# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AdmMailBulletin;
use strict;
use Bivio::Base 'Bivio::Biz::Action';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_M) = __PACKAGE__->use('Biz.Model');
my($_F) = __PACKAGE__->use('IO.File');
my($_T) = __PACKAGE__->use('MIME.Type');
my($_O) = __PACKAGE__->use('Mail.Outgoing');
my($_E) = __PACKAGE__->use('Type.Email');
my($_FCT) = __PACKAGE__->use('FacadeComponent.Text');

sub BULLETIN_ID_KEY {
    # : string
    # Returns the request key for the bulletin ID.
    return __PACKAGE__ . 'bulletin_id';
}

sub TEST_MODE {
    # : string
    # Returns the request key for the test mode.
    return __PACKAGE__ . 'test_mode';
}

sub execute {
    # (proto, Agent.Request) : undef
    # Mails the bulletin to email addresses defined by subclass.
    # Only sends to local addresses in dev mode.
    my($proto, $req) = @_;
    my($bulletin) = $_M->new($req, 'Bulletin')->load({
        bulletin_id => $req->get(BULLETIN_ID_KEY()),
    });

    if ($req->get(TEST_MODE())) {
        _send_bulletin($proto, $bulletin,
            $_FCT->get_value('support_email', $req));
        $bulletin->cascade_delete;
        return;
    }
    my($test_email);
    foreach my $email (@{$proto->internal_get_recipients($req)}) {
        next unless $_E->is_valid($email)
            && ! $_E->is_ignore($email);
        # avoid accidentally sending to real email address in dev mode
	if ($req->is_test) {
	    $test_email ||= ($proto->use('Bivio::Test::Language::HTTP')
		->generate_local_email('x') =~ /(\@.+)/)[0];
	    next unless $email =~ /\Q$test_email\E$/;
        }
        _send_bulletin($proto, $bulletin, $email);
    }
    return;
}

sub get_body {
    # (proto, Biz.Model, string) : string_ref
    # Returns the text/plain or text/html message body. Subclasses may override
    # this method to provide dynamic content.
    my($proto, $bulletin, $email) = @_;
    my($content) = $bulletin->get('body');
    return \$content;
}

sub _add_attachments {
    # (proto, Mail.Outgoing, Biz.Model) : undef
    # Adds any attachments to the message, from the REALM_DATA location.
    my($proto, $msg, $bulletin) = @_;

    my($list) = Bivio::Biz::Model->new($bulletin->get_request,
        'AdmBulletinAttachmentList')->load_all;
    while ($list->next_row) {
        $msg->attach($_F->read($list->get('filename')),
            $_T->from_extension($list->get('filename')),
           $list->get('name'));
    }
    return;
}

sub _send_bulletin {
    # (proto, Biz.Model, string) : undef
    # Sends the bulletin to the specified email address.
    my($proto, $bulletin, $email) = @_;
    _trace($email) if $_TRACE;
    my($req) = $bulletin->get_request;
    my($site_name) = $_FCT->get_value('site_name', $req);
    my($support_email) = $_FCT->get_value('support_email', $req);
    my($msg) = $_O->new();
    $msg->set_recipients($email, $req);
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

1;
