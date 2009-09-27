# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Email;
use strict;
use Bivio::Base 'Type.Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_HTML) = __PACKAGE__->use('Bivio.HTML');
my($_TE) = __PACKAGE__->use('Bivio.TypeError');
my($_IGNORE) = __PACKAGE__->IGNORE_PREFIX;
my($_INVALID) = __PACKAGE__->INVALID_PREFIX;
my($_ATOM_ONLY_ADDR) = __PACKAGE__->use('Mail.RFC822')->ATOM_ONLY_ADDR;

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
	if $value =~ /^$_ATOM_ONLY_ADDR$/os && $value =~ /.+\..*/;
    return (undef, $_TE->EMAIL);
}

sub get_domain_part {
    my($proto, $value) = @_;
    return $1
        if $value
            && UNIVERSAL::isa('Bivio::Agent::Request', 'Bivio::UNIVERSAL')
            && Bivio::Agent::Request->is_test
            && $proto->get_local_part($value) =~
                b_use('TestLanguage.HTTP')->LOCAL_EMAIL_DOMAIN_RE;
    return (shift->split_parts(@_))[1];
}

sub get_local_part {
    return (shift->split_parts(@_))[0];
}

sub invalidate {
    my($proto, $email) = @_;
    $$email = substr($_INVALID . $$email, 0, $proto->get_width);
    return;
}

sub is_ignore {
    my($proto, $email) = @_;
    return !$proto->is_valid($email) ? 1
	: $email =~ /^$_IGNORE/ios ? 1 : 0;
}

sub is_valid {
    my($proto, $email) = @_;
    return defined($email) && $email =~ /^$_ATOM_ONLY_ADDR$/os ? 1 : 0;
}

sub join_parts {
    my($proto, $local, $domain) = @_;
    return $proto->from_literal_or_die(join('@', $local, $domain));
}

sub split_parts {
    my(undef, $value) = @_;
    return $value && $value =~ /^(.+?)\@(.+)$/ ? ($1, $2) : (undef, undef);
}

sub to_xml {
    my($proto, $value) = @_;
    return !defined($value) || $proto->is_ignore($value) ? ''
	: $_HTML->escape($value);
}

1;
