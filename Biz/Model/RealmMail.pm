# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMail;
use strict;
use Bivio::Base 'Model.RealmBase';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_MAX_EMAIL) = b_use('Type.Email')->get_width;
my($_MS) = b_use('Type.MailSubject');
my($_MFN) = b_use('Type.MailFileName');
my($_RF) = b_use('Model.RealmFile');
my($_DT) = b_use('Type.DateTime');
my($_I) = b_use('Mail.Incoming');
my($_MI) = b_use('Type.MessageId');
my($_D) = b_use('Bivio.Die');
my($_F) = b_use('Biz.File');
my($_FP) = b_use('Type.FilePath');
my($_RI) = b_use('Agent.RequestId');
my($_HANDLERS) = b_use('Biz.Registrar')->new;

sub cascade_delete {
    my($self, $query) = @_;
    if ($query) {
	$self->cascade_delete
	    if $self->unsafe_load($query);
	return;
    }
    $self->die('model must be loaded or query must be supplied')
	unless $self->is_loaded;
    foreach my $m (@{
	$self->new->map_iterate(
	    sub {
		my($it) = @_;
		return $it->new->internal_load_properties(
		    $it->get_shallow_copy);
	    },
	    'realm_file_id',
	    {thread_parent_id => $self->get('realm_file_id')},
	)
    }) {
	$m->cascade_delete;
    }
    $self->delete;
    $self->new_other('RealmFile')->delete({
	realm_file_id => $self->get('realm_file_id'),
	override_is_read_only => 1,
    });
    return;
}

sub create_from_rfc822 {
    my($self, $rfc822) = @_;
    my($die);
    my($res) = $_D->catch(
	sub {_create($self, _create_file($self, $rfc822))},
	\$die,
    );
    return $res
	unless $die;
    $_F->write(
	$_FP->join(
	    $self->simple_package_name,
	    $_RI->current($self->req) . '.eml',
	),
	$rfc822,
    );
    $die->throw;
    # DOES NOT RETURN
}

sub get_mail_part_list {
    my(undef, $delegator, $prefix) = shift->delegated_args(@_);
    return $delegator->new_other('MailPartList')->load_all({
	parent_id => $delegator->get(($prefix || '') . 'realm_file_id'),
    });
}

sub get_rfc822 {
    return $_RF->get_content(shift(@_));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'realm_mail_t',
	as_string_fields => [qw(message_id)],
        columns => {
            realm_file_id => ['RealmFile.realm_file_id', 'PRIMARY_KEY'],
	    # Index on realm_id, message_id.  Does it need to be unique?
	    message_id => ['MessageId', 'NOT_NULL'],
	    thread_root_id => ['RealmFile.realm_file_id', 'NOT_NULL'],
	    thread_parent_id => ['RealmFile.realm_file_id', 'NONE'],
            from_email => ['Email', 'NOT_NULL'],
            subject => ['MailSubject', 'NOT_NULL'],
            subject_lc => ['MailSubject', 'NOT_NULL'],
        },
	other => [
	    [qw(realm_file_id RealmFile.realm_file_id)],
	    [qw(realm_id RealmOwner.realm_id)],
	],
        auth_id => 'realm_id',
    });
}

sub register {
    shift;
    $_HANDLERS->push_object(@_);
    return;
}

sub update {
    my($self, $values) = @_;
    if (defined($values->{subject})) {
	$values->{subject} = $_MS->trim_literal($values->{subject});
	$values->{subject_lc} = $_MS->clean_and_trim($values->{subject});
    }
    $self->die(
	$values,
	': must set both thread_parent_id and thread_root_id or neither',
    ) if exists($values->{thread_parent_id})
        xor exists($values->{thread_root_id});
    return shift->SUPER::update(@_);
}

sub _call_handlers {
    $_HANDLERS->call_fifo(shift, [@_]);
    return;
}

sub _create {
    my($self, $in, $file) = @_;
    $self->create(
	_thread_values($self, $in, {
	    map(($_ => $file->get($_)), qw(realm_id realm_file_id)),
	    message_id => $_MI->from_literal_or_die(
		$_MI->clean_and_trim($in->get_message_id)),
	    from_email => substr(lc(($in->get_from)[0]), 0, $_MAX_EMAIL),
	    subject => $_MS->trim_literal($in->get_subject),
	    subject_lc => $_MS->clean_and_trim($in->get_subject),
	}, $in),
    );
    _call_handlers(handle_mail_post_create => $self, $in, $file);
    return $in;
}

sub _create_file {
    my($self, $rfc822) = @_;
    _call_handlers(handle_mail_pre_create_file => $self, $rfc822);
    my($in) = $_I->new($rfc822);
    my($date) = $in->get_date_time;
    my($rf) = $self->new_other('RealmFile');
    return (
	$in,
	$rf->create_with_content({
	    override_is_read_only => 1,
	    path => $_MFN->to_unique_absolute($date),
	    user_id => _user_id($self, $in),
	    modified_date_time => $date,
	}, $rfc822),
    );
}

sub _thread_values {
    my($self, $in, $values) = @_;
    my($l) = $self->new_other('RealmMailReferenceList')
	->load_first_from_incoming($in);
    $values->{thread_parent_id} = $l ? $l->get('RealmMail.realm_file_id')
	: undef;
    $values->{thread_root_id} = $l ? $l->get('RealmMail.thread_root_id')
	: $values->{realm_file_id};
    return $values;
}

sub _user_id {
    my($self, $in) = @_;
    my($f) = $in->get_from;
    my($e);
    if ($e = $self->ureq('Model.Email')) {
	return $e->get('realm_id')
	    if $e->field_equals(email => $f);
    }
    my($user_id) = $in->get_from_user_id($self->req);
    return $user_id
	? $user_id
	: $self->req('auth_user_id') || $self->new_other('RealmUser')
	    ->get_any_online_admin->get('realm_id');
}

1;
