# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserCreateForm;
use strict;
$Bivio::Biz::Model::UserCreateForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::UserCreateForm::VERSION;

=head1 NAME

Bivio::Biz::Model::UserCreateForm - create a new user

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserCreateForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::UserCreateForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserCreateForm> creates a new user.  Subclasses may want
to override this form.

=cut

#=IMPORTS
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::IO::Trace;
use Bivio::Type::Location;
use Bivio::Type::Name;
use Bivio::Type::Password;
use Bivio::Biz::Random;

#=VARIABLES
my($_E) = Bivio::Type->get_instance('Email');

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Create the RealmOwner, User, Email, and RealmUser models.
Logs in as the new user.

=cut

sub execute_ok {
    my($self) = @_;
    Bivio::Biz::Model->get_instance('UserLoginForm')->execute(
	$self->get_request,
	{realm_owner => ($self->internal_create_models)[0]});
    return;
}

=for html <a name="internal_create_models"></a>

=head2 internal_create_models() : array

Creates User, RealmOwner, Email and RealmUser models.
Returns the RealmOwner and User created.

Sets the password to INVALID if does not exist.
Email is set to an ignored value if it doesn't exist.

The only difference between this method and execute_ok is that
the user is logged in at that point.

Will not create email if value is
L<Bivio::Type::Email::IGNORE_PREFIX|Bivio::Type::Email::IGNORE_PREFIX>.

Returns () if there is an error.

=cut

sub internal_create_models {
    my($self, $params) = @_;
    $params ||= {};
    my($req) = $self->get_request;
    my($x) = $self->parse_display_name($self->get('RealmOwner.display_name'));
    unless (ref($x) eq 'HASH') {
	$self->internal_put_error('RealmOwner.display_name' => $x);
	return;
    }
    my($user, $realm) = $self->new_other('User')->create_realm(
	$x,
	$self->get_model_properties('RealmOwner'),
    );
    $self->internal_put_field('User.user_id' => $user->get('user_id'));
    $self->new_other('Email')->create({
	realm_id => $user->get('user_id'),
	email => $self->unsafe_get('Email.email')
	    || $_E->format_ignore(
		$realm->get('name') . '-' . Bivio::Biz::Random->hex_digits(8),
		$req,
	    ),
	want_bulletin => $params->{'Email.want_bulletin'} || 0,
    }) unless ($self->unsafe_get('Email.email') || '') eq $_E->IGNORE_PREFIX;
    return ($realm, $user);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [
	    'RealmOwner.display_name',
	    'Email.email',
            'RealmOwner.password',
	    {
		name => 'confirm_password',
		type => 'Password',
		constraint => 'NOT_NULL',
	    },
	],
	other => [
	    {
		name => 'RealmOwner.name',
		constraint => 'NONE',
	    },
	    {
		name => 'User.user_id',
		constraint => 'NONE',
	    },
	],
    });
}

=for html <a name="parse_display_name"></a>

=head2 parse_display_name(string display_name) : any

Returns a hash_ref of first_name, middle_name, last_name parsed from the
display_name.  Returns L<Bivio::TypeError|Bivio::TypeError> if there
was a syntax error while parsing.

=cut

sub parse_display_name {
    my($self, $display_name) = @_;
    # Clean up display_name (add spaces after commas, non-suffix periods,
    # remove extra spaces).
    my($dn) = $display_name;
    $dn =~ s/,(\S)/, $1/g;
    $dn =~ s/\.(.*\s)/. $1/g;

    # Split on spaces; reorder and remove comma if entered backwards
    # Only works if comma after first word (eg: 'la salle, jane' fails)
    my(@parts) = split(' ', $dn);
    return Bivio::TypeError->UNSPECIFIED
	unless scalar(@parts);
    if($parts[0] =~ /,$/) {
	$parts[0] =~ s/,//;
	push(@parts, shift(@parts));
    }

    # Parse by priority.  There is always a last name (unless format is a & b)
    my($name) = {};
    _parse_last($name, \@parts);
    _parse_first($name, \@parts);
    _parse_middle($name, \@parts);

    my($total) = 0;
    foreach my $part (keys(%$name)) {
	return Bivio::TypeError->from_name(uc($part).'_LENGTH')
	    if defined($name->{$part})
		&& length($name->{$part}) > Bivio::Type::Name->get_width;
	$total += length($name->{$part});
    }

    return Bivio::TypeError->NULL
	unless $total;
    _trace($name) if $_TRACE;
    return $name;
}

