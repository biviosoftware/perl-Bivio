# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Email;
use strict;
use Bivio::Base 'Model.LocationBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    my($self, $values) = @_;
    $values->{want_bulletin} = 1
	    unless defined($values->{want_bulletin});
    return $self->SUPER::create($values);
}

sub execute_load_home {
    my($proto, $req) = @_;
    $proto->new($req)->load({
	location => Bivio::Type::Location->HOME,
    });
    return 0;
}

sub internal_initialize {
    return {
	version => 2,
	table_name => 'email_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            location => ['Location', 'PRIMARY_KEY'],
            email => ['Email', 'NOT_NULL_UNIQUE'],
	    want_bulletin => ['Boolean', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
        other => [
            [qw(realm_id RealmOwner.realm_id)],
        ],
    };
}

sub invalidate {
    my($self) = @_;
    my($address) = $self->get('email');
    my($prefix) = $self->get_field_type('email')->INVALID_PREFIX;
    return if $address =~ /^\Q$prefix/o;
    my($other) = $self->new_other('Email');
    my($i) = 0;
    $i++ while $other->unauth_load({email => $prefix . $i . $address});
    $self->update({email => $prefix . $i . $address});
    return;
}

sub is_ignore {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return Bivio::Type::Email->is_ignore($model->get($model_prefix.'email'));
}

1;
