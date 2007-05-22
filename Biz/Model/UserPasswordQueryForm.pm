# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserPasswordQueryForm;
use strict;
$Bivio::Biz::Model::UserPasswordQueryForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::UserPasswordQueryForm::VERSION;

=head1 NAME

Bivio::Biz::Model::UserPasswordQueryForm - request password reset

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserPasswordQueryForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::UserPasswordQueryForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserPasswordQueryForm>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Default the email address to the user in the cookie if present.

=cut

sub execute_empty {
    my($self) = @_;
    # don't overwrite if already set by subclass
    return if $self->unsafe_get('Email.email');
    my($req) = $self->get_request;
    $self->SUPER::execute_empty;
    my($cookie) = $req->unsafe_get('cookie');
    return unless $cookie;
    my($user_id) = $cookie->unsafe_get(
        $self->get_instance('UserLoginForm')->USER_FIELD);
    return unless $user_id;
    my($email) = $self->new_other('Email');
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
    my($e) = $self->new_other('Email');
    unless ($e->unauth_load({email => $self->get('Email.email')})) {
	$self->internal_put_error(qw(Email.email NOT_FOUND));
	return;
    }
    if ($self->get_request->is_super_user($e->get('realm_id'))) {
	$self->internal_put_error(qw(Email.email PASSWORD_QUERY_SUPER_USER));
	return;
    }
    $self->get_request->set_realm($e->get('realm_id'));
    $self->internal_put_field(
	uri => Bivio::Biz::Action->get_instance('UserPasswordQuery')
	    ->format_uri($req),
    );
    $self->put_on_request(1);
    return 'server_redirect.next';
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns config

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
		type => 'Line',
		constraint => 'NONE',
	    },
	],
    });
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
