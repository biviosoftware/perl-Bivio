# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ForwardUserMail;
use strict;
$Bivio::Biz::Action::ForwardUserMail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::ForwardUserMail - forwards mail to user's real email

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::ForwardUserMail::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Action::ForwardUserMail> forwards email to the user's
email addresses.

=cut

#=IMPORTS
use Bivio::Biz::Model::MailMessage;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Request req)

Forwards the email to the owner of the auth_realm.

=cut

sub execute {
    my(undef, $req) = @_;

    # Load the user and get the msg
    my($user_id) = $req->get('auth_id');
    my($user) = Bivio::Biz::Model::User->new($req);
    $user->load(user_id => $user_id);

    my($msg) = $req->get('message');
    _trace($req->unsafe_get('auth_realm'), ': ', $msg->get_message_id)
	    if $_TRACE;

    my($headers) = $msg->get_headers;
    if (exists($headers->{'x-bivio-forwarding'})) {
        $req->die('FORBIDDEN', 'msg already has X-Bivio-Forwarding set, avoid mail loops');
    }
            
    # Get the outgoing address(es)
    my($emails) = $user->get_outgoing_emails();

    # Bounce mail if couldn't find a valid email
    $req->die('NOT_FOUND', 'email marked as invalid')
	    unless $emails;

    # Forward the message
    $msg->set_recipients($emails);
    $msg->enqueue_send;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
