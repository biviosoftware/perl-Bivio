# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DisplayName;
use strict;
use Bivio::Base 'Type.Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_N) = __PACKAGE__->use('Type.Name');

sub get_width {
    return 500;
}

sub parse_to_names {
    my(undef, $display_name) = @_;
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
    return $name;
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
    return substr($value, 0, $_N->get_width);
}

1;
