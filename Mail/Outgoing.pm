# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Outgoing;
use strict;
$Bivio::Mail::Outgoing::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Outgoing - send mail directly or via a queue

=head1 SYNOPSIS

    use Bivio::Mail::Outgoing;
    my($bmo) = Bivio::Mail::Outgoing->new();
    my($bmo) = Bivio::Mail::Outgoing->new($incoming);
    $bmo->set_headers_for_list_send('my-list', 'My List', 1, 1);
    $bmo->set_header('X-Magic', 'hello');
    $bmo->set_recipients([qw(larry mo curly)]);
    $bmo->set_body('what a body');
    $bmo->remove_headers('Subject', 'x-mailer');

=cut

use Bivio::Mail::Common;
@Bivio::Mail::Outgoing::ISA = qw(Bivio::Mail::Common);

=head1 DESCRIPTION

C<Bivio::Mail::Outgoing> is used to create and send mail messages.
One can resend an existing mail message or simply create one from
scratch.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Mail::Incoming;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
# Some of these were taken from majordomo's resend.  Others, just make
# sense.  Check set_headers_for_list_send for headers which set but
# not in this list.
#
# NOTE: This list is sorted for maintenance convenience.
my(@_REMOVE_FOR_LIST_RESEND) = qw(
    approved
    cc
    encoding
    errors-to flags
    message-id
    priority
    received
    references
    reply-to
    return-path
    return-receipt-to
    x-ack
    x-confirm-reading-to
    x-mozilla-status
    x-mozilla-status2
    x-pmrqc
);
# 822:
# Due to an artifact of the notational conventions, the syn-
# tax  indicates that, when present, some fields, must be in
# a particular order.  Header fields  are  NOT  required  to
# occur  in  any  particular  order, except that the message
# body must occur AFTER  the  headers.   It  is  recommended
# that,  if  present,  headers be sent in the order "Return-
# Path", "Received", "Date",  "From",  "Subject",  "Sender",
# "To", "cc", etc.
#
# This specification permits multiple  occurrences  of  most
# fields.   Except  as  noted,  their  interpretation is not
# specified here, and their use is discouraged.
#
# NOTE: This is list is sorted as described above!
my(@_FIRST_HEADERS) = qw(
    return-path
    received
    message-id
    date
    from
    subject
    sender
    to
    cc
    reply-to
    mime-version
    content-type
    content-transfer-encoding
    content-length
);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Mail::Outgoing

=head2 static new(Bivio::Mail::Incoming incoming) : Bivio::Mail::Outgoing

Creates a new outgoing mail message.  If I<incoming> is supplied,
uses as the basis for the message.

=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    my(undef, $incoming) = @_;
    my($fields) = {};
    if (defined($incoming)
	    && UNIVERSAL::isa($incoming, 'Bivio::Mail::Incoming')) {
	my($body);
	$incoming->get_body(\$body);
	$fields->{body} = $body;
	$fields->{headers} = $incoming->get_headers();
        $fields->{env_from} = $incoming->get_from();
    }
    else {
	$fields->{headers} = {};
    }
    $self->{$_PACKAGE} = $fields;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="remove_headers"></a>

=head2 remove_headers(string name1, ...)

Removes the named header fields.

=cut

sub remove_headers {
    my($self, @names) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($name);
    foreach $name (@names) {
	delete($fields->{lc($name)});
    }
    return;
}

=for html <a name="send"></a>

=head2 send()

Sends the message.  Recipients must be set.  Errors are
e-mailed except if recipients are not set.

=cut

sub send {
    my($self, $email_errors) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($msg) = $self->as_string;
    Bivio::Mail::Common->send($fields->{recipients}, \$msg, 0, 
                              $fields->{env_from});
}

=for html <a name="set_body"></a>

=head2 set_body(string body)

=head2 set_body(string_ref body)

Sets the body of the message to I<body>, which may be C<undef>.
If I<body> is a reference, it will be retained.

