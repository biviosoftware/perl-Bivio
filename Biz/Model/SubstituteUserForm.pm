# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::SubstituteUserForm;
use strict;
$Bivio::Biz::Model::SubstituteUserForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::SubstituteUserForm - allows general admin to become other user

=head1 SYNOPSIS

    use Bivio::Biz::Model::SubstituteUserForm;
    Bivio::Biz::Model::SubstituteUserForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::SubstituteUserForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::SubstituteUserForm> allows a general admin to
become another user. 
Sets the special cookie value
so we know the we are operating in super-user mode.

=cut

=head1 CONSTANTS

=cut

=for html <a name="SUBMIT_OK"></a>

=head2 SUBMIT_OK : string

Returns login button.

=cut

sub SUBMIT_OK {
    return ' Login ';
}

=for html <a name="SUBMIT_CANCEL"></a>

=head2 SUBMIT_CANCEL : string

There is no cancel button for login forms.

=cut

sub SUBMIT_CANCEL {
    return '';
}

#=IMPORTS
use Bivio::Agent::HTTP::Cookie;
use Bivio::SQL::Constraint;
use Bivio::Type::Hash;
use Bivio::Type::Text;
use Bivio::TypeError;

#=VARIABLES
my($_COOKIE_FIELD) = Bivio::Agent::HTTP::Cookie->SU_FIELD();

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute_input()

Sets the user if found.

=cut

sub execute_input {
    my($self) = @_;
    my($properties) = $self->internal_get;
    my($req) = $self->get_request;

    my($super_user_id) = $req->get('auth_user')->get('realm_id');
    # Only set the user if not already su'd
    Bivio::Agent::HTTP::Cookie->set_field($req, $_COOKIE_FIELD,
	    $super_user_id)
		unless defined(Bivio::Agent::HTTP::Cookie->unsafe_get_field(
			$req, $_COOKIE_FIELD));
    $req->put(super_user_id => $super_user_id);

    # Loaded by validate
    $req->set_user($req->get('Bivio::Biz::Model::RealmOwner'));
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
		name => 'login',
		type => 'Bivio::Type::Line',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	],
	auth_id => ['RealmOwner.realm_id'],
	primary_key => [
	    'RealmOwner.realm_id',
	],
    };
}

=for html <a name="validate"></a>

=head2 validate()

Validate user is found.

=cut

sub validate {
    my($self) = @_;
    my($properties) = $self->internal_get();
    return unless defined($properties->{'login'});

    # Emulate what happens in Type::RealmName
    $properties->{'login'} = lc($properties->{'login'});
    $properties->{'login'} =~ s/\s+//g;

    my($login) = $properties->{'login'};
    my($owner) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    my($expected) = ($login =~ /@/ ? $owner->unauth_load_by_email($login)
	    : $owner->unauth_load(name => $login))
	    ? $owner->get('password') : undef;
    # Also handles ("impossible case") of a NULL password
    unless (defined($expected)) {
	$self->internal_put_error('login',
		Bivio::TypeError::NOT_FOUND());
	return;
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
