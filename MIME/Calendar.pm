# Copyright (c) 2005-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::MIME::Calendar;
use strict;
use Bivio::Base 'Collection.Attributes';
use POSIX ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_HTML) = b_use('Bivio::HTML');
my($_S) = b_use('Type.String');
my($_SECONDS_IN_WEEK) = $_DT->SECONDS_IN_DAY * 7;
my($_TZ) = b_use('Type.TimeZone');

sub COMMON_TIME_ZONES {
    return [
        $_TZ->PACIFIC_HONOLULU,
        $_TZ->AMERICA_ANCHORAGE,
        $_TZ->AMERICA_ADAK,
        $_TZ->AMERICA_LOS_ANGELES,
        $_TZ->AMERICA_DENVER,
        $_TZ->AMERICA_CHICAGO,
        $_TZ->AMERICA_NEW_YORK,
        $_TZ->UTC,
        $_TZ->EUROPE_BERLIN,
        $_TZ->EUROPE_ATHENS,
        $_TZ->EUROPE_MOSCOW,
        $_TZ->ASIA_KARACHI,
        $_TZ->ASIA_SHANGHAI,
        $_TZ->ASIA_TOKYO,
        $_TZ->AUSTRALIA_SYDNEY,
        $_TZ->PACIFIC_AUCKLAND,
    ];
}

sub from_ics {
    my($proto, $ics) = @_;
    return _split(
        $proto->new({
            ics => $ics,
            row_num => 0,
            vevents => [],
        }));
}

sub guess_time_zone {
    my($self, $time) = @_;
    if (my $tz = $_TZ->unsafe_from_any($self->unsafe_get('time_zone_id'))) {
        return $tz;
    }
    $time ||= $_DT->now;
    my($utc) = $self->to_utc($time);
    my(@tzs) = $_TZ->get_list;
    foreach my $tz (@{$self->COMMON_TIME_ZONES}) {
        return $tz
            unless $_DT->compare_defined($utc, $tz->date_time_to_utc($time));
    }
    return $_TZ->UTC;
}

sub to_utc {
    my($self, $time) = @_;
    $time ||= $_DT->now;
    my($transitions) = _tz_transitions_for_year($self, $time);
    my($offset);
    foreach my $transition (@$transitions) {
        if ($_DT->compare_defined($time, $transition->{start}) < 0) {
            $offset ||=  $transition->{offset_from};
            last;
        } else {
            $offset = $transition->{offset_to};
        }
    }
    return $_DT->add_seconds($time, - $offset)
        if defined($offset);
    return $time;
}

sub vevents_from_ics {
    my($proto, $ics) = @_;
    return [
	sort({
	    my($r) = $_D->compare($a->{dtstart}, $b->{dtstart});
	    if ($r) {
		return $r;
	    }
	    if ($a->{rrule} && $b->{rrule}) {
		return $a->{rrule} cmp $b->{rrule}
	    }
	    if ($a->{rrule} || $b->{rrule}) {
		return $a->{rrule} ? 1 : -1;
	    }
	    return 0;
	} @{$proto->from_ics($ics)->get('vevents')}),
    ];
}


sub _assert {
    my($self, $expect) = @_;
    my($r) = _next_row($self);
    _die($self, ': element does not match: ', $expect)
	unless "@{[map(lc($_), @$r)]}" eq "@$expect";
    return;
}

sub _do_until {
    my($self, $key, $op) = @_;
    my($rows) = $self->get('rows');
    until ($rows->[0]->[0] eq $key) {
	last unless $op->(@{_next_row($self)});
    }
    return;
}

sub _die {
    my($self, @msg) = @_;
    b_die($self->get('row'), ': ', @msg, ' at row ', $self->get('row_num'));
}

