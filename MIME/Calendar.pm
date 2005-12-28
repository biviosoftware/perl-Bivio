# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::MIME::Calendar;
use strict;
use base 'Bivio::Collection::Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = Bivio::Type->get_instance('Date');
my($_DT) = Bivio::Type->get_instance('DateTime');

sub from_ics {
    my($proto, $ics) = @_;
    return _split($proto->new({
	ics => $ics,
	row_num => 0,
	vevents => [],
    }))->get('vevents');
}

sub _assert {
    my($self, $expect) = @_;
    my($r) = _next_row($self);
    _e($self, ': element does not match: ', $expect)
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

sub _e {
    my($self, @msg) = @_;
    Bivio::Die->die(
	$self->get('row'), ': ', @msg, ' at row ', $self->get('row_num'));
    # DOES NOT RETURN
}

sub _event {
    my($self) = @_;
    my($ve) = {};
    _do_until($self, 'end', sub {
        my($k, $v) = @_;
        return 1
	    if $k =~ m{^(status|x-lic-error|categories|last-modified|created
	    |dtstamp|priority)$}x;
	if ($k =~ /^(dtstart|dtend)(;value=date)?$/) {
	    my($w) = $1;
	    my($is_date) = $2;
#TODO: Timezone
	    $v .= 'Z'
		unless $is_date || $v =~ /Z$/;
	    my($t, $e) = ($2 ? $_D : $_DT)->from_literal($v);
	    _e($v, ": failed to parse $k: ", $e)
		unless $t;
	    $k = $w;
	    $v = $t;
	}
	elsif ($k !~ m{^(summary|description|location|class|url|uid)$}x) {
	    _e($self, $k, ': unsupported attribute');
	    # DOES NOT RETURN
	}
	_e($k, ': attribute may not be repeated')
	    if exists($ve->{$k});
	$ve->{$k} = $v;
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
	_e($self, 'unknown element')
	    unless $k =~ /^(version|prodid)$/;
	return 1;
    });
    _do_until($self, 'end', sub {
	my($k, $v) = @_;
        _e($self, 'expecting begin vevent')
	    unless $k eq 'begin' && lc($v) eq 'vevent';
	_event($self);
	_assert($self, [end => 'vevent']);
	return 1;
    });
    _assert($self, [end => 'vcalendar']);
    return $self;
}

sub _next_row {
    my($self) = @_;
    $self->put(row_num => $self->get('row_num') + 1);
    my($r) = shift(@{$self->get('rows')}) || _e($self, 'unexpected eof');
    $self->put(row => $r);
    return $r;
}

sub _split {
    my($self) = @_;
    (my $ics = ${$self->get('ics')}) =~ s/\r?\n //g;
    return _header($self->put(rows => [
	map({
	    chomp($_);
	    $_ =~ s/\s+$//;
	    my($k, $v) = split(/\s*:\s*/, $_, 2);
	    [lc($k), $v];
	} split(/\r?\n/, $ics)),
    ]));
}

1;
