# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CommForm;
use strict;
$Bivio::Biz::Model::CommForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::CommForm - change a realm's phone and email

=head1 SYNOPSIS

    use Bivio::Biz::Model::CommForm;
    Bivio::Biz::Model::CommForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::CommForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::CommForm> edits a realm's Comm.

=cut

#=IMPORTS
use Bivio::TypeError;
use Bivio::Type::Location;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads the User model from this auth_realm.

=cut

sub execute_empty {
    my($self) = @_;
    my($properties) = $self->internal_get;

    # Target is auth_realm
    my($owner) = $self->get_request->get('auth_realm')->get('owner');
    $properties->{'Phone.realm_id'} = $owner->get('realm_id');
#TODO: Make work for multiple addrs
    $properties->{'Phone.location'} = Bivio::Type::Location::HOME();
    $self->load_from_model_properties('Phone');
    $self->load_from_model_properties('Email');
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()

Update the RealmComm with the validated input.

Caller may supply the I<Phone.realm_id>.  Otherwise, the I<auth_realm> of the
request is used.

=cut

sub execute_input {
    my($self) = @_;
    my($properties) = $self->internal_get;

    # Target is auth_realm
    unless ($properties->{'Phone.realm_id'}) {
	my($owner) = $self->get_request->get('auth_realm')->get('owner');
	$properties->{'Phone.realm_id'} = $owner->get('realm_id');
    }
    $properties->{'Phone.location'} = Bivio::Type::Location::HOME();

    foreach my $model (qw(Phone Email)) {
	my($m) = $self->get_model($model);
	my($values) = $self->get_model_properties($model);
	# Won't update if values haven't changed
	$m->update($values);
    }
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	visible => [qw(
	    Phone.phone
	    Email.email
	)],
	auth_id => [
	    'Phone.realm_id', 'Email.realm_id',
	],
	primary_key => [
	    'Phone.realm_id',
	    ['Phone.location', 'Email.location'],
	],
    };
}

=for html <a name="validate"></a>

=head2 validate()

Does nothing.

=cut

sub validate {
    # Individual field validation is enough.
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
