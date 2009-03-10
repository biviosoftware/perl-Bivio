# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Util::TestUser;
use strict;
use Bivio::Base 'ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ADM {
    return 'root';
}

sub init_adm {
    my($self) = @_;
    $self->initialize_fully->with_realm(undef, sub {
	$self->new_other('SQL')->create_user_with_account($self->ADM)
	    unless $self->model('RealmOwner')->unauth_load({name => $self->ADM});
    });
    return shift->SUPER::init_adm(@_);
}

1;
