# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ClubUser;
use strict;
$Bivio::Biz::ClubUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::ClubUser - user settings related to a specific club

=head1 SYNOPSIS

    use Bivio::Biz::ClubUser;
    Bivio::Biz::ClubUser->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::ClubUser::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::ClubUser>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Error;
use Bivio::Biz::FieldDescriptor;
use Bivio::IO::Trace;
use Bivio::SQL::Support;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_PROPERTY_INFO) = {
    'club_id' => ['Club Internal ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    'user_id' => ['User Internal ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    'role' => ['Role',
	    Bivio::Biz::FieldDescriptor->lookup('ROLE', 2)],
    'email_mode' => ['Email Forwarded',
	    Bivio::Biz::FieldDescriptor->lookup('BOOLEAN', 1)]
    };

my($_SQL_SUPPORT) = Bivio::SQL::Support->new('club_user_t',
	keys(%$_PROPERTY_INFO));

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::ClubUser

Creates a user club settings model.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::PropertyModel::new($proto, 'club_user',
	    $_PROPERTY_INFO);

    $self->{$_PACKAGE} = {};
    $_SQL_SUPPORT->initialize();

    return $self;
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash new_values) : boolean

Creates a new model in the database with the specified value. After creation,
this instance has the same values.

=cut

sub create {
    my($self, $new_values) = @_;
    my($fields) = $self->{$_PACKAGE};

    # clear the status from previous invocations
    $self->get_status()->clear();

    return $_SQL_SUPPORT->create($self, $self->internal_get_fields(),
	    $new_values);
}

=for html <a name="delete"></a>

=head2 delete() : boolean

Deletes the current model from the database. Returns 1 if successful,
0 otherwise.

=cut

sub delete {
    my($self) = @_;

    return $_SQL_SUPPORT->delete($self, 'where club_id=? and user_id=?',
	    $self->get('club_id'), $self->get('user_id'));
}

=for html <a name="find"></a>

=head2 load(FindParams fp) : boolean

Finds the user given the specified search parameters. Valid find keys
are 'club' and 'user_id'.

=cut

sub load {
    my($self, $fp) = @_;

    # clear the status from previous invocations
    $self->get_status()->clear();

    if ($fp->has_keys('club_id', 'user_id')) {
	return $_SQL_SUPPORT->load($self, $self->internal_get_fields(),
		'where club_id=? and user_id=?', $fp->get('club_id'),
		$fp->get('user_id'));
    }

    $self->get_status()->add_error(
	    Bivio::Biz::Error->new("Club user not found"));
    return 0;
}

=for html <a name="get_heading"></a>

=head2 get_heading() : string

Returns the user's full name.

=cut

sub get_heading {
    my($self) = @_;

    return 'Club User Information';
}
=for html <a name="get_title"></a>

=head2 get_title() : string

Returns the user's full name.

=cut

sub get_title {
    my($self) = @_;
    return 'Club User Information';
}

=for html <a name="update"></a>

=head2 update(hash new_values) : boolean

Updates the current model's values.
NOTE: find should be called prior to an update.

=cut

sub update {
    my($self, $new_values) = @_;

    return $_SQL_SUPPORT->update($self, $self->internal_get_fields(),
	    $new_values, 'where club_id=? and user_id=?',
	    $self->get('club_id'), $self->get('user_id'));
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
