# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleRealmName;
use strict;
$Bivio::Delegate::SimpleRealmName::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::SimpleRealmName::VERSION;

=head1 NAME

Bivio::Delegate::SimpleRealmName - validates RealmOwner.name

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

C<Bivio::Delegate::SimpleRealmName> validates RealmOwner.name values.

=cut

=head1 CONSTANTS

=cut

=for html <a name="OFFLINE_PREFIX"></a>

=head2 OFFLINE_PREFIX : string

Returns prefix character for offline names.

=cut

sub OFFLINE_PREFIX {
    return '=';
}

#=IMPORTS
use Bivio::TypeError;

#=VARIABLES
my($_OFFLINE_PREFIX) = OFFLINE_PREFIX();

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Trims whitespace and checks syntax an returns (value).

Returns C<undef> if the name is empty or zero length.

Return (C<undef>, L<Bivio::TypeError::REALM_NAME|Bivio::TypeError::REALM_NAME>)
if the syntax check fails.

=cut

sub from_literal {
    my($proto, $value) = @_;
    $value =~ s/^\s+|\s+$//g
	if defined($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless $v;
    $v = lc($v);
    return (undef, Bivio::TypeError->REALM_NAME)
        unless $proto->internal_is_realm_name($v);
    return $v;
}

=for html <a name="internal_is_realm_name"></a>

=head2 static internal_is_realm_name(string name) : boolean

Returns true if the name is allowed. May be overridden by subclasses.
Must begin with a letter and be at least three chars

=cut

sub internal_is_realm_name {
    my($proto, $value) = @_;
    return $value =~ /^[a-z][a-z0-9_]{2,}$/i ? 1 : 0;
}

=for html <a name="is_offline"></a>

=head2 is_offline(string value) : boolean

Returns true if the RealmName is a offline name.

=cut

sub is_offline {
    my(undef, $value) = @_;
    return defined($value) && $value =~ /^$_OFFLINE_PREFIX/o ? 1 : 0;
}

=for html <a name="unsafe_from_uri"></a>

=head2 static unsafe_from_uri(string name) : string

Returns the name (possibly cleaned up) or undef, if not valid.

=cut

sub unsafe_from_uri {
    my($proto, $value) = @_;
    return undef
	unless ($proto->SUPER::from_literal($value))[0];
    # We allow dashes in URI names (my-site and other constructed names)
    (my $v = $value) =~ s/-//g;
    return $proto->internal_is_realm_name($v) && $value !~ /^-/
	? $value : undef;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
