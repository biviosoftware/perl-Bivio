# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ClubInviteForm;
use strict;
$Bivio::Biz::Model::ClubInviteForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ClubInviteForm - invite a new realm member

=head1 SYNOPSIS

    use Bivio::Biz::Model::ClubInviteForm;
    Bivio::Biz::Model::ClubInviteForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::ClubInviteForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::ClubInviteForm> invite a new realm member.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::ClubUserTitle;
use Bivio::Biz::Model::RealmUser;
use Bivio::UI::Mail::ClubInvite;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Fills in the default values.

=cut

sub execute_empty {
    my($self) = @_;
    my($properties) = $self->internal_get;
    $properties->{title} = Bivio::Type::ClubUserTitle::UNKNOWN();
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()

Invite an "email" to join the club identified by
I<RealmInvite.realm_id> (if set) or by I<auth_id>.

Note that this call will send an email to the invitee.
This email only goes out if executed from a task or if you
call
L<Bivio::Mail::Common::send_queued_messages|Bivio::Mail::Common/"send_queued_messages">.

=cut

sub execute_input {
    my($self) = @_;
    my($properties) = $self->internal_get;
    my($req) = $self->get_request;
    $properties->{'RealmInvite.realm_id'} = $req->get('auth_id')
	    unless defined($properties->{'RealmInvite.realm_id'});
    # Shouldn't load.  If it does, then already invited.
#TODO: Make this work.  It needs to load email explicitly
    my($invite) = $self->get_model('RealmInvite');
    if ($invite->get('realm_id')) {
	$self->internal_put_error('RealmInvite.email',
		Bivio::TypeError::ALREADY_INVITED());
	return;
    }
    my($values) = $self->get_model_properties('RealmInvite');
    # This transfer is necessary, because the types don't agree.
    # We are using a string in the DB, but a enum (for convenience) in UI
    $values->{title} = $properties->{title}->get_short_desc;
    $values->{role} = $properties->{title}->get_role;
    my($model) = $self->get_model('RealmInvite');
    $model->create($values);

    # Finally, send email an invitation
    Bivio::UI::Mail::ClubInvite->execute($self->get_request);
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
	    'RealmInvite.email',
	    {
		name => 'title',
		type => 'Bivio::Type::ClubUserTitle',
		constraint => Bivio::SQL::Constraint::NOT_ZERO_ENUM(),
	    },
	],
	auth_id => [
	    'RealmInvite.realm_id',
	],
	primary_key => [
	    'RealmInvite.realm_id',
	    'RealmInvite.email',
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
