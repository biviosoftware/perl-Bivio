# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMailBounce;
use strict;
use base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub TASK_URI {
    return 'bounce';
}

sub create_from_rfc822 {
    my($self, $mr) = @_;
    my($rfid, $email) = ($mr->get('plus_tag') || '') =~ /^(\d+)-(.+)$/;
    if ($email && $email =~ s/(?=.*)=/@/) {
	my($rm) = $self->new_other('RealmMail');
	if ($rm->unauth_load({realm_file_id => $rfid})) {
	    my($c) = $mr->get('message')->{content};
#TODO: Should parse properly, but this is good enough
	    my($reason) = $$c =~ /\(reason:\s*([^\r\n]+)\)/i;
	    unless ($reason) {
		$reason = ($$c =~ /Diagnostic-Code:\s*([^\r\n]+)/i)[0];
		$reason ||= ($$c =~ /(Deferred:[^\r\n])/i)[0];
		$reason ||= ($$c =~ /(Status:[^\r\n])/i)[0];
		$reason ||= '<unable to parse error>';
	    }
	    substr($reason, 0, 0) = 'transient: '
		if $$c =~ /Action:\s*delayed|Will-Retry-Until|transient non-fatal/i;
	    return $self->create_or_update({
		realm_file_id => $rfid,
		email => substr($email, 0, $self->get_field_type('email')->get_width),
		realm_id => $rm->get('realm_id'),
		user_id => $self->get_request->get('auth_id'),
		modified_date_time => Bivio::Type->get_instance('DateTime')->now,
		reason => substr($reason, 0, $self->get_field_type('reason')->get_width),
	    });
	}
    }
    Bivio::IO::Alert->warn(
	$mr->get('recipient'), ': ', $email ? 'unable parse' : 'no RealmMail');
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
    return $self->get_request->format_email(
	$self->TASK_URI
        . '.'
	. $user_id
	. '+'
	. $realm_file_id
	. '-'
	. $email
    );
}

1;
