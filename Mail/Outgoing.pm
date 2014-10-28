# Copyright (c) 1999-2012 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::Outgoing;
use strict;
use Bivio::Base 'Mail.Common';
use MIME::Base64 ();
use MIME::QuotedPrint ();

# C<Bivio::Mail::Outgoing> is used to create and send mail messages.
# One can resend an existing mail message or simply create one from
# scratch.

my($_T) = b_use('MIME.Type');
my($_R) = b_use('Biz.Random');
my($_FP) = b_use('Type.FilePath');
my($_I) = b_use('Mail.Incoming');
my($_A) = b_use('Mail.Address');
my($_IOT) = b_use('IO.Template');
my($_DT) = b_use('Type.DateTime');
my($_E) = b_use('Type.Email');
my($_RFC) = b_use('Mail.RFC822');
my($_KEEP_HEADERS_LIST_SEND_RE) = qr{
    ^(?:
    @{[join(
        '|',
	qw(
	    bcc
	    cc
	    comments
	    content-.+
	    date
	    from
	    in-reply-to
	    keywords
	    message-id
	    mime-version
	    references
	    reply-to
	    subject
	    to
        ),
    )]}
    )$
}six;

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
my($_FIRST_HEADERS) = [qw(
    return-path
    received
    message-id
    date
    from
    subject
    sender
    to
    cc
    bcc
    reply-to
    mime-version
    content-type
    content-transfer-encoding
    content-length
)];

sub add_missing_headers {
    my($self, $req, $from_email) = @_;
    # Sets Date, Message-ID, From and Return-Path if not set.
    $from_email ||= $self->get_from_email($req);
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
	map(
	    delete($headers->{$_}) || '',
	    @$_FIRST_HEADERS,
	    sort(keys(%$headers)),
	),
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

sub edit_body {
    my($self, $vars) = @_;
    my($body) = ${$self->get_body};
    # fix vars cut-off by quoted printable formatting
    my($count) = 0;
    while ($body =~ s/( quoted-printable.*?\$\w*)\=\n(\w+)/$1$2/s) {
	b_die('too many vars replaced')
	    if ++$count > 10;
    }
    $self->set_body($_IOT->replace_in_string(\$body, $vars));
    return;
}

sub generate_addr_spec {
    my(undef, $req) = @_;
    return $req->format_email(
	    $_DT->to_file_name($_DT->now) . '.' . $_R->string(16)
	);
}

sub generate_message_id {
    return '<' 
        . shift->generate_addr_spec(@_)
        . '>';
}

sub get_body {
    # Returns the receiver's body.
    return shift->get('body');
}

sub get_from_email {
    my($self, $req) = @_;
    return ($_A->parse(
	$self->unsafe_get_header('from')
	|| $self->unsafe_get_header('Apparently-From')
	|| ($self->user_email($req))[0],
    ))[0];
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
    my($h) = $self->get('headers');
    foreach my $name (@names) {
	delete($h->{lc($name)});
    }
    return;
}

sub send {
    my($self, $req) = shift->internal_req(@_);
    _rewrite_from($self, $req);
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
    $self->remove_headers('content-type');
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
    b_warn('stripped trailing newline from header value: ', $name, ' ', $value)
	if $value =~ s/\n+$//g;
    $self->set_envelope_from(($_A->parse($value))[0])
	if $n eq 'return-path';
    $self->get('headers')->{$n} = $name . ': ' . $value . "\n";
    return $self;
}

sub set_headers_for_forward {
    my($self, $sender, $req) = @_;
    _inc_forward_header($self);
    $self->set_header('Sender', $sender)
	if $sender;
    return $self;
}

sub set_headers_for_list_send {
    sub SET_HEADERS_FOR_LIST_SEND {[
	[qw(req Agent.Request)],
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
    $self->remove_headers(
	grep($_ !~ $_KEEP_HEADERS_LIST_SEND_RE, keys(%$headers)));
    $self->set_header(
	To => $self->unsafe_get_header('cc') || $bp->{list_email},
    ) unless $self->unsafe_get_header('to');
    $self->set_header('X-Mailer', "Bivio-Mail-Outgoing");
    $self->set_header('Precedence', 'list');
    $self->set_header('X-Auto-Response-Suppress', 'OOF');
    $self->set_header('List-Id', _list_id($bp->{list_email}));
    $self->set_header('Reply-To', $bp->{reply_to})
	if $bp->{reply_to_list};
    $self->set_header(From => $bp->{sender})
	unless $headers->{from};
    $self->set_header(
	'Return-Path',
	'<'
	. ($bp->{return_path} || $self->get_from_email($bp->{req}))
	. '>',
    );
    $self->set_headers_for_forward($bp->{sender}, $bp->{req});
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

sub _inc_forward_header {
    my($self) = @_;
    return $self->set_header(
	$self->FORWARDING_HDR,
	($self->unsafe_get_header($self->FORWARDING_HDR) || 0) + 1,
    );
}

sub _list_id {
    my($list_email) = @_;
    $list_email =~ s/[^-\w]+/./g;
    return "<$list_email>";
}

sub _rewrite_from {
    my($self, $req) = @_;
    my($full_from) = $self->unsafe_get_header('from');
    $req->throw_die('FORBIDDEN', {
	message => 'missing from header',
    })
	unless $full_from;
    my($old_email, $old_name) = $_A->parse($full_from);
    $req->throw_die('FORBIDDEN', {
	message => 'from header missing email',
	entity => $full_from,
    })
	unless $old_email;
    # We assume that if From does NOT need to be rewritten, then nothing needs a rewrite
    return
	unless $old_email =~ $self->internal_get_config->{rewrite_from_domains_re};
    my($new_email, $new_name) = _rewrite_from_generate($self, $old_email, $old_name, $req);
    $self->set_header('Reply-To', $old_email)
	unless $self->unsafe_get_header('reply-to');
    my($rp) = $self->unsafe_get_header('return-path');
    $self->set_header('Return-Path', $_RFC->format_angle_brackets($new_email))
	if !$rp || $rp eq $old_email;
    my($ef) = $self->unsafe_get('envelope_from');
    $self->set_envelope_from($new_email)
	if !$ef || $ef eq $old_email;
    $self->set_header('From', $_RFC->format_mailbox($new_email, $new_name));
    return;
}

sub _rewrite_from_generate {
    my($self, $email, $name, $req) = @_;
    my($ro) = b_use('Model.RealmOwner')->new($req);
    if ($ro->unauth_load_by_email($email)) {
        $email = b_use('Model.MailReceiveDispatchForm')->new($req)
	    ->format_recipient(
		$ro->get('realm_id'),
		undef,
		b_use('Action.MailForward')->REWRITE_FROM_DOMAIN_URI,
	    );
	$name ||= $ro->get('display_name');
    }
    else {
	$name ||= $_E->get_local_part($email);
	$email = $_E->format_ignore($email, $req);
    }
    $name .= ' via ' . b_use('UI.Facade')->get_value('mail_host', $req);
    return ($email, $name);
}

1;
