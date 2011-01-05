# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::MIME::Calendar;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_TZ) = b_use('Type.TimeZone');

sub from_ics {
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
	} @{_split(
	    $proto->new({
		ics => $ics,
		row_num => 0,
		vevents => [],
	    }),
	)->get('vevents')}),
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
    my($default_tz) = $self->unsafe_get('time_zone');
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
	        |x-lic-error
	    )(?:$|;)}x;
	if ($k =~ /^(dtstart|dtend|recurrence-id|exdate)(;value=date)?(;tzid=(.*))?$/) {
	    my($w) = $1;
	    my($is_date) = $2;
	    my($tz) = $3 ? $4 : $default_tz;
	    my($is_gmt) = $v =~ /Z$/;
	    my($t, $e) = ($is_date ? $_D : $_DT)->from_literal(
		$v . ($is_date || $is_gmt ? '' : 'Z'));
	    _die($self, $v, ": failed to parse $k: ", $e)
		unless $t;
	    $ve->{time_zone} = $tz ? $_TZ->from_any($tz) : $_TZ->UTC;
	    $k = $w;
	    $v = $is_date || $is_gmt
		? $t
		: $ve->{time_zone}->date_time_to_utc($t);
	}
	elsif ($k eq 'begin') {
	    _die($self, 'unknown event subentry')
		unless _ignore_subentry($self, $v) eq 'valarm';
	    return 1;
	}
	elsif ($k !~ m{^(?:
	    summary
	    |description
	    |location
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
    _do_until($self, 'begin', sub {
	my($k, $v) = @_;
	_die($self, 'unknown element')
	    unless $k =~ /^(version|prodid|method|calscale|(x-wr-.*))$/;
	return 1;
    });
    _do_until($self, 'end', sub {
	my($k, $v) = @_;
	_die($self, 'expecting begin')
	    unless $k eq 'begin';
	my($type) = lc($v);

	if ($type eq 'vtimezone') {
	    _timezone($self);
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

sub _split {
    my($self) = @_;
    (my $ics = ${$self->get('ics')}) =~ s/\r?\n //g;
    $ics =~ s/(\r?\n)+/\n/g;
    return _header($self->put(rows => [
	map({
	    chomp($_);
	    $_ =~ s/\s+$//;
	    my($k, $v) = split(/\s*:\s*/, $_, 2);
	    $v =~ s/\\n/\n/g;
	    $v =~ s/\\([,;])/$1/g;
	    [lc($k), $v];
	} split(/\r?\n/, $ics)),
    ]));
}

sub _timezone {
    my($self) = @_;
    _do_until($self, 'end', sub {
        my($k, $v) = @_;
	$self->put(time_zone => $v)
	    if $k eq 'tzid';
	return 1
	    unless $k eq 'begin';
	_ignore_subentry($self, $v);
	return 1;
    });
    return;
}

1;
