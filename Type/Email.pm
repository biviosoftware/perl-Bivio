# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Email;
use strict;
use Bivio::Base 'Type.Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DN) = b_use('Type.DomainName');
my($_C) = b_use('IO.Config');
my($_HTML) = b_use('Bivio.HTML');
my($_TE) = b_use('Bivio.TypeError');
my($_ATOM_ONLY_RE) = qr{^@{[b_use('Mail.RFC822')->ATOM_ONLY_ADDR]}$}ois;

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

sub format_ignore {
    my($proto, $base, $req) = @_;
    return $req->format_email($proto->IGNORE_PREFIX . $base);
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
    return lc($1)
        if $value
        && $_C->is_test
        && $proto->get_local_part($value)
	=~ b_use('TestLanguage.HTTP')->LOCAL_EMAIL_DOMAIN_RE;
    return (shift->split_parts(@_))[1];
}

sub get_local_part {
    return (shift->split_parts(@_))[0];
}

sub invalidate {
    my($proto, $email) = @_;
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
    return $value && $value =~ /^(.+?)\@(.+)$/
	? (lc($1), lc($2))
	: (undef, undef);
}

sub to_xml {
    my($proto, $value) = @_;
    return !defined($value) || $proto->is_ignore($value) ? ''
	: $_HTML->escape($value);
}

1;
