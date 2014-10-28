# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Email;
use strict;
use Bivio::Base 'Type.Line';
b_use('IO.ClassLoaderAUTOLOAD');

my($_DN) = b_use('Type.DomainName');
my($_C) = b_use('IO.Config');
my($_HTML) = b_use('Bivio.HTML');
my($_TE) = b_use('Bivio.TypeError');
my($_ATOM_ONLY_RE) = qr{^@{[b_use('Mail.RFC822')->ATOM_ONLY_ADDR]}$}ois;
my($_OP_SEP) = '*';
my($_PLUS_SEP) = '+';
my($_MAX_LOCAL_IN_IGNORE) = 30;

sub IGNORE_PREFIX {
    return 'ignore-';
}

sub INVALID_PREFIX {
    return 'invalid:';
}

sub compare_defined {
    my(undef, $left, $right) = @_;
    return lc($left) cmp lc($right);
}

sub equals_domain {
    my($proto, $value, $domain) = @_;
    return lc($domain) eq $proto->get_domain_part($value) ? 1 : 0
}

sub format_email {
    my($proto, $local_or_realm_or_email, $domain, $plus, $op, $req) = @_;
    return lc($local_or_realm_or_email)
	if $local_or_realm_or_email =~ /\@/;
    my($local) = ($op ? $op . $_OP_SEP : '')
	. $local_or_realm_or_email
	. ($plus ? $_PLUS_SEP . $plus : '');
    return $proto->join_parts($local, $domain)
	if $domain;
    return FacadeComponent_Email()->format($local, $req)
        if $req->unsafe_get('UI.Facade');
    return $proto->join_parts($local, b_use('Bivio.BConf')->bconf_host_name);
}

sub format_ignore {
    my($proto, $local, $req) = @_;
    $local =~ s/\W/-/g;
    return $proto->format_email(
	$proto->IGNORE_PREFIX . substr($local, 0, $_MAX_LOCAL_IN_IGNORE),
	undef,
	undef,
	undef,
	$req,
    );
}

sub format_ignore_random {
    my($proto, $base, $req) = @_;
    $base ||= 'nobody';
    return $proto->format_ignore("$base-" . Biz_Random()->hex_digits(8), $req);
}

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return undef
	unless defined($value);
    $value =~ s/^\s+|\s+$//g;
    return undef
	unless length($value);
    return (undef, $_TE->TOO_LONG)
	if length($value) > $proto->get_width;
    $value = lc($value);
    return $value
	if $value =~ $_ATOM_ONLY_RE
	&& $value =~ /.+\..*/;
    return (undef, $_TE->EMAIL);
}

sub get_domain_part {
    my($proto, $value) = @_;
    return (shift->split_parts(@_))[1];
}

sub get_local_part {
    return (shift->split_parts(@_))[0];
}

sub invalidate {
    my($proto, $email) = @_;
#TODO: elimnate reference
    $$email = substr(
	$proto->INVALID_PREFIX . $$email,
	0,
	$proto->get_width,
    );
    return $$email;
}

sub is_ignore {
    my($proto, $email) = @_;
    return !$proto->is_valid($email) ? 1
	: $email =~ /^@{[$proto->IGNORE_PREFIX]}/ios ? 1 : 0;
}

sub is_valid {
    my($proto, $email) = @_;
    return defined($email) && $email =~ $_ATOM_ONLY_RE ? 1 : 0;
}

sub join_parts {
    my($proto, $local, $domain) = @_;
    return $proto->from_literal_or_die(join('@', $local, $domain));
}

sub replace_domain {
    my($proto, $email, $new_domain) = @_;
    return $proto->join_parts(
	$proto->get_local_part($email) || b_die($email, ': malformed email'),
	$new_domain,
    );
}

sub split_parts {
    my(undef, $value) = @_;
    return (undef, undef, undef, undef, undef)
	unless $value;
    return ($1, $2, $1, undef, undef)
        if $_C->is_test
        && $value =~ b_use('TestLanguage.HTTP')->LOCAL_EMAIL_RE;
    my($local, $domain) = lc($value) =~ /^(.+?)\@(.+)$/;
    return (undef, undef, undef, undef, undef)
	unless $domain;
    my($base) = $local;
    my($plus) = $1
	if $base =~ s/\Q$_PLUS_SEP\E(.+)$//o;
    my($op) = $1
	if $base =~ s/^(\w+?)\Q$_OP_SEP\E//o;
    return length($base) ? ($local, $domain, $base, $plus, $op)
	: ($local, $domain, undef, undef, undef);
}

sub to_json {
    my($proto, $value) = @_;
    return ${b_use('MIME.JSON')->to_text(_to_xml($proto, $value))};
}

sub to_xml {
    my($proto, $value) = @_;
    return $_HTML->escape(_to_xml($proto, $value));
}

sub _to_xml {
    my($proto, $value) = @_;
    return ''
	if !defined($value) || $proto->is_ignore($value);
    return $value;
}

1;
