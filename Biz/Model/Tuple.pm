# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Tuple;
use strict;
use base 'Bivio::Biz::PropertyModel';
use Bivio::Ext::MIMEParser;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_LABEL_RE)
    = qr{^\s*(@{[Bivio::Type->get_instance('TupleLabel')->REGEX]}):\s*}om;
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_TSN) = Bivio::Type->get_instance('TupleSlotNum');

sub LIST_FIELDS {
    return $_TSN->map_list(sub {'Tuple.' . shift(@_)});
}

sub create {
    my($self, $values) = @_;
    my($req) = $self->get_request;
    $self->die($values, ': realm_id may not be set')
	if $values->{realm_id};
    $values->{realm_id} = $req->get('auth_id');
    $self->get_instance('Lock')->execute_unless_acquired($req);
    $values->{modified_date_time} = $_DT->now;
    $values->{tuple_num} = (Bivio::SQL::Connection->execute_one_row(
	'SELECT MAX(tuple_num)
        FROM tuple_t
        WHERE realm_id = ?
        AND tuple_def_id = ?',
	[$values->{realm_id}, $values->{tuple_def_id}],
    )->[0] || 0) + 1;
    return shift->SUPER::create(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'tuple_t',
	columns => {
	    realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    tuple_def_id => ['PrimaryId', 'PRIMARY_KEY'],
	    tuple_num => ['TupleNum', 'PRIMARY_KEY'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
	    thread_root_id => ['RealmMail.thread_root_id', 'NONE'],
	    @{$_TSN->map_list(sub {shift(@_) => ['TupleSlot', 'NONE']})},
        },
	auth_id => 'realm_id',
    });
}

sub realm_mail_hook {
    my($proto, $realm_mail, $incoming) = @_;
    my($state) = {
	realm_mail => $realm_mail,
	incoming => $incoming,
    };
    my($tul) = $realm_mail->new_other('TupleUseList');
    my($m) = join('|', $tul->monikers);
    return unless $m && $realm_mail->get('subject') =~ m{^\s*($m)\#(\d*)}x;
    $state->{moniker} = $1;
    $state->{tuple_num} = $2;
    $state->{tuple_def_id} = $tul->find_row_by_moniker($state->{moniker})
	->get('tuple_def_id');
    my($die);
    return _mail_err($state, $die ? $die->as_string : 'no text/plain part')
	unless $state->{body} = Bivio::Die->catch(
	    sub {_text_plain($incoming)}, \$die);
    $state->{self} = $proto->new($realm_mail->get_request);
    if ($state->{is_update} = $state->{tuple_num} ? 1 : 0) {
#TODO: Need proper warning output to user
	return _mail_err($state, 'unable to load model')
	    unless $state->{self}->unsafe_load(
		{tuple_num => $state->{tuple_num}});
    }
    else {
	# thread_root_id is this message.  Subject will be unique after
	# update.  This is a bit incestuous, but it works.
	$state->{tuple_num} = $state->{self}->create({
	    thread_root_id => $realm_mail->get('realm_file_id'),
	})->get('tuple_num');
	(my $s = $realm_mail->get('subject'))
	    =~ s/(?=$state->{moniker}\#)/$state->{tuple_num}/;
	$realm_mail->update({subject => $s});
    }
    return _parse_slots($state);
}

sub slot_header {
    my(undef, $label, $value) = @_;
    return "$label: $value\n";
}

sub update {
    my($self, $values) = @_;
    $values->{modified_date_time} = $_DT->now;
    return shift->SUPER::update(@_);
}

sub _create_or_update_slots {
    my($state, $slots) = @_;
    my($self) = $state->{self};
    $slots = [
	map([lc(shift(@$slots)), shift(@$slots)], 1 .. int((@$slots + 1)/ 2)),
    ];
    my($tsdl) = $state->{self}->new_other('TupleSlotDefList')->load_all;
    my($err);
    my($values) = {};
    $tsdl->do_rows(sub {
        my($l) = $tsdl->get('TupleSlotDef.label');
	my($matches) = grep($_->[0] eq lc($l), @$slots);
	if (@$matches) {
	    if (@$matches > 1) {
		$err = "$l: duplicate field in message";
		return 0;
	    }
	    my($v, $e) = $tsdl->validate_slot($matches->[0]->[1]);
	    if ($e) {
		$err = "$l: contains an invalid value ($matches->[0]->[1]): "
		    . $e->as_string;
		return 0;
	    }
	    $values->{$tsdl->field_from_num} = $v;
	    return 1;
	}
	$values->{$tsdl->field_from_num}
	    = $tsdl->get('TupleSlotType.default_value')
	    if !$state->{is_update} && $tsdl->get('TupleSlotType.is_required');
        return 1;
    });
    return _mail_err($state, $err)
	if $err;
    return $state->{self}->update($values);
}

sub _mail_err {
    my($state, $msg) = @_;
    Bivio::IO::Alert->die(
        $state->{realm_mail}, ": $msg for $state->{moniker}#",
	($state->{tuple_num} || ''));
#TODO: better return msg
    return;
}

sub _parse_slots {
    my($state) = @_;
    ${$state->{body}} =~ s/^.*?(?=$_LABEL_RE)//s;
    my($slots) = [split(
	$_LABEL_RE,
	(split(/\n\n/, ${$state->{body}}, 2))[0] || '')];
    return
	unless @$slots > 1;
    shift(@$slots);
    return _create_or_update_slots($state, $slots);
}

sub _text_plain {
    my($in) = @_;
    my($me) = Bivio::Ext::MIMEParser->parse_data(\($in->get_rfc822));
    foreach my $p ($me->mime_type =~ m{^multipart/}i ? $me->parts : $me) {
	return \($p->body_as_string)
	    if $p->mime_type eq 'text/plain';
    }
    return undef;
}

1;
