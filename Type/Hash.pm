# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Hash;
use strict;
use Bivio::Base 'Bivio::Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = __PACKAGE__->use('IO.Ref');

sub compare_defined {
    die('not supported');
}

sub extract_by_keys {
    my(undef, $value, $to_include) = @_;
    return {map({
	my($k) = $_;
	grep($k eq $_, @$to_include) ? ($k => $value->{$k}) : ();
    } keys(%$value))};
}

sub is_equal {
    my(undef, $left, $right) = @_;
    return $_R->nested_equals($left, $right);
}

sub from_literal {
    my(undef, $value) = @_;
    return !defined($value) ? (undef, undef)
	: ref($value) eq 'HASH' ? $value
	: (undef, Bivio::TypeError->SYNTAX_ERROR);
}

sub from_sql_column {
    my(undef, $value) = @_;
    return $value && Bivio::Die->eval_or_die($value);
}

sub get_width {
    return 0xffff;
}

sub to_literal {
    return shift->to_sql_param(@_);
}

sub to_sql_param {
    my(undef, $value) = @_;
    return $value && ${Bivio::IO::Ref->to_string($value, 0, 0)};
}

sub to_string {
    my(undef, $value) = @_;
    return !$value ? ''
	: join('; ',
	       map("$_: " . ${Bivio::IO::Ref->to_string($value->{$_}, 0, 0)},
		   sort(keys(%$value))));
}

1;
