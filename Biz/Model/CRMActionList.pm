# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMActionList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_CTS) = b_use('Type.CRMThreadStatus');
my($_LIST) = [grep(!$_->eq_new, $_CTS->get_non_zero_list)];
my($_NAMES) = [map($_->get_name, @$_LIST)];
my($_T) = b_use('UI.Text');
my($_E) = b_use('Type.Email');
my($_R) = b_use('Auth.Role');

sub all_actions {
    return _names_only(shift, 0);
}

sub id_to_name {
    my($self, $id) = @_;
    my($name);
    if ($self->id_to_owner($id)) {
	$name = _format_name($self,
	    $self->new_other('GroupUserList')->load_this({this => $id}));
    } else {
	$name = _labels($self)->{$self->id_to_status($id)->get_name};
    }
    return $name;
}

sub id_to_owner {
    my($self, $id) = @_;
    return $id > 0 ? $id : undef;
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
	    type => 'Line',
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
    my($fields) = $self->[$_IDI];
    my($req) = $self->req;
    return [
	map(
	    sort({lc($a->{name}) cmp lc($b->{name})} @$_),
	    $fields && $fields->{names_only}
	        ? ()
	        : [map(+{
		    id => $self->status_to_id($_),
		    name => _labels($self)->{$_->get_name},
		}, @$_LIST)],
	    $self->new_other('GroupUserList')->map_iterate(
		sub {
		    my($it) = @_;
		    return
			unless $it->get('RealmUser.role')->
			    in_category_role_group('all_members');
		    return {
			id => $it->get('RealmUser.user_id'),
			name => _format_name($self, $it),
		    };
		},
	    ),
	),
    ];
}

sub load_owner_names {
    my($self) = @_;
    _names_only($self, 1);
    return $self->load_all;
}

sub name_to_id {
    my($self, $name) = @_;
    return undef
	unless defined($name);
    my($id);
    my($l) = _labels($self);
    foreach my $k (keys(%$l)) {
	my($v) = $l->{$k};
	$id = -$_CTS->$k->as_int
	    if $v eq $name;
	last if defined($id);
    }
    return $id
	if defined($id);
    $self->new_other('GroupUserList')->do_iterate(sub {
        my($it) = @_;
	return 1
	    unless _format_name($self, $it) eq $name;
	$id = $it->get('RealmUser.user_id');
	return 0;
    });
    return $id;
}

sub names_only {
    return _names_only(shift, 1);
}

sub owner_email_to_name {
    my(undef, $email) = @_;
    return $_E->get_local_part($email);
}

sub status_to_id {
    my(undef, $status) = @_;
    return -$status->as_int;
}

sub status_to_id_in_list {
    my($self, $status) = @_;
    $status = $status->OPEN
	if $status->eq_new;
    return $self->status_to_id($status);
}

sub validate_id {
    my($self, $id) = @_;
    return $id && $self->find_row_by(id => $id) ? 1 : 0;
}

sub _format_name {
    my($self, $row) = @_;
    my($fields) = $self->[$_IDI];
    return ($fields && $fields->{names_only}
		? '' : _labels($self)->{assign_to})
	. $row->get('display_name') . ' (' . $row->get('Email.email') . ')';
}

sub _labels {
    my($self) = @_;
    return {map(
	($_ => $_T->get_value('CRMActionList', 'label', $_, $self->req)),
	'assign_to',
	@$_NAMES,
    )};
}

sub _names_only {
    my($self, $names_only) = @_;
    $self->[$_IDI] ||= {
	names_only => $names_only,
    };
    return;
}

1;
