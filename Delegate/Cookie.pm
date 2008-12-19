# Copyright (c) 2004-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::Cookie;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::IO::Trace;

# C<Bivio::Delegate::Cookie> manages cookies arriving via HTTP and
# returns cookies to the user. By default cookies are persistent. Temporary
# cookies do not set the 'expires' field. A cookie can be set to time-out
# after a period of activity. Cookie fields must begin with a letter.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_MODIFIED_FIELD) = '_modified';
my($_SEP) = "\036";
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_F) = __PACKAGE__->use('UI.Facade');
my($_S) = __PACKAGE__->use('Type.Secret');
#TODO: Need to format dynamically
my($_EXPIRES) = "; expires=Thu, 15 Apr 2020 20:00:00 GMT";
Bivio::IO::Config->register(my $_CFG = {
    domain => undef,
    tag => 'A',
    is_temporary => 0,
    session_timeout_seconds => undef,
    session_update_seconds => undef,
});

sub DATE_TIME_FIELD {
    return 'd';
}

sub assert_is_ok {
    my($proto, $req) = @_;
    return unless $req->get('Type.UserAgent')->is_browser;
    $req->throw_die('MISSING_COOKIES', {
	client_addr => $req->unsafe_get('client_addr'),
    }) unless $req->get('cookie')->unsafe_get($proto->DATE_TIME_FIELD);
    return;
}

sub delete {
    my($self) = shift;
    _trace(\@_) if $_TRACE;
    my($res) = $self->SUPER::delete(@_);
    $self->put;
    return $res;
}

sub delete_all {
    die('not supported');
}

sub handle_config {
    my(undef, $cfg) = @_;
    Bivio::Die->die($cfg->{domain}, ': domain must begin with dot (.)')
        if defined($cfg->{domain}) && $cfg->{domain} !~ /^\./;
    $cfg->{session_update_seconds} = int($cfg->{session_timeout_seconds}/20)
	if $cfg->{session_timeout_seconds}
	&& !defined($cfg->{session_update_seconds});
    $_CFG = {%{$cfg}, tag => uc($cfg->{tag})};
    return;
}

sub header_out {
    my($self, $req, $r) = @_;
    my($fields) = $self->internal_get;
    return 0
	unless _need_header_out($self, $fields, $req);
    my($domain) = $_CFG->{domain}
        ? $_F->get_from_request_or_self($req)
            ->unsafe_get('cookie_domain') || $_CFG->{domain}
        : undef;
    $fields->{$self->DATE_TIME_FIELD} = $_DT->now;
    my($p) = '; path=/';
    $p .= "; domain=$domain" if $domain;
    $p .= $_EXPIRES
        unless $_CFG->{is_temporary};
    _trace('data=', $fields) if $_TRACE;
    my($clear_text) = '';
    while (my($k, $v) = each(%$fields)) {
	next unless $k =~ /^[a-z]/i;
	$clear_text .= "$k$_SEP$v$_SEP"
	    if defined($v);
    }
    chop($clear_text);
    my($value) = $_CFG->{tag}
	. '=' . $_S->encrypt_http_base64($clear_text)
	. $p;
    _trace($value) if $_TRACE;
    $r->header_out('Set-Cookie', $value);
    return 1;
}

sub new {
    my($proto, $req, $r) = @_;
    return $proto->SUPER::new(
        $req->get('Type.UserAgent')->is_browser
            ? _parse($proto, $r->header_in('Cookie') || '')
            : {});
}

sub put {
    my($self) = shift;
    my(%values) = @_;
    foreach my $key (keys(%values)) {
        Bivio::Die->die('keys must start with a letter: ', $key)
            unless $key =~ /^[a-z]/i;
    }
    _trace(\@_) if $_TRACE;
    return $self->SUPER::put(@_, $_MODIFIED_FIELD => 1);
}

sub _need_header_out {
    my($self, $fields, $req) = @_;
    return 0
	unless $req->get('Type.UserAgent')->is_browser;
    return 1
	if $fields->{$_MODIFIED_FIELD};
    return 0
	unless $_CFG->{session_timeout_seconds};
    return 1
	unless $_CFG->{session_update_seconds}
	&& $fields->{$self->DATE_TIME_FIELD};
    return $_DT->compare(
	$_DT->add_seconds(
	    $fields->{$self->DATE_TIME_FIELD},
	    $_CFG->{session_update_seconds},
	),
	$_DT->now,
    ) > 0 ? 0 : 1;
}

sub _parse {
    my($proto, $cookie) = @_;
    _trace($cookie) if $_TRACE;
    my($values) = _parse_values($proto, $cookie);
    return {$_MODIFIED_FIELD => 1}
        unless $values && %$values;
    if ($_CFG->{session_timeout_seconds}) {
        my($date) = $_DT->from_literal($values->{$proto->DATE_TIME_FIELD});
        if ($date
	    && $_DT->compare(
	        $_DT->now,
                $_DT->add_seconds($date, $_CFG->{session_timeout_seconds}),
	    ) > 0
	) {
            _trace('session timed out: ', $_DT->to_string($date)) if $_TRACE;
            return {
		$_MODIFIED_FIELD => 1,
		$proto->DATE_TIME_FIELD => $date
	    };
        }
    }
    return $values;
}

sub _parse_items {
    my($proto, $cookie) = @_;
    my($items) = {};
    foreach my $f (split(/\s*[;,]\s*/, $cookie)) {
	my($k, $v) = split(/\s*=\s*/, $f, 2);
	unless (defined($k) && defined($v)) {
	    _trace($k, ': ignoring other element') if $_TRACE;
	    next;
	}
	$k = uc($k);
	unless ($k eq $_CFG->{tag}) {
	    _trace('tag from another server or old tag: ', $k) if $_TRACE;
	    next;
	}
        if (exists($items->{$k})) {
	    Bivio::IO::Alert->warn('duplicate cookie value for key: ', $k,
                ', ', $items->{$k}, ' and ', $v);
            next;
        }
        $items->{$k} = $v;
    }
    return $items;
}

sub _parse_values {
    my($proto, $cookie) = @_;
    my($values) = {};
    my($items) = _parse_items($proto, $cookie);
    while (my($k, $v) = each(%$items)) {
	$v =~ s/"//g;
	my($s) = $_S->decrypt_http_base64($v);
	unless ($s) {
	    _trace('unable to decode: ', $v) if $_TRACE;
            return undef;
	}
	my(@v) = split(/$_SEP/o, $s);
	_trace('data=', \@v) if $_TRACE;
	push(@v, '') if int(@v) % 2;
	my(%v) = @v;
	unless (($_DT->from_literal(
	    $v{$proto->DATE_TIME_FIELD}))[0]) {
	    Bivio::IO::Alert->warn(
		'invalid cookie: encrypted=', $v, ' decrypted=', \@v);
            return undef;
	}
	while (my($k, $v) = each(%v)) {
	    $values->{$k} = $v;
	}
    }
    return $values;
}

1;
