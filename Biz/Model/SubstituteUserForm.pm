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
Sets the special cookie value (L<COOKIE_FIELD|"COOKIE_FIELD">)
so we know the we are operating in super-user mode.

=cut

=head1 CONSTANTS

=cut

=for html <a name="COOKIE_FIELD"></a>

=head2 COOKIE_FIELD : string

Name of the field in our cookie

=cut

sub COOKIE_FIELD {
    return 'su';
}

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
use Bivio::Auth::RealmType;
use Bivio::SQL::Constraint;
use Bivio::Type::Hash;
use Bivio::Type::Text;
use Bivio::TypeError;

#=VARIABLES

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
    my($owner) = Bivio::Biz::Model::RealmOwner->new($req);
    unless ($owner->unauth_load(name => $properties->{'RealmOwner.name'})) {
	$self->internal_put_error('RealmOwner.name',
		Bivio::TypeError::NOT_FOUND());
	return;
    }
    my($cookie) = $req->unsafe_get('cookie');
    $req->put(cookie => ($cookie = {})) unless $cookie;
    unless (defined($cookie->{COOKIE_FIELD()})) {
	$cookie->{COOKIE_FIELD()} = $req->get('auth_user')->get('realm_id');
    }
    # Will set the user and role for this realm
    $req->set_user($owner);
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
            'RealmOwner.name',
	],
	auth_id => ['RealmOwner.realm_id'],
	primary_key => [
	    'RealmOwner.realm_id',
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
