# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ImportedMemberInviteForm;
use strict;
$Bivio::Biz::Model::ImportedMemberInviteForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ImportedMemberInviteForm - invite imported shadow members

=head1 SYNOPSIS

    use Bivio::Biz::Model::ImportedMemberInviteForm;
    Bivio::Biz::Model::ImportedMemberInviteForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListFormModel>

=cut

use Bivio::Biz::ListFormModel;
@Bivio::Biz::Model::ImportedMemberInviteForm::ISA = ('Bivio::Biz::ListFormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ImportedMemberInviteForm> invite imported shadow members

=cut

#=IMPORTS
use Bivio::Type::FileVolume;
use Bivio::Biz::Model::ClubInviteForm;
use Bivio::Biz::Model::File;
use Bivio::Biz::Model::RealmInvite;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::RealmUser;
use Bivio::Type::ClubUserTitle;
use Bivio::TypeError;
use Bivio::Type::Email;
use Bivio::Type::FileVolume;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty_row"></a>

=head2 execute_empty_row()

Fill emails with guesses found in the original export file info.
Looks in fields: contact, home_phone, and work_phone.

=cut

sub execute_empty_row {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($user_id) = $self->get_list_model->get('RealmUser.user_id');

    # try to find the user's email in member_info
    my($member_info) = $fields->{member_info};
    if ($member_info && exists($member_info->{$user_id})) {
	my($member) = $member_info->{$user_id};

	# look in contact, home_phone, and work_phone
	foreach my $field (qw(contact home_phone work_phone)) {
	    my($value) = $member->{$field};
	    next unless Bivio::Type::Email->is_valid($value);

	    # protect against sending emails for test data
	    unless ($self->get_request->unsafe_get('is_production')) {
		$value = ':'.$value;
	    }
	    $self->internal_put_field('invite_email', $value);
	    last;
	}
    }
    return;
}

=for html <a name="execute_empty_start"></a>

=head2 execute_empty_start()

Set default broker account.

=cut

sub execute_empty_start {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE} = {};

    # redirects to the next task if there are no members to process.
    if ($self->get_list_model->get_result_set_size == 0) {
	my($req) = $self->get_request;
	$req->server_redirect($req->get('task')->get('next'));
    }

    # get the most recent export info file, save member info in fields
    my($file) = Bivio::Biz::Model::File->new($self->get_request);
    if ($file->unsafe_load(name => 'export_info.txt',
	    volume => Bivio::Type::FileVolume::EW_IMPORT())) {

	my($info) = eval(${$file->get('content')});
	my($member_info) = {};
	foreach my $member (values(%{$info->{members}})) {
	    $member_info->{$member->{user_id}} = $member;
	}
	$fields->{member_info} = $member_info;
    }
    return;
}

=for html <a name="execute_input_row"></a>

=head2 execute_input_row()

Sends an invite or merges each member which has an email.

=cut

sub execute_input_row {
    my($self) = @_;
    my($properties) = $self->internal_get;

    my($email) = $properties->{invite_email};
    if (defined($email)) {
	_send_invite($self, $email,
		$self->get_list_model->get_model('Email'));
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
	list_class => 'ActiveShadowMemberList',
	visible => [
	    {
		name => 'invite_email',
		in_list => 1,
		constraint => 'NONE',
		type => 'Bivio::Type::Email',
	    },
	],
	auth_id => 'RealmUser.realm_id',
    };
}

=for html <a name="validate_end"></a>

=head2 validate_end()

Finishes validation phase.

=cut

sub validate_end {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    # Drop all temporary references.
    delete($self->{$_PACKAGE});
    return;
}

=for html <a name="validate_row"></a>

=head2 validate_row()

Validates the current row.

=cut

sub validate_row {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($properties) = $self->internal_get;

    my($emails) = $fields->{emails};
    my($email) = $properties->{invite_email};

    if (defined($email)) {
	# check that all emails are unique in the list
	if (exists($emails->{$email})) {
	    $self->internal_put_error('invite_email',
		    Bivio::TypeError::EXISTS());
	}
	# check that it isn't an already merged member of the club
	elsif (_is_merged_member_email($self, $email)) {
	    $self->internal_put_error('invite_email',
		    Bivio::TypeError::MEMBER_ALREADY_MERGED);
	}
	# check that the member isn't already invited
	else {
	    my($invite) = Bivio::Biz::Model::RealmInvite->new(
		    $self->get_request);

	    $self->internal_put_error('invite_email',
		    Bivio::TypeError::ALREADY_INVITED())
		    if $invite->unsafe_load(email => $email);
	}
	$emails->{$email} = $email;
    }
}

=for html <a name="validate_start"></a>

=head2 validate_start()

Initializes the validation phase.

=cut

sub validate_start {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE} = {
	emails => {}
    };
    return;
}

