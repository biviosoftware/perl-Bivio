# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMActionList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CTS) = __PACKAGE__->use('Type.CRMThreadStatus');
my($_MEMBER) = __PACKAGE__->use('Auth.Role')->MEMBER;
my($_LIST) = [grep(!$_->eq_new, $_CTS->get_non_zero_list)];
my($_NAMES) = [map($_->get_name, @$_LIST)];
my($_T) = __PACKAGE__->use('UI.Text');
my($_LOCATION) = __PACKAGE__->use('Model.Email')->DEFAULT_LOCATION;
my($_E) = __PACKAGE__->use('Type.Email');

sub id_to_owner {
    my($self, $id) = @_;
    return $id > 0 ? $id
	: $self->id_to_status($id)->eq_locked ? $self->req('auth_user_id')
	: undef;
}

sub id_to_status {
    my($self, $id) = @_;
    return $id < 0 ? $_CTS->from_int(-$id) : $_CTS->OPEN;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
        primary_key => [{
	    name => 'id',
	    type => 'CRMActionId',
	    constraint => 'NOT_NULL',
	}],
	order_by => [{
	    name => 'name',
	    type => 'DisplayName',
	    constraint => 'NOT_NULL',
	}],
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($req) = $self->req;
    my($n) = {map(
	($_ => $_T->get_value('CRMActionList', 'label', $_, $req)),
	'assign_to',
	@$_NAMES,
    )};
    return [
	map(
	    sort({lc($a->{name}) cmp lc($b->{name})} @$_),
	    [map(+{
	        id => $self->status_to_id($_),
	        name => $n->{$_->get_name},
	    }, @$_LIST)],
	    $self->new_other('RealmEmailList')->map_iterate(
		sub {
		    my($it) = @_;
		    return
			unless $it->get('Email.location') == $_LOCATION
			    && $it->get('RealmUser.role') == $_MEMBER;
		    return {
			id => $it->get('RealmUser.user_id'),
			name => $n->{assign_to}
			    . $self->owner_email_to_name(
				$it->get('Email.email')),
		    };
		},
		{roles => [$_MEMBER]},
	    ),
	),
    ];
}

sub owner_email_to_name {
    my(undef, $email) = @_;
    return $_E->get_local_part($email);
}

sub status_to_id {
    my(undef, $status) = @_;
    $status = $status->OPEN
	if $status->eq_new;
    return -$status->as_int;
}

sub validate_id {
    my($self, $id) = @_;
    return $id && $self->find_row_by(id => $id) ? 1 : 0;
}

1;
