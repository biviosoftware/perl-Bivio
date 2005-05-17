# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::RealmType;
use strict;
$Bivio::Delegate::RealmType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::RealmType::VERSION;

=head1 NAME

Bivio::Delegate::RealmType - Realm types

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::RealmType;

=cut

=head1 EXTENDS

L<Bivio::Delegate>

=cut

use Bivio::Delegate;
@Bivio::Delegate::RealmType::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::RealmType> implements the common RealmTypes in bOP,
defined as follows:

=over 4

=item UNKNOWN

realm has not been determined

=item GENERAL

access to general areas (not club or user specific)

=item USER

access to a particular user

=item CLUB

access to a particular club

=back

You should extend this class if you have new RealmTypes in your application.
The numbers 0-19 are reserved by this module so your first RealmType would
look like:

    sub get_delegate_info {
	my($proto) = @_;
	return $proto->merge_task_info($proto->SUPER::get_delegate_info, [
	    MY_NEW_TYPE => [
	        20,
		undef,
		'access to some new type of realm',
	    ],
        ]);
    }									  

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 get_delegate_info() : array_ref

Returns standard realm types.

=cut

sub get_delegate_info {
    return [
	'UNKNOWN' => [
	    0,
	    undef,
	    'realm has yet to be established',
	],
	'GENERAL' => [
	    1,
	    undef,
	    'access to general areas (not club or user specific)',
	],
	'USER' => [
	    2,
	    undef,
	    'access to a particular user',
	],
	'CLUB' => [
	    3,
	    undef,
	    'access to a particular club',
	],
    ];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
