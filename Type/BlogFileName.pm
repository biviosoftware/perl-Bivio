# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BlogFileName;
use strict;
use base 'Bivio::Type::Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = Bivio::Type->get_instance('FilePath');
my($_IS_PATH) = qr{@{[$_FP->join(
    '^(?:' . join('|', map(__PACKAGE__->to_path(undef, $_), 0, 1)) . ')',
    '\d{6}',
    '\d{8}$',
)]}}oisx;

sub PRIVATE_FOLDER {
    return '/Blog';
}

sub PUBLIC_FOLDER {
    return $_FP->join($_FP->PUBLIC_FOLDER, shift->PRIVATE_FOLDER);
}

sub SQL_LIKE_BASE {
    return _base('_' x shift->get_width);
}

sub from_literal {
    my(undef, $value) = @_;
    return (undef, undef)
	unless defined($value) && length($value);
    # This is overly friendly, but we are only parsing URLs and such
    $value =~ s,\D,,g;
    return $value =~ /^\d{14}$/ ? $value
	: (undef, Bivio::TypeError->BLOG_FILE_NAME);
}

sub from_path {
    my($proto, $path) = @_;
    return $proto->from_literal_or_die(
	$path ? $path =~ m{([\d/]+)$} ? $1 : $path : ());
}

sub from_sql_column {
    return shift->from_path(@_);
}

sub get_width {
    return 14;
}

sub is_path {
    my(undef, $path) = @_;
    return $path =~ $_IS_PATH ? 1 : 0;
}

sub to_path {
    my($proto, $value, $is_public) = @_;
    return $_FP->join(
	$is_public ? $proto->PUBLIC_FOLDER : $proto->PRIVATE_FOLDER,
	defined($value) ? _base($value) : $value,
    );
}

sub to_sql_like_path {
    my($proto, $is_public) = @_;
    return lc($proto->to_path('_' x $proto->get_width, $is_public));
}

sub to_sql_param {
    my(undef, $value) = @_;
    return _base($value);
}

sub _base {
    my($value) = @_;
    Bivio::Die->die($value, ': invalid value')
        unless $value =~ /^([\d_]{6})([\d_]{8})$/;
    return $_FP->join($1, $2);
}

1;
