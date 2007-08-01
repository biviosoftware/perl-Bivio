# Copyright (c) 2002-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Bean;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::IO::Ref;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
my($_IDI) = __PACKAGE__->instance_data_index;

sub AUTOLOAD {
    my($self, @args) = @_;
    my($method) = $AUTOLOAD;
    $method =~ s/.*:://;
    return if $method eq 'DESTROY';
    my($fields) = $self->[$_IDI];
    if ($fields->{_new_mode}) {
	my($orig_args) = [@args];
	while(1) {
	    my($sig) = "$method(" . join(',', @args) . ')';
	    return ref($fields->{$sig}) eq 'CODE' ? $fields->{$sig}->($orig_args)
		: wantarray ? @{$fields->{$sig}} : $fields->{$sig}->[0]
		if exists($fields->{$sig});
	    if (@args) {
		pop(@args);
	    }
	    else {
		$fields->{$sig} = [];
		Bivio::IO::Alert->warn($sig, ': not found returning nothing');
	    }
	}
	return;
    }
#    Bivio::IO::Alert->warn_deprecated('set up in new()');
    my($res) = $fields->{$method} || [];
    $fields->{$method} = \@args if @args;
    return wantarray ? @$res : $res->[0];
}

sub new {
    my($proto, $values) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = $values ? _verify(Bivio::IO::Ref->nested_copy($values)) : {};
    return $self;
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
