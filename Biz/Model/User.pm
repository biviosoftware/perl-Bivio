# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::User;
use strict;
$Bivio::Biz::Model::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::User - interface to user_t SQL table

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
use Bivio::Agent::Request;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::RealmUser;
use Bivio::SQL::Connection;
use Bivio::SQL::Constraint;
use Bivio::Type::Date;
use Bivio::Type::Email;
use Bivio::Type::Enum;
use Bivio::Type::Gender;
use Bivio::Type::Location;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
use Bivio::Type::RealmName;

#=VARIABLES
my($_SHADOW_PREFIX) = Bivio::Biz::Model::RealmOwner->SHADOW_PREFIX();
# arbitrary value, allows for 99,999 name collisions
my($_MAX_SHADOW_INDEX) = 99999;
my($_MAX_SHADOW_NAME_SIZE) = Bivio::Type::RealmName->get_width - 8;

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 cascade_delete()

Deletes this user and all its related realm information. This will not
delete club RealmUser data, and if it exists then this method will die.

=cut

sub cascade_delete {
    my($self) = @_;

    my($id) = $self->get('user_id');
    my($realm) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    $realm->unauth_load(realm_id => $id)
	    || die("couldn't load realm from user");
    # delete this user's RealmUser
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($self->get_request);
    $realm_user->unauth_load(realm_id => $id, user_id => $id)
	    || die("couldn't find user's RealmUser");
    $realm_user->delete();

    # Clear the user from any outstanding invites.
    # This happens if the user is a shadow user.
    Bivio::SQL::Connection->execute('
            DELETE from realm_invite_t
            WHERE realm_user_id=?',
	    [undef, $id]);

    $self->delete();

    # delete realm specified data (email, address, ...)
    $realm->cascade_delete();
    return;
}

=for html <a name="concat_last_first_middle"></a>

=head2 static concat_last_first_middle(string last, string first, string middle) : string

Does the work of L<format_last_first_middle|"format_last_first_middle">.

=cut

sub concat_last_first_middle {
    my(undef, $ln, $fn, $mn) = @_;

    # We shown the last_name as "-" if not set.
    if (defined($ln)) {
	my($res) = undef;
	return $ln unless defined($fn) || defined($mn);
	$res = $ln.',';
	$res .= ' '.$fn if defined($fn);
	$res .= ' '.$mn if defined($mn);
	return $res;
    }

    return $fn.' '.$mn if defined($fn) && defined($mn);

    return defined($fn) ? $fn : $mn;
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<gender> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = (shift, shift);
    $values->{gender} ||= Bivio::Type::Gender::UNKNOWN();
    my($got_one) = 0;
    foreach my $field (qw(last_name first_name middle_name)) {
	my($value) = $values->{$field};
	if (defined($value) && length($value)) {
	    $values->{$field.'_sort'} = lc($value);
	    $got_one++;
	}
	else {
	    $values->{$field.'_sort'} = undef;
	}
    }
    $self->die('must have at least one of first, last, and middle names')
	    unless $got_one;
    return $self->SUPER::create($values, @_);
}

=for html <a name="format_full_name"></a>

=head2 format_full_name() : string

Returns the first, middle, and last names as one string.

B<You should use RealmOwner.display_name whenever possible as the
values are identical.>

=cut

sub format_full_name {
    my($self) = @_;
    my($res) = '';
    # Always have at least one name.
    foreach my $n ($self->unsafe_get(qw(first_name middle_name last_name))) {
 	$res .= $n.' ' if defined($n);
    }
    # Get rid of last ' '
    chop($res);
    return $res;
}

=for html <a name="format_last_first_middle"></a>

=head2 format_last_first_middle() : string

=head2 static format_last_first_middle(Bivio::Biz::ListModel list_model, string model_prefix) : string

Return Last, First Middle.

See L<format_name|"format_name"> for params.

=cut

