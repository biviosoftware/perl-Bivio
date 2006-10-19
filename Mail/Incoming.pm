# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::Incoming;
use strict;
$Bivio::Mail::Incoming::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Incoming - parses an incoming mail message

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Mail::Incoming;

=cut

use Bivio::Mail::Common;
@Bivio::Mail::Incoming::ISA = qw(Bivio::Mail::Common);

=head1 DESCRIPTION

C<Bivio::Mail::Incoming> parses and maintains the state of an incoming mail
message.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Mail::Address;
use Bivio::Mail::Common;
use Bivio::Mail::RFC822;
use Bivio::Type::DateTime;
use IO::Scalar ();
require 'ctime.pl';

#=VARIABLES
use vars qw($_TRACE);
my($_DT) = 'Bivio::Type::DateTime';
Bivio::IO::Trace->register;
# Bivio::IO::Config->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string_ref rfc822) : Bivio::Mail::Incoming

=head2 static new(string_ref rfc822, int offset) : Bivio::Mail::Incoming

Create an instance and L<initialize|"initialize"> with I<rfc822>.
Default I<offset> is 0.

Note: the reference to I<rfc822> will be retained, so do not modify this value
until L<uninitialize|"uninitialize"> has been called or the object is
destroyed.

=cut

sub new {
    return shift->SUPER::new->initialize(@_);
}

=head1 METHODS

=cut

=for html <a name="get_body"></a>

=head2 get_body() : string

=head2 get_body(string_ref body)

Returns the body of the message or puts a copy in I<body>.

=cut

sub get_body {
    my($self, $body) = @_;
    return substr(${$self->get('rfc822')}, $self->get('body_offset'))
	unless defined($body);
    $$body = substr(${$self->get('rfc822')}, $self->get('body_offset'));
    return;
}

=for html <a name="get_date_time"></a>

=head2 get_date_time() : time

Returns the date specified by the message

=cut

sub get_date_time {
    my($self) = @_;
    return $self->get_if_exists_else_put(date_time => sub {
        return $_DT->to_unix(
	    ($_DT->from_literal(
		_get_field($self, 'date:') || return undef,
	    ))[0] || return undef,
	);
    });
}

=for html <a name="get_from"></a>

=head2 get_from() : (string addr, string name)

=head2 get_from() : string addr

Return <I>From:</I> email address and name or just email if not array context.

=cut

sub get_from {
    my($self) = @_;
    # 822: The  "Sender"  field  mailbox  should  NEVER  be  used
    #      automatically, in a recipient's reply message.
    return _two_parter(
	$self,
	qw(from_email from_name),
	['from:', 'apparently-from:'],
    );
}

=for html <a name="get_headers"></a>

=head2 get_headers() : hash

=head2 get_headers(hash headers) : hash

Returns a hash of headers.  The key is a the field name in lower case sans the
colon.  The value is the field name in original case followed by the field
value, i.e. the original text.  If a header appears multiple times, its
value will be a scalar contain all instances of the field.

Note: the field values include the terminating newline.

If I<headers> is undefined, a new hash will be created.  If I<headers> is
defined, fills in and returns I<headers>.

=cut

sub get_headers {
    my($self, $headers) = @_;
    $headers ||= {};
    my($fn) = Bivio::Mail::RFC822->FIELD_NAME;
    # Important to include the newline in $f
    foreach my $f (split(/^(?=$fn)/om, $self->get('header'))) {
	my($n) = $f =~ /^($fn)/o;
	unless (defined($n)) {
	    Bivio::IO::Alert->warn($f, ': invalid RFC822 field');
	    next;
	}
	$n =~ s/:$//;
	$headers->{lc($n)} .= $f;
    }
    return $headers;
}

=for html <a name="get_message_id"></a>

=head2 get_message_id() : string

Returns the Message-Id for this message.

=cut

sub get_message_id {
    my($self) = @_;
    return $self->get_if_exists_else_put(message_id => sub {
	(_get_field($self, 'message-id:') =~ /<([^<>]+)>/)[0];
    });
}

=for html <a name="get_references"></a>

=head2 get_references() : array

Return sorted array of message ids this message refers to.

The first id in the array returned is either the "In-Reply-To" value
or (if In-Reply-To does not exist) the last (most recent) id in the
"References" list.

=cut

sub get_references {
    my($self) = @_;
    return $self->get_if_exists_else_put(references => sub {
	my($seen) = {};
        return [map(
	    $seen->{$_}++ ? () : $_,
	    _get_field($self, 'in-reply-to:') =~ /.*<([^<>]+)>/,
	    reverse(_get_field($self, 'references:') =~ /<([^<>]+)>/g),
	)];
    });
}

=for html <a name="get_reply_to"></a>

=head2 get_reply_to() : (string addr, string name)

=head2 get_reply_to() : string addr

Return I<Reply-To:> email address and name or just email
if not array context.

=cut

sub get_reply_to {
    my($self) = @_;
    return _two_parter(
	$self,
	qw(reply_to_email reply_to_name),
	['reply-to:'],
    );
}

=for html <a name="get_rfc822"></a>

=head2 get_rfc822() : string

