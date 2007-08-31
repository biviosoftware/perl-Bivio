# Copyright (c) 2002-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserCreateForm;
use strict;
use Bivio::Base 'Bivio::Biz::FormModel';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    # Create the RealmOwner, User, Email, and RealmUser models.
    # Logs in as the new user.
    Bivio::Biz::Model->get_instance('UserLoginForm')->execute(
	$self->get_request,
	{realm_owner => ($self->internal_create_models)[0]});
    return;
}

sub internal_create_models {
    my($self, $params) = @_;
    # Creates User, RealmOwner, Email and RealmUser models.
    # Returns the RealmOwner and User created.
    #
    # Sets the password to INVALID if does not exist.
    # Email is set to an ignored value if it doesn't exist.
    #
    # The only difference between this method and execute_ok is that
    # the user is logged in at that point.
    #
    # Will not create email if value is
    # L<Bivio::Type::Email::IGNORE_PREFIX|Bivio::Type::Email::IGNORE_PREFIX>.
    #
    # Returns () if there is an error.
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
    my($e) = $self->new_other('Email');
    my($et) = $e->get_field_type('email');
    $e->create({
	realm_id => $user->get('user_id'),
	email => $self->unsafe_get('Email.email')
	    || $et->format_ignore(
		$realm->get('name')
		    . '-'
		    . $self->use('Bivio::Biz::Random')->hex_digits(8),
		$req,
	    ),
	want_bulletin => $params->{'Email.want_bulletin'} || 0,
    }) unless ($self->unsafe_get('Email.email') || '') eq $et->IGNORE_PREFIX;
    return ($realm, $user);
}

sub internal_initialize {
    my($self) = @_;
    # B<FOR INTERNAL USE ONLY>
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

sub parse_display_name {
    my($self, $display_name) = @_;
    # Returns a hash_ref of first_name, middle_name, last_name parsed from the
    # display_name.  Returns L<Bivio::TypeError|Bivio::TypeError> if there
    # was a syntax error while parsing.
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

sub validate {
    my($self) = @_;
    # Ensures the fields are valid.
    $self->internal_put_error('RealmOwner.password', 'CONFIRM_PASSWORD')
	unless $self->get_field_error('RealmOwner.password')
	    || $self->get_field_error('confirm_password')
	    || $self->get('RealmOwner.password')
		eq $self->get('confirm_password');
    return;
}

sub _is_conjunction {
    my($str) = @_;
    # Returns 1 if $str matches a conjunction
    return 1 if ($str =~ /^and$|^&$/i);
    return 0;
}

sub _parse_first {
    my($name, $parts) = @_;
    # Sets the prefix (if applicable) and the firstname.
    # Catches (with or without periods):
    #   Mr, Mrs, Sir, Dr, Miss, Rev, Ms, etc.
    # Names joined by 'and' or '&' are considered both firstnames components,
    # unless there is no last name given.
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

sub _parse_last {
    my($name, $parts) = @_;
    # Sets the suffix (if applicable) and the surname (including patronymic).
    # Catches anything with a period in the last place as a suffix.  Also detects
    # certain common suffixes without periods, ie:
    #     Sr, Jr, PhD, JD, MD, I, II, III, IV, 1st, 2nd, 3rd, etc.
    # Removes commas if present before adding them.
    # Returns if second to last word is a form of '&' (both stored as first name)
    return if @$parts > 2 && _is_conjunction($parts->[-2]);
    my($last) = pop(@$parts);
    $name->{last_name} = $last;

    if (scalar(@$parts)) {
        while ($last =~ /^(sr|jr|phd|dvm|jd|md|dds|pe|I|IV|V|\d..)$|\.|^I{2,}/i
            || ((@$parts)[-1] && (@$parts)[-1] =~ /\,$/)) {
            $last = pop(@$parts);
            $name->{last_name} = $last . ($last =~ /\,$/ ? ' ' : ', ')
                . $name->{last_name};
        }
    }
    return unless scalar(@$parts);
    # Check for patronymics in last place: van, von, de la
    if ($parts->[-1] =~ /^(van|von|la|de|du)$/i) {
	my($patr) = pop(@$parts);
	$name->{last_name} = $patr.' '.$name->{last_name};
	return unless defined($parts->[0]);
	if ($parts->[-1] =~ /^de$/i) {
	    my($de) = pop(@$parts);
	    $name->{last_name} = $de.' '.$name->{last_name};
	}
    }
    return;
}

sub _parse_middle {
    my($name, $parts) = @_;
    # Checks for leftover parts and stores them as the middle name.
    return unless @$parts;
    $name->{middle_name} = join(' ', @$parts);
    return;
}

sub _trim {
    my($value) = @_;
    # Trims the field to the correct size.
    return undef unless defined($value);
    return substr($value, 0, Bivio::Type::Name->get_width);
}

1;
