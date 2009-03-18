# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Bean;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_R) = b_use('IO.Ref');

sub AUTOLOAD {
    my($self, @args) = @_;
    my($method) = $AUTOLOAD;
    $method =~ s/.*:://;
    return if $method eq 'DESTROY';
    if ($self->unsafe_get('_new_mode')) {
	my($orig_args) = [@args];
	while(1) {
	    my($sig) = "$method(" . join(',', @args) . ')';
	    return ref($self->unsafe_get($sig)) eq 'CODE'
		? $self->unsafe_get($sig)->($orig_args)
		: wantarray
		? @{$self->unsafe_get($sig)}
		: $self->unsafe_get($sig)->[0]
		if $self->has_keys($sig);
	    if (@args) {
		pop(@args);
	    }
	    else {
		$self->put($sig => []);
		Bivio::IO::Alert->warn($sig, ': not found returning nothing');
	    }
	}
	return;
    }
    my($res) = $self->get_or_default($method => []);
    $self->put($method => \@args)
	if @args;
    return wantarray ? @$res : $res->[0];
}

sub new {
    my(undef, $values) = @_;
    return shift->SUPER::new($values ? _verify($_R->nested_copy($values)) : {});
}

sub _verify {
    my($values) = @_;
    while (my($k, $v) = each(%$values)) {
	Bivio::Die->die($k, ': invalid key format')
            unless $k =~ /^\w+\(.*\)$/s;
	Bivio::Die->die($v, ': value for ', $k, ' must be array_ref or code_ref')
            unless ref($v) =~ /^(?:ARRAY|CODE)$/s;
    }
    $values->{_new_mode} = 1;
    return $values;
}

1;
