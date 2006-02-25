# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Mail::Outgoing;
use strict;
$Bivio::Mail::Outgoing::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Mail::Outgoing::VERSION;

=head1 NAME

Bivio::Mail::Outgoing - send mail directly or via a queue

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Mail::Outgoing;
    my($bmo) = Bivio::Mail::Outgoing->new();
    my($bmo) = Bivio::Mail::Outgoing->new($incoming);
    $bmo->set_headers_for_list_send('my-list', 'My List', 1, 1);
    $bmo->set_header('X-Magic', 'hello');
    $bmo->set_recipients([qw(larry mo curly)]);
    $bmo->set_body('what a body');
    $bmo->remove_headers('Subject', 'x-mailer');

    $bmo->set_content_type('multipart/mixed');
    $bmo->attach( \$buffer1, 'image/jpg', 'my.jpg');
    $bmo->attach( \$buffer2, 'application/pdf', 'my.pdf');

=cut

use Bivio::Mail::Common;
@Bivio::Mail::Outgoing::ISA = qw(Bivio::Mail::Common);

=head1 DESCRIPTION

C<Bivio::Mail::Outgoing> is used to create and send mail messages.
One can resend an existing mail message or simply create one from
scratch.

=cut

#=IMPORTS
use Bivio::MIME::Type;
use Bivio::Mail::Address;
use Bivio::Mail::Incoming;
use MIME::Base64;

#=VARIABLES
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_IDI) = __PACKAGE__->instance_data_index;
# Some of these were taken from majordomo's resend.  Others, just make
# sense.  Check set_headers_for_list_send for headers which set but
# not in this list.
#
# NOTE: This list is sorted for maintenance convenience.
my($_REMOVE_FOR_LIST_RESEND) = [map(lc($_), qw(
    approved
    cc
    encoding
    errors-to flags
    message-id
    priority
    received
    reply-to
    return-path
    return-receipt-to
    x-ack
    x-confirm-reading-to
    x-mozilla-status
    x-mozilla-status2
    x-pmrqc
),
    Bivio::Mail::Common->RECIPIENTS_HDR,
)];

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
    my($self) = shift->SUPER::new;
    my($incoming) = @_;
    my($fields) = $self->[$_IDI] = {};
    if (UNIVERSAL::isa($incoming, 'Bivio::Mail::Incoming')) {
	my($body);
	$incoming->get_body(\$body);
	$fields->{body} = $body;
	$fields->{headers} = $incoming->get_headers();
        $fields->{env_from} = $incoming->get_from();
    }
    else {
	$fields->{headers} = {};
    }
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_missing_headers"></a>

=head2 add_missing_headers(string from_email, Bivio::Agent::Request req) : self

Sets Date, Message-ID, From, and Return-Path if not set.

=cut

sub add_missing_headers {
    my($self, $from_email, $req) = @_;
    $from_email ||= (Bivio::Mail::Address->parse(
	$self->unsafe_get_header('From')
	|| $self->unsafe_get_header('Apparently-From')
	|| ($self->user_email($req))[0],
    ))[0];
    my($now) = $_DT->now;
    foreach my $x (
	[Date => $_DT->rfc822($now)],
	['Message-ID' => '<' .
	     $req->format_email(
		 $_DT->to_file_name($now) . "." . int(rand(1_000_000_000)))
	     . '>'],
	[From => "<$from_email>"],
	['Return-Path' => "<$from_email>"],
    ) {
	$self->set_header(@$x)
	    unless $self->unsafe_get_header($x->[0]);
    }
    return $self;
}

=for html <a name="attach"></a>

=head2 attach(string_ref content, string content-type, string name, int binary) : 