I was not sure what to call this method. Basically, you want it to return
the entire RFC822, offset by the header_offset.

=cut

sub get_rfc822 {
    my($self) = @_;
    return substr(${$self->get('rfc822')}, $self->get('header_offset'));
}

=for html <a name="get_rfc822_io"></a>

=head2 get_rfc822_io() : IO::File

Return IO::File opend

=cut

sub get_rfc822_io {
    my($self) = @_;
#TODO: Read only?
    my($file) = IO::Scalar->new($self->get('rfc822'));
#TODO: setpos uses opaque ;  SEEK whence?
    $file->setpos($self->get('header_offset'));
    return $file;

}

=for html <a name="get_rfc822_length"></a>

=head2 get_rfc822_length() : int

Returns length of C<rfc822>.

=cut

sub get_rfc822_length {
    return shift->get('rfc822_length');
}

=for html <a name="get_subject"></a>

=head2 get_subject() : string

Returns I<Subject> of message or C<undef>.

=cut

sub get_subject {
    my($self) = @_;
    return $self->get_if_exists_else_put(
	subject => sub {
	    my($subject) = _get_field($self, 'subject:');
	    return undef
		unless length($subject);
	    $subject =~ s/^\s+|\s+$//sg;
	    return $subject;
    });
}

=for html <a name="get_unix_mailbox"></a>

=head2 get_unix_mailbox() : string

Returns the message in unix mailbox format.  Always ends in a newline.

=cut

sub get_unix_mailbox {
    my($self, $buffer, $offset) = @_;
    # ctime already has newline
    return 'From unknown ' . ctime($self->get('time'))
	    . substr(${$self->get('rfc822')}, $self->get('header_offset'))
	    . (substr(${$self->get('rfc822')}, -1) eq "\n" ? '' : "\n");
}

=for html <a name="initialize"></a>

=head2 initialize(string_ref $rfc822)

=head2 initialize(string_ref $rfc822, int offset)

Initializes the object with the reference supplied.

Note: the reference to I<rfc822> will be retained, so do not modify this value
until L<uninitialize|"uninitialize"> has been called or the object is
destroyed.

=cut

sub initialize {
    my($self, $rfc822, $offset) = @_;
    $offset ||= 0;
    my($i) = index($$rfc822, "\n\n", $offset);
    my($h);
    if (substr($$rfc822, $offset, 5) eq 'From ') {
	# Skip Unix From line
	$offset = index($$rfc822, "\n", $offset) + 1;
    }
    if ($i >= 0) {
	$i -= $offset;
	$h = substr($$rfc822, $offset, $i + 1);
	# Account for \n\n
	$i += 2 + $offset;
    }
    else {
	$i = length($$rfc822) - $offset;
	$h = substr($$rfc822, $offset, $i + 1);
    }
#TODO: Handle "From " start lines.
#TODO: Don't unfold headers in advance.  Unfold headers as they
#      are parsed.  This makes resent mail messages cleaner.
    # unfold all headers in advance.  Makes other code simpler.
    #
    # [rfc882] Unfolding is accomplished by regarding CRLF immediately
    # followed by a LWSP-char as equivalent to the LWSP-char.
    # Can't use \s, because isn't locale specific.
    # TODO: Not handling quoted CRLF sequences which appear to be legitimate.
    #      The effect will be to lose quoted LF and replace it with a
    #      quoted space.
    $h =~ s/\r?\n[ \t]/ /gs;
    return $self->put(
	rfc822 => $rfc822,
	header => $h,
	header_offset => $offset,
	rfc822_length => length($$rfc822) - $offset,
	# If there is no body, get_body will return empty string.
	body_offset => $i,
	time => time,

    );
}

=for html <a name="send"></a>

=head2 send() : self

Send the mail message to the specified recipients (see
L<set_recipients|"set_recipients">).  The headers
and body remain unchanged, even C<Sender:>.   This should be used
for "alias-like" forwarding only.

=cut

sub send {
    my($self, $req) = shift->internal_req(@_);
    return $self->SUPER::send(
	undef,
	$self->get(qw(rfc822 header_offset)),
	($self->get_from)[0],
	$req,
    );
}

=for html <a name="uninitialize"></a>

=head2 uninitialize()

Clear any state associated with this object.

=cut

sub uninitialize {
    shift->delete_all;
    return;
}

#=PRIVATE METHODS

sub _get_field {
    my($self, $name) = @_;
    return $self->get_if_exists_else_put(
	$name,
	sub {
	    my($v) = $self->get('header') =~ m{^$name(?: |\t)*(.*)}im;
	    return defined($v) ? $v : '';
	},
    );
}

sub _two_parter {
    my($self, $field1, $field2, $headers) = @_;
    my($f1) = $self->get_if_exists_else_put($field1 => sub {
	my($v);
        foreach my $f (@$headers) {
	    last if $v = _get_field($self, $f);
        }
	my($f1, $f2) = $v ? Bivio::Mail::Address->parse($v) : ();
	$self->put($field2 => $f2);
	return $f1;
    });
    return wantarray ? ($f1, $self->get($field2)) : $f1;
}

=head1 COPYRIGHT

Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
