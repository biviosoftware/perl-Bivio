# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Preferences;
use strict;
$Bivio::Biz::Model::Preferences::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

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
    my($perl) = $dd->Dumpxs();

    # Create or update?  Create if was able to load (see _get_instance)
    if ($self->get('realm_id')) {
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

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'preferences_t',
	columns => {
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
            perl => ['BLOB', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
    };
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
	$self->die('DIE', {message => 'eval of perl failed',
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
