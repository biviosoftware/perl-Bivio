# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Tuple;
use strict;
use Bivio::Base 'Model.OrdinalBase';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_LABEL_RE)
    = qr{^\s*(@{[Bivio::Type->get_instance('TupleLabel')->REGEX]}):\s*}om;
our($_TRACE);
__PACKAGE__->use('Model.RealmMail')->register(__PACKAGE__);
my($_TSN) = __PACKAGE__->use('Type.TupleSlotNum');
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_MP) = __PACKAGE__->use('Ext.MIMEParser');

sub LIST_FIELDS {
    return $_TSN->map_list(sub {'Tuple.' . shift(@_)});
}

sub ORD_FIELD {
    return 'tuple_num';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'tuple_t',
	columns => {
	    tuple_def_id => ['PrimaryId', 'PRIMARY_KEY'],
	    tuple_num => ['TupleNum', 'PRIMARY_KEY'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
	    thread_root_id => ['RealmMail.thread_root_id', 'NONE'],
	    @{$_TSN->map_list(sub {shift(@_) => ['TupleSlot', 'NONE']})},
        },
    });
}

sub internal_prepare_max_ord {
    my($self, $stmt, $values) = @_;
    $stmt->where([
	$self->get_qualified_field_name('tuple_def_id'),
	[$values->{tuple_def_id}],
    ]);
    return shift->SUPER::internal_prepare_max_ord(@_);
}

sub mail_slot {
    my(undef, $label, $value) = @_;
    return "$label: $value\n";
}

sub mail_subject {
    my($proto, $tuple_use) = @_;
    return $tuple_use->get('moniker') . '#'
	. (ref($proto) && $proto->is_loaded ? $proto->get('tuple_num') : '');
}

sub handle_mail_post_create {
    my($proto, $realm_mail, $incoming) = @_;
#TODO: Use FEATURE_TUPLE to control loading
    # AUTH: TupleUseList authenticates access to schema
    my($tul) = $realm_mail->new_other('TupleUseList')->load_all;
    my($m) = join('|', @{$tul->monikers});
    _trace($realm_mail->get('subject'), ' matching with ', $m) if $_TRACE;
    return unless $m;
    my($qr) = qr{^\s*($m)\#(\d*)};
    my($mm, $mn) = $realm_mail->get('subject') =~ $qr;
    unless (defined($mm)) {
	my($rt) = $realm_mail->new_other('RowTag');
	return unless defined($mm = $rt->get_value(
	    $realm_mail->get('realm_id'),
	    'DEFAULT_TUPLE_MONIKER',
	));
	unless ("$mm#" =~ $qr) {
	    Bivio::IO::Alert->warn(
		$mn, ': DEFAULT_TUPLE_MONIKER not in TupleUseList, deleting RowTag');
	    $rt->replace_value(
		$realm_mail->get('realm_id'), 'DEFAULT_TUPLE_MONIKER');
	    return;
	}
    }
    my($state) = {
	realm_mail => $realm_mail,
	incoming => $incoming,
	moniker => $mm,
	tuple_num => $mn,
	is_update => $mn ? 1 : 0,
	tuple_def_id => $tul->moniker_to_id($mm),
	self => $proto->new($realm_mail->get_request),
    };
    my($body) = _text_plain(\($incoming->get_rfc822));
    return _mail_err($state, $body ? $body->as_string : 'no text/plain part')
	unless $body && ref($body) eq 'SCALAR';
    $state->{body} = $body;
    if ($state->{is_update}) {
	return _mail_err($state, 'unable to load model')
	    unless $state->{self}->unsafe_load(
		{map(($_ => $state->{$_}), qw(tuple_def_id tuple_num))});
	# Override given possible subject change
	$realm_mail->update({
	    thread_root_id => $state->{self}->get('thread_root_id'),
	});
    }
    else {
	# thread_root_id is this message.  Subject will be unique after
	# update.  This is a bit incestuous, but it works.
	$state->{tuple_num} = $state->{self}->create({
	    tuple_def_id => $state->{tuple_def_id},
	    thread_root_id => $realm_mail->get('realm_file_id'),
	})->get('tuple_num');
	(my $s = $realm_mail->get('subject'))
	    =~ s/(?<=$state->{moniker}\#)/$state->{tuple_num}/;
	$realm_mail->update({subject => $s});
	# These headers are not identical
	($s = $incoming->get('header'))
	    =~ s/^(subject:.*$state->{moniker}\#)/$1$state->{tuple_num}/im;
	$incoming->put(header => $s);
#TODO: Need to update the subject in the disk file
    }
    return _create_or_update_slots($state, _parse_slots($state->{body}));
}

sub split_body {
    my(undef, $body) = @_;
    return (undef, _strip($body))
	unless $body =~ s/^(.*?)($_LABEL_RE)//s;
    my($c1) = $1 || '';
    my($slots, $c2) = split(/\n\n/, $2 . $body, 2);
    return (_strip($slots), _strip($c1 . (defined($c2) ? $c2 : '')));
}

#TODO: Should probably deprecate since only client is now calling split_body
sub split_rfc822 {
    my($self, $rfc822) = @_;
    my($body) = (split(/\n\n/, $$rfc822, 2))[1];
    $body ||= '';
    return $self->split_body($body);
}

sub _create_or_update_slots {
    my($state, $slots) = @_;
    my($self) = $state->{self};
    $slots = $self->map_by_two(sub {[lc($_[0]), $_[1]]}, $slots);
    my($tsdl) = $state->{self}->new_other('TupleSlotDefList')->load_all({
	parent_id => $state->{tuple_def_id},
    });
    my($err);
    my($values) = {};
    $tsdl->do_rows(sub {
        my($l) = $tsdl->get('TupleSlotDef.label');
	my($m) = [grep($_->[0] eq lc($l), @$slots)];
	return 1
	    unless @$m || !$state->{is_update};
	_trace($l, ' matches: ', $m) if $_TRACE;
	if (@$m > 1) {
	    $err = "$l: duplicate field in message";
	    return 0;
	}
	$m = ($m->[0] || [])->[1];
	my($v, $e) = $tsdl->validate_slot($m);
	if ($e) {
	    $err = "$l: "
		. (defined($m) ? "contains an invalid value ($m): " : '')
		. $e->as_string;
	    return 0;
	}
	$values->{$tsdl->field_from_num} = defined($v) || $state->{is_update}
	    ? $v : $tsdl->get('TupleSlotType.default_value');
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
#TODO: return msg via b-sendmail-http
    return;
}

sub _parse_slots {
    my($body) = @_;
    $$body =~ s/^.*?(?=$_LABEL_RE)//s;
    my($slots) = [split($_LABEL_RE, (split(/\n\n/, $$body, 2))[0] || '')];
    return
	unless @$slots > 1;
    shift(@$slots);
    return $slots;
}

sub _strip {
    my($v) = @_;
    $v =~ s/^\s+|\s+$//sg;
    return $v;
}

sub _text_plain {
    my($rfc822) = @_;
    my($res);
    my($die) = Bivio::Die->catch(sub {
        my($me) = $_MP->parse_data($rfc822);
	foreach my $p ($me->mime_type =~ m{^multipart/}i ? $me->parts : $me) {
	    return $res = \($p->body_as_string)
		if $p->mime_type eq 'text/plain';
	}
	return;
    });
    return $res || $die;
}

1;