sub format_last_first_middle {
    my($self, $list_model, $model_prefix) = @_;
    # Have at least on name or returns undef
    my($p) = $model_prefix || '';
    my($m) = $list_model || $self;

    return $self->concat_last_first_middle($m->unsafe_get(
	    $p.'last_name', $p.'first_name', $p.'middle_name'));
}

=for html <a name="generate_shadow_user_name"></a>

=head2 static generate_shadow_user_name(string first_name, string last_name) : string

=head2 static generate_shadow_user_name(string first_name, string last_name) : string

Creates a shadow realm name for the user with the specified first/last name.
The name will be unique across current realms.

The shadow user name format is:

    =<first>_<last><num>

Ex. =roberto_zanutta2-1

The name portion will be truncated if necessary.

=cut

sub generate_shadow_user_name {
    my(undef, $first_name, $last_name) = @_;

    die("invalid first and last name")
	    unless defined($first_name) || defined($last_name);
    my($name) = $last_name || '';
    $name = $first_name.'_'.$name if defined($first_name);
    $name =~ s/\s/_/g;
    $name =~ s/[\W]//g;
    $name = $_SHADOW_PREFIX.lc($name);
    if (length($name) > $_MAX_SHADOW_NAME_SIZE) {
	$name = substr($name, 0, $_MAX_SHADOW_NAME_SIZE)
    }

    my($req) = Bivio::Agent::Request->get_current
	    || Bivio::Agent::Request->new();
    my($realm) = Bivio::Biz::Model::RealmOwner->new($req);
    my($unique_num) = 0;
    my($n);
    while ($realm->unauth_load(name => $n = $name.$unique_num)) {
	$unique_num++;
	# Unlikely to happen, but we certainly want to die when it does.
	die($n, ": too many collisions") if $unique_num > $_MAX_SHADOW_INDEX;
    }
    return $n;
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


    # Load Email
    my($loc) = $which ? $which : Bivio::Type::Location::HOME();
    my($email) = Bivio::Biz::Model::Email->new($self->get_request);
    return undef unless $email->unauth_load(
	    location => $loc, realm_id => $self->get('user_id'));

    # Validate address
    my($a) = $email->get('email');
    return undef unless Bivio::Type::Email->is_valid($a);

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
            user_id => ['PrimaryId', 'PRIMARY_KEY'],
            first_name => ['Name', 'NONE'],
            first_name_sort => ['Name', 'NONE'],
            middle_name => ['Name', 'NONE'],
            middle_name_sort => ['Name', 'NONE'],
            last_name => ['Name', 'NONE'],
            last_name_sort => ['Name', 'NONE'],
            gender => ['Gender', 'NOT_NULL'],
            birth_date => ['Date', 'NONE'],
        },
	auth_id => 'user_id',
    };
}

=for html <a name="set_encrypted_password"></a>

=head2 set_encrypted_password(string encrypted) : 

Sets a user's encrypted password to a new value.

=cut

sub set_encrypted_password {
    my($self, $encrypted) = @_;

    my($id) = $self->get('user_id');
    my($realm) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    $realm->unauth_load(realm_id => $id)
	    || die("couldn't load realm from user");
    return $realm->update({password => $encrypted});
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values)

Updates the current model's values.  Validates one of
first, last and middle are set.

=cut

sub update {
    my($self, $new_values) = (shift, shift);
    my($properties) = $self->internal_get;
    my($got_one) = 0;
    # Must either have a defined value
    foreach my $n (qw(first_name middle_name last_name)) {
	if (exists($new_values->{$n})) {
	    if (defined($new_values->{$n}) && length($new_values->{$n})) {
		$new_values->{$n.'_sort'} = lc($new_values->{$n});
		$got_one++;
	    }
	    else {
		# Set value to null
		$new_values->{$n.'_sort'} = undef;
	    }
	}
	# Don't need to check length, since user can't touch these values
	elsif (defined($properties->{$n})) {
	    $got_one++;
	}
    }
    $self->die('must have at least one of first, last, and middle names')
	    unless $got_one;
    return $self->SUPER::update($new_values, @_);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
