# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MemberForm;
use strict;
$Bivio::Biz::Model::MemberForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MemberForm - a list of Member information

=head1 SYNOPSIS

    use Bivio::Biz::Model::MemberForm;
    Bivio::Biz::Model::MemberForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::MemberForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::MemberForm>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Auth::RealmType;
use Bivio::SQL::Constraint;
use Bivio::Biz::Model::MailMessage;
use Bivio::TypeError;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create()

Processes the form's values and creates models.
Any errors are "put" on the form and the operation is aborted.

=cut

sub create {
    my($self) = @_;
    my($properties) = $self->internal_get;

    my($club) = $self->get_model('Realmowner_1');
    my($user) = $self->get_model('RealmOwner_2');

    # Create RealmUser
    my($values) = $self->get_model_properties('RealmUser');
    $values->{realm_id} = $club->get('realm_id');
    $values->{user_id} = $user->get('realm_id');
    $self->get_model('RealmUser')->create($values);
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
	    'RealmOwner_1.name',
	    'RealmOwner_2.name',
	    'RealmUser.role',
	],
	primary_key => [
	    ['RealmOwner_1.realm_id', 'RealmUser.realm_id'],
	    ['RealmOwner_2.realm_id', 'RealmUser.user_id'],
	],
    };
}

=for html <a name="update"></a>

=head2 update()

Processes the form's values and updates models.
Any errors are "put" on the form and the operation is aborted.


=cut

sub update {
    my($self) = @_;
    die('not implemented properly');
}

=for html <a name="validate"></a>

=head2 validate(boolean is_create)

Checks the form property values.  Puts errors on the fields
if there are any.

=cut

sub validate {
    my($self) = @_;
    my($club) = $self->get_model('RealmOwner_1');
    $self->internal_put_error('RealmOwner_1.name',
	    Bivio::TypeError::NOT_FOUND()) unless $club->get('realm_id');

    my($user) = $self->get_model('RealmOwner_2');
    $self->internal_put_error('RealmOwner_2.name',
	    Bivio::TypeError::NOT_FOUND()) unless $user->get('realm_id');
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
