# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMail;
use strict;
use base 'Bivio::Biz::PropertyModel';
use Bivio::Mail::Incoming;
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_MAX_LINE) = Bivio::Type->get_instance('Line')->get_width;
my($_MAX_EMAIL) = Bivio::Type->get_instance('Email')->get_width;
my($_MS) = Bivio::Type->get_instance('MailSubject');
my($_MFN) = Bivio::Type->get_instance('MailFileName');
my($_RF) = __PACKAGE__->use('Model.RealmFile');
my($_HANDLERS) = [];
my($_DT) = __PACKAGE__->use('Type.DateTime');

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

sub create_from_file {
    my($self, $file) = @_;
    return _create($self, Bivio::Mail::Incoming->new($file->get_content), $file);
}

sub create_from_rfc822 {
    my($self, $rfc822) = @_;
    return _create($self, _create_file($self, $rfc822));
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
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
	    message_id => ['Line', 'NOT_NULL'],
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
    my($proto, $handler) = @_;
    $handler = $proto->use($handler);
    push(@$_HANDLERS, $handler)
	unless grep($_ eq $handler, @$_HANDLERS);
    return;
}

sub update {
    my($self, $values) = @_;
    if (defined($values->{subject})) {
	$values->{subject} = $_MS->trim_literal($values->{subject});
	$values->{subject_lc} = $_MS->clean_and_trim($values->{subject});
	# Used by Tuple, but makes sense to cut the thread if
	# the subject is changed.
#TODO: Update children of thread to have correct thread_root_id
	$values->{thread_root_id} = $self->get('realm_file_id')
	    unless $self->get('subject_lc') eq $values->{subject_lc};
    }
    $values->{thread_parent_id} = undef
	if $self->get('realm_file_id') eq ($values->{thread_root_id} || '');
    return shift->SUPER::update(@_);
}

sub _call_handlers {
    my($method) = shift;
    foreach my $h (@$_HANDLERS) {
	$h->$method(@{[@_]})
	    if $h->can($method);
    }
    return;
}

sub _create {
    my($self, $in, $file) = @_;
    $self->create(
	_thread_values({
	    map(($_ => $file->get($_)), qw(realm_id realm_file_id)),
	    message_id => substr($in->get_message_id, 0, $_MAX_LINE),
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
    my($in) = Bivio::Mail::Incoming->new($rfc822);
    my($date) = $in->get_date_time;
    $date = $date ? $_DT->from_unix($date) : $_DT->now;
    my($rf) = $self->new_other('RealmFile');
    return (
	$in,
	$rf->create_with_content({
	    override_is_read_only => 1,
	    path => $_MFN->to_unique_absolute($date, $in->get_subject),
	    user_id => _user_id($self, $in),
	    modified_date_time => $date,
	}, $rfc822),
    );
}

sub _thread_values {
    my($values, $in) = @_;
    my($row);
    foreach my $ref (@{$in->get_references}) {
        last if $row = Bivio::SQL::Connection->execute_one_row(
            'SELECT realm_file_id, thread_root_id, message_id
            FROM realm_mail_t
            WHERE realm_id = ?
            AND realm_file_id < ?
            AND message_id = ?',
	    [@{$values}{qw(realm_id realm_file_id)}, $ref],
	);
    }
    $row ||= [];
    _trace($values->{realm_file_id}, ' ', $row) if $_TRACE;
    $values->{thread_parent_id} = $row->[0];
    $values->{thread_root_id} = $row->[1] || $values->{realm_file_id};
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
    $e = $self->new_other('Email');
    return $e->get('realm_id')
	if $e->unauth_load({email => $f});
    return $self->req('auth_user_id')
	|| $self->new_other('RealmUser')
	->get_any_online_admin->get('realm_id'),
}

1;
