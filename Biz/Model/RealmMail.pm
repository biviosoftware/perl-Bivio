# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMail;
use strict;
use base 'Bivio::Biz::PropertyModel';
use Bivio::Mail::Incoming;
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MAX_LINE) = Bivio::Type->get_instance('Line')->get_width;
my($_MAX_EMAIL) = Bivio::Type->get_instance('Email')->get_width;
our($_TRACE);
my($_DT) = Bivio::Type->get_instance('DateTime');

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
            subject => ['Line', 'NOT_NULL'],
            subject_lc => ['Line', 'NOT_NULL'],
        },
	other => [
	    [qw(realm_file_id RealmFile.realm_file_id)],
	    [qw(realm_id RealmOwner.realm_id)],
	],
        auth_id => 'realm_id',
    });
}

sub _chomp_subject {
    my($s, $sortable) = @_;
    $s = ''
	unless defined($s);
    $s =~ s/\s+/ /;
    0 while $s =~ s/^(\s+|\[\S*\]|[a-z]{1,3}(:|\[\d+\])|\.)//i;
    $s =~ s{
        \s$
        |/
        |@{[__PACKAGE__->get_instance('RealmFile')->get_field_type('path')->ILLEGAL_CHAR_REGEXP]}
    }{}xog if $sortable;
    return length($s) ? substr($s, 0, $_MAX_LINE) : '(No Subject)';
}

sub _create {
    my($self, $in, $file) = @_;
    $self->create(
	_thread_values({
	    map(($_ => $file->get($_)), qw(realm_id realm_file_id)),
	    message_id => substr($in->get_message_id, 0, $_MAX_LINE),
	    from_email => substr(lc(($in->get_from)[0]), 0, $_MAX_EMAIL),
	    subject => _chomp_subject($in->get_subject),
	    subject_lc => lc(_chomp_subject($in->get_subject, 1)),
	}, $in),
    );
    return $in;
}

sub _create_file {
    my($self, $rfc822) = @_;
    my($in) = Bivio::Mail::Incoming->new($rfc822);
    my($date) = Bivio::Type::DateTime->from_unix($in->get_date_time || time);
    return (
	$in,
	$self->new_other('RealmFile')->create_with_content({
	    override_is_read_only => 1,
	    path => $self->get_instance('Forum')->MAIL_FOLDER
		. '/'
		. join('-', $_DT->get_parts($date, qw(year month)))
		. '/'
		. _chomp_subject($in->get_subject, 1)
		. ' '
		. $_DT->to_file_name($date)
		. sprintf('%03d', int(rand(1_000)))
		. '.eml',
	    user_id => $self->get_request->get('auth_user_id')
		|| $self->new_other('RealmUser')
		    ->get_any_online_admin->get('realm_id'),
	    modified_date_time => $date,
	}, $rfc822),
    );
}

sub _thread_values {
    my($values, $in) = @_;
    my($row);
    foreach my $ref ($in->get_references) {
        last if $row = Bivio::SQL::Connection->execute_one_row(
            'SELECT realm_file_id, thread_root_id, message_id
            FROM realm_mail_t
            WHERE realm_id = ?
            AND realm_file_id < ?
            AND message_id = ?',
	    [@{$values}{qw(realm_id realm_file_id)}, $ref],
	);
    }
    $row = Bivio::SQL::Connection->execute_one_row(
	'SELECT realm_file_id, thread_root_id, subject_lc
        FROM realm_mail_t
        WHERE realm_id = ?
	AND realm_file_id < ?
        AND subject_lc = ?
	ORDER BY realm_file_id DESC',
	[@{$values}{qw(realm_id realm_file_id subject_lc)}],
    ) unless $row;
    $row ||= [];
    _trace($values->{realm_file_id}, ' ', $row) if $_TRACE;
    $values->{thread_parent_id} = $row->[0];
    $values->{thread_root_id} = $row->[1] || $values->{realm_file_id};
    return $values;
}

1;
