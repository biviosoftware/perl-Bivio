# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleRealmName;
use strict;
$Bivio::Delegate::SimpleRealmName::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::SimpleRealmName::VERSION;

=head1 NAME

Bivio::Delegate::SimpleRealmName - realm owner name, e.g. club or user name

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::SimpleRealmName;

=cut

=head1 EXTENDS

L<Bivio::Type::Name>

=cut

use Bivio::Type::Name;
@Bivio::Delegate::SimpleRealmName::ISA = ('Bivio::Type::Name');

=head1 DESCRIPTION

C<Bivio::Delegate::SimpleRealmName> RealmOwner.name.

=cut

=head1 CONSTANTS

=cut

=for html <a name="DEMO_CLUB"></a>

=head2 DEMO_CLUB : string

Name used for the demo club.

=cut

sub DEMO_CLUB {
    return 'demo_club';
}

=for html <a name="DEMO_CLUB_SUFFIX"></a>

=head2 DEMO_CLUB_SUFFIX : string

Suffix for a user's demo club.

=cut

sub DEMO_CLUB_SUFFIX {
    return '_'.DEMO_CLUB();
}

=for html <a name="OFFLINE_PREFIX"></a>

=head2 OFFLINE_PREFIX : string

Returns prefix character for offline names.

=cut

sub OFFLINE_PREFIX {
    return '=';
}

=for html <a name="TEST_SUFFIX"></a>

=head2 TEST_SUFFIX : string

Convention which identifies of test clubs and users.

=cut

sub TEST_SUFFIX {
    return '_test';
}

#=IMPORTS
use Bivio::HTML;
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DEMO_CLUB_SUFFIX) = DEMO_CLUB_SUFFIX();
my($_OFFLINE_PREFIX) = OFFLINE_PREFIX();

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
    return (undef, Bivio::TypeError::DEMO_CLUB_SUFFIX())
	    if $value =~ /$_DEMO_CLUB_SUFFIX/o;
    return $value;
}

=for html <a name="is_offline"></a>

=head2 is_offline(string value) : boolean

Returns true if the RealmName is a offline name.

=cut

sub is_offline {
    my(undef, $value) = @_;
    return defined($value) && $value =~ /^$_OFFLINE_PREFIX/o ? 1 : 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