=cut

sub set_body {
    my($self, $body) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{body} = $body;
    return;
}

=for html <a name="set_headers_for_list_send"></a>

=head2 set_headers_for_list_send(string list_name, string list_title, boolean reply_to_list, boolean list_in_subject)

Removes the headers that are either to be replaced or are uninteresting on a
resend.  This is used for mailing list resends, not simple alias forwarding.
For example, Received:, To:, Cc:, and Message-Id: are removed.

Sets the I<list_name> in the C<To>. Sets From to owner-I<list_name> if C<From:>
not already set.  Inserts the I<list_name> in the C<Subject:> if
I<list_in_subject>.  Sets I<Reply-To:> to I<list_name> if I<reply_to_list>.

ASSUMES: Header addresses are rewritten with appropriate domain name
by MTA (sendmail).

=cut

sub set_headers_for_list_send {
    my($self, $list_name, $list_title, $reply_to_list, $list_in_subject) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($headers) = $fields->{headers};
#TODO: Being too restrictive on list_name syntax?
    $list_name =~ /^[-\w]+$/s || die("$list_name: invalid list name");
    $list_title =~ /^[^\n]+$/s || die("$list_title: invalid list title");
    $list_title =~ s/(["\\])/\\$1/g;
    my($name);
    foreach $name (@_REMOVE_FOR_LIST_RESEND) {
	delete $headers->{$name};
    }
    $headers->{precedence} = "Precedence: bulk\n";
    $headers->{sender} = "Sender: owner-$list_name\n";
    $headers->{to} = "To: \"$list_title\" <$list_name>\n";
    $reply_to_list && ($headers->{'reply-to'} = 'Reply-' . $headers->{to});
    # If there is no From:, add it now.
    $headers->{from} ||= "From: owner-$list_name\n";
    # Set the envelope FROM which is used for bounces
    $fields->{env_from} = "owner-$list_name";
    # Insert the list in the subject, if not already there
#TODO: Need to upcase $list_name appropriately, e.g. Cosmic:, not cosmic:.
    if ($list_in_subject) {
	if (defined($headers->{subject})) {
	    $headers->{subject}
	    =~ s/^subject:(?!(\s*Re:\s*)*$list_name:)/Subject: $list_name:/is;
	}
	else {
	    $headers->{subject} = "Subject: $list_name:\n";
	}
    }
    return;
}

=for html <a name="set_header"></a>

=head2 set_header(string name, string value)

Sets a particular header field.  The previous value of the field is
deleted.  The newline will be appended to the value.

ASSUMES: I<name> and I<value> conform to RFC 822.

=cut

sub set_header {
    my($self, $name, $value) = @_;
    my($fields) = $self->{$_PACKAGE};
#TODO: Should assert header name is valid and quote value if need be
    $fields->{headers}->{lc($name)} = $name . ':' . $value . "\n";
    return;
}

=for html <a name="set_recipients"></a>

=head2 set_recipients(string email_list)

=head2 set_recipients(array email_list)

Sets the recipient of this mail message.  It does not modify the
headers, i.e. To:, etc.  I<email_list> may be a single scalar
containing multiple addresses (separated by commas)
or an array whose elements may contain scalar lists.

=cut

sub set_recipients {
    my($self, $email_list) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{recipients} = $email_list;
    return;
}

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns string representation of the mail message, suitable for sending.

=cut

sub as_string {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($res) = '';
    my(%headers) = %{$fields->{headers}};
    my($name);
    foreach $name (@_FIRST_HEADERS) {
	defined($headers{$name}) || next;
	$res .= $headers{$name};
	delete($headers{$name});
    }
    foreach $name (sort keys %headers) {
	$res .= $headers{$name};
    }
    defined($fields->{body}) && ($res .= "\n"
	    . (ref($fields->{body}) ? ${$fields->{body}} : $fields->{body}));
    return $res;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
