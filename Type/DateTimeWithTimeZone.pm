# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DateTimeWithTimeZone;
use strict;
use Bivio::Base 'Bivio.Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_DT) = b_use('Type.DateTime');

sub as_date_time {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{tz}->date_time_from_utc($fields->{dt});
}

sub as_literal {
    my($self) = @_;
    return $_DT->to_string($self->as_date_time, 0);
}

sub from_literal {
    b_die('not supported yet');
    # DOES NOT RETURN
}

sub new {
    my($proto, $date_time, $time_zone) = @_;
    my($self) = shift->SUPER::new;
    $self->[$_IDI] = {
	tz => $time_zone,
	dt => $date_time,
    };
    return $self;
}

sub to_literal {
    my($self, $value) = @_;
    return ''
	unless $value;
    return $value->as_literal;
}

1;
