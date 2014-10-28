# Copyright (c) 2002-2014 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Bean;
use strict;
use Bivio::Base 'Collection.Attributes';

our($AUTOLOAD);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_R) = b_use('IO.Ref');

sub AUTOLOAD {
    my($self, @args) = @_;
    my($method) = $AUTOLOAD;
    $method =~ s/.*:://;
    return if $method eq 'DESTROY';
    return _callback($self, $method, \@args);
}

sub new {
    my(undef, $values) = @_;
    b_die('must supply $values')
	unless $values;
    return shift->SUPER::new(_verify($_R->nested_copy($values)));
}

sub test_bean_register_callback {
    my($self, $method, $args, $callback) = @_;
    $self->put(_sig($method, $args) => $callback);
    return $self;
}

sub _callback {
    my($self, $method, $args) = @_;
    my($orig_args) = [@$args];
    while(1) {
	my($sig) = _sig($method, $args);
	return ref($self->unsafe_get($sig)) eq 'CODE'
	    ? $self->unsafe_get($sig)->($orig_args)
	    : wantarray
	    ? @{$self->unsafe_get($sig)}
	    : $self->unsafe_get($sig)->[0]
	    if $self->has_keys($sig);
	if (@$args) {
	    pop(@$args);
	}
	else {
	    $self->put_unless_exists(
		"_warn_$sig",
		sub {
		    # Don't use b_warn, because in AUTOLOAD
		    Bivio::IO::Alert->warn($sig, ': not found returning nothing');
		    return 1;
		},
	    );
	    return wantarray ? () : undef;
	}
    }
    # DOES NOT RETURN
}

sub _sig {
    my($method, $args) = @_;
    return "$method(" . join(',', @$args) . ')';
}
sub _verify {
    my($values) = @_;
    while (my($k, $v) = each(%$values)) {
	Bivio::Die->die($k, ': invalid key format')
            unless $k =~ /^\w+\(.*\)$/s;
	Bivio::Die->die($v, ': value for ', $k, ' must be array_ref or code_ref')
            unless ref($v) =~ /^(?:ARRAY|CODE)$/s;
    }
    return $values;
}

1;
