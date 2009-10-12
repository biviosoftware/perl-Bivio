# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::Outgoing;
use strict;
use Bivio::Base 'Mail.Common';
use MIME::Base64 ();
use MIME::QuotedPrint ();

# C<Bivio::Mail::Outgoing> is used to create and send mail messages.
# One can resend an existing mail message or simply create one from
# scratch.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');
# Some of these were taken from majordomo's resend.  Others, just make
# sense.  Check set_headers_for_list_send for headers which set but
# not in this list.
#
# NOTE: This list is sorted for maintenance convenience.
# cc and to are optional, see below
my($_REMOVE_FOR_LIST_RESEND) = [map(lc($_), qw(
    approved
    encoding
    errors-to flags
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
    Bivio::Mail::Common->TEST_RECIPIENT_HDR,
)];
my($_T) = __PACKAGE__->use('MIME.Type');
my($_R) = __PACKAGE__->use('Biz.Random');
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_I) = __PACKAGE__->use('Mail.Incoming');
my($_A) = __PACKAGE__->use('Mail.Address');

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

sub add_missing_headers {
    my($self, $req, $from_email) = @_;
    # Sets Date, Message-ID, From and Return-Path if not set.
    $from_email ||= ($_A->parse(
	$self->unsafe_get_header('From')
	|| $self->unsafe_get_header('Apparently-From')
	|| ($self->user_email($req))[0],
    ))[0];
    my($now) = $_DT->now;
    foreach my $x (
	[Date => $_DT->rfc822($now)],
	['Message-ID' => $self->generate_message_id($req)],
	[From => "<$from_email>"],
	['Return-Path' => "<$from_email>"],
    ) {
 	$self->set_header(@$x)
	    unless $self->unsafe_get_header($x->[0]);
    }

    return $self;
}

sub as_string {
    my($self) = @_;
    # Returns string representation of the mail message, suitable for sending.
    my($headers) = {%{$self->get('headers')}};
    my($res) = join(
	'',
	map(delete($headers->{$_}) || '',
	    @_FIRST_HEADERS, sort(keys(%$headers))),
    );
    my($body, $ct, $parts) = $self->unsafe_get(qw(body content_type parts));
    if ($parts) {
	die("'content_type' must be set for attachments")
	    unless $ct;
	Bivio::IO::Alert->warn("ignoring body, have attachments")
	    if $body;
        _encapsulate_parts(\$res, $ct, $parts);
    }
    elsif ($body) {
	$res .= "Content-Type: $ct\n"
	    if $ct;
	$res .= "\n" . $$body;
    }
    return $res;
}

sub attach {
    sub ATTACH {[qw(content content_type ?filename ?binary)]};
    my($self, $bp) = shift->parameters(\@_);
    Bivio::IO::Alert->warn('binary is supplanted by suggest_encoding')
        if defined($bp->{binary});
    push(@{$self->get_if_exists_else_put('parts', [])}, $bp);
    return;
}

sub generate_message_id {
    my(undef, $req) = @_;
    return '<' .
	$req->format_email(
	    $_DT->to_file_name($_DT->now) . '.' . $_R->string(16)
	) . '>';
}

sub get_body {
    # Returns the receiver's body.
    return shift->get('body');
}

sub new {
    my($proto, $msg) = @_;
    # Creates a new outgoing mail message.  If I<incoming> is supplied,
    # uses as the basis for the message.
    my($attrs) = {};
    $msg = $_I->new($msg)
	if ref($msg) eq 'SCALAR';
    if (UNIVERSAL::isa($msg, $_I)) {
	my($body);
	$msg->get_body(\$body);
	$attrs->{body} = \$body;
	$attrs->{headers} = $msg->get_headers;
        $attrs->{envelope_from} = $msg->get_from;
    }
    elsif (UNIVERSAL::isa($msg, __PACKAGE__)) {
	# NOTE: This shares \$body if it exists, which neither class nor
	# its parents modify.  Action.RealmMailReflector depends on this
	# so that the server doesn't grow too large.
	my($c) = $msg->get_shallow_copy;
	while (my($k, $v) = each(%$c)) {
	    $attrs->{$k} = ref($v) eq 'ARRAY' ? [@$v]
		: ref($v) eq 'HASH' ? {%$v}
		: $v;
	}
    }
    elsif (defined($msg)) {
	Bivio::Die->die('invalid message type');
    }
    $attrs->{headers} ||= {};
    return $proto->SUPER::new($attrs);
}

sub remove_headers {
    my($self, @names) = @_;
    # Removes the named header fields.
    foreach my $name (@names) {
	$self->delete(lc($name));
    }
    return;
}

sub send {
    my($self, $req) = shift->internal_req(@_);
    # Sends the message.  Recipients must be set.  Errors are
    # e-mailed except if recipients are not set.
    return $self->SUPER::send(undef, undef, 0, $self->unsafe_get('envelope_from'), $req);
}

sub set_body {
    my($self, $body) = @_;
    # Sets the body of the message to I<body>, which may be C<undef>.
    # If I<body> is a reference, it will be retained.
    $self->put(body => ref($body) eq 'SCALAR' ? $body : \$body);
    return;
}

