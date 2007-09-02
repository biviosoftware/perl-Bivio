# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmOwner;
use strict;
use Bivio::Agent::TaskId;
use Bivio::Auth::RealmType;
use Bivio::Base 'Bivio::Biz::PropertyModel';

# C<Bivio::Biz::Model::RealmOwner> is the create, read, update,
# and delete interface to the C<realm_owner_t> table.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_RN) = Bivio::Type->get_instance('RealmName');
my($_PI) = Bivio::Type->get_instance('PrimaryId');
my($_P) = Bivio::Type->get_instance('Password');
my($_HOME_TASK_MAP) = {
    map({
        $_ => Bivio::Agent::TaskId->from_name($_->get_name . '_HOME'),
    } (grep($_->equals_by_name(qw(UNKNOWN GENERAL)) ? 0 : 1,
        Bivio::Auth::RealmType->get_list))),
};

sub create {
    my($self, $values) = @_;
    # Sets I<creation_date_time>, I<password> (to invalid),
    # I<display_name>, I<name> if not set, downcases I<name>, then calls SUPER.
    $values->{name} =
	substr($values->{realm_type}->get_name, 0, 1) . $values->{realm_id}
	unless defined($values->{name});
    $values->{name} = $_RN->process_name($values->{name});
    $values->{display_name} = $values->{name}
	unless defined($values->{display_name});
    $values->{creation_date_time} ||= $_DT->now;
    $values->{password} = $_P->INVALID
	unless defined($values->{password});
    return shift->SUPER::create(@_);
}

sub format_email {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns fully-qualified email address for this realm or '' if the
    # realm is an offline user.
    #
    # See L<format_name|"format_name"> for params.
    my($name) = $proto->format_name($model, $model_prefix);
    return $name ? $model->get_request->format_email($name) : '';
}

sub format_http {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns the absolute URL (with http) to access (the root of) this realm.
    #
    # HACK!
    #
    # See L<format_name|"format_name"> for params.
    return $model->get_request->format_http_prefix
        . $proto->format_uri($model, $model_prefix);
}

sub format_mailto {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns email address with C<mailto:> prefix.
    #
    # See L<format_name|"format_name"> for params.
    return $model->get_request->format_mailto($proto->format_email(
        $model, $model_prefix));
}

sub format_name {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns the name formatted for display. Accounting offline users
    # return ''.
    #
    # In the second form, I<model> is used to get the values, not I<self>.
    # Other Models can declare a method of the form:
    #
    #     sub format_name {
    # 	my($self) = shift;
    # 	Bivio::Biz::Model::RealmOwner->format($self, 'RealmOwner.', @_);
    #     }
    return $_RN->to_string(
        $model->get($model_prefix . 'name'));
}

sub format_uri {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns the URI to access the HOME task for this realm.
    #
    # See L<format_name|"format_name"> for params.
    my($name) = $proto->format_name($model, $model_prefix);
    Bivio::Die->die($model->get($model_prefix . 'name'),
        ': must not be offline user') unless $name;
    my($task) = $_HOME_TASK_MAP->{$model->get($model_prefix . 'realm_type')};
    Bivio::Die->die($model->get($model_prefix . 'name'), ', ',
        $model->get($model_prefix . 'realm_type'),
        ': invalid realm type') unless $task;
    return $model->get_request->format_uri($task, undef, $name, undef);
}

sub has_valid_password {
    my($self) = @_;
    # Returns true if self's password is valid.
    return $_P->is_valid($self->get('password'));
}

sub init_db {
    my($self) = @_;
    # Initializes database with default realms.  The default realms
    # have special realm_ids.

    foreach my $rt (Bivio::Auth::RealmType->get_list) {
	$self->init_realm_type($rt)
	    unless $rt->equals_by_name('UNKNOWN');
    }
    return;
}

sub init_realm_type {
    my($self, $rt) = @_;
    # Adds I<rt> to the database.
    return $self->create({
	name => lc($rt->get_name),
	realm_id => $rt->as_int,
	realm_type => $rt,
    });
}

