# Copyright (c) 2002-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Bean;
use strict;
use base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
my($_IDI) = __PACKAGE__->instance_data_index;

sub AUTOLOAD {
    my($self, @args) = @_;
    # The widget and shortcut methods are dynamically loaded.
    my($method) = $AUTOLOAD;
    $method =~ s/.*:://;
    return if $method eq 'DESTROY';
    my($fields) = $self->[$_IDI];
    my($res) = $fields->{$method} || [];
    $fields->{$method} = \@args if @args;
    return wantarray ? @$res : $res->[0];
}

sub new {
    my($proto) = @_;
    # Creates a bean.  Set initial values by calling methods.
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {};
    return $self;
}

1;
