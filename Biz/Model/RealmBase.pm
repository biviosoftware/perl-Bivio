# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmBase;
use strict;
use base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

sub create {
    my($self, $values) = @_;
    my($req) = $self->get_request;
    $values->{realm_id} ||= $req->get('auth_id');
    $values->{user_id} ||= $req->get('auth_user_id')
	if $self->has_fields('user_id');
    my($t);
    foreach my $f (qw(modified_date_time creation_date_time)) {
	$values->{$f} ||= ($t ||= $_DT->now)
	    if $self->has_fields($f);
    }
    return shift->SUPER::create(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	columns => {
	    realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
    });
}

sub update {
    my($self, $values) = @_;
    $values->{modified_date_time} ||= $_DT->now
	if $self->has_fields('modified_date_time');
    return shift->SUPER::update(@_);
}

1;
