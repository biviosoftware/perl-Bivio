# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::RealmName;
use strict;
$Bivio::Type::RealmName::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::RealmName - realm owner name, e.g. club or user name

=head1 SYNOPSIS

    use Bivio::Type::RealmName;

=cut

=head1 EXTENDS

L<Bivio::Type::Name>

=cut

use Bivio::Type::Name;
@Bivio::Type::RealmName::ISA = ('Bivio::Type::Name');

=head1 DESCRIPTION

C<Bivio::Type::RealmName> is the name of a realm's owner.  There is a list of
invalid RealmName names.  Syntax is limited.

=cut


=head1 CONSTANTS

=cut

=for html <a name="DEMO_CLUB_SUFFIX"></a>

=head2 DEMO_CLUB_SUFFIX : string

Name used for the demo club.

=cut

sub DEMO_CLUB_SUFFIX {
    return '_demo_club';
}

#=IMPORTS
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DEMO_CLUB_SUFFIX) = DEMO_CLUB_SUFFIX();
my(%_RESERVED) = map {($_, 1)} qw(
    adm
    admin
    administrator
    advoco
    amanda
    amicus
    beta
    bin
    bivio
    cvs
    daemon
    dba
    decode
    dump
    dumper
    email
    ftp
    games
    gopher
    goto
    guest
    halt
    help
    home
    hostmaster
    httpd
    general
    info
    ingres
    jobs
    login
    logout
    mail
    majordomo
    manager
    messages
    mgfs
    my_club
    news
    nfs
    nobody
    operator
    oracle
    oraoper
    pilot
    postgres
    postmaster
    pub
    public
    redhat
    reqtrack
    research
    root
    sales
    setup
    shutdown
    site
    societas
    support
    sync
    sys
    sysop
    system
    toor
    ultra
    user
    usr
    uucp
    webmaster
    webmistress
    xfs
);

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Returns C<undef> if the name is empty or zero length.
Checks syntax and returns L<Bivio::TypeError|Bivio::TypeError>.

=cut

sub from_literal {
    my(undef, $value) = @_;
    return undef unless defined($value);
    # Leave middle spaces, because user can't have them
    $value =~ s/^\s+|\s+$//g;
    return undef unless length($value);
    $value = lc($value);
    # Must begin with a letter and be at least three chars
    return (undef, Bivio::TypeError::REALM_NAME())
	    unless $value =~ /^[a-z][a-z0-9_]{2,}$/;
    return (undef, Bivio::TypeError::EXISTS())
	    if defined($_RESERVED{$value});
    return (undef, Bivio::TypeError::DEMO_CLUB_SUFFIX())
	    if $value =~ /$_DEMO_CLUB_SUFFIX/o;
    return $value;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
