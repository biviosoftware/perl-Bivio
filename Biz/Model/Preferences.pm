# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Preferences;
use strict;
$Bivio::Biz::Model::Preferences::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::Preferences::VERSION;

=head1 NAME

Bivio::Biz::Model::Preferences - realm preferences

=head1 SYNOPSIS

    use Bivio::Biz::Model::Preferences;
    Bivio::Biz::Model::Preferences->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Preferences::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::Preferences> holds a list preferences for a realm.
A preference is specified by an enumerated type (currently
L<Bivio::Type::ClubPreference|Bivio::Type::ClubPreference> or
L<Bivio::Type::UserPreference|Bivio::Type::UserPreference>).
The preferences are stored in perl format, but each element is
converted to "sql" first.   This makes it is easy to do comparisons.

=cut

#=IMPORTS
use Bivio::Agent::Task;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Auth::RoleSet;
use Bivio::Biz::Action::DemoClub;
use Bivio::Die;
use Bivio::IO::Trace;
use Bivio::Type::ClubPreference;
use Bivio::Type::UserPreference;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_ACTIVE_CLUB_ROLES) = '';
Bivio::Auth::RoleSet->set(\$_ACTIVE_CLUB_ROLES,
	Bivio::Auth::Role::GUEST(),
	Bivio::Auth::Role::MEMBER(),
	Bivio::Auth::Role::ACCOUNTANT(),
	Bivio::Auth::Role::ADMINISTRATOR(),
	);
my($_CLUB_PREFS) = Bivio::Type::ClubPreference->REQUEST_ATTRIBUTE;
my($_USER_PREFS) = Bivio::Type::UserPreference->REQUEST_ATTRIBUTE;

# used to save the user's "current club" user preference
Bivio::Agent::Task->register($_PACKAGE);

=head1 METHODS

=cut

=for html <a name="get_value"></a>

=head2 static get_value(Bivio::Agent::Request req, string attr, Bivio::Biz::Model::RealmOwner realm, Bivio::Type::Preference which) : any

Use
L<Bivio::Agent::Request::get_user_pref|Bivio::Agent::Request/"get_user_pref">
or
L<Bivio::Agent::Request::get_club_pref|Bivio::Agent::Request/"get_club_pref">.

Returns I<which> preference for I<realm>.
I<attr> identifies the attribute on the request which holds the current
prefs for I<realm>, if loaded.

If the type of the preference exports I<get_default>, this well be
used if the user preference is not set.

If I<realm> is C<undef>, returns default value or undef.

=cut

sub get_value {
    my(undef, $req, $attr, $realm, $which) = @_;
    my($type) = $which->get_type();

    # If no realm, return default.
    return $type->can('get_default') ? $type->get_default : undef
	    unless $realm;

    # Have a realm
    my($self) = _get_instance($req, $attr, $realm);
    my($fields) = $self->{$_PACKAGE};
    # Loaded:  Get fields and return value (after type conversion)
    my($value) = $type->from_sql_column($fields->{values}->[$which->as_int]);
    $value = $type->get_default
	    if !defined($value) && $type->can('get_default');
    _trace_self($fields, $which->get_name, '=',
	    $fields->{values}->[$which->as_int]) if $_TRACE;
    return $value;
}

=for html <a name="handle_commit"></a>

=head2 handle_commit()

Write I<self> to database.

=cut

sub handle_commit {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Serialize
    my($dd) = Data::Dumper->new([$fields->{values}]);
    $dd->Indent(0);
    $dd->Terse(1);
    $dd->Deepcopy(1);
    my($perl) = $dd->Dumpxs();

    # Create or update?  Update if was able to load (see _get_instance)
    if ($self->unsafe_get('realm_id')) {
	_trace_self($fields, 'updating ', $perl) if $_TRACE;
	$self->update({perl => \$perl});
    }
    else {
	_trace_self($fields, 'creating ', $perl) if $_TRACE;
	$self->create({realm_id => $fields->{realm_id},  perl => \$perl});
    }
    delete($fields->{need_commit});
    return;
}

=for html <a name="handle_pre_execute_task"></a>

=head2 handle_pre_execute_task(Bivio::Agent::Request req)

Saves the CLUB_LAST_VISITED User Preference.

=cut

sub handle_pre_execute_task {
    my($proto, $req) = @_;

    # Don't set preferences unless browser
    return unless $req->get('Bivio::Type::UserAgent')->is_browser;

    # Don't set preferences if no auth_user
    return unless $req->get('auth_user');

    # Only for clubs
    return unless $req->get('auth_realm')->get('type')
	    == Bivio::Auth::RealmType::CLUB();

    # Don't save the demo club as a visited club
    return if Bivio::Biz::Action::DemoClub->is_demo_club(
	    $req->get('auth_realm')->get('owner'));

    # Don't save if not a guest or member
    return unless Bivio::Auth::RoleSet->is_set(\$_ACTIVE_CLUB_ROLES,
	    $req->get('auth_role'));

    # Set CLUB_LAST_VISITED preference
    $proto->set_user_pref($req, 'CLUB_LAST_VISITED', $req->get('auth_id'));
    return;
}

=for html <a name="handle_rollback"></a>

=head2 handle_rollback()

Clear this attribute from request, so won't be referenced again.

=cut

sub handle_rollback {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->get_request->delete($fields->{attr});
    _trace_self($fields) if $_TRACE;
    return;
}

=for html <a name="get_club_pref"></a>

=head2 static get_club_pref(Bivio::Agent::Request req, any pref) : any

Gets a club preference.  I<pref> must be a
L<Bivio::Type::ClubPreference|Bivio::Type::ClubPreference>.
The value returned may be C<undef> if club is undefined or preference
not set iwc the default should be used.

=cut

