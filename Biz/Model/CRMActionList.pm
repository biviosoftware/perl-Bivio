# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMActionList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_CTS) = b_use('Type.CRMThreadStatus');
my($_LIST) = [grep(!$_->eq_new, $_CTS->get_non_zero_list)];
my($_NAMES) = [map($_->get_name, @$_LIST)];
my($_T) = b_use('FacadeComponent.Text');
my($_E) = b_use('Type.Email');
my($_R) = b_use('Auth.Role');

sub all_actions {
    return _names_only(shift, 0);
}

sub id_to_name {
    my($self, $id) = @_;
    return undef
	unless defined($id);
    my($res) = $self->find_row_by(id => $id);
    return $res	? $res->get('name')
        : -$id eq $_CTS->NEW->as_int
        ? _get_label($self, $_CTS->NEW->get_name) : undef;
}

sub id_to_owner {
    my($self, $id, $curr_owner) = @_;
    return $id
        if $id > 0;
    my($s) = $_CTS->from_int(-$id);
    return $s->eq_unassign ? undef : $curr_owner;
}

sub id_to_status {
    my($self, $id, $curr_status) = @_;
    $curr_status or b_die('unset curr_status');
    return $_CTS->OPEN
        if $id > 0;
    my($s) = $_CTS->from_int(-$id);
    return $s->eq_unassign
        ? $curr_status->eq_locked
        ? $curr_status->OPEN
        : $curr_status
        : $s;
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
	$fields && $fields->{names_only}
	    ? ()
	    : sort({lc($a->{name}) cmp lc($b->{name})} map(+{
		id => $self->status_to_id($_),
		name => _labels($self)->{$_->get_name},
	    }, @$_LIST)),
	@{$self->new_other('CRMUserList')->map_iterate(
	    sub {
		my($it) = @_;
		return {
		    id => $it->get('RealmUser.user_id'),
		    name => _format_name($self, $it),
		};
	    },
	)},
    ];
}

sub load_all_actions {
    my($self) = @_;
    _names_only($self, 0);
    return $self->load_all;
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
    my($res) = $self->find_row_by(name => $name);
    return $res	? $res->get('id')
        : $name eq _get_label($self, $_CTS->NEW->get_name)
        ? -$_CTS->NEW->as_int : undef;
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

sub _format_name {
    my($self, $row) = @_;
    my($fields) = $self->[$_IDI];
    return ($fields && $fields->{names_only}
		? '' : _labels($self)->{assign_to})
	. $row->get('display_name') . ' <' . $row->get('Email.email') . '>';
}

sub _get_label {
    my($self, $name) = @_;
    return $_T->get_value('CRMActionList', 'label', $name, $self->req);
}

sub _labels {
    my($self) = @_;
    return {map(
	($_ => _get_label($self, $_)),
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
