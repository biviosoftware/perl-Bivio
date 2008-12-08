# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::UserRegisterForm;
use strict;
use Bivio::Base 'Model';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_create_models {
    my($self) = shift;
    my($realm, @rest) = $self->SUPER::internal_create_models(@_);
    $self->req->with_realm($realm => sub {
	foreach my $model (qw(Address Phone)) {
	    $self->new_other($model)->create({});
	};
	return;
    });
    return ($realm, @rest);
}

1;