sub _event {
    my($self) = @_;
    my($ve) = {};
    _do_until($self, 'end', sub {
        my($k, $v) = @_;
        return 1
	    if $k =~ m{^(?:
		|attendee
		|categories
		|confirmed
		|created
		|dtstamp
		|last-modified
		|organizer
		|priority
		|transp
                |x-alt-[^;]*
                |x-entourage[^;]*
	        |x-lic-error
                |x-microsoft-[^;]*
                |x-ms-[^;]*
		|contact
		|exrule
		|x-cost
	    )(?:$|;)}x;
	if ($k =~ /^(dtstart|dtend|recurrence-id|exdate)(;value=date(?:-time)?)?(;tzid=(.*))?$/) {
	    my($w) = $1;
	    my($is_date) = ($2 && $2 =~ /date$/) || $v =~ /\b\d{8}\b/ ? 1 : 0;
	    my($tz) = $3 ? $4 : $self->unsafe_get('time_zone_id');
	    my($is_gmt) = $v =~ /Z$/;
	    my($t, $e) = ($is_date ? $_D : $_DT)->from_literal(
		$v . ($is_date || $is_gmt ? '' : 'Z'));
	    _die($self, $v, ": failed to parse $k: ", $e)
		unless $t;
	    $ve->{time_zone} = $_TZ->unsafe_from_any($tz)
                || $self->guess_time_zone($t);
	    $k = $w;
	    $v = $is_date || $is_gmt
		? $t
		: $self->to_utc($t);
	}
	elsif ($k eq 'tzid') {
	    $ve->{time_zone} = $_TZ->from_any($v);

	    foreach my $key (qw(dtstart dtend)) {
		_die($self, 'tzid found, but missing field: ', $key)
		    unless $ve->{$key};
		next if $_DT->is_date($ve->{$key});
		$ve->{$key} = $ve->{time_zone}->date_time_to_utc($ve->{$key});
	    }
	}
	elsif ($k eq 'begin') {
	    _die($self, 'unknown event subentry')
		unless _ignore_subentry($self, $v) eq 'valarm';
	    return 1;
	}
	elsif ($k =~ /^(url)(;value=uri)?$/) {
	    $k = $1;
	}
	elsif ($k =~ /^(summary)(;language=(.*))?$/) {
	    $k = $1;
	}
	elsif ($k =~ /^(description)(;language=(.*))?$/) {
	    $k = $1;
	}
	elsif ($k !~ m{^(?:
	    location
            |method
	    |class
	    |url
	    |uid
	    |rrule
	    |recurrence-id
	    |sequence
	    |status
	    )$}x) {
	    _die($self, $k, ': unsupported attribute');
	    # DOES NOT RETURN
	}

	if ($k eq 'exdate') {
	    push(@{$ve->{$k} ||= []}, $v);
	}
	elsif (exists($ve->{$k})) {
	    _die($self, $k, ': attribute may not be repeated');
	}
	else {
	    $ve->{$k} = $v;
	}
	return 1;
    });
    push(@{$self->get('vevents')}, $ve);
    return;
}

sub _header {
    my($self) = @_;
    _assert($self, [begin => 'vcalendar']);
    my($end_vcalendar) = 0;
    _do_until($self, 'begin', sub {
	my($k, $v) = @_;

	if ($k eq 'end' && lc($v) eq 'vcalendar') {
	    $end_vcalendar = 1;
	    return 0;
	}
        if ($k eq 'method') {
            $self->put($k => $v);
            return 1;
        }
	_die($self, 'unknown element')
	    unless $k =~ /^(version|prodid|calscale|(x-wr-.*)|(x-ms-.*)|(x-from-.*)|(x-published-.*))$/;
	return 1;
    });
    return $self
	if $end_vcalendar;
    _do_until($self, 'end', sub {
	my($k, $v) = @_;
	_die($self, 'expecting begin but found: ', $k)
	    unless $k eq 'begin';
	my($type) = lc($v);

	if ($type eq 'vtimezone') {
	    $self->put(time_zone_periods => _timezone($self));
	}
	elsif ($type eq 'vevent') {
	    _event($self);
	}
	else {
	    _die($self, 'unknown begin: ', $v);
	}
	_assert($self, [end => $type]);
	return 1;
    });
    _assert($self, [end => 'vcalendar']);
    return $self;
}

sub _ignore_subentry {
    my($self, $type) = @_;
    $type = lc($type);
    _do_until($self, 'end', sub {
        return 1;
    });
    _assert($self, [end => $type]);
    return $type;
}

sub _next_row {
    my($self) = @_;
    $self->put(row_num => $self->get('row_num') + 1);
    my($r) = shift(@{$self->get('rows')}) || _die($self, 'unexpected eof');
    $self->put(row => $r);
    return $r;
}

sub _parse_value_params {
    my($self, $value, $sep) = @_;
    $sep ||= ';';
    my($res) = {};
    foreach my $part (split($sep, $value)) {
        my($n, $v) = $part =~ /(^[^=]+)=(.*)$/;
        $res->{lc($n)} = $v;
    }
    return $res;
}

sub _seconds_from_hhmmss {
    my($self, $value) = @_;
    my($hours, $minutes, $seconds) = ($value || '') =~ /^([+\-]\d\d)(\d\d)?(\d\d)?/;
    return (($hours * 60) + ($minutes || 0)) * 60 + ($seconds || 0);
}

