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
    $self ||= _self($caller_proto, (caller(2))[4]);
    my($decls) = $self->[$_IDI];
    $$error = undef;
    my($args) = ref($argv) eq 'HASH' ? _hash($decls, $argv)
	: @$argv == 1 && ref($argv->[0]) eq 'HASH' ? _hash($decls, $argv->[0])
	: _positional($decls, $argv, $error) || return $caller_proto;
    foreach my $decl (@$decls) {
	unless (exists($args->{$decl->{name}})) {
	    return ($caller_proto, _error(undef, $decl, $_NULL, $error))
		unless $decl->{optional};
	    my($d) = ref($decl->{default}) eq 'CODE'
		? $decl->{default}->($caller_proto)
	        : $decl->{default};
	    $args->{$decl->{name}} = $decl->{repeatable} ? [$d] : $d;
	    next;
	}
	next
	    unless $decl->{type};
	if ($decl->{repeatable}) {
	    $args->{$decl->{name}} = [map({
		my($v, $e)
		    = $decl->{type}->from_literal($args->{$decl->{name}});
		$e ? _error($_, $decl, $e, $error)
		    : $v;
	    } @{$args->{$decl->{name}}})];
	    return $caller_proto
		if $$error;
	}
	else {
	    my($v, $e)
		= $decl->{type}->from_literal($args->{$decl->{name}});
	    return (
		$caller_proto,
		_error($args->{$decl->{name}}, $decl, $e, $error),
	    ) if $e;
	    $args->{$decl->{name}} = $v;
	}
    }
    return ($caller_proto, $args);
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
	if ($optional) {
	    $now_optional = 1;
	}
	elsif ($now_optional) {
	    b_die($name, ': param must be optional');
	}
	$type ||= $name =~ /^[A-Z]/ ? $name : undef;
	$type &&= b_use("Type.$type");
	+{
	    name => $name,
	    type => $type,
	    $optional ? (default => $default) : (),
	    optional => $optional,
	    repeatable => $repeatable,
	};
    } @$decls)];
}

sub _error {
    my($value, $decl, $type_error, $error) = @_;
    b_die(
	$decl->{name},
	defined($value) ? ('=', $value) : (), ': ',
	$type_error,
    ) unless $error;
    $$error = join(
	'',
	$decl->{name},
	defined($value) && !ref($value) ? '='. substr($value, 0, 20) : (),
	': ',
	$type_error->get_long_desc,
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

sub _self {
    my($caller_proto, $sub) = @_;
    $sub =~ /(.+::)(.+)/;
    my($method) = $1 . uc($2);
    no strict;
    local(*cache) = *$method;
    return $cache ||= $proto->new(&cache($caller_proto));
}

1;
