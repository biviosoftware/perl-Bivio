# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::User;
use strict;
$Bivio::Biz::Model::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::User::VERSION;

=head1 NAME

Bivio::Biz::Model::User - interface to user_t SQL table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::User;
    Bivio::Biz::Model::User->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::User::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::User> is the create, read, update,
and delete interface to the C<user_t> table.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::Type::Email;
use Bivio::Type::Gender;
use Bivio::Type::Location;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 cascade_delete()

Deletes this user and all its related realm information. This will not
delete club RealmUser data, and if it exists then this method will die
with a database constraint violation.

(RealmUser is not deleted because the auth_id on that model is realm_id,
which is not the same as the User's auth_id.)

=cut

sub cascade_delete {
    my($self) = @_;
    my($req) = $self->get_request;
    my($realm) = _get_realm($self);

    # switches to the user auth realm, restored at end of method
    my($old_auth_realm) = $req->get('auth_realm');
    $req->set_realm($realm);

    my($die) = Bivio::Die->catch(
        sub {
            $self->SUPER::cascade_delete;
            $realm->cascade_delete;
        });

    # restore previous auth realm
    $req->set_realm($old_auth_realm);
    $die->throw if $die;
    return;
}

=for html <a name="concat_last_first_middle"></a>

=head2 static concat_last_first_middle(string last, string first, string middle) : string

Does the work of L<format_last_first_middle|"format_last_first_middle">.

=cut

sub concat_last_first_middle {
    my(undef, $last, $first, $middle) = @_;

    # We shown the last_name as "-" if not set.
    if (defined($last)) {
	my($res) = undef;
	return $last unless defined($first) || defined($middle);
	$res = $last . ',';
	$res .= ' ' . $first if defined($first);
	$res .= ' ' . $middle if defined($middle);
	return $res;
    }
    return $first . ' ' . $middle if defined($first) && defined($middle);
    return defined($first) ? $first : $middle;
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values) : self

Sets I<gender> if not set and computes the sorting name fields then
calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{gender} ||= Bivio::Type::Gender->UNKNOWN;
    _compute_sorting_names($values);
    my($res) = $self->SUPER::create($values);
    _validate_names($self);
    return $res;
}

=for html <a name="format_full_name"></a>

=head2 format_full_name() : string

=head2 static format_full_name(Bivio::Biz::Model model, string model_prefix) : string

Returns the first, middle, and last names as one string.

B<You should use RealmOwner.display_name whenever possible as the
values are identical.>

=cut

sub format_full_name {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    my($res) = '';

    foreach my $name ($model->unsafe_get($model_prefix.'first_name',
        $model_prefix . 'middle_name', $model_prefix . 'last_name')) {
	$res .= $name . ' ' if defined($name);
    }
    # Get rid of last ' '
    chop($res);
    return $res;
}

=for html <a name="format_last_first_middle"></a>

=head2 format_last_first_middle() : string

=head2 static format_last_first_middle(Bivio::Biz::Model model, string model_prefix) : string

Return Last, First Middle.

See L<format_name|"format_name"> for params.

=cut

sub format_last_first_middle {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return $proto->concat_last_first_middle($model->unsafe_get(
        $model_prefix . 'last_name', $model_prefix . 'first_name',
        $model_prefix . 'middle_name'));
}

=for html <a name="get_outgoing_emails"></a>

=head2 get_outgoing_emails() : array_ref

=head2 get_outgoing_emails(Bivio::Type::Location which) : array_ref

Returns an array of outgoing addresses for this user if no
I<which>.  Otherwise, returns a single address.

Returns C<undef> is there are no outgoing email addresses for
this user.

=cut

sub get_outgoing_emails {
    my($self, $which) = @_;
    my($email) = $self->new_other('Email');
    return undef unless $email->unauth_load({
        location => $which || Bivio::Type::Location->HOME,
        realm_id => $self->get('user_id'),
    });
    # Validate address
    return undef unless Bivio::Type::Email->is_valid($email->get('email'));
    return [$email->get('email')];
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'user_t',
	columns => {
            user_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            first_name => ['Name', 'NONE'],
            first_name_sort => ['Name', 'NONE'],
            middle_name => ['Name', 'NONE'],
            middle_name_sort => ['Name', 'NONE'],
            last_name => ['Name', 'NONE'],
            last_name_sort => ['Name', 'NONE'],
            gender => ['Gender', 'NOT_NULL'],
            birth_date => ['Date', 'NONE'],
        },
	other => [
            [qw(user_id RealmOwner.realm_id)],
	],
	auth_id => 'user_id',
    };
}

=for html <a name="invalidate_email"></a>

=head2 invalidate_email()

Invalidates user's e-mail address be prefixing it with "invalid:".
Checks to see if already invalidated.

=cut

sub invalidate_email {
    my($self) = @_;
    my($email) = $self->new_other('Email')->unauth_load_or_die({
        realm_id => $self->get('user_id'),
    });
    my($address) = $email->get('email');
    my($prefix) = Bivio::Type::Email->INVALID_PREFIX;
    # Already invalidated?
    return if $address =~ /^\Q$prefix/o;

    # Nope, need to invalidate
    my($other) = $self->new_other('Email');
    my($i) = 0;
    $i++ while $other->unauth_load({email => $prefix . $i . $address});
    $email->update({email => $prefix . $i . $address});
    return;
}

=for html <a name="set_encrypted_password"></a>

=head2 set_encrypted_password(string encrypted) : self

Sets a user's encrypted password to a new value.

=cut

sub set_encrypted_password {
    my($self, $encrypted) = @_;
    return _get_realm->update({password => $encrypted});
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values) : self

Updates the current model's values.  Validates one of
first, last and middle are set.

=cut

sub update {
    my($self, $new_values) = @_;
    _compute_sorting_names($new_values);
    my($res) = $self->SUPER::update($new_values);
    _validate_names($self);
    return $res;
}

#=PRIVATE METHODS

# _compute_sorting_names(hash_ref values, boolean )
#
# Computes the first/middle/last sorting field values.
#
sub _compute_sorting_names {
    my($values) = @_;

    # user lower case for sorting
    foreach my $field (qw(first_name middle_name last_name)) {
	next unless exists($values->{$field});

	if (defined($values->{$field}) && length($values->{$field})) {
	    $values->{$field . '_sort'} = lc($values->{$field});
	}
	else {
	    # set both to undef
	    $values->{$field} = undef;
	    $values->{$field . '_sort'} = undef;
	}
    }
    return;
}

# _get_realm() : Bivio::Biz::Model::RealmOwner
#
# Returns the realm owner for the current user_id.
#
sub _get_realm {
    my($self) = @_;
    return $self->new_other('RealmOwner')->unauth_load_or_die({
        realm_id => $self->get('user_id'),
    });
}

# _validate_names(self)
#
# Dies unless at least one of first/middle/last names are set.
#
sub _validate_names {
    my($self) = @_;
    $self->throw_die('must have at least one of first, last, and middle names')
        unless defined($self->get('first_name'))
            || defined($self->get('middle_name'))
            || defined($self->get('last_name'));
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
