# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Visitor;
use strict;
$Bivio::Biz::Model::Visitor::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Visitor - represents a visitor (non-user)

=head1 SYNOPSIS

    use Bivio::Biz::Model::Visitor;
    Bivio::Biz::Model::Visitor->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Visitor::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::Visitor> represents a non-user, i.e. a "unique" visitor.

=cut

#=IMPORTS
use Bivio::Type::Name;

#=VARIABLES
my($_CLIENT_ADDR_LENGTH) = Bivio::Type::Name->get_width;

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{creation_date_time} ||= Bivio::Type::DateTime->now();
    $values->{user_id} ||= undef;
    $values->{client_addr} = substr($values->{client_addr}, 0,
            $_CLIENT_ADDR_LENGTH) if defined($values->{client_addr});
    return $self->SUPER::create($values);
}

=for html <a name="get_first_id_for_user"></a>

=head2 get_first_id_for_user(string user_id) : string

Returns newest visitor record for cookie.

=cut

sub get_first_id_for_user {
    my($self, $user_id) = @_;
    my($it) = $self->unauth_iterate_start('visitor_id desc',
	    {user_id => $user_id});
    my($res) = $self->iterate_next_and_load($it)
	    ? $self->get('visitor_id') : undef;
    $self->iterate_end($it);
    return $res;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'visitor_t',
	columns => {
            visitor_id => ['PrimaryId', 'PRIMARY_KEY'],

	    # Was this visitor converted to a user?
	    user_id => ['PrimaryId', 'NONE'],

	    # Only store first part, because we don't want to blow up
	    # cookie.  Data is saved in cookie before it is written to
	    # db record.  See Action::Referral.
	    entry_uri => ['Line', 'NONE'],
	    # Propagate misspelling as per RFC2616
	    referer_uri => ['Line', 'NONE'],
	    referer_realm_id => ['PrimaryId', 'NONE'],
	    client_addr => ['Name', 'NOT_NULL'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
        },

	# A realm can get at its referrals, but not at all referrals
	auth_id => 'referer_realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
