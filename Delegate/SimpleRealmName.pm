# Copyright (c) 2001-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleRealmName;
use strict;
use Bivio::Base 'Type.Name';

my($_TE) = b_use('Bivio.TypeError');
my($_RESERVED) = {map(($_ => 1), qw(
    abuse
    admin
    administrator
    amanda
    apache
    api
    beta
    bin
    bounce
    cvs
    daemon
    dav
    dba
    dbus
    decode
    demo
    dump
    dumper
    email
    etc
    ftp
    games
    gdm
    general
    gopher
    goto
    guest
    haldaemon
    halt
    help
    home
    hostmaster
    httpd
    ignore
    info
    ingres
    ldap
    login
    logout
    lp
    mail
    mailnull
    majordomo
    manager
    messages
    mgfs
    my_club
    my_club_site
    my_site
    mysql
    naic
    named
    news
    nfs
    nobody
    ntp
    operator
    oracle
    oraoper
    owner
    pilot
    postfix
    postgres
    postmaster
    pub
    public
    reqtrack
    research
    root
    rpcuser
    sales
    setup
    shutdown
    site
    squid
    sshd
    sync
    sys
    sysop
    system
    toor
    ultra
    unsubscribe
    user
    usr
    uucp
    var
    vcsa
    webmaster
    webmistress
    xfs
))};

sub OFFLINE_PREFIX {
    # Returns prefix character for offline names.
    return '=';
}

sub REGEXP {
    # Returns regular expression used by from_literal.
    return qr/^[a-z][a-z0-9_]{2,}$/i;
}

sub SPECIAL_PLACEHOLDER {
    return 'my';
}

sub SPECIAL_SEPARATOR {
    # The special separator is used in URIs and to group realm names (see ForumName).
    # Don't assume '-'.  Rather explicitly couple with this call.
    return '-';
}

sub check_reserved_name {
    my(undef, $value) = @_;
    return $_RESERVED->{$value} ? $_TE->EXISTS : undef;
}

sub clean_and_trim {
    my($proto, $value) = @_;
    $value =~ s/\W+//g;
    return shift->SUPER::clean_and_trim(lc($value));
}

sub from_literal {
    my($proto, $value) = @_;
    $value =~ s/^\s+|\s+$//g
	if defined($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless defined($v);
    return (undef, Bivio::TypeError->REALM_NAME)
        unless $proto->internal_is_realm_name($v);
    return $proto->process_name($v);
}

sub get_min_width {
    return 3;
}

sub internal_is_realm_name {
    my($proto, $value) = @_;
    # Returns true if the name is allowed. May be overridden by subclasses.
    # Must begin with a letter and be at least three chars
    return $value =~ $proto->REGEXP ? 1 : 0;
}

sub is_offline {
    my($proto, $value) = @_;
    # Returns true if the RealmName is a offline name.
    return defined($value) && $value =~ /^@{[$proto->OFFLINE_PREFIX]}/ ? 1 : 0;
}

sub make_offline {
    my($proto, $value) = @_;
    # Returns an offline realm name.
    return $value if $proto->is_offline($value);
    $value = substr($value, 0, $proto->get_width - 1)
	if length($value) >= $proto->get_width;
    return $proto->OFFLINE_PREFIX . $value;
}

sub process_name {
    my($proto, $value) = @_;
    # Returns the value, converted to lowercase. May be overridden by subclasses.
    return lc($value);
}

sub unsafe_from_uri {
    my($proto, $value) = @_;
    return $value
	if ($value || '') eq $proto->SPECIAL_PLACEHOLDER;
    return undef
	unless $value = ($proto->SUPER::from_literal($value))[0];
    # We allow dashes in URI names (my-site and other constructed names)
    my($s) = $proto->SPECIAL_SEPARATOR;
    (my $v = $value) =~ s/$s//g;
    return $proto->internal_is_realm_name($v) && $value !~ /^$s/
	? $proto->process_name($value) : undef;
}

1;
