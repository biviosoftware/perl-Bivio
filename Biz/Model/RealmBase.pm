# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmBase;
use strict;
use Bivio::Base 'Biz.PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

sub REALM_ID_FIELD {
    return 'realm_id';
}

sub USER_ID_FIELD {
    return 'user_id';
}

sub create {
    my($self, $values) = @_;
    my($req) = $self->get_request;
    $values->{$self->REALM_ID_FIELD} ||= $req->get('auth_id');
    $values->{$self->USER_ID_FIELD} ||= $req->get('auth_user_id')
	if $self->USER_ID_FIELD && $self->has_fields($self->USER_ID_FIELD);
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
	    $self->REALM_ID_FIELD => ['RealmOwner.realm_id', 'NOT_NULL'],
        },
	auth_id => $self->REALM_ID_FIELD,
    });
}

sub update {
    my($self, $values) = @_;
    $values->{modified_date_time} ||= $_DT->now
	if $self->has_fields('modified_date_time');
    return shift->SUPER::update(@_);
}

1;
