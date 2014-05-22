# Copyright (c) 2006-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMail;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Bivio.Die');
my($_E) = b_use('Type.Email');
my($_F) = b_use('Biz.File');
my($_FP) = b_use('Type.FilePath');
my($_HANDLERS) = b_use('Biz.Registrar')->new;
my($_I) = b_use('Mail.Incoming');
my($_LM) = b_use('Biz.ListModel');
my($_MAIL_READ) = ${b_use('Auth.PermissionSet')->from_array(['MAIL_READ'])};
my($_MAX_EMAIL) = b_use('Type.Email')->get_width;
my($_MAX_NAME) = b_use('Type.DisplayName')->get_width;
my($_MFN) = b_use('Type.MailFileName');
my($_MI) = b_use('Type.MessageId');
my($_MS) = b_use('Type.MailSubject');
my($_MV) = b_use('Type.MailVisibility');
my($_RF) = b_use('Model.RealmFile');
my($_RI) = b_use('Agent.RequestId');

sub access_is_public_only {
    my($proto, $req) = @_;
    return $req->get('auth_realm')->does_user_have_permissions($_MAIL_READ, $req) ? 0 : 1;
}

sub assert_mail_visibility {
    my($proto, $req) = @_;
    $proto->throw_die('FORBIDDEN', 'Always is private')
	if $_MV->row_tag_get($req)->eq_always_is_private
	&& $proto->access_is_public_only($req);
    return;
}

sub assert_original_visibility {
    my($proto, $req) = @_;
    $proto->throw_die('FORBIDDEN', 'Not authorized to view original')
	unless _original_visibility($req);
    return;
}

sub audit_threads {
    my($self) = @_;
    $self->new_other('RealmMailList')
	->do_iterate(
	    sub {
		my($it) = @_;
		my($rm) = $it->get_model('RealmMail');
		$rm->update(
		    _thread_values(
			$rm,
			$_I->new(
			    $_RF->get_content($it, 'RealmMail.'),
			),
			$rm->get_shallow_copy,
		    ),
		);
		return 1;
	    },
	    {
		order_by => [qw(RealmFile.modified_date_time asc)],
	    },
	);
    return;
}

sub can_view_original {
    my(undef, $req) = @_;
    return _original_visibility($req);
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

#TODO: this needs a better name that describes the function.  Probably is just "delete",
# just like when you delete a file, it has to audit properly.
sub delete_message {
    my($self) = @_;
    my($this_id) = $self->get('realm_file_id');
    my($parent_id) = $self->get('thread_parent_id');
    if ($parent_id) {
	$self->new_other('RealmMail')->do_iterate(sub {
	    my($it) = @_;
	    $it->update({
		thread_root_id => $self->get('thread_root_id'),
		thread_parent_id => $parent_id,
	    });
	    return 1;
	}, {
	    'thread_parent_id' => $this_id,
	});
    } else {
	my($new_root_id);
	$_LM->new_anonymous({
	    primary_key => [[qw(RealmMail.realm_file_id RealmFile.realm_file_id)]],
	    order_by => [{
		name => 'RealmFile.modified_date_time',
		sort_order => 1,
	    }],
	    other => [['RealmMail.thread_parent_id', [$this_id]]],
	})->do_iterate(sub {
	    my($it) = @_;
	    my($new_parent_id);
	    if ($new_root_id) {
		$new_parent_id = $new_root_id;
	    } else {
		$new_root_id = $it->get('RealmMail.realm_file_id');
	    }
	    $it->get_model('RealmMail')->update({
		thread_root_id => $new_root_id,
		thread_parent_id => $new_parent_id,
	    });
	    return 1;
	});
#TODO: Delete the CRMThread if there are no mail messages
	my($crmt) = $self->new_other('CRMThread');
	$crmt->unauth_load({
	    thread_root_id => $self->get('thread_root_id'),
	});
	if (defined($new_root_id)) {
	    $crmt->update({
		thread_root_id => $new_root_id,
	    }) if $crmt->is_loaded;
	    $self->new_other('RealmMail')->do_iterate(
		sub {
		    my($it) = @_;
		    $it->update({
			thread_root_id => $new_root_id,
			thread_parent_id => $it->get('thread_parent_id'),
		    });
		    return 1;
		}, {
		    'thread_root_id' => $this_id,
		});
	}
	else {
	    $crmt->delete
		if $crmt->is_loaded;
	}
    }
    $self->delete;
    $self->new_other('RealmMailBounce')->delete_all({
	realm_file_id => $self->get('realm_file_id'),
    });
    $self->new_other('RealmFile')->delete({
	realm_file_id => $self->get('realm_file_id'),
	override_is_read_only => 1,
	override_versioning => 1,
    });
    return;
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
	    from_display_name => ['DisplayName', 'NONE'],
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

sub to_subject_lc {
    my($proto, $subject) = @_;
    return lc($_MS->clean_and_trim($subject, 1));
}

sub update {
    my($self, $values) = @_;
    if (defined($values->{subject})) {
	$values->{subject} = $_MS->clean_and_trim($values->{subject});
	$values->{subject_lc} = $self->to_subject_lc($values->{subject});
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
    my($email, $name) = $in->get_from;
    $name ||= $_E->get_local_part($email);
    $self->create(
	_thread_values($self, $in, {
	    map(($_ => $file->get($_)), qw(realm_id realm_file_id)),
	    message_id => $_MI->from_literal_or_die(
		$_MI->clean_and_trim($in->get_message_id)),
	    from_email => substr(lc($email), 0, $_MAX_EMAIL),
	    from_display_name => substr($name || '', 0, $_MAX_NAME),
	    subject => $_MS->clean_and_trim($in->get_subject),
	    subject_lc => lc($_MS->clean_and_trim($in->get_subject, 1)),
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
	    path => $_MFN->to_unique_absolute(
		$date,
		$_MV->row_tag_get($self->req)->eq_always_is_public,
	    ),
	    user_id => _user_id($self, $in),
	    modified_date_time => $date,
	}, $rfc822),
    );
}

sub _original_visibility {
    my($req) = @_;
    return $req->unsafe_get('auth_user_id')
	&& $req->can_user_execute_task(
	    'GROUP_USER_LIST',
	    $req->get('auth_id'),
	);
}

sub _thread_values {
    my($self, $in, $values) = @_;
    my($l) = $self->new_other('RealmMailReferenceList')
	->load_first_from_incoming($in);

    if ($l && ! $_MS->subject_lc_matches(
	$values->{subject_lc}, $l->get('RealmMail.subject_lc'))) {
	$l = undef;
    }
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
