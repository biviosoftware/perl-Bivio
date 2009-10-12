# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Parameters;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_NULL) = b_use('Bivio.TypeError')->NULL;
my($_TOO_MANY) = $_NULL->TOO_MANY;

sub internal_as_string {
    my($decls) = shift->[$_IDI];
    return map(
	($_->{repeatable} && $_->{optional} ? '*'
	     : $_->{repeatable} ? '+'
	     : $_->{optional} ? '?'
	     : ''
	) . $_->{name},
	@$decls,
    );
}

sub new {
    my($proto, $decls) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = _decls($decls);
    return $self;
}

sub process_via_universal {
    my($proto, $caller_proto, $argv, $self, $error) = @_;
    $self ||= _self($proto, $caller_proto, (caller(2))[3]);
    my($decls) = $self->[$_IDI];
    my($args) = ref($argv) eq 'HASH' ? _hash($decls, $argv)
	: @$argv == 1 && ref($argv->[0]) eq 'HASH' ? _hash($decls, $argv->[0])
	: _positional($decls, $argv, $error) || return $caller_proto;
    foreach my $decl (@$decls) {
	if ($decl->{repeatable}) {
	    my($got_one);
	    my($values) = $args->{$decl->{name}} || [];
	    @$values = ()
		if @$values == 1 && !defined($values->[0]);
	    foreach my $value (@$values) {
		$got_one++;
		return $caller_proto
		    unless _value(\$value, $decl, $caller_proto, $error);
	    }
	    return $caller_proto
		unless $got_one
		|| _default(
		    \$args->{$decl->{name}}, $decl, $caller_proto, $error);
	}
	elsif (exists($args->{$decl->{name}})) {
	    return $caller_proto
		unless _value(
		    \$args->{$decl->{name}}, $decl, $caller_proto, $error);
	}
	else {
	    return $caller_proto
		unless _default(
		    \$args->{$decl->{name}}, $decl, $caller_proto, $error);
	}
    }
    return ($caller_proto, $args);
}

sub _decls {
    my($decls) = @_;
    my($i) = 0;
    my($now_optional) = 0;
    return [map({
	my($name, $type, $default) = ref($_) ? @$_ : $_;
	my($optional) = ref($_) && @$_ > 2 ? 1 : 0;
	my($repeatable) = 0;
	$i++;
	if ($name =~ s/^([\?\*\+])//) {
	    $optional = 1
		unless $1 eq '+';
	    $repeatable = 1
		unless $1 eq '?';
	    b_die($name, ': only the last param may repeat')
		if $repeatable && @$decls != $i;
	}
	b_die($name, ': must be a perl identifier')
	    unless $name =~ /^\w+$/;
	if ($optional) {
	    $now_optional = 1;
	}
	elsif ($now_optional) {
	    b_die($name, ': param must be optional');
	}
	$type ||= $name =~ /^[A-Z]/ ? $name : 'String';
	$type = b_use("Type.$type");
	+{
	    name => $name,
	    type => $type,
	    $optional ? (default => $default) : (),
	    optional => $optional,
	    repeatable => $repeatable,
	};
    } @$decls)];
}

sub _default {
    my($value, $decl, $caller_proto, $error) = @_;
    return _error(undef, $decl, $_NULL, $error)
	unless $decl->{optional};
    my($res) = ref($decl->{default}) eq 'CODE'
	? $decl->{default}->($caller_proto)
	: $decl->{default};
    $$value = $decl->{repeatable} ? [$res] : $res;
    return 1;
}

sub _error {
    my($value, $decl, $type_error, $error) = @_;
    b_die(
	$decl->{name},
	defined($value) ? ('=', $value) : (),
	': ',
	$type_error->get_long_desc,
    ) unless $error;
    %$error = (
	name => $decl->{name},
	value => $value,
	error => $type_error,
    );
    return;
}

sub _hash {
    my($decls, $hash) = @_;
    $hash = {%$hash};
    if ((my $repeat = $decls->[$#$decls])->{repeatable}) {
	$hash->{$repeat->{name}} = [$hash->{$repeat->{name}}]
	    if exists($hash->{$repeat->{name}})
	    && ref($hash->{$repeat->{name}}) ne 'ARRAY';
    }
    return $hash;
}

sub _positional {
    my($decls, $argv, $error) = @_;
    my($decl);
    my($hash) = {};
    $decls = [@$decls];
    foreach my $arg (@$argv) {
	if (@$decls) {
	    $decl = shift(@$decls);
	    $hash->{$decl->{name}} = $decl->{repeatable} ? [$arg] : $arg;
	}
	elsif ($decl->{repeatable}) {
	    push(@{$hash->{$decl->{name}}}, $arg);
	}
	else {
	    return _error(undef, $decl, $_TOO_MANY, $error);
	}
    }
    return $hash;
}

sub _self {
    my($proto, $caller_proto, $sub) = @_;
    $sub =~ /(.+::)(.+)/;
    my($method) = $1 . uc($2);
    b_die($sub, ': not a valid subroutine')
	unless $method;
    no strict;
    local(*cache) = *$method;
    return $cache ||= $proto->new(&cache($caller_proto));
}

sub _value {
    my($value, $decl, $caller_proto, $error) = @_;
    my($v, $e) = $decl->{type}->from_literal($$value);
    return _error($$value, $decl, $e, $error)
	if $e;
    unless (defined($v)) {
	return _error($$value, $decl, $_NULL, $error)
	    unless $decl->{optional} && !$decl->{repeatable};
	_default(\$v, $decl, $caller_proto, $error);
    }
    $$value = $v;
    return 1;
}

1;
