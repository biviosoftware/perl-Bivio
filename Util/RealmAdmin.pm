# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RealmAdmin;
use strict;
$Bivio::Util::RealmAdmin::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::RealmAdmin::VERSION;

=head1 NAME

Bivio::Util::RealmAdmin - realm/user tools

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::RealmAdmin;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::RealmAdmin::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::RealmAdmin> is a generic interface to administration tasks.
It's likely you'll have to subclass this class.

=cut

=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns usage string.

=cut

sub USAGE {
    return <<'EOF';
usage: b-realm-admin [options] command [args...]
commands:
    create_user email display_name password [user_name] -- creates a new user
    delete_user -- deletes the user
    delete_with_users -- deletes realm and all of its users
    invalidate_email -- invalidate a user's email
    invalidate_password -- invalidates a user's password
    join_user role -- adds specified user role to realm
    leave_user -- removes all user roles from realm
    reset_password password -- reset a user's password
    info -- dump info on a realm
    users -- dump users in realm
EOF
}

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::Biz::Model;
use Bivio::Type::DateTime;
use Bivio::Type::Password;

#=VARIABLES
my($_DT) = 'Bivio::Type::DateTime';

=head1 METHODS

=cut

=for html <a name="create_user"></a>

=head2 create_user(string email, string display_name, string password, string user_name)

Creates a new user.  Does not validate the arguments.  AuthUser is
new users (L<Bivio::Biz::Model::UserCreateForm|Bivio::Biz::Model::UserCreateForm>).  Last option is optional.  It allows you to force the I<user_name>
to be something specific.

=cut

sub create_user {
    my($self, $email, $display_name, $password, $user_name) = @_;
    $self->usage_error("missing argument")
	unless $email && $display_name && $password;
    my($req) = $self->get_request;
#TODO: Need to move this to form model.  execute should have validate option.
    Bivio::Biz::Model->get_instance('UserCreateForm')->execute($req, {
	'Email.email' => $self->convert_literal('Email', $email),
	'RealmOwner.display_name' =>
	    $self->convert_literal('Line', $display_name),
	'RealmOwner.password' => $self->convert_literal('Password', $password),
	confirm_password => $self->convert_literal('Password', $password),
	$user_name ? ('RealmOwner.name' =>
	    $self->convert_literal('RealmName', $user_name)) : (),
    });
    return;
}

=for html <a name="delete_user"></a>

=head2 delete_user()

Deletes current user.

=cut

sub delete_user {
    my($self) = @_;
    my($req) = $self->get_request;
    my($email) = Bivio::Biz::Model->new($req, 'Email')
	->unauth_load_or_die({realm_id => $req->get('auth_user_id')});
    $self->are_you_sure("delete user " . $email->get('email'));
    $req->set_realm($req->get('auth_user'));
    $req->get('auth_user')->cascade_delete;
    $req->set_user(undef);
    $req->set_realm(undef);
    return;
}

=for html <a name="delete_with_users"></a>

=head2 delete_with_users()

Deletes current realm and its users and sets realm to general,
and user to nobody afterwards.

=cut

sub delete_with_users {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->usage_error(
	$req->get_nested('auth_realm'),
	': cannot delete a default realm',
    ) if $req->get('auth_realm')->is_default;
    $self->are_you_sure(
	'delete realm ' . $req->get_nested(qw(auth_realm owner_name)));
    foreach my $r (
	$req->get('auth_id'),
	@{Bivio::Biz::Model->new($req, 'RealmUser')->map_iterate(
	    sub {shift->get('user_id')}, 'user_id',
	)},
    ) {
	$req->set_realm($r)->get('owner')->cascade_delete;
    }
    $req->set_user(undef);
    $req->set_realm(undef);
    return;
}

=for html <a name="info"></a>

=head2 info()

info on realm.

=cut

sub info {
    my($self) = @_;
    return _info($self->get_request->get_nested(qw(auth_realm owner))) . "\n";
}