sub _split {
    my($self) = @_;
    (my $ics = ${$self->get('ics')}) =~ s/\r?\n( |\t)//g;
    $ics =~ s/(\r?\n)+/\n/g;
    return _header($self->put(rows => [
	map({
	    chomp($_);
	    $_ =~ s/\s+$//;
	    my($k, $v) = split(/\s*:\s*/, $_, 2);
	    $v = defined($v) ? $v : '';
	    $v =~ s/\\n/\n/ig;
	    $v =~ s/\\([,;\\:"])/$1/g;
	    # quotes are sometimes double escaped?
	    $v =~ s/\\(["])/$1/g;
	    [lc($k), ${$_S->canonicalize_charset(
		$_HTML->unescape(${$_S->canonicalize_charset(\$v)}))}];
	} split(/\r?\n/, $ics)),
    ]));
}

sub _timezone {
    my($self) = @_;
    my($res) = {};
    _do_until($self, 'end', sub {
        my($k, $v) = @_;
        _die($self, ['repeated timezone'])
            if $self->unsafe_get('time_zone_periods');
	$self->put(time_zone_id => $v)
	    if $k eq 'tzid';
	return 1
	    unless $k eq 'begin';
        $res->{$v} = _timezone_period($self, $v);
	return 1;
    });
    return $res;
}

sub _timezone_period {
    my($self, $type) = @_;
    $type = lc($type);
    my($res) = {};
    _do_until($self, 'end', sub {
        my($k, $v) = @_;
        $res->{$k} = $v;
        return 1;
     });
    _assert($self, [end => $type]);
    return $res;
}

sub _tz_transition_for_year {
    my($self, $time, $period) = @_;
    my($dtstart) = $period->{dtstart};
    return
        unless defined($dtstart)
            && defined($period->{tzoffsetfrom})
            && defined($period->{tzoffsetto});
    $dtstart .= 'Z'
        unless $dtstart =~ /Z$/;
    $dtstart =~ s/^16\d\d/1970/;
    return {
        start => $_DT->from_literal($dtstart),
        offset_from => _seconds_from_hhmmss($self, $period->{tzoffsetfrom}),
        offset_to => _seconds_from_hhmmss($self, $period->{tzoffsetto}),
    } unless defined($period->{rrule});
    # nearly all the world's timezone transitions are
    # on the nth Sunday of a given month see
    # http://www.webexhibits.org/daylightsaving/g.html
    my($sec, $min, $hour, $day, $mon) = $_DT->to_parts($_DT->from_literal($dtstart));
    my($dt) = $_DT->from_parts_or_die($sec, $min, $hour, 1, $mon,
                                      $_DT->get_parts($time, 'year'));
    my($unix) = $_DT->to_unix($dt);
    $unix = (POSIX::floor($unix / $_SECONDS_IN_WEEK) * $_SECONDS_IN_WEEK)
        + ($unix % $_DT->SECONDS_IN_DAY);
    $unix -= 4 * $_DT->SECONDS_IN_DAY;
    my($sundays) = [];
    foreach my $i (1 .. 6) {
        push(@$sundays, $_DT->from_unix($unix))
            if (gmtime($unix))[4] + 1 == $mon;
        $unix += $_SECONDS_IN_WEEK;
    }
    my($rule) = _parse_value_params($self, $period->{rrule});
    return
        unless defined($rule->{freq})
            && defined($rule->{bymonth})
            && defined($rule->{byday})
            && $rule->{freq} eq 'YEARLY'
            && $rule->{byday} =~ /^-?\dSU$/;
    my($n) = $rule->{byday} =~ /^(-?\d)/;
    $n -= 1
        if $n > 0;
    return {
        start => $sundays->[$n],
        offset_from => _seconds_from_hhmmss($self, $period->{tzoffsetfrom}),
        offset_to => _seconds_from_hhmmss($self, $period->{tzoffsetto}),
    };
}

sub _tz_transitions_for_year {
    my($self, $time) = @_;
    my($tzp) = $self->unsafe_get('time_zone_periods');
    my ($res) = [];
    foreach my $k (keys(%$tzp)) {
        my($period) = $tzp->{$k};
        if (my($transition) = _tz_transition_for_year($self, $time, $tzp->{$k})) {
            push(@$res, $transition);
        }
    }
    return [sort({$_DT->compare_defined($a->{start}, $b->{start})} @$res)];
}

1;
