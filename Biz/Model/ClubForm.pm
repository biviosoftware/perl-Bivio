# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ClubForm;
use strict;
$Bivio::Biz::Model::ClubForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ClubForm - a list of Club information

=head1 SYNOPSIS

    use Bivio::Biz::Model::ClubForm;
    Bivio::Biz::Model::ClubForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::ClubForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::ClubForm>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Auth::RealmType;
use Bivio::SQL::Constraint;
use Bivio::Biz::Model::MailMessage;

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

    # Create Club
    my($values) = $self->get_model_properties('Club');
    $values->{kbytes_in_use} = 0;
    $values->{max_storage_kbytes} = 8 * 1024;
    my($club) = $self->get_model('Club');
    $club->create($values);
    $properties->{'Club.club_id'} = $club->get('club_id');

    # Create RealmOwner
    $values = $self->get_model_properties('RealmOwner');
    $values->{password} = 'xx';
    $values->{realm_type} = Bivio::Auth::RealmType::CLUB();
    my($realm_owner) = $self->get_model('RealmOwner');
    $realm_owner->create($values);

    # Create MailMessage directories
    my($mm) = Bivio::Biz::Model::MailMessage->new($self->get_request);
    $mm->setup_club($realm_owner);
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
            'Club.full_name',
	],
	auth_id =>
	    ['Club.club_id', 'RealmOwner.realm_id'],
	primary_key => [
	    'Club.club_id',
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
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