#=PRIVATE METHODS

# _send_invite(string email_address, Bivio::Biz::Model::Email shadow_email)
#
# Invites the specified shadow user with the specified email to join the
# club.
#
sub _send_invite {
    my($self, $email_address, $shadow_email) = @_;

    my($req) = $self->get_request;
    my($club_id) = $req->get('auth_id');

    # set a shadow email for the shadow user
    # this will be reconciled during the invitation acceptance
    # Bivio::Biz::Model::RealmInviteAcceptForm
    $shadow_email->update({
	email => $shadow_email->generate_shadow_email(
		$email_address, $club_id)
    });

    Bivio::Biz::Model::ClubInviteForm->execute($req, {
	title => Bivio::Type::ClubUserTitle::MEMBER(),
	'RealmInvite.email' => $email_address,
	'RealmInvite.realm_id' => $club_id,
    });

    return;
}

# _get_existing_member_email(string email) : Bivio::Biz::Model::RealmUser
#
# Returns the realm user associated with the email if it exists.
# Otherwise returns undef.
#
sub _get_existing_member_email {
    my($self, $email) = @_;

    my($req) = $self->get_request;
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
    my($mail_host) = $req->get('mail_host');

    if ($email =~ /^(.+)\@$mail_host$/) {
	# it is an existing bivio user
	my($user_name) = $1;
	my($realm) = Bivio::Biz::Model::RealmOwner->new($req);
	if ($realm->unauth_load(name => $user_name)) {
	    # see if they are a realm user
	    return $realm_user->unsafe_load(user_id =>
		    $realm->get('realm_id'))
		    ? $realm_user
		    : undef;
	}
    }
    else {
	my($email_model) = Bivio::Biz::Model::Email->new($req);
	# unauth load - it is outside this realm
	if ($email_model->unauth_load(email => $email)) {
	    # see if a realm user exists for the realm_id
	    return $realm_user->unsafe_load(user_id =>
		    $email_model->get('realm_id'))
		    ? $realm_user
		    : undef;
	}
    }
    return undef;
}

# _is_merged_member_email(string email) : boolean
#
# Returns 1 if the email identifies an existing member which owns
# transactions.
#
sub _is_merged_member_email {
    my($self, $email) = @_;

    my($realm_user) = _get_existing_member_email($self, $email);
    if (defined($realm_user)) {
	return $realm_user->has_transactions;
    }
    return 0;
}

=comment

sub invite_users {
    my($proto, $config) = @_;

    my($club_id) = $config->{club_id} || die("config missing club_id");

#TODO: an awful lot of hackery just to get Bivio::Biz::Model::ClubInviteForm
#      ready to use
    use Bivio::Agent::HTTP::Dispatcher;
    Bivio::Agent::HTTP::Dispatcher->initialize;
    my($req) = Bivio::Agent::Request->get_current_or_new;
    my($club_realm) = Bivio::Biz::Model::RealmOwner->new($req);
    $club_realm->unauth_load(realm_id => $club_id)
            || die("couldn't load club realm $club_id");
    $req->put(auth_user => _find_club_admin($club_id));
    $req->put(task_id => Bivio::Agent::TaskId::CLUB_ADMIN_INVITE());
    $req->put(auth_realm => Bivio::Auth::Realm::Club->new($club_realm));
# end hackery

    my($email) = Bivio::Biz::Model::Email->new($req);
    my($realm) = Bivio::Biz::Model::RealmOwner->new($req);
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);

    # create shadow emails and send invites
    my($users) = $config->{users};
    foreach my $user (values(%$users)) {
        my($email_address) = $user->{email};
        next unless $email_address;
        next unless exists($user->{user_id});

        # make sure the shadow user exists
        my($shadow) = $user->{login};
        unless ($realm->unauth_load(name => $shadow)) {
            _trace("no shadow '$shadow', skipping");
            next;
        }

        my($shadow_email) = $email->generate_shadow_email($email_address,
                $club_id);

        # check if a shadow email has already been created
        if ($email->unauth_load(email => $shadow_email)) {
            _trace("invite already sent for $email_address");
            next;
        }

        # set a shadow email for the shadow user
        # this will be reconciled during the invitation acceptance
        # Bivio::Biz::Model::RealmInviteAcceptForm
        $email->unauth_load(realm_id => $user->{user_id})
                || die("couldn't find email for shadow user");
        $email->update({
            email => $shadow_email,
        });

        _trace("inviting $email_address");
        Bivio::Biz::Model::ClubInviteForm->execute($req, {
            title => Bivio::Type::ClubUserTitle::MEMBER(),
            'RealmInvite.email' => $email_address,
            'RealmInvite.realm_id' => $club_id,
        });
    }
    Bivio::Mail::Common::send_queued_messages;
    return;
}

=cut

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
