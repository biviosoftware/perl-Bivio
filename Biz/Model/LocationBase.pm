# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::LocationBase;
use strict;
$Bivio::Biz::Model::LocationBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::LocationBase::VERSION;

=head1 NAME

Bivio::Biz::Model::LocationBase - base class for Address, Email, etc.

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::LocationBase;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::LocationBase::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::LocationBase> base class for Address, Email, etc.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

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

=for html <a name="unauth_load"></a>

=head2 unauth_load(hash_ref query) : boolean

=head2 unauth_load(hash query) : boolean

Sets I<location> if not set, then calls SUPER.

=cut

sub unauth_load {
    my($self) = shift;
    my($query) = int(@_) == 1 ? @_ : {@_};
    $query->{location} = Bivio::Type::Location::HOME()
	    unless $query->{location};
    return $self->SUPER::unauth_load($query);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
