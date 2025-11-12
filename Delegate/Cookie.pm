# Copyright (c) 2004-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::Cookie;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::IO::Trace;

# C<Bivio::Delegate::Cookie> manages cookies arriving via HTTP and
# returns cookies to the user. By default cookies are persistent. Temporary
# cookies do not set the 'max-age' field. A cookie can be set to time-out
# after a period of activity. Cookie fields must begin with a letter.

our($_TRACE);
my($_MODIFIED_FIELD) = '_modified';
my($_PRIOR_TAG_FIELD) = '_prior_tag';
my($_ESC) = "\027";
my($_SEP) = "\036";
my($_ESC_ESC) = "${_ESC}E";
my($_ESC_SEP) = "${_ESC}S";
my($_DT) = b_use('Type.DateTime');
my($_S) = b_use('Type.Secret');
# 10 years
my($_MAX_AGE) = "; max-age=31536000";
b_use('IO.Config')->register(my $_CFG = {
    domain => undef,
    tag => 'A',
    prior_tags => undef,
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
b_use('IO.Alert')->print_stack
    unless $req->get('cookie')->unsafe_get($proto->DATE_TIME_FIELD);

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
    $cfg = b_use('IO.Ref')->nested_copy($cfg);
    $cfg->{session_update_seconds} = int($cfg->{session_timeout_seconds}/20)
        if $cfg->{session_timeout_seconds}
        && !defined($cfg->{session_update_seconds});
    $cfg->{prior_tags} = $cfg->{prior_tags} && @{$cfg->{prior_tags}}
        ? [map(
            ref($_) ? [uc($_->[0]), lc($_->[1])] : [uc($_)],
            @{$cfg->{prior_tags}}
        )]
        : undef;
    $cfg->{tag} = uc($cfg->{tag});
    $_CFG = $cfg;
    return;
}

sub header_out {
    my($self, $req, $r) = @_;
    my($fields) = $self->internal_get;
    return 0
        unless _need_header_out($self, $fields, $req);
    my($domain) = $_CFG->{domain}
        ? b_use('UI.Facade')->get_from_request_or_self($req)
            ->unsafe_get('cookie_domain') || $_CFG->{domain}
        : undef;
    $fields->{$self->DATE_TIME_FIELD} = $_DT->now;
    my($p) = '; path=/';
    $p .= (my $domain_prefix = "; domain=$domain")
        if $domain;
    $p .= $_MAX_AGE
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
        . $p . '; HttpOnly'
        . ($req->agent_execution_is_secure ? '; Secure' : '');
    _trace($value) if $_TRACE;
    $req->get('reply')->send_append_header($r, 'Set-Cookie', $value);
    _clear_prior_tags($req)
        if $fields->{$_PRIOR_TAG_FIELD};
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
        b_die('keys must start with a letter: ', $key)
            unless $key =~ /^[a-z]/i;
    }
    _trace(\@_) if $_TRACE;
    return $self->SUPER::put(@_, $_MODIFIED_FIELD => 1);
}

sub unsafe_get_escaped {
    my($self) = shift;
    my($value);
    if ($value = $self->unsafe_get(@_)) {
        $value =~ s/$_ESC_SEP/$_SEP/g;
        $value =~ s/$_ESC_ESC/$_ESC/g;
    }
    return $value;
}

sub put_escaped {
    my($self, %values) = @_;
    foreach my $value (values(%values)) {
        $value =~ s/$_ESC/$_ESC_ESC/g;
        $value =~ s/$_SEP/$_ESC_SEP/g;
    }
    return $self->put(%values);
}

sub _clear_prior_tags {
    my($req) = @_;
    my($r) = $req->get('r');
    # cookie has already been set, need to append multiple Set-Cookie vlaues
    foreach my $prior_tag (@{$_CFG->{prior_tags}}) {
        my($tag, $domain) = @$prior_tag;
        my($h) = $r->hostname;
        foreach my $d (
            undef,
            $h,
            !$domain ? ()
                : $domain eq $h
                ? ()
                : $domain,
        ) {
            $req->get('reply')->send_append_header(
                $r,
                'Set-Cookie',
                "$tag=; path=/; max-age=0"
                    . ($d ? "; domain=$d" : ''),
            );
        }
    }
    return;
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
    my($rows) = [split(/\s*[;,]\s*/, $cookie)];
    my($ignore_prior_tags) = grep(/^\s*$_CFG->{tag}\s*=/, @$rows) ? 1 : 0;
    foreach my $f (@$rows) {
        my($k, $v) = split(/\s*=\s*/, $f, 2);
        unless (defined($k) && defined($v) && length($v)) {
            _trace($k, ': ignoring other element') if $_TRACE;
            next;
        }
        $k = uc($k);
        unless ($k eq $_CFG->{tag}) {
            if ($_CFG->{prior_tags} && grep($k eq $_->[0], @{$_CFG->{prior_tags}})) {
                $items->{$_PRIOR_TAG_FIELD}++;
                next
                    if $ignore_prior_tags;
            }
            else {
                _trace('tag from another server or old tag: ', $k) if $_TRACE;
                next;
            }
        }
        if (exists($items->{$k})) {
#TODO: use the largest DATE_TIME value in the cookie to solve collisions
            b_warn('duplicate cookie value for key: ', $k,
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
    my($prior_tag) = delete($items->{$_PRIOR_TAG_FIELD});
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
            b_warn(
                'invalid cookie: encrypted=', $v, ' decrypted=', \@v);
            return undef;
        }
        while (my($k, $v) = each(%v)) {
            $values->{$k} = $v;
        }
    }
    if ($prior_tag) {
        $values->{$_PRIOR_TAG_FIELD}++;
        $values->{$_MODIFIED_FIELD}++;
    }
    return $values;
}

1;