=for html <a name="validate"></a>

=head2 validate()

Ensures the fields are valid.

=cut

sub validate {
    my($self) = @_;
    $self->internal_put_error('RealmOwner.password', 'CONFIRM_PASSWORD')
	unless $self->get_field_error('RealmOwner.password')
	    || $self->get_field_error('confirm_password')
	    || $self->get('RealmOwner.password')
		eq $self->get('confirm_password');
    return;
}

#=PRIVATE SUBROUTINES

# _is_conjunction(string str) : boolean
#
# Returns 1 if $str matches a conjunction
#
sub _is_conjunction {
    my($str) = @_;
    return 1 if ($str =~ /^and$|^&$/i);
    return 0;
}

# _parse_first(hashref name, arrayref parts)
#
# Sets the prefix (if applicable) and the firstname.
# Catches (with or without periods):
#   Mr, Mrs, Sir, Dr, Miss, Rev, Ms, etc.
# Names joined by 'and' or '&' are considered both firstnames components,
# unless there is no last name given.
sub _parse_first {
    my($name, $parts) = @_;
    return unless int (@$parts)>0;
    my($first) = shift(@$parts);
    if ($first =~ /^(mr\.?|mrs\.?|sir|dr\.?|miss|rev\.?|ms\.?)$/i
	    && @$parts) {
	$name->{first_name} = $first.' '.shift(@$parts);
    }
    else {
	$name->{first_name} = $first;
    }
    return unless @$parts;
    if(_is_conjunction($parts->[0])) {
	$name->{first_name} .= ' '.shift(@$parts).' ';
	$name->{first_name} .= shift(@$parts) if @$parts;
    }
    # Remove trailing space if exists
    $name->{first_name} =~ s/\s$//;
    return;
}

# _parse_last(hashref name, arrayref parts)
#
# Sets the suffix (if applicable) and the surname (including patronymic).
# Catches anything with a period in the last place as a suffix.  Also detects
# certain common suffixes without periods, ie:
#     Sr, Jr, PhD, JD, MD, I, II, III, IV, 1st, 2nd, 3rd, etc.
# Removes commas if present before adding them.
# Returns if second to last word is a form of '&' (both stored as first name)
sub _parse_last {
    my($name, $parts) = @_;
    return if _is_conjunction($parts->[$#$parts - 1]);
    my($last) = pop(@$parts);
    if ($last =~ /^(sr|jr|phd|dvm|jd|md|dds|pe|I|IV|V|\d..)$|\.|^I{2,}/i
	    && defined($parts->[0])) {
	my($penult) = pop(@$parts);
	$penult =~ s/,//;
	$name->{last_name} = $penult.', ';
    }
    $name->{last_name} .= $last;

    return unless defined($parts->[0]);
    # Check for patronymics in last place: van, von, de la
    if ($parts->[$#$parts] =~ /^(van|von|la|de|du)$/i) {
	my($patr) = pop(@$parts);
	$name->{last_name} = $patr.' '.$name->{last_name};
	return unless defined($parts->[0]);
	if ($parts->[$#$parts] =~ /^de$/i) {
	    my($de) = pop(@$parts);
	    $name->{last_name} = $de.' '.$name->{last_name};
	}
    }
    return;
}

# _parse_middle(hashref name, arrayref parts)
#
# Checks for leftover parts and stores them as the middle name.
#
sub _parse_middle {
    my($name, $parts) = @_;
    return unless @$parts;
    $name->{middle_name} = join(' ', @$parts);
    return;
}

# _trim(string value) : string
#
# Trims the field to the correct size.
#
sub _trim {
    my($value) = @_;
    return undef unless defined($value);
    return substr($value, 0, Bivio::Type::Name->get_width);
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
