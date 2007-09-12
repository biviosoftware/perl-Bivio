# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DocletFileName;
use strict;
use Bivio::Base 'Type.FileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ABSOLUTE_REGEX {
    my($proto) = @_;
    return qr{^@{[$proto->join(
        '(?:' . join('|', map($proto->to_absolute(undef, $_), 0, 1)) . ')',
	$proto->PATH_REGEX,
    )]}$}is;
}

sub from_absolute {
    my($proto, $path) = @_;
    Bivio::Die->throw(DIE => {
	message => 'not an absolute path',
	entity => $path,
#TODO: This is too lax
    }) unless my(@x) = ($path || '') =~ $proto->PATH_REGEX;
    return join('', @x);
}

sub from_literal {
    my($proto, $value) = @_;
    return (undef, undef)
	unless defined($value) && length($value);
    $value = $proto->from_literal_stripper($value);
    return (undef, $proto->ERROR)
	unless length($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless defined($v);
    return $v =~ m{^@{[$proto->REGEX]}$}s ? $v : (undef, $proto->ERROR);
}

sub from_literal_stripper {
    return $_[1];
}

sub is_absolute {
    my($proto, $value) = @_;
    return defined($value) && $value =~ $proto->ABSOLUTE_REGEX ? 1 : 0;
}

sub is_valid {
    my($proto, $value) = @_;
    return defined($value) && $value =~ qr{^@{[$proto->REGEX]}$} ? 1 : 0;
}

sub public_path_info {
    my($proto, $value) = @_;
    return $value
	unless $value;
    $value =~ s{^\Q@{[$proto->PUBLIC_FOLDER_ROOT]}\E}{}i;
    return $value;
}

sub to_absolute {
    my($proto, $value, $is_public) = @_;
    return $proto->join(
	$is_public ? $proto->PUBLIC_FOLDER : $proto->PRIVATE_FOLDER,
	$value,
    );
}

sub to_sql_like_path {
    my($proto, $is_public) = @_;
    return lc($proto->to_absolute('_' x $proto->get_width, $is_public));
}

1;