sub get_club_pref {
    my($proto, $req, $pref) = @_;
    my($auth_realm) = $req->get('auth_realm');
    return $proto->get_value(
	    $req,
	    $_CLUB_PREFS,
	    $auth_realm && $auth_realm->get('type')
		    == Bivio::Auth::RealmType::CLUB()
	    ? $auth_realm->get('owner') : undef,
	    Bivio::Type::ClubPreference->from_any($pref));
}

=for html <a name="get_user_pref"></a>

=head2 static get_user_pref(Bivio::Agent::Request req, any pref) : any

Gets a user preference.  I<pref> must be a
L<Bivio::Type::UserPreference|Bivio::Type::UserPreference>.
The value returned may be C<undef> if user undefined or preference
not set iwc the default should be used.

=cut

sub get_user_pref {
    my($proto, $req, $pref) = @_;
    return $proto->get_value(
	    $req,
	    $_USER_PREFS,
	    $req->get('auth_user'),
	    Bivio::Type::UserPreference->from_any($pref));
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'preferences_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            perl => ['BLOB', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
    };
}

=for html <a name="set_club_pref"></a>

=head2 static set_club_pref(Bivio::Agent::Request req, any pref, any value)

Sets a club preference.  I<pref> must be a
L<Bivio::Type::ClubPreference|Bivio::Type::ClubPreference>.
I<value> may be undef.

Avoid setting defaults in the file.  If the value is same as
default, don't set it.

=cut

sub set_club_pref {
    my($proto, $req, $pref, $value) = @_;
    my($auth_realm) = $req->get('auth_realm');
    return undef unless $auth_realm && $auth_realm->get('type')
	    == Bivio::Auth::RealmType::CLUB();
    $proto->set_value(
	    $req,
	    $_CLUB_PREFS,
	    $auth_realm->get('owner'),
	    Bivio::Type::ClubPreference->from_any($pref),
	    $value);
    return;
}

=for html <a name="set_user_pref"></a>

=head2 static set_user_pref(Bivio::Agent::Request req, any pref, any value)

Sets a user preference.  I<pref> must be a
L<Bivio::Type::UserPreference|Bivio::Type::UserPreference>.
I<value> may be undef.

Avoid setting defaults in the file.  If the value is same as
default, don't set it.

=cut

sub set_user_pref {
    my($proto, $req, $pref, $value) = @_;
    my($auth_user) = $req->get('auth_user');
    return unless $auth_user;
    $proto->set_value(
	    $req,
	    $_USER_PREFS,
	    $auth_user,
	    Bivio::Type::UserPreference->from_any($pref),
	    $value);
    return;
}

=for html <a name="set_value"></a>

=head2 static set_value(Bivio::Agent::Request req, string attr, Bivio::Biz::Model::RealmOwner realm, Bivio::Type::Preference which, any value)


Use
L<Bivio::Agent::Request::get_user_pref|Bivio::Agent::Request/"get_user_pref">
or
L<Bivio::Agent::Request::get_club_pref|Bivio::Agent::Request/"get_club_pref">.

Sets I<which> preference for I<realm> to I<value>.
I<attr> identifies the attribute on the request which holds the current
prefs for I<realm>, if loaded.

=cut

sub set_value {
    my($proto, $req, $attr, $realm, $which, $value) = @_;

    my($self) = _get_instance($req, $attr, $realm);
    my($fields) = $self->{$_PACKAGE};
    my($new) = $which->get_type()->to_sql_param($value);
    my($old) = $fields->{values}->[$which->as_int];

    # Changed?
    return if defined($new) == defined($old)
	    && (!defined($new) || $new eq $old);

    $fields->{values}->[$which->as_int] = $new;

    _trace_self($fields, $which->get_name, '=', $new) if $_TRACE;

    # Already in commit queue?
    return if $fields->{need_commit};

    # Need to commit
    $req->push_txn_resource($self);
    $fields->{need_commit} = 1;
    return;
}

#=PRIVATE METHODS

# _get_instance(Bivio::Agent::Request req, string attr, Bivio::Biz::Model::RealmOwner realm) : Bivio::Biz::Model::Preferences
#
# Returns loaded instance.
#
sub _get_instance {
    my($req, $attr, $realm) = @_;
    my($self) = $req->unsafe_get($attr);
    my($realm_id) = $realm->get('realm_id');

    # Already loaded for this realm?
    if ($self) {
	# Use fields realm_id, because self->get() may be undef (not in db).
	my($self_realm_id) = $self->{$_PACKAGE}->{realm_id};
	return $self if defined($self_realm_id) && $self_realm_id eq $realm_id;
	_trace($realm_id, ': need to load, realms differ') if $_TRACE;
    }

    # Load
    $self = __PACKAGE__->new($req);
    my($values);
    if ($self->unauth_load(realm_id => $realm_id)) {
	my($perl) = $self->get('perl');
	local($SIG{__DIE__});
	$values = Bivio::Die->eval($$perl);
	$self->throw_die('DIE', {message => 'eval of perl failed',
	    field => 'perl', realm_id => $realm_id,
	    entity => $perl,
	    error => defined($values) ? 'not an array ref' : $@,
	}) unless ref($values) eq 'ARRAY';
    }
    else {
	$values = [];
    }
    my($fields) = $self->{$_PACKAGE} = {
	realm_id => $realm_id,
	values => $values,
	attr => $attr,
    };
    $req->put($attr => $self);
    _trace_self($fields, 'loaded ', $values) if $_TRACE;
    return $self;
}

# _trace_self(hash_ref fields, ...)
#
# Tracing with this
# 
sub _trace_self {
    my($fields) = shift;
    _trace((caller(1))[3], ' ',
	    $fields->{attr}, '[realm_id=', $fields->{realm_id}, ']: ', @_);
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
