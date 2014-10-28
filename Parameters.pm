# Copyright (c) 2009-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Parameters;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_NULL) = b_use('Bivio.TypeError')->NULL;
my($_TOO_MANY) = $_NULL->TOO_MANY;
my($_NOT_FOUND) = $_NULL->NOT_FOUND;
my($_SYNTAX_ERROR) = $_NULL->SYNTAX_ERROR;

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
    $self->[$_IDI] = _decls($self, $decls);
    return $self;
}

sub process_via_universal {
    my($proto, $caller_proto, $argv, $self, $error, $sub) = @_;
    $self ||= _self($proto, $caller_proto, $sub || (caller(2))[3]);
    my($decls) = $self->[$_IDI];
    my($args) = ref($argv) eq 'HASH'
	? _hash($decls, $argv, $error)
	: @$argv == 1 && ref($argv->[0]) eq 'HASH'
	? _hash($decls, $argv->[0], $error)
	: _positional($decls, $argv, $error);
    return $caller_proto
	unless $args;
    foreach my $decl (@$decls) {
	my($name) = $decl->{name};
	if ($decl->{repeatable}) {
	    my($got_one);
	    my($values) = $args->{$name} || [];
	    @$values = ()
		if @$values == 1 && !defined($values->[0]);
	    foreach my $value (@$values) {
		$got_one++;
		return $caller_proto
		    unless _value(\$value, $decl, $caller_proto, $error);
	    }
	    return $caller_proto
		unless $got_one
		|| _default(\$args->{$name}, $decl, $caller_proto, $error);
	}
	elsif (exists($args->{$name})) {
	    return $caller_proto
		unless _value(\$args->{$name}, $decl, $caller_proto, $error);
	}
	else {
	    return $caller_proto
		unless _default(\$args->{$name}, $decl, $caller_proto, $error);
	}
    }
    return ($caller_proto, $args);
}

sub _decls {
    my($self, $decls) = @_;
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
	$type ||= $name =~ /^[A-Z]/ ? $name : undef;
	$type &&= b_use(
	    $self->is_simple_package_name($type) ? "Type.$type" : $type,
	);
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
    $$value = !$decl->{repeatable} ? $res
	: ref($res) eq 'ARRAY' ? $res
	: defined($res) ? [$res]
	: [];
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
	param_name => $decl->{name},
	param_value => $value,
	type_error => $type_error,
    );
    return;
}

sub _hash {
    my($decls, $hash, $error) = @_;
    $hash = {%$hash};
    if (@$decls and (my $repeat = $decls->[$#$decls])->{repeatable}) {
	$hash->{$repeat->{name}} = [$hash->{$repeat->{name}}]
	    if exists($hash->{$repeat->{name}})
	    && ref($hash->{$repeat->{name}}) ne 'ARRAY';
    }
    my($extra) = [grep({
	my($k) = $_;
	!grep($k eq $_->{name}, @$decls);
    } keys(%$hash))];
    return _error(undef, {name => $extra->[0]}, $_NOT_FOUND, $error)
	if @$extra;
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
    my($v, $e) = !$decl->{type} ? $$value
	: ($caller_proto->b_can('from_literal', $decl->{type})
	       || UNIVERSAL::isa($decl->{type}, 'Bivio::Delegator'))
	? $decl->{type}->from_literal($$value)
	: $decl->{type}->is_blesser_of($$value)
        ? $$value
	: (undef, $_SYNTAX_ERROR);
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
