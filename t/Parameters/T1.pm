# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::Parameters::T1;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

my($_S1) = 0;
my($_M) = b_use('Type.Month');

sub s1 {
    sub S1 {
	b_die('called multiple times')
	    if $_S1++;
	return [qw(p1 ?p2)];
    }
    my($self, $bp) = shift->parameters(\@_);
    b_die('no p1')
	unless exists($bp->{p1});
    return ($bp->{p1}, $bp->{p2});
}

sub s2 {
    sub S2 {[[qw(p1 Boolean)], [qw(+p2 Month)]]}
    my($self, $bp) = shift->parameters(\@_);
    b_die('no p1')
	unless defined($bp->{p1});
    b_die('p2 not array')
	unless ref($bp->{p2}) eq 'ARRAY';
    b_die('p2 empty')
	unless @{$bp->{p2}};
    foreach my $p2 (@{$bp->{p2}}) {
	b_b_die($p2, ': p2 element not Month')
	    unless Bivio::Type::Month->is_blesser_of($p2);
    }
    return ($bp->{p1}, $bp->{p2});
}

sub s3 {
    sub S3 {[[qw(*p1 Month), $_M->MARCH]]}
    my($self, $bp) = shift->parameters(\@_);
    b_die('p1 not array')
	unless ref($bp->{p1}) eq 'ARRAY';
    b_die('p1 empty')
	unless @{$bp->{p1}};
    foreach my $p1 (@{$bp->{p1}}) {
	b_b_die($p1, ': p1 element not Month')
	    unless Bivio::Type::Month->is_blesser_of($p1);
    }
    return $bp->{p1};
}

sub s4 {
    sub S4 {[[qw(*Month)]]}
    return _check(shift->parameters(\@_));
}

sub s5 {
    sub S5 {[['*Month', undef, sub {[$_M->MARCH, $_M->JULY]}]]}
    return _check(shift->parameters(\@_));
}

sub s6 {
    sub S6 {[['req', 'Agent.Request']]}
    my($self, $bp) = shift->parameters(\@_);
    return 'ok';
}

sub _check {
    my($self, $bp) = @_;
    b_die('Month not array')
	unless ref($bp->{Month}) eq 'ARRAY';
    b_die('Month contains undef')
	if grep(!defined($_), @{$bp->{Month}});
    return $bp->{Month};
}

1;
