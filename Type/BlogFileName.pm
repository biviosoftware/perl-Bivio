# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BlogFileName;
use strict;
use base 'Bivio::Type::DocletFileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

sub PRIVATE_FOLDER {
    return shift->BLOG_FOLDER;
}

sub PATH_REGEX {
    return qr{@{[shift->join('(\d{6})', '(\d{8})')]}}o;
}

sub REGEX {
    return qr{(\d{14})};
}

sub SQL_LIKE_BASE {
    my($proto) = @_;
    return _base($proto, '_' x $proto->get_width);
}

sub from_date_time {
    my(undef, $date_time) = @_;
    return $_DT->to_file_name($date_time);
}

sub from_literal {
    my($proto, $value) = @_;
    return (undef, undef)
	unless defined($value) && length($value);
    # This is overly friendly, but we are only parsing pretty much anything
    # COUPLING: Assumes nothing in the path but the BFN has digits in it
    $value =~ s{\D}{}g;
    return $value =~ /^@{[$proto->REGEX]}$/ ? $value
	: (undef, Bivio::TypeError->BLOG_FILE_NAME);
}

sub from_sql_column {
    return shift->from_absolute(@_);
}

sub get_width {
    return 14;
}

sub to_absolute {
    my($proto, $value) = (shift, shift);
    return $proto->SUPER::to_absolute($value && _base($proto, $value), @_);
}

sub to_sql_param {
    return _base(@_);
}

sub _base {
    my($proto, $value) = @_;
    Bivio::Die->die($value, ': invalid value')
        unless $value =~ /^([\d_]{6})([\d_]{8})$/;
    return $proto->join($1, $2);
}

1;
