# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserLostPasswordForm;
use strict;
$Bivio::Biz::Model::UserLostPasswordForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::UserLostPasswordForm::VERSION;

=head1 NAME

Bivio::Biz::Model::UserLostPasswordForm - request password reset

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserLostPasswordForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::UserLostPasswordForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserLostPasswordForm>

=cut

#=IMPORTS
use Bivio::DieCode;
use Bivio::Type::Password;
use Bivio::Type::PrimaryId;

#=VARIABLES
my($_REALM_ID_KEY) = 't';
my($_PASSWORD_KEY) = 'x';

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Default the email address to the user in the cookie if present.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->SUPER::execute_empty;
    my($cookie) = $req->unsafe_get('cookie');
    return unless $cookie;
    my($user_id) = $cookie->unsafe_get(
        $self->get_instance('UserLoginForm')->USER_FIELD);
    return unless $user_id;
    my($email) = $self->new($req, 'Email');
    return unless $email->unauth_load({
        realm_id => $user_id,
    });
    $email = $email->unsafe_get('email');
    return unless Bivio::Type->get_instance('Email')->is_valid($email);
    $self->internal_put_field('Email.email' => $email);
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok() : string

Sets the user's password to a random value. Saves the reset URI in the
'uri' field. Performs a server redirect to the next task when done.

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my($password) = int(rand(899999) + 100000);
    $self->new_other('RealmOwner')->unauth_load_or_die({
        realm_id => _get_email($self)->get('realm_id')
    })->update({password => Bivio::Type::Password->encrypt($password)});

    my($uri) = $req->format_http('CHANGE_PASSWORD', {
        $_REALM_ID_KEY => Bivio::Type::PrimaryId->to_literal(
            _get_email($self)->get('realm_id')),
        $_PASSWORD_KEY => $password,
    });
    # remove the context from the URI
    $uri =~ s/&fc=[^&]+$//;
    $self->internal_put_field(uri => $uri);
    $req->server_redirect($req->get('task')->get('next'));
    # DOES NOT RETURN
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [
	    'Email.email',
	],
        other => [
	    {
		name => 'uri',
		type => 'String',
		constraint => 'NONE',
	    },
	],
    });
}

=for html <a name="unsafe_get_realm_from_query"></a>

=head2 static unsafe_get_realm_from_query(Bivio::Agent::Request req) : Bivio::Biz::Model

Loads the lost password user from the request query args. Only returns the
user's RealmOwner model if the password matches the query value.

=cut

sub unsafe_get_realm_from_query {
    my($proto, $req) = @_;
    my($query) = $req->get('query') || {};
    my($realm_id, $err) = Bivio::Type::PrimaryId->from_literal(
        $query->{$_REALM_ID_KEY});
    return undef unless $query->{$_PASSWORD_KEY} && $realm_id;
    my($realm) = Bivio::Biz::Model->new($req, 'RealmOwner');
    return Bivio::Type::Password->is_equal(
        $realm->unauth_load_or_die({
            realm_id => $realm_id,
        })->get('password'), $query->{$_PASSWORD_KEY})
        ? $realm : undef;
}

=for html <a name="validate"></a>

=head2 validate()

Ensure email exists.

=cut

sub validate {
    my($self) = @_;
    return if $self->in_error;
    $self->internal_put_error('Email.email', 'NOT_FOUND')
        unless _unsafe_get_email($self);
    return;
}

#=PRIVATE SUBROUTINES

# _get_email(self) : Bivio::Biz::Model
#
# Returns the email model or dies. It shouldn't die unless the form
# has been hacked, or the email is no longer in the database.
#
sub _get_email {
    my($self) = @_;
    return _unsafe_get_email($self)
        || Bivio::DieCode->NOT_FOUND->throw_die;
}

# _unsafe_get_email(self) : Bivio::Biz::Model
#
# Returns the Email model for the form value. Returns undef if not found.
#
sub _unsafe_get_email {
    my($self, $die_if_not_found) = @_;
    my($email) = $self->new($self->get_request, 'Email');
    return $email->unauth_load($self->get_model_properties('Email'))
        ? $email : undef;
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
