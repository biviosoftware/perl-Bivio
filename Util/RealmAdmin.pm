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
    create_user email display_name password -- creates a new user
    delete_user -- deletes the user
EOF
}

#=IMPORTS
use Bivio::Biz::Model;
use Bivio::Type::Honorific;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_user"></a>

=head2 create_user(string email, string display_name, string password)

Creates a new user.  Does not validate the arguments.  AuthUser is
new users (L<Bivio::Biz::Model::UserCreateForm|Bivio::Biz::Model::UserCreateForm>).

=cut

sub create_user {
    my($self, $email, $display_name, $password) = @_;
    $self->usage_error("missing argument")
	unless $email && $display_name && $password;
    my($req) = $self->get_request;
    Bivio::Biz::Model->get_instance('UserCreateForm')->execute($req, {
	'Email.email' => $email,
	'RealmOwner.display_name' => $display_name,
	'RealmOwner.password' => $password,
	confirm_password => $password,
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

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