=for html <a name="invalidate_email"></a>

=head2 invalidate_email()

Invalidates the user's email address.

=cut

sub invalidate_email {
    my($self) = @_;
    _validate_user($self, 'Invalidate Email')
        ->get_model('User')->invalidate_email;
    return;
}

=for html <a name="invalidate_password"></a>

=head2 invalidate_password()

Invalidate the user's password.

=cut

sub invalidate_password {
    my($self) = @_;
    _validate_user($self, 'Invalidate Password')->invalidate_password;
    return;
}

=for html <a name="join_user"></a>

=head2 join_user(string role)

Adds user to realm with I<role>.

=cut

sub join_user {
    my($self, $role) = @_;
    my($req) = $self->get_request;
    Bivio::Biz::Model->new($req, 'RealmUser')->create({
	realm_id => $req->get('auth_id'),
	user_id => $req->get('auth_user_id'),
	role => Bivio::Auth::Role->from_name($role),
    });
    return;
}

=for html <a name="leave_user"></a>

=head2 leave_user()

Drops I<user> from I<realm>.

=cut

sub leave_user {
    my($self) = @_;
    my($req) = $self->get_request;
    my($realm_user) = Bivio::Biz::Model->new($req, 'RealmUser');
    $realm_user->unauth_iterate_start('realm_id', {
	realm_id => $req->get('auth_id')
	   || $self->usage_error('realm not set'),
	user_id => $req->get('auth_user_id')
	   || $self->usage_error('user not set'),
	});
    while ($realm_user->iterate_next_and_load) {
	$realm_user->delete;
    }
    $realm_user->iterate_end;
    return;
}

=for html <a name="reset_password"></a>

=head2 reset_password(string password)

Changes a user's password.

=cut

sub reset_password {
    my($self, $password) = @_;
    $self->usage_error("missing new password")
        unless defined($password);
    _validate_user($self, 'Reset Password')->update({
        password => Bivio::Type::Password->encrypt($password),
    });
    return;
}

=for html <a name="users"></a>

=head2 users()

users for realm.

=cut

sub users {
    my($self) = @_;
    my($users) = {};
    my($ru) = Bivio::Biz::Model->new($self->get_request, 'RealmUser');
    $ru->do_iterate(
	sub {
	    my($it) = @_;
	    push(@{$users->{$it->get('user_id')} ||= []},
		 $it->get('role')->get_name
		 . ' '
		 . $_DT->to_xml($it->get('creation_date_time'))
	    );
	    return 1;
	},
	'role asc',
    );
    my($ro) = $ru->new_other('RealmOwner');
    return join('',
        map(join("\n  ",
		 _info($ro->unauth_load_or_die({realm_id => $_})),
		 sort(@{$users->{$_}}),
	    ) . "\n",
	    sort(keys(%$users)),
	),
    );
}

#=PRIVATE SUBROUTINES

sub _info {
    my($user) = @_;
    return join("\n  ",
	join(' ',
	    $user->get(qw(name realm_id password)),
	    $_DT->to_xml($user->get('creation_date_time')),
	    $user->get('display_name'),
	),
	@{$user->new_other('Email')->map_iterate(
	    sub {
		my($l, $e) = shift->get(qw(location email));
		return $l->get_name . ' ' . $e;
	    },
	    'unauth_iterate_start',
	    'location',
	    {realm_id => $user->get('realm_id')},
	)},
    );
}

# _validate_user(self, string message) : Bivio::Biz::Model::RealmOwner
#
# Ensures the user is present, displays the are_you_sure using the
# specified message.
# Returns the user's realm.
#
sub _validate_user {
    my($self, $message) = @_;
    my($req) = $self->get_request;
    $self->usage_error("missing user")
        unless $self->unsafe_get('user');
    $self->are_you_sure($message . ' for '
	. $req->get_nested(qw(auth_user display_name))
	. ' of '
	. $req->get_nested(qw(auth_realm owner display_name))
	. '?');
    return $req->get('auth_user');
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