Add an attachment part to the mail message.
Arguments 'content' and 'content-type' are mandatory.
'name' is the file name that should be used to store it.
'binary' can be set to true to base64-encode the contents.
Anything which is not of type text/* is encoded automatically.

=cut

sub attach {
    my($self, $content, $type, $name, $binary) = @_;
    my($fields) = $self->[$_IDI];

    defined($binary) || ($binary = 0);
    my($part) = { content => $content, type => $type, binary => $binary };
    if (defined($name)) {
        $part->{name} = $name;
    }
    push(@{$fields->{parts}}, $part);
    return;
}

=for html <a name="get_body"></a>

=head2 get_body() : scalar_ref

Returns the receiver's body.

=cut

sub get_body {
    my($body) = shift->[$_IDI]->{body};
    return (ref($body) eq 'SCALAR')
        ? $body
        : \$body
}

=for html <a name="remove_headers"></a>

=head2 remove_headers(string name1, ...)

Removes the named header fields.

=cut

sub remove_headers {
    my($self, @names) = @_;
    my($fields) = $self->[$_IDI];
    my($name);
    foreach $name (@names) {
	delete($fields->{lc($name)});
    }
    return;
}

=for html <a name="send"></a>

=head2 send(Bivio::Agent::Request req)

Sends the message.  Recipients must be set.  Errors are
e-mailed except if recipients are not set.

=cut

sub send {
    my($self, $req) = shift->internal_req(@_);
    my($fields) = $self->[$_IDI];
    my($msg) = $self->as_string;
    Bivio::Mail::Common->send($fields->{recipients}, \$msg, 0,
                              $fields->{env_from}, $req);
    return;
}

=for html <a name="set_body"></a>

=head2 set_body(string body)

=head2 set_body(string_ref body)

Sets the body of the message to I<body>, which may be C<undef>.
If I<body> is a reference, it will be retained.

=cut

sub set_body {
    my($self, $body) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{body} = $body;
    return;
}

=for html <a name="set_content_type"></a>

=head2 set_content_type(string name, string value)

Sets the Content-Type header field. Any previous setting is overridden.

=cut

sub set_content_type {
    my($self, $value) = @_;
    my($fields) = $self->[$_IDI];
    # Remove possibly existing Content-Type setting from the headers
    exists($fields->{headers}->{'content-type'})
            && delete($fields->{headers}->{'content-type'});
    $fields->{content_type} = $value;
    return;
}

=for html <a name="set_from_with_user"></a>

=head2 set_from_with_user(Bivio::Agent::Request req) : string

Sets the from with the current user and host name.  It uses the email
address not the comment entry (/etc/passwd) for the name.  If it can't get
the user, it is does nothing.  The MTA will add it.

Returns the from email address or C<undef> if it couldn't set anything.

=cut

sub set_from_with_user {
    my($self, $req) = shift->internal_req(@_);
    my($email, $name) = $self->user_email($req);
    $self->set_envelope_from($email);
    $self->set_header('From', qq{"$name" <$email>});
    return $email
}

=for html <a name="set_header"></a>

=head2 set_header(string name, string value)

Sets a particular header field.  The previous value of the field is
deleted.  The newline will be appended to the value.

ASSUMES: I<name> and I<value> conform to RFC 822.

=cut

sub set_header {
    my($self, $name, $value) = @_;
    my($fields) = $self->[$_IDI];
#TODO: Should assert header name is valid and quote value if need be
    $fields->{headers}->{lc($name)} = $name . ': ' . $value . "\n";
    return;
}

=for html <a name="set_headers_for_list_send"></a>

=head2 set_headers_for_list_send(string list_name, string list_title, boolean reply_to_list, string subject_prefix, Bivio::Agent::Request req) : self

Removes the headers that are either to be replaced or are uninteresting on a
resend.  This is used for mailing list resends, not simple alias forwarding.
For example, Received:, To:, Cc:, and Message-Id: are removed.

Sets the I<list_name> in the C<To>. Sets From to owner-I<list_name> if C<From:>
not already set.  Inserts the I<list_name> in the C<Subject:> if
I<list_in_subject>.  Sets I<Reply-To:> to I<list_name> if I<reply_to_list>.

=cut

sub set_headers_for_list_send {
    my($self, $np) = shift->name_parameters(
	[qw(list_name list_title reply_to_list subject_prefix req list_email return_path sender reply_to)], \@_);
    if (($np->{subject_prefix} || '') eq 1) {
	Bivio::IO::Alert->warn_deprecated(
	    'list_in_subject is now subject_prefix');
	$np->{subject_prefix} = "$np->{list_name}:";
    }
    if ($np->{list_email}) {
	$np->{reply_to} ||= $np->{list_email};
	$np->{sender} ||= $np->{list_email};
    }
    else {
	Bivio::Die->die($np->{list_name}, ': invalid list name')
	   unless $np->{list_name} =~ /^[-\.\w]+$/s;
	Bivio::Die->die($np->{list_title}, ': invalid list title')
	    unless $np->{list_title} =~ /^[^\n]+$/s;
	$np->{list_title} =~ s/(["\\])/\\$1/g;
	$np->{list_email} = $np->{req}->format_email($np->{list_name});
    }
    my($fields) = $self->[$_IDI];
    my($headers) = $fields->{headers};
    delete(@$headers{@$_REMOVE_FOR_LIST_RESEND});
    my($sender) = $np->{sender}
	|| $np->{req}->format_email("$np->{list_name}-owner");
    $headers->{sender} = "Sender: $sender\n";
    $self->set_envelope_from($sender);
    my($to) = qq{"$np->{list_title}" <$np->{list_email}>};
    $np->{reply_to} = $to
	if $np->{reply_to_list} && !$np->{reply_to};
    $headers->{'reply-to'}
	= "Reply-To: $np->{reply_to}\n"
	if $np->{reply_to};
    $headers->{'return-path'}
	= "Return-Path: $np->{return_path}\n"
	if $np->{return_path};
    $headers->{from} ||= "From: $sender\n";
    $headers->{to} = "To: $to\n";
    return $self
	unless $np->{subject_prefix};
    if (defined($headers->{subject})) {
	$headers->{subject}
	    =~ s/^subject:(?!(\s*Re:\s*)*\Q$np->{subject_prefix}\E)/Subject: $np->{subject_prefix}/is;
    }
    else {
	$headers->{subject} = "Subject: $np->{subject_prefix}\n";
    }
    return $self;
}

=for html <a name="set_recipients"></a>

=head2 set_recipients(string email_list) : self

=head2 set_recipients(array_ref email_list) : self

Sets the recipient of this mail message.  It does not modify the
headers, i.e. To:, etc.  I<email_list> may be a single scalar
containing multiple addresses (separated by commas)
or an array whose elements may contain scalar lists.

=cut

sub set_recipients {
    my($self, $email_list) = @_;
    $self->[$_IDI]->{recipients}
	= ref($email_list) ? join(',', @$email_list) : $email_list;
    return $self;
}

=for html <a name="set_envelope_from"></a>

=head2 set_envelope_from(string email)

Sets the envelope FROM of this mail message.  It's the address
which appears as Return-Path: in the outgoing message header and
is used by MTAs to return bounces.

=cut

sub set_envelope_from {
    my($self, $from) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{env_from} = $from;
    return;
}

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns string representation of the mail message, suitable for sending.

=cut

sub as_string {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
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

    if (defined($fields->{parts})) {
        defined($fields->{content_type})
                || die("'content_type' must be set for attachments");
        defined($fields->{body}) &&
                Bivio::IO::Alert->warn("ignoring body, have attachments");
        _encapsulate_parts(\$res, $fields->{content_type}, $fields->{parts});
    }
    elsif (defined($fields->{body})) {
	defined($fields->{content_type})
		&& ($res .= "Content-Type: $fields->{content_type}\n");
	$res .= "\n" . (ref($fields->{body}) ?
		${$fields->{body}} : $fields->{body});
    }
    return $res;
}

=for html <a name="unsafe_get_header"></a>

=head2 unsafe_get_header(string name) : string

Returns header value or undef.

=cut

sub unsafe_get_header {
    return [
	((shift->[$_IDI]->{headers}->{lc(shift)})[0] || '')
        =~ /^(?:.*?):\s+(.*)\n$/s
    ]->[0];
}

=for html <a name="unsafe_get_recipients"></a>

=head2 unsafe_get_recipients() : string

Returns recipients.

=cut

sub unsafe_get_recipients {
    return shift->[$_IDI]->{recipients};
}

#=PRIVATE METHODS

# _encapsulate_parts(string_ref buf, string type, array parts) : 
#
# Encapsulate all attachments according to type.
#
sub _encapsulate_parts {
    my($buf, $type, $parts) = @_;
# TODO: Randomize boundary    
    my($boundary) = '------------8169AB88A610572B963B8638';
    $$buf .= <<"EOF";
MIME-Version: 1.0
Content-Type: $type;
 boundary="$boundary"

This is a multi-part message in MIME format.
EOF
    $$buf .= "--$boundary";
    my($p);
    foreach $p (@$parts) {
        $$buf .= "\nContent-Type: $p->{type}";
        defined($p->{name}) && ($$buf .= ";\n name=\"$p->{name}\"");
        if ($p->{type} =~ m!^text/! && !$p->{binary}) {
            $$buf .= "\nContent-Transfer-Encoding: 7bit\n\n";
            $$buf .= ${$p->{content}} . "\n\n";
        }
	else {
            $$buf .= "\nContent-Transfer-Encoding: base64\n\n";
            $$buf .= MIME::Base64::encode(${$p->{content}});
        }
        $$buf .= "--$boundary";
    }
    $$buf .= "--\n";
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
