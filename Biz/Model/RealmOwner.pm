# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmOwner;
use strict;
$Bivio::Biz::Model::RealmOwner::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmOwner::VERSION;

=head1 NAME

Bivio::Biz::Model::RealmOwner - interface to realm_owner_t SQL table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmOwner;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmOwner::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmOwner> is the create, read, update,
and delete interface to the C<realm_owner_t> table.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Auth::RealmType;

#=VARIABLES
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

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time>, I<password> (to invalid),
I<display_name>, I<name> if not set, downcases I<name>, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
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

=for html <a name="format_email"></a>

=head2 format_email() : string

=head2 static format_email(Bivio::Biz::Model model, string model_prefix) : string

Returns fully-qualified email address for this realm or '' if the
realm is an offline user.

See L<format_name|"format_name"> for params.

=cut

sub format_email {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    my($name) = $proto->format_name($model, $model_prefix);
    return $name ? $model->get_request->format_email($name) : '';
}

=for html <a name="format_http"></a>

=head2 format_http() : string

=head2 static format_http(Bivio::Biz::Model model, string model_prefix) : string

Returns the absolute URL (with http) to access (the root of) this realm.

HACK!

See L<format_name|"format_name"> for params.

=cut

sub format_http {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return $model->get_request->format_http_prefix
        . $proto->format_uri($model, $model_prefix);
}

=for html <a name="format_mailto"></a>

=head2 format_mailto() : string

=head2 static format_mailto(Bivio::Biz::Model model, string model_prefix) : string

Returns email address with C<mailto:> prefix.

See L<format_name|"format_name"> for params.

=cut

sub format_mailto {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return $model->get_request->format_mailto($proto->format_email(
        $model, $model_prefix));
}

=for html <a name="format_name"></a>

=head2 format_name() : string

=head2 static format_name(Bivio::Biz::Model model, string model_prefix) : string

Returns the name formatted for display. Accounting offline users
return ''.

In the second form, I<model> is used to get the values, not I<self>.
Other Models can declare a method of the form:

    sub format_name {
	my($self) = shift;
	Bivio::Biz::Model::RealmOwner->format($self, 'RealmOwner.', @_);
    }

=cut

sub format_name {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return $_RN->to_string(
        $model->get($model_prefix . 'name'));
}

=for html <a name="format_uri"></a>

=head2 format_uri() : string

=head2 static format_uri(Bivio::Biz::Model model, string model_prefix) : string

Returns the URI to access the HOME task for this realm.

See L<format_name|"format_name"> for params.

=cut

sub format_uri {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    my($name) = $proto->format_name($model, $model_prefix);
    Bivio::Die->die($model->get($model_prefix . 'name'),
        ': must not be offline user') unless $name;
    my($task) = $_HOME_TASK_MAP->{$model->get($model_prefix . 'realm_type')};
    Bivio::Die->die($model->get($model_prefix . 'name'), ', ',
        $model->get($model_prefix . 'realm_type'),
        ': invalid realm type') unless $task;
    return $model->get_request->format_uri($task, undef, $name, undef);
}

=for html <a name="has_valid_password"></a>

=head2 has_valid_password() : boolean

Returns true if self's password is valid.

=cut

sub has_valid_password {
    my($self) = @_;
    return $_P->is_valid($self->get('password'));
}

=for html <a name="init_db"></a>

=head2 init_db()

Initializes database with default realms.  The default realms
have special realm_ids.

=cut

sub init_db {
    my($self) = @_;

    foreach my $rt (Bivio::Auth::RealmType->get_list) {
	$self->init_realm_type($rt)
	    unless $rt->equals_by_name('UNKNOWN');
    }
    return;
}

=for html <a name="init_realm_type"></a>

=head2 init_realm_type(Bivio::Auth::RealmType rt) : self

Adds I<rt> to the database.

=cut

