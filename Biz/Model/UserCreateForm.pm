# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserCreateForm;
use strict;
$Bivio::Biz::Model::UserCreateForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::UserCreateForm::VERSION;

=head1 NAME

Bivio::Biz::Model::UserCreateForm - create a new user

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserCreateForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::UserCreateForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserCreateForm> creates a new user.  Subclasses may want
to override this form.

=cut

#=IMPORTS
use Bivio::Auth::RealmType;
use Bivio::IO::Trace;
use Bivio::Type::Honorific;
use Bivio::Type::Location;
use Bivio::Type::Name;
use Bivio::Type::Password;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Create the RealmOwner, User, Email, and RealmUser models.
Logs in as the new user.

=cut

sub execute_ok {
    my($self) = @_;
    Bivio::Biz::Model->get_instance('UserLoginForm')->execute(
	$self->get_request,
	{realm_owner => ($self->internal_create_models)[0]});
    return;
}

=for html <a name="internal_create_models"></a>

=head2 internal_create_models() : array

Creates User, RealmOwner, Email and RealmUser models.
Returns the RealmOwner and User created.

Sets the password to INVALID if does not exist.
Email is set to an ignored value if it doesn't exist.

The only difference between this method and execute_ok is that
the user is logged in at that point.

Will not create email if value is
L<Bivio::Type::Email::IGNORE_PREFIX|Bivio::Type::Email::IGNORE_PREFIX>.

=cut

sub internal_create_models {
    my($self) = @_;
    my($req) = $self->get_request;
    my($user) = $self->new_other('User')->create(
        $self->parse_display_name($self->get('RealmOwner.display_name')));
    my($realm) = $self->new_other('RealmOwner')->create({
	realm_id => $user->get('user_id'),
	name =>	 $self->unsafe_get('RealmOwner.name')
	    || 'u' . $user->get('user_id'),
	realm_type => Bivio::Auth::RealmType->USER,
	password => $self->has_keys('RealmOwner.password')
	    ? Bivio::Type::Password->encrypt(
	        $self->get('RealmOwner.password'))
	    : Bivio::Type::Password->INVALID,
	display_name => $self->get('RealmOwner.display_name'),
    });
    $self->new_other('Email')->create({
	realm_id => $user->get('user_id'),
	email => $self->unsafe_get('Email.email')
	    || $req->format_email(Bivio::Type::Email->IGNORE_PREFIX
	    . $realm->get('name')
	    . '-' . time),
	location => Bivio::Type::Location->HOME,
	want_bulletin => 0,
    }) unless ($self->unsafe_get('Email.email') || '')
	eq Bivio::Type::Email->IGNORE_PREFIX;
    $self->new_other('RealmUser')->create({
	realm_id => $user->get('user_id'),
	user_id => $user->get('user_id'),
	honorific => Bivio::Type::Honorific->SELF,
    });
    return ($realm, $user);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
	visible => [
	    'RealmOwner.display_name',
	    'Email.email',
            'RealmOwner.password',
	    {
		name => 'confirm_password',
		type => 'Password',
		constraint => 'NOT_NULL',
	    },
	],
	other => [
	    {
		# Optionally, set user name explicitly
		name => 'RealmOwner.name',
		constraint => 'NONE',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="parse_display_name"></a>

=head2 parse_display_name(string display_name) : hash_ref

Returns a hash_ref of first_name, middle_name, last_name parsed from the
display_name.  Suitable for L<Bivio::Biz::Model::User|Bivio::Biz::Model::User>
updates.

=cut

sub parse_display_name {
    my($self, $display_name) = @_;
    my($first, $middle, @last) = split(' ', $display_name);

    # split on spaces, last name gets all the extra words
    my($last);
    if (int(@last)) {
        $last = join(' ', @last);
    }
    else {
        $last = $middle;
        $middle = undef;
    }
    my($result) = {
        first_name => _trim($first),
        middle_name => _trim($middle),
        last_name => _trim($last),
    };
    _trace($result) if $_TRACE;
    return $result;
}

=for html <a name="validate"></a>

=head2 validate()

Ensures the fields are valid.

=cut

sub validate {
    my($self) = @_;
    $self->internal_put_error('RealmOwner.password', 'CONFIRM_PASSWORD')
	unless $self->get_field_error('RealmOwner.password')
	    || $self->get_field_error('confirm_password')
	    || $self->get('RealmOwner.password')
		eq $self->get('confirm_password');
    return;
}

#=PRIVATE SUBROUTINES

# _trim(string value) : string
#
# Trims the field to the correct size.
#
sub _trim {
    my($value) = @_;
    return undef unless defined($value);
    return substr($value, 0, Bivio::Type::Name->get_width);
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
