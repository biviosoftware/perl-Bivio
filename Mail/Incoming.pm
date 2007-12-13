# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::Incoming;
use strict;
use Bivio::Base 'Bivio::Mail::Common';
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Mail::Address;
use Bivio::Mail::Common;
use Bivio::Mail::RFC822;
use Bivio::Type::DateTime;
use IO::Scalar ();

# C<Bivio::Mail::Incoming> parses and maintains the state of an incoming mail
# message.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
require 'ctime.pl';

#=VARIABLES
use vars qw($_TRACE);
my($_DT) = 'Bivio::Type::DateTime';
Bivio::IO::Trace->register;
# Bivio::IO::Config->register;

sub get_body {
    my($self, $body) = @_;
    # Returns the body of the message or puts a copy in I<body>.
    return substr(${$self->get('rfc822')}, $self->get('body_offset'))
	unless defined($body);
    $$body = substr(${$self->get('rfc822')}, $self->get('body_offset'));
    return;
}

sub get_date_time {
    my($self) = @_;
    # Returns the date specified by the message
    return $self->get_if_exists_else_put(date_time => sub {
        return $_DT->to_unix(
	    ($_DT->from_literal(
		_get_field($self, 'date:') || return undef,
	    ))[0] || return undef,
	);
    });
}

sub get_from {
    my($self) = @_;
    # Return <I>From:</I> email address and name or just email if not array context.
    # 822: The  "Sender"  field  mailbox  should  NEVER  be  used
    #      automatically, in a recipient's reply message.
    return _two_parter(
	$self,
	qw(from_email from_name),
	['from:', 'apparently-from:'],
    );
}

sub get_headers {
    my($self, $headers) = @_;
    # Returns a hash of headers.  The key is a the field name in lower case sans the
    # colon.  The value is the field name in original case followed by the field
    # value, i.e. the original text.  If a header appears multiple times, its
    # value will be a scalar contain all instances of the field.
    #
    # Note: the field values include the terminating newline.
    #
    # If I<headers> is undefined, a new hash will be created.  If I<headers> is
    # defined, fills in and returns I<headers>.
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

sub get_message_id {
    my($self) = @_;
    # Returns the Message-Id for this message.
    return $self->get_if_exists_else_put(message_id => sub {
	(_get_field($self, 'message-id:') =~ /<([^<>]+)>/)[0];
    });
}

sub get_references {
    my($self) = @_;
    # Return sorted array of message ids this message refers to.
    #
    # The first id in the array returned is either the "In-Reply-To" value
    # or (if In-Reply-To does not exist) the last (most recent) id in the
    # "References" list.
    return $self->get_if_exists_else_put(references => sub {
	my($seen) = {};
        return [map(
	    $seen->{$_}++ ? () : $_,
	    _get_field($self, 'in-reply-to:') =~ /.*<([^<>]+)>/,
	    reverse(_get_field($self, 'references:') =~ /<([^<>]+)>/g),
	)];
    });
}

sub get_reply_to {
    my($self) = @_;
    # Return I<Reply-To:> email address and name or just email
    # if not array context.
    return _two_parter(
	$self,
	qw(reply_to_email reply_to_name),
	['reply-to:'],
    );
}

sub get_rfc822 {
    my($self) = @_;
    # I was not sure what to call this method. Basically, you want it to return
    # the entire RFC822, offset by the header_offset.
    return substr(${$self->get('rfc822')}, $self->get('header_offset'));
}

sub get_rfc822_io {
    my($self) = @_;
    # Return IO::File opend
#TODO: Read only?
    my($file) = IO::Scalar->new($self->get('rfc822'));
#TODO: setpos uses opaque ;  SEEK whence?
    $file->setpos($self->get('header_offset'));
    return $file;

}

sub get_rfc822_length {
    # Returns length of C<rfc822>.
    return shift->get('rfc822_length');
}

sub get_subject {
    my($self) = @_;
    # Returns I<Subject> of message or C<undef>.
    return $self->get_if_exists_else_put(
	subject => sub {
	    my($subject) = _get_field($self, 'subject:');
	    return undef
		unless length($subject);
	    $subject =~ s/^\s+|\s+$//sg;
	    return $subject;
    });
}

sub get_unix_mailbox {
    my($self, $buffer, $offset) = @_;
    # Returns the message in unix mailbox format.  Always ends in a newline.
    # ctime already has newline
    return 'From unknown ' . ctime($self->get('time'))
	    . substr(${$self->get('rfc822')}, $self->get('header_offset'))
	    . (substr(${$self->get('rfc822')}, -1) eq "\n" ? '' : "\n");
}

sub initialize {
    my($self, $rfc822, $offset) = @_;
    # Initializes the object with the reference supplied.
    #
    # Note: the reference to I<rfc822> will be retained, so do not modify this value
    # until L<uninitialize|"uninitialize"> has been called or the object is
    # destroyed.
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

sub new {
    # Create an instance and L<initialize|"initialize"> with I<rfc822>.
    # Default I<offset> is 0.
    #
    # Note: the reference to I<rfc822> will be retained, so do not modify this value
    # until L<uninitialize|"uninitialize"> has been called or the object is
    # destroyed.
    return shift->SUPER::new->initialize(@_);
}

sub send {
    my($self, $req) = shift->internal_req(@_);
    # Send the mail message to the specified recipients (see
    # L<set_recipients|"set_recipients">).  The headers
    # and body remain unchanged, even C<Sender:>.   This should be used
    # for "alias-like" forwarding only.
    Bivio::IO::Alert->warn_deprecated('convert to Outgoing to send');
    return $self->SUPER::send(
	undef,
	$self->get(qw(rfc822 header_offset)),
	($self->get_from)[0],
	$req,
    );
}

sub uninitialize {
    # Clear any state associated with this object.
    shift->delete_all;
    return;
}

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

1;
