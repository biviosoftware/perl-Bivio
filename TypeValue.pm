# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::TypeValue;
use strict;
use Bivio::Base 'Collection.Attributes';

# Binds a type and a value.  Convenient for parameter passing.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub as_string {
    my($self) = @_;
    my($t) = $self->get('type');
    return (ref($t) || $t) . '[' . $t->to_string($self->get('value')) . ']';
}

sub equals {
    my($self, $that) = @_;
    return defined($that)
	&& ref($self) eq ref($that)
	&& $self->get('type') eq $that->get('type')
	&& $self->get('type')->is_equal(
	    $self->get('value'), $that->get('value')) ? 1 : 0;
}

sub new {
    my($proto, $type, $value) = @_;
    Bivio::Die->die($type, ': not a type')
	unless UNIVERSAL::isa($type, 'Bivio::Type');
    return $proto->SUPER::new({
	type => $type,
	value => $value,
    });
}

1;