sub internal_initialize {
    # B<FOR INTERNAL USE ONLY>
    return {
	version => 1,
	table_name => 'realm_owner_t',
	columns => {
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
            name => ['RealmName', 'NOT_NULL_UNIQUE'],
            password => ['Password', 'NOT_NULL'],
            realm_type => ['Bivio::Auth::RealmType', 'NOT_NULL'],
	    display_name => ['DisplayName', 'NOT_NULL'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
# prevent circular dependency, handled by overridden unsafe_get_model()
#	other => [
#	    [qw(realm_id Club.club_id User.user_id)],
#	],
    };
}

sub invalidate_password {
    my($self) = @_;
    # Invalidates I<self>'s password.
    $self->update({password => $_P->INVALID});
    return;
}

sub is_auth_realm {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns true if the current row is the request's auth_realm.
    my($auth_id) = $model->get_request->get('auth_id');
    return 0 unless $auth_id;
    return $model->get($model_prefix . 'realm_id') eq $auth_id ? 1 : 0;
}

sub is_auth_user {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns true if the current row is the request's auth_user.
    my($auth_user) = $model->get_request->get('auth_user');
    return 0 unless $auth_user;
    return $model->get($model_prefix . 'realm_id')
        eq $auth_user->get('realm_id') ? 1 : 0;
}

sub is_default {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns true if the realm is one of the default realms (general,
    # user, club).
    # Default realms have ids same as their types as_int.
    return $model->get($model_prefix . 'realm_type')->as_int
	eq $model->get($model_prefix . 'realm_id') ? 1 : 0;
}

sub is_name_eq_email {
    my(undef, $req, $name, $email) = @_;
    # If I<name> points to I<email>, returns true.  Caller should
    # put error C<EMAIL_LOOP> on the email.  If I<name> or I<email>
    # C<undef>, returns false.
    return 0 unless defined($name) && defined($email);
    my($mail_host) = Bivio::UI::Facade->get_value('mail_host', $req);
#TODO: ANY OTHER mail_host aliases?
    return $email eq $name . '@' . $mail_host
        || $email eq $name . '@www.' . $mail_host;
}

sub is_offline_user {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns true if is a offline realm.
    #
    # See L<format_name|"format_name"> for params.
    return $_RN->is_offline(
        $model->get($model_prefix . 'name'));
}

sub require_otp {
    my($self) = @_;
    return $self->get_field_type('password')->is_otp($self->get('password'));
}

sub unauth_load_by_email {
    my($self, $email, @query) = @_;
    # Tries to load this realm using I<email> and any other I<query> parameters,
    # e.g. (realm_type, Bivio::Auth::RealmType->USER()).
    #
    # I<email> is interpreted as follows:
    #
    #
    # *
    #
    # An C<Bivio::Biz::Model::Email> is loaded with I<email>.  If found,
    # loads the I<realm_id> of the model.
    #
    # *
    #
    # Parsed for the I<mail_host> associated with this request.
    # If it matches, the mailhost is stripped and the (syntactically
    # valid realm) name is used to find a realm owner.
    #
    # *
    #
    # Returns false.
    my($query) = @query == 1
	? ref($query[0]) eq 'HASH'
	? $query[0]
	: Bivio::Die->die(@query, ': query not a hash')
	: {@query};
    # Emails are always lower case
    $email = lc($email);
    # Load the email.  Return the result of the next unauth_load, just in case
    my($em) = $self->new_other('Email');
    return $self->unauth_load({%$query, realm_id => $em->get('realm_id')})
        if $em->unauth_load({email => $email});
    return unless Bivio::IO::ClassLoader->simple_require(
        'Bivio::UI::Facade')->is_fully_initialized;
    # Strip off @mail_host and validate resulting name
    my($mail_host) = '@' . Bivio::UI::Facade->get_value('mail_host',
        $self->get_request);
    return 0 unless $email =~ s/\Q$mail_host\E$//i;
    # Is it a valid user/club?
    return $self->unauth_load({
        %$query,
        name => $_RN->process_name($email),
    });
}

sub unauth_load_by_email_id_or_name {
    my($self, $email_id_or_name) = @_;
    # If email_id_or_name has an '@', will try to unauth_load_by_email.
    # Otherwise, tries to load by id or name.
    return $email_id_or_name =~ /@/
	? $self->unauth_load_by_email($email_id_or_name)
	: _unauth_load($self, $email_id_or_name, {});
}

sub unauth_load_by_id_or_name_or_die {
    my($self, $id_or_name, $realm_type) = @_;
    # Loads I<id_or_name> or dies with NOT_FOUND.  If I<realm_type> is specified, further qualifies the query.
    _unauth_load($self, $id_or_name, $realm_type
        ? {realm_type => Bivio::Auth::RealmType->from_any($realm_type)}
	: {},
	1,
    );
    return $self;
}

sub unsafe_get_model {
    my($self, $name) = @_;
    # Overridden to support getting the related User or Club.
    # For backward compatibility.

    if ($name eq 'User' || $name eq 'Club') {
	my($model) =  $self->new_other($name);
	$model->unauth_load({
            lc($name).'_id' => $self->get('realm_id'),
        });
        return $model;
    }
    return shift->SUPER::unsafe_get_model(@_);
}

sub update_password {
    my($self, $clear_text) = @_;
    # Sets self's clear_text password to a new value.
    return $self->update({
	password => $_P->encrypt($clear_text)
    });
}

sub validate_login {
    my($self, $login) = @_;
    # Load the RealmOwner for I<login> (or email or id) if valid.
    # Return error if invalid.

    return 'NOT_FOUND'
	if !$self->unauth_load_by_email_id_or_name($login)
	    || $self->is_offline_user
	    || $self->is_default
	    || $self->get('realm_type') != Bivio::Auth::RealmType->USER;

    return;
}

sub _unauth_load {
    my($self, $id_or_name, $query, $want_die) = @_;
    if ($_PI->is_valid($id_or_name)) {
	$query->{realm_id} = $id_or_name;
	return 1
	    if $self->unauth_load($query);
    }
    $query->{name} = $_RN->process_name($id_or_name);
    return 1
	if $self->unauth_load($query);
    if ($id_or_name =~ /^\d+$/) {
	delete($query->{name});
	$query->{realm_id} = $id_or_name;
	if ($self->unauth_load($query)) {
	    Bivio::IO::Alert->warn_deprecated('use the RealmType name to load default Realms');
	    return 1;
	}
    }
    $self->throw_die(MODEL_NOT_FOUND => $query)
	if $want_die;
    return 0;
}

1;
