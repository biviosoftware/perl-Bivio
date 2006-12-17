# Copyright (c) 2001-2005 bivio Software, Inc.  All rights reserved.
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

=for html <a name="REGEXP"></a>

=head2 REGEXP : regexp_ref

Returns regular expression used by from_literal.

=cut

sub REGEXP {
    return qr/^[a-z][a-z0-9_]{2,}$/i;
}

=for html <a name="SPECIAL_SEPARATOR"></a>

=head2 SPECIAL_SEPARATOR : string

The special separator is used in URIs and to group realm names (see ForumName).
Don't assume '-'.  Rather explicitly couple with this call.

=cut

sub SPECIAL_SEPARATOR {
    return '-';
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
	unless defined($v);
    return (undef, Bivio::TypeError->REALM_NAME)
        unless $proto->internal_is_realm_name($v);
    return $proto->process_name($v);
}

=for html <a name="internal_is_realm_name"></a>

=head2 static internal_is_realm_name(string name) : boolean

Returns true if the name is allowed. May be overridden by subclasses.
Must begin with a letter and be at least three chars

=cut

sub internal_is_realm_name {
    my($proto, $value) = @_;
    return $value =~ $proto->REGEXP ? 1 : 0;
}

=for html <a name="is_offline"></a>

=head2 is_offline(string value) : boolean

Returns true if the RealmName is a offline name.

=cut

sub is_offline {
    my(undef, $value) = @_;
    return defined($value) && $value =~ /^$_OFFLINE_PREFIX/o ? 1 : 0;
}

=for html <a name="make_offline"></a>

=head2 make_offline(string value) : string

Returns an offline realm name.

=cut

sub make_offline {
    my($proto, $value) = @_;
    return $value if $proto->is_offline($value);
    $value = substr($value, 0, $proto->get_width - 1)
	if length($value) >= $proto->get_width;
    return $_OFFLINE_PREFIX . $value;
}

=for html <a name="process_name"></a>

=head2 static process_name(string value) : string

Returns the value, converted to lowercase. May be overridden by subclasses.

=cut

sub process_name {
    my($proto, $value) = @_;
    return lc($value);
}

=for html <a name="unsafe_from_uri"></a>

=head2 static unsafe_from_uri(string name) : string

Returns the name (possibly cleaned up) or undef, if not valid.

=cut

sub unsafe_from_uri {
    my($proto, $value) = @_;
    return undef
	unless $value = ($proto->SUPER::from_literal($value))[0];
    # We allow dashes in URI names (my-site and other constructed names)
    my($s) = $proto->SPECIAL_SEPARATOR;
    (my $v = $value) =~ s/$s//og;
    return $proto->internal_is_realm_name($v) && $value !~ /^$s/o
	? $proto->process_name($value) : undef;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
