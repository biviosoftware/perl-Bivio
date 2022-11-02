# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::TypeValue;
use strict;
use Bivio::Base 'Collection.Attributes';

# Binds a type and a value.  Convenient for parameter passing.


sub as_json {
    my($self) = @_;
    return $self->get('type')->to_json($self->get('value'));
}

sub as_string {
    my($self) = @_;
    my($t) = $self->get('type');
    my($v) = $self->get('value');
    return (ref($t) || $t)
        . '['
        . join(',', map($t->to_string($_), ref($v) eq 'ARRAY' ? @$v : $v))
        . ']';
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
