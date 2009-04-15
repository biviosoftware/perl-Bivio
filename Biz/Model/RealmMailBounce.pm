# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMailBounce;
use strict;
use Bivio::Base 'Biz.PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

sub TASK_URI {
    return 'bounce';
}

sub create_from_rfc822 {
    my($self, $mr) = @_;
    my($c) = $mr->get('message')->{content};
    my($uid) = _log($mr->req('auth_id'), $c);
    my($rfid, $email) = ($mr->get('plus_tag') || '') =~ /^(\d+)-(.+)$/;
    if ($email && $email =~ s/(.*)=/$1@/) {
	my($rm) = $self->new_other('RealmMail');
	if ($rm->unauth_load({realm_file_id => $rfid})) {
	    return $self->unauth_create_or_update({
		realm_file_id => $rfid,
		email => _trunc($self, $email, 'email'),
		realm_id => $rm->get('realm_id'),
		user_id => $uid,
		modified_date_time => $_DT->now,
		reason => _trunc($self, _reason($self, $rfid, $uid, $c),
				 'reason'),
	    });
	}
    }
    else {
	$email = undef;
    }
    Bivio::IO::Alert->warn(
	$mr->get('recipient'), ': ', $email ? 'no RealmMail' : 'unable parse');
    return $self;
}

sub execute {
    my($proto, $req) = @_;
    $proto->new($req)->create_from_rfc822(
	$req->get('Model.MailReceiveDispatchForm'));
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'realm_mail_bounce_t',
	as_string_fields => [qw(realm_file_id email)],
        columns => {
            realm_file_id => ['RealmFile.realm_file_id', 'PRIMARY_KEY'],
	    email => ['Email', 'PRIMARY_KEY'],
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
            user_id => ['User.user_id', 'NOT_NULL'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
            reason => ['Line', 'NOT_NULL'],
        },
	other => [
	    [qw(realm_file_id RealmFile.realm_file_id RealmMail.realm_file_id)],
	    [qw(realm_id RealmOwner.realm_id)],
	],
        auth_id => 'realm_id',
    });
}

sub return_path {
    my($self, $user_id, $email, $realm_file_id) = @_;
    $email =~ s/\@/=/;
    return $self->req->format_email(
	$self->TASK_URI
        . '.'
	. $user_id
	. '+'
	. $realm_file_id
	. '-'
	. $email
    );
}

sub _check_loop {
    my($self, $rfid, $uid) = @_;
    my($rf) = $self->new_other('RealmFile');
    $rf->unauth_load({realm_file_id => $rfid});
    return '<invalid auto-response>'
	if $uid eq $rf->get('user_id');
    return '<unable to parse error>';
}

sub _log {
    my($uid, $c) = @_;
    b_use('Biz.File')->write(
	"RealmMailBounce/$uid/" . $_DT->now_as_file_name . '.eml',
	$c);
    return $uid;
}

sub _reason {
    my($self, $rfid, $uid, $c) = @_;
#TODO: Should parse properly, but this is good enough
    $$c =~ /\(reason:\s*([^\r\n]+)\)/i
	|| $$c =~ /Diagnostic-Code:\s*([^\r\n]+)/i
        || $$c =~ /(Deferred:[^\r\n])/i
	|| $$c =~ /(Status:[^\r\n])/i;
    my($res) = $1 || _check_loop($self, $rfid, $uid);
    return ($$c =~ /Action:\s*delayed|Will-Retry-Until|transient non-fatal/i
	? 'Transient: ' : '') . $res;
}

sub _trunc {
    my($self, $value, $field) = @_;
    return substr($value, 0, $self->get_field_type($field)->get_width);
}

1;
