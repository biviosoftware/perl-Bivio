# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmInvite;
use strict;
$Bivio::Biz::Model::RealmInvite::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmInvite - interface to realm_invite_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmInvite;
    Bivio::Biz::Model::RealmInvite->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmInvite::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmInvite> is the create, read, update,
and delete interface to the C<realm_invite_t> table.

=cut

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::SQL::Constraint;
use Bivio::Type::DateTime;
use Bivio::Type::Email;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
use Bivio::Type::Text;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time> and I<title> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless $values->{creation_date_time};
    unless (defined($values->{title})) {
	# Set the title to Self if the realm and user are the same,
	# else set to the description of the role
	$values->{title} = $values->{realm_id} eq $values->{user_id}
		? 'Self' : $values->{role}->get_short_desc;
    }
    # Save the use who initiated the invite
    $values->{user_id}
	    = $self->get_request->get('auth_user')->get('realm_id')
		    unless defined($values->{user_id});
    return $self->SUPER::create($values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_invite_t',
	columns => {
            realm_invite_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            realm_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
            user_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
            email => ['Bivio::Type::Email',
    		Bivio::SQL::Constraint::NOT_NULL()],
            role => ['Bivio::Auth::Role',
    		Bivio::SQL::Constraint::NOT_ZERO_ENUM()],
	    title => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::NOT_ZERO_ENUM()],
	    creation_date_time => ['Bivio::Type::DateTime',
		Bivio::SQL::Constraint::NOT_NULL()],
            message => ['Bivio::Type::Text',
    		Bivio::SQL::Constraint::NONE()],
	    # unique(realm_id, email)
        },
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
