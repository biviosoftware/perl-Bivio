# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::RealmUser;
use strict;
$Bivio::Biz::Model::RealmUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmUser - interface to realm_user_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmUser;
    Bivio::Biz::Model::RealmUser->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmUser::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmUser> is the create, read, update,
and delete interface to the C<realm_user_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::PrimaryId;
use Bivio::Type::Name;
use Bivio::Auth::Role;
use Bivio::Type::DateTime;

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
    return $self->SUPER::create($values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_user_t',
	columns => {
            realm_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            user_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            role => ['Bivio::Auth::Role',
    		Bivio::SQL::Constraint::NOT_NULL()],
	    title => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::NOT_NULL()],
	    creation_date_time => ['Bivio::Type::DateTime',
		Bivio::SQL::Constraint::NOT_NULL()],
        },
	auth_id => 'realm_id',
#TODO: SECURITY: If user_id known, does that mean can get to all user's info?
	other => [
	    # User_1 is the owner, if the realm_type is a user.
	    [qw(realm_id Club.club_id User_1.user_id)],
	    # User_2 is the the "realm_user"
	    [qw(user_id User_2.user_id)],
	],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
