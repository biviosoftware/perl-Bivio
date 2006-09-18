# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TimeZone;
use strict;
use base 'Bivio::Type::Enum';
use DateTime ();  #Olson DateTime::TimeZone CPAN module

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile;
my($_DT) = Bivio::Type->get_instance('DateTime');
#TODO: Would like this, but it creates compile errors for subclasses
#my($_UTC) = Bivio::Type->get_instance('TimeZone')->UTC;

sub compile {
    my($i) = 2;
    return shift->SUPER::compile([
	UNKNOWN => [0, "Select Time Zone"],
	UTC => [1, "UTC"],
	map({
	    my($x) = $_;
	    $x =~ s/\W/_/g;
	    (uc($x) => [$i++, $_]);
	} DateTime::TimeZone->all_names),
    ]);
}

sub date_time_from_utc {
    my($self, $date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year) = $_DT->to_parts($date_time);
    my($utc) = Bivio::Type->get_instance('TimeZone')->UTC;
    my($dt) = scalar(DateTime->new(
	year   => $year,
	month  => $mon,
	day    => $mday,
	hour   => $hour,
	minute => $min,
	second => $sec,
	time_zone => $utc->get_short_desc,
    ));
    $dt->set_time_zone($self->get_short_desc);
    return $_DT->from_parts_or_die(
	$dt->second, $dt->minute, $dt->hour, $dt->day, $dt->month, $dt->year);
}

sub date_time_to_utc {
    my($self, $date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year) = $_DT->to_parts($date_time);
    my($utc) = Bivio::Type->get_instance('TimeZone')->UTC;
    my($dt) = scalar(DateTime->new(
	year   => $year,
	month  => $mon,
	day    => $mday,
	hour   => $hour,
	minute => $min,
	second => $sec,
	time_zone => $self->get_short_desc,
    ));
    $dt->set_time_zone($utc->get_short_desc);
    return $_DT->from_parts_or_die(
	$dt->second, $dt->minute, $dt->hour, $dt->day, $dt->month, $dt->year);
}

1;
