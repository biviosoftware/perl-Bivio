# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmEmailList;
use strict;
use Bivio::Base 'Model.RealmUserList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_E) = Bivio::Biz::Model->get_instance('Email')->get_field_type('email');

sub get_recipients {
    my($self, $iterate_handler) = @_;
    my($method) = 'map_' . ($self->is_loaded ? 'rows' : 'iterate');
    my($t) = $self->get_field_type('Email.email');
    return $self->$method(sub {
        my($e) = $self->get('Email.email');
	return $t->is_ignore($e) ? ()
	    : $iterate_handler ? $iterate_handler->($self)
	    : $e;
    });
}

sub internal_get_roles {
    return [Bivio::Auth::Role->MAIL_RECIPIENT];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	order_by => [qw(
	    Email.email
        )],
	other => [
	    'Email.location',
	    [qw(RealmUser.user_id Email.realm_id(+))],
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return $_E->is_ignore($row->{'Email.email'}) ? 0 : 1;
}

sub is_ignore {
    my($self) = @_;
    return $self->get_field_type('Email.email')
	->is_ignore($self->get('Email.email'));
}

1;
