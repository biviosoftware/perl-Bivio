# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Email;
use strict;
$Bivio::Biz::Model::Email::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Email - interface to email_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::Email;
    Bivio::Biz::Model::Email->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Email::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::Email> is the create, read, update,
and delete interface to the C<email_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::Email;
use Bivio::Type::Location;
use Bivio::Type::PrimaryId;
use Bivio::Type::Email;

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

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'email_t',
	columns => {
            realm_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            location => ['Bivio::Type::Location',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            email => ['Bivio::Type::Email',
    		Bivio::SQL::Constraint::NOT_NULL_UNIQUE()],
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
