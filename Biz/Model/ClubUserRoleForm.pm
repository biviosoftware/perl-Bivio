# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ClubUserRoleForm;
use strict;
$Bivio::Biz::Model::ClubUserRoleForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ClubUserRoleForm - edit a club member's role

=head1 SYNOPSIS

    use Bivio::Biz::Model::ClubUserRoleForm;
    Bivio::Biz::Model::ClubUserRoleForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::ClubUserRoleForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::ClubUserRoleForm> edit a club user's function
and privileges.

=cut

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::Auth::RoleSet;
use Bivio::TypeError;
use Bivio::SQL::Constraint;
use Bivio::Type::ClubUserTitle;
use Bivio::Biz::Model::RealmUser;

#=VARIABLES
my($_CLUB_ROLES) = Bivio::Biz::Model::RealmUser::VALID_CLUB_ROLES();

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Fills in the values from the list model which is already loaded.

=cut

sub execute_empty {
    my($self) = @_;
    # Load the row
    my($req) = $self->get_request;
    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $self->die(Bivio::DieCode::NOT_FOUND())
	    unless $list->set_cursor(0);

    # Fill properties from the row.  They match pretty much.
    my($properties) = $self->internal_get;
    my(@p) = qw(RealmOwner.name
        RealmOwner.display_name
        RealmUser.title
        RealmUser.role
	RealmUser.realm_id
        RealmUser.user_id);
    @{$properties}{@p} = $list->get(@p);
    # Title is special case, because is a string in DB and enum in UI
    $properties->{title} = Bivio::Type::ClubUserTitle->from_any(
	    $properties->{'RealmUser.title'});
    delete($properties->{'RealmUser.title'});
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()

=cut

sub execute_input {
    my($self) = @_;
    my($req) = $self->get_request;
    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $self->die(Bivio::DieCode::NOT_FOUND())
	    unless $list->set_cursor(0);

    # Make sure we don't let admin clear last admin.
    my($a) = Bivio::Auth::Role::ADMINISTRATOR();
    my($properties) = $self->internal_get;
    $properties->{'RealmUser.role'} = $properties->{title}->get_role();
    if ($list->get('RealmUser.role') == $a
	    && $properties->{'RealmUser.role'} != $a) {
	my($realm_id) = $list->get('RealmUser.realm_id');
	# Check the count
	my($ai) = $a->as_int;
	my($statement) = Bivio::SQL::Connection->execute(<<"EOF");
	    select count(*) from realm_user_t
	    where role = $ai and realm_id = $realm_id
EOF
	if ($statement->fetchrow_arrayref->[0] <= 1) {
	    $self->internal_put_error('title',
		    Bivio::TypeError::LAST_CLUB_ADMIN());
	    return;
	}
    }

    # Load the RealmUser model (blows up if doesn't load)
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
    $realm_user->load(user_id => $list->get('RealmUser.user_id'));
    my($values) = $self->get_model_properties('RealmUser');
    # Cumbersome title...
    $values->{title} = $properties->{title}->get_short_desc;
    $realm_user->update($values);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	visible => [
	    {
		name => 'title',
		type => 'Bivio::Type::ClubUserTitle',
		constraint => Bivio::SQL::Constraint::NOT_ZERO_ENUM(),
	    },
	],
	auth_id => [
	    'RealmUser.realm_id',
	],
	other => [
	    'RealmUser.role',
	],
	primary_key => [
	    ['RealmUser.user_id', 'RealmOwner.realm_id'],
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
