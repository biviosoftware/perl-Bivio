# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Address;
use strict;
$Bivio::Biz::Model::Address::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Address - interface to address_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::Address;
    Bivio::Biz::Model::Address->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Address::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::Address> is the create, read, update,
and delete interface to the C<address_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::Country;
use Bivio::Type::Enum;
use Bivio::Type::Line;
use Bivio::Type::Location;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<location> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{location} = Bivio::Type::Location::HOME()
	    unless $values->{location};
    return $self->SUPER::create($values);
}

=for html <a name="format"></a>

=head2 format() : string

Returns the street1, street2, city, state, zip, and country as
a single string (with embedded newlines).

=cut

sub format {
    my($self) = @_;
    my($sep) = ', ';
    my($csz) = undef;
    foreach my $n ($self->unsafe_get(qw(city state zip))) {
	$csz .= $n.$sep if defined($n);
	$sep = '  ';
    }
    chop($csz), chop($csz) if defined($csz);
    my($res) = undef;
    my(@f) = $self->unsafe_get(qw(street1 street2 country));
    splice(@f, 2, 0, $csz);
    foreach my $n (@f) {
	$res .= $n."\n" if defined($n);
    }
    chop($res) if defined($res);
    return $res;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'address_t',
	columns => {
            realm_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    location => ['Bivio::Type::Location',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    street1 => ['Bivio::Type::Line',
    		Bivio::SQL::Constraint::NONE()],
	    street2 => ['Bivio::Type::Line',
    		Bivio::SQL::Constraint::NONE()],
	    city => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::NONE()],
	    state => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::NONE()],
	    zip => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::NONE()],
	    country => ['Bivio::Type::Country',
    		Bivio::SQL::Constraint::NONE()],
        },
	auth_id => 'realm_id',
    };
}

=for html <a name="unauth_load"></a>

=head2 unauth_load(hash query) : boolean

Sets I<location> if not set, then calls SUPER.

=cut

sub unauth_load {
    my($self, %query) = @_;
    $query{location} = Bivio::Type::Location::HOME() unless $query{location};
    return $self->SUPER::unauth_load(%query);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
