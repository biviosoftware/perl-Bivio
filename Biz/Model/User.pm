# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::User;
use strict;
$Bivio::Biz::Model::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::User - interface to user_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::User;
    Bivio::Biz::Model::User->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::User::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::User> is the create, read, update,
and delete interface to the C<user_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::Enum;
use Bivio::Type::Gender;
use Bivio::Type::Name;
use Bivio::Type::Date;
use Bivio::Type::PrimaryId;
use Bivio::Type::Location;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<gender> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{gender} = Bivio::Type::Gender::UNKNOWN();
    return $self->SUPER::create($values);
}

=for html <a name="format_full_name"></a>

=head2 format_full_name() : string

Returns the first, middle, and last names as one string.

=cut

sub format_full_name {
    my($self) = @_;
    # Have at least on name or returns undef
    my($res) = undef;
    foreach my $n ($self->unsafe_get(qw(first_name middle_name last_name))) {
	$res .= $n.' ' if defined($n);
    }
    # Get rid of last ' '
    chop($res) if defined($res);
    return $res;
}

=for html <a name="get_email_address"></a>

=head2 get_email_address() : string

Returns the "first" email address.

=cut

sub get_email_address {
#TODO: Need to make this real
    return shift->get_email_addresses();
}

=for html <a name="get_email_addresses"></a>

=head2 get_email_addresses() : array

=head2 get_email_addresses(Bivio::Type::Location which) : array

Returns an array of email addresses for this user.  Returns
a particular email address (starting at number 0).

=cut

sub get_email_addresses {
    my($self, $which) = @_;
    my($loc) = $which ? $which : Bivio::Type::Location::HOME();
    my($email) = Bivio::Biz::Model::Email->new($self->get_request);
    return $which ? [] : undef unless $email->unauth_load(
	    location => $loc, realm_id => $self->get('user_id'));
    return $which ? [$email->get('email')] : $email->get('email');
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'user_t',
	columns => {
            user_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            first_name => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::NONE()],
            middle_name => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::NONE()],
            last_name => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::NONE()],
            gender => ['Bivio::Type::Gender',
    		Bivio::SQL::Constraint::NOT_NULL()],
            birth_date => ['Bivio::Type::Date',
    		Bivio::SQL::Constraint::NONE()],
        },
	auth_id => 'user_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