sub init_realm_type {
    my($self, $rt) = @_;
    return $self->create({
	name => lc($rt->get_name),
	realm_id => $rt->as_int,
	realm_type => $rt,
    });
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
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

=for html <a name="invalidate_password"></a>

=head2 invalidate_password()

Invalidates I<self>'s password.

=cut

sub invalidate_password {
    my($self) = @_;
    $self->update({password => $_P->INVALID});
    return;
}

=for html <a name="is_auth_realm"></a>

=head2 is_auth_realm() : boolean

=head2 static is_auth_realm(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if the current row is the request's auth_realm.

=cut

sub is_auth_realm {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    my($auth_id) = $model->get_request->get('auth_id');
    return 0 unless $auth_id;
    return $model->get($model_prefix . 'realm_id') eq $auth_id ? 1 : 0;
}

=for html <a name="is_auth_user"></a>

=head2 is_auth_user() : boolean

=head2 static is_auth_user(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if the current row is the request's auth_user.

=cut

sub is_auth_user {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    my($auth_user) = $model->get_request->get('auth_user');
    return 0 unless $auth_user;
    return $model->get($model_prefix . 'realm_id')
        eq $auth_user->get('realm_id') ? 1 : 0;
}

=for html <a name="is_default"></a>

=head2 is_default() : boolean

=head2 static is_default(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if the realm is one of the default realms (general,
user, club).

=cut

sub is_default {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Default realms have ids same as their types as_int.
    return $model->get($model_prefix . 'realm_type')->as_int
	eq $model->get($model_prefix . 'realm_id') ? 1 : 0;
}

=for html <a name="is_name_eq_email"></a>

=head2 static is_name_eq_email(Bivio::Agent::Request req, string name, string email) : boolean

If I<name> points to I<email>, returns true.  Caller should
put error C<EMAIL_LOOP> on the email.  If I<name> or I<email>
C<undef>, returns false.

=cut

sub is_name_eq_email {
    my(undef, $req, $name, $email) = @_;
    return 0 unless defined($name) && defined($email);
    my($mail_host) = Bivio::UI::Facade->get_value('mail_host', $req);
#TODO: ANY OTHER mail_host aliases?
    return $email eq $name . '@' . $mail_host
        || $email eq $name . '@www.' . $mail_host;
}

=for html <a name="is_offline_user"></a>

=head2 is_offline_user() : boolean

=head2 static is_offline_user(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if is a offline realm.

See L<format_name|"format_name"> for params.

=cut

sub is_offline_user {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return $_RN->is_offline(
        $model->get($model_prefix . 'name'));
}

=for html <a name="unauth_load_by_email"></a>

=head2 unauth_load_by_email(string email) : boolean

=head2 unauth_load_by_email(string email, hash_ref query) : boolean

Tries to load this realm using I<email> and any other I<query> parameters,
e.g. (realm_type, Bivio::Auth::RealmType->USER()).

I<email> is interpreted as follows:

=over 4

=item *

An C<Bivio::Biz::Model::Email> is loaded with I<email>.  If found,
loads the I<realm_id> of the model.

=item *

Parsed for the I<mail_host> associated with this request.
If it matches, the mailhost is stripped and the (syntactically
valid realm) name is used to find a realm owner.

=item *

Returns false.

=back

=cut

sub unauth_load_by_email {
    my($self, $email, @query) = @_;
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

=for html <a name="unauth_load_by_email_id_or_name"></a>

=head2 unauth_load_by_email_id_or_name(string email_id_or_name) : boolean

If email_id_or_name has an '@', will try to unauth_load_by_email.
Otherwise, tries to load by id or name.

=cut

sub unauth_load_by_email_id_or_name {
    my($self, $email_id_or_name) = @_;
    return $email_id_or_name =~ /@/
	? $self->unauth_load_by_email($email_id_or_name)
	: _unauth_load($self, $email_id_or_name, {});
}

=for html <a name="unauth_load_by_id_or_name_or_die"></a>

=head2 unauth_load_by_id_or_name_or_die(string id_or_name) : Bivio::Biz::Model::RealmOwner

=head2 unauth_load_by_id_or_name_or_die(string id_or_name, any realm_type) : Bivio::Biz::Model::RealmOwner

Loads I<id_or_name> or dies with NOT_FOUND.  If I<realm_type> is specified, further qualifies the query.

=cut

sub unauth_load_by_id_or_name_or_die {
    my($self, $id_or_name, $realm_type) = @_;
    _unauth_load($self, $id_or_name, $realm_type
        ? {realm_type => Bivio::Auth::RealmType->from_any($realm_type)}
	: {},
	1,
    );
    return $self;
}

=for html <a name="unsafe_get_model"></a>

=head2 unsafe_get_model(string name) : Bivio::Biz::PropertyModel

Overridden to support getting the related User or Club.
For backward compatibility.

=cut

sub unsafe_get_model {
    my($self, $name) = @_;

    if ($name eq 'User' || $name eq 'Club') {
	my($model) =  $self->new_other($name);
	$model->unauth_load({
            lc($name).'_id' => $self->get('realm_id'),
        });
        return $model;
    }
    return shift->SUPER::unsafe_get_model(@_);
}

=for html <a name="update_password"></a>

=head2 update_password(string clear_text) : self

Sets self's clear_text password to a new value.

=cut

sub update_password {
    my($self, $clear_text) = @_;
    return $self->update({
	password => $_P->encrypt($clear_text)
    });
}

=for html <a name="validate_login"></a>

=head2 validate_login(string login) : string

Load the RealmOwner for I<login> (or email or id) if valid.
Return error if invalid.

=cut

sub validate_login {
    my($self, $login) = @_;

    return 'NOT_FOUND'
	if !$self->unauth_load_by_email_id_or_name($login)
	    || $self->is_offline_user
	    || $self->is_default
	    || $self->get('realm_type') != Bivio::Auth::RealmType->USER;

    return;
}

#=PRIVATE METHODS

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

=head1 COPYRIGHT

Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
