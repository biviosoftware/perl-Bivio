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
use Bivio::Auth::Role;
use Bivio::Auth::RoleSet;
use Bivio::SQL::Constraint;
use Bivio::Type::DateTime;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;

#=VARIABLES
my($_CLUB_ROLES) = '';
Bivio::Auth::RoleSet->set(\$_CLUB_ROLES,
	Bivio::Auth::Role::GUEST(),
	Bivio::Auth::Role::MEMBER(),
	Bivio::Auth::Role::ACCOUNTANT(),
	Bivio::Auth::Role::ADMINISTRATOR(),
	);

=head1 CONSTANTS

=cut

=for html <a name="VALID_CLUB_ROLES"></a>

=head2 VALID_CLUB_ROLES : string

Value is a L<Bivio::Auth::RoleSet|Bivio::Auth::RoleSet>.

=cut

sub VALID_CLUB_ROLES {
    return $_CLUB_ROLES;
}

=head1 METHODS

=cut

#TODO: Add code to make sure don't delete last admin.
#      See ClubUserForm.  Throw type error on field and wille
#      be picked up by form.

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
	    # User_1 is the realm, if the realm_type is a user.
	    [qw(realm_id Club.club_id User_1.user_id RealmOwner_1.realm_id)],
	    # User_2 is the the "realm_user"
	    [qw(user_id User_2.user_id  RealmOwner_2.realm_id)],
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