sub set_content_type {
    my($self, $value) = @_;
    # Sets the Content-Type header field. Any previous setting is overridden.
    # Remove possibly existing Content-Type setting from the headers
    if (my $h = $self->unsafe_get('headers')) {
	delete($h->{'content-type'});
    }
    $self->put(content_type => $value);
    return;
}

sub set_envelope_from {
    return shift->put(envelope_from => shift);
}

sub set_from_with_user {
    my($self, $req) = shift->internal_req(@_);
    # Sets the from with the current user and host name.  It uses the email
    # address not the comment entry (/etc/passwd) for the name.  If it can't get
    # the user, it is does nothing.  The MTA will add it.
    #
    # Returns the from email address or C<undef> if it couldn't set anything.
    my($email, $name) = $self->user_email($req);
    $self->set_envelope_from($email);
    $self->set_header('From', qq{"$name" <$email>});
    return $email
}

sub set_header {
    my($self, $name, $value) = @_;
    # Sets a particular header field.  The previous value of the field is
    # deleted.  The newline will be appended to the value.
    #
    # ASSUMES: I<name> and I<value> conform to RFC 822.
    my($n) = lc($name);
#TODO: Should assert header name is valid and quote value if need be
    $self->get('headers')->{$n} = $name . ': ' . $value . "\n";
    $self->set_envelope_from(($_A->parse($value))[0])
	if $n eq 'return-path';
    return $self;
}

sub set_headers_for_forward {
    my($self) = @_;
    return $self->set_header(
	'X-Bivio-Forwarded',
	($self->unsafe_get_header('X-Bivio-Forwarded') || 0) + 1,
    );
}

sub set_headers_for_list_send {
    sub SET_HEADERS_FOR_LIST_SEND {[
	[qw(list_email Email)],
	[qw(?reply_to Email)],
	[qw(?reply_to_list Boolean)],
	[qw(?return_path Email)],
	[qw(?sender Email)],
	[qw(?subject_prefix Line)],
    ]};
    my($self, $bp) = shift->parameters(\@_);
    $bp->{sender} ||= $bp->{list_email};
    $bp->{reply_to} ||= $bp->{list_email};
    my($headers) = $self->get('headers');
    b_die('missing To: in headers: ', $headers)
	unless $headers->{to};
    $self->set_headers_for_forward;
    delete(@$headers{@$_REMOVE_FOR_LIST_RESEND});
    $self->set_header(Sender => $bp->{sender});
    $self->set_header('Reply-To', $bp->{reply_to})
	if $bp->{reply_to_list};
    $self->set_header(From => $bp->{sender})
	unless $headers->{from};
    $self->set_header(
	'Return-Path',
	'<' . (
	    $bp->{return_path} || ($_A->parse(
		    $self->unsafe_get_header('from')))[0]
	 ) . '>',
    );
    b_die('missing To: in headers: ', $headers)
	unless $self->unsafe_get_header('to');
    return $self
	unless $bp->{subject_prefix};
    my($s) = $self->unsafe_get_header('subject');
    if (defined($s)) {
	$s =~ s/^(?!(Re:\s*)*\Q$bp->{subject_prefix}\E)/$bp->{subject_prefix} /is;
    }
    else {
	$s = $bp->{subject_prefix};
    }
    $self->set_header(Subject => $s);
    return $self;
}

sub unsafe_get_header {
    # Returns header value or undef.
    return [
	((shift->get('headers')->{lc(shift)})[0] || '')
        =~ /^(?:.*?):\s+(.*)\n$/s
    ]->[0];
}

sub _encapsulate_parts {
    my($buf, $type, $parts) = @_;
    my($boundary) = $_R->string(32);
    $$buf .= <<"EOF";
MIME-Version: 1.0
Content-Type: $type; boundary="$boundary"

This is a multi-part message in MIME format.
EOF
    my($p);
    foreach $p (@$parts) {
	$$buf .= "--$boundary\nContent-Type: $p->{content_type}";
	my($n) = $_FP->get_clean_tail($p->{filename});
	if ($n) {
	    $n =~ s/^\s+|\s+$|"//g;
	    $$buf .= qq{; name="$n"}
	}
	$$buf .= "\nContent-Disposition: inline";
	$$buf .= qq{; filename="$n"}
            if $n;
	my($encoding)
	    = $_T->suggest_encoding($p->{content_type}, $p->{content});
	$$buf .= "\nContent-Transfer-Encoding: $encoding\n\n";
        if ($encoding eq 'quoted-printable' ) {
            $$buf .= MIME::QuotedPrint::encode(${$p->{content}});
        }
	elsif ($encoding eq 'base64' ) {
            $$buf .= MIME::Base64::encode(${$p->{content}});
        }
	else {
            $$buf .= ${$p->{content}};
	    $$buf .= "\n"
		unless $$buf =~ /\n$/s;
	}
    }
    $$buf .= "--$boundary--\n";
    return;
}

1;
