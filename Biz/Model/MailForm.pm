# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_EA) = b_use('Type.EmailArray');
my($_I) = b_use('Mail.Incoming');
my($_O) = b_use('Mail.Outgoing');
my($_RFC) = b_use('Mail.RFC822');
my($_MRW) = b_use('Type.MailReplyWho');
my($_ARM) = b_use('Action.RealmMail');
my($_MA) = b_use('Mail.Address');
my($_QUERY_WHO) = 'to';
my($_MWRT) = b_use('Type.MailWantReplyTo');
my($_BRM) = b_use('Action.BoardRealmMail');
my($_FM) = b_use('Type.FormMode');
my($_MS) = b_use('Type.MailSubject');

sub CALL_SUPER_HACK {
    return 0;
}

sub VIEW_CLASS {
    return (shift->simple_package_name =~ /(.+)Form/)[0];
}

sub execute_cancel {
    my($self) = @_;
    $self->clear_errors;
    if ($self->CALL_SUPER_HACK) {
        my($res) = shift->SUPER::execute_cancel(@_);
        return $res
            if defined($res);
    }
    return $self->internal_return_value;
}

sub execute_empty {
    my($self) = @_;
    my($m) = $self->get('realm_mail');
    my($in) = $m && $_I->new($m);
    my($to, $cc) = $self
        ->internal_get_reply_incoming($in)
        ->get_reply_email_arrays(
            $self->internal_query_who,
            $self->get(qw(realm_email realm_emails)),
            $self->req,
        );
    $self->internal_put_field(
        subject => $in ? $in->get_reply_subject : '',
        to => $to,
        cc => $cc,
    );
    return;
}

sub execute_ok {
    my($self) = @_;
    my($board_only, $removed_sender, $other_recipients, $from_email)
        = $self->internal_set_headers;
    return
        if $self->in_error;
    my($msg) = $self->internal_format_incoming;
    if ($board_only) {
        $msg = $self->internal_send_to_board($msg);
    }
    elsif ($removed_sender) {
        $msg = $self->internal_send_to_realm($msg);
    }
    $_O->new($msg)
        ->set_recipients($other_recipients->as_literal)
        ->set_envelope_from($from_email)
        ->enqueue_send($self->req)
        if $other_recipients->as_length;
    if ($self->CALL_SUPER_HACK) {
        my($res) = shift->SUPER::execute_ok(@_);
        return $res
            if defined($res);
    }
    return $self->internal_return_value;
}

sub get_realm_emails {
    my($self) = @_;
    return $self->new_other('EmailAlias')->get_all_emails;
}

sub internal_format_from {
    my($self, $realm_email) = @_;
    return $_RFC->format_mailbox(
        $self->new_other('EmailAlias')
            ->format_realm_as_incoming($self->req('auth_user')),
        $self->req(qw(auth_user display_name)),
    );
}

sub internal_format_incoming {
    my($self) = @_;
    return b_use('UI.View')->render($self->VIEW_CLASS . '->form_imail', $self->req);
}

sub internal_format_reply_to {
    my($self, $realm_email) = @_;
    return $_MWRT->is_set_for_realm($self->req) ? $_RFC->format_mailbox(
        $realm_email,
        $self->req(qw(auth_realm owner display_name)),
    ) : ();
}

sub internal_format_sender {
    my($self, $realm_email) = @_;
    return $self->new_other('EmailAlias')->format_realm_as_sender($realm_email);
}

sub internal_format_subject {
    return shift->get('subject');
}

sub internal_get_reply_incoming {
    my($self, $in) = @_;
    return $in || $_I;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        $self->field_decl(
            visible => [
                [qw(to EmailArray IS_SPECIFIED)],
                [qw(cc EmailArray)],
                [qw(subject RealmMail.subject NOT_NULL)],
                [qw(body TextArea NOT_NULL)],
                @{$self->map_attachments(sub {[shift, 'FileField']})},
                [qw(board_only Boolean)],
            ],
            other => [
                [qw(headers Hash)],
                'RealmMail.realm_file_id',
                'RealmMail.thread_root_id',
                [qw(is_new Boolean NOT_NULL)],
                [qw(realm_mail Model.RealmMail)],
                [qw(realm_email Email)],
                [qw(realm_emails EmailArray)],
                [qw(board_always Boolean)],
                [qw(from_email Email)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($rml) = $self->new_other('RealmMailList');
    my($edit) = $_FM->setup_by_list_this($rml, 'RealmMail')->eq_edit;
    $self->internal_put_field(
        realm_mail => $self->ureq('Model.RealmMail'),
        is_new => $edit ? 0 : 1,
        realm_emails => $self->get_realm_emails,
        realm_email => $self->new_other('EmailAlias')
            ->format_realm_as_incoming,
        map(
            ($_ => $edit && $rml->get($_)),
            qw(RealmMail.realm_file_id RealmMail.thread_root_id),
        ),
    );
    return shift->SUPER::internal_pre_execute(@_);
}

sub internal_query_who {
    return $_MRW->unsafe_from_any((shift->req('query') || {})->{$_QUERY_WHO})
        || $_MRW->REALM;
}

sub internal_return_value {
    return {
        task_id => 'next',
    };
}

sub internal_send_to_board {
    my($self, $rfc822) = @_;
    my($req) = $self->req;
    $_BRM->execute_receive($req, $rfc822);
    return $req->get('Model.RealmMail')->get_rfc822;
}

sub internal_send_to_realm {
    my($self, $rfc822, $board_only) = @_;
    my($req) = $self->req;
    $_ARM->execute_receive($req, $rfc822);
    return $req->get('Model.RealmMail')->get_rfc822;
}

sub internal_set_headers {
    my($self) = @_;
    my($to, $cc, $realm_email, $realm_emails)
        = $self->get(qw(to cc realm_email realm_emails));
    my($board_email) = $_BRM->format_email_for_realm($self->req);
    my($from) = $self->internal_format_from($realm_email);
    my($from_email) = $_MA->parse($from);
    unless ($from_email) {
        $self->internal_put_error(from_email => 'INVALID_SENDER');
        return;
    }
    my($sender) = $self->internal_format_sender($realm_email);
    my($reply_to) = $self->internal_format_reply_to($realm_email);
    my($other_recipients, $removed_sender)
        = _remove_emails($to->append($cc), $realm_emails);
    my($removed_board);
    ($other_recipients, $removed_board)
        = _remove_emails($other_recipients, $board_email);
    my($board_only) = $removed_board
        || $self->unsafe_get('board_only')
        || (!$removed_sender && $self->unsafe_get('board_always'));
    if ($board_only) {
        if ($removed_sender) {
            $to = $to->exclude($realm_emails);
            $cc = $cc->exclude($realm_emails);
        }
        unless ($removed_board) {
            if ($to->as_length) {
                $cc = $cc->append($board_email);
            }
            else {
                $to = $to->append($board_email);
            }
        }
    }
    my($subject) = $self->internal_format_subject;
    $self->internal_put_field(headers => {
        _from => $from,
        _recipients => $other_recipients->as_literal,
        Sender => $sender,
        To => $to->as_literal,
        $reply_to ? ('Reply-To' => $reply_to) : (),
        $cc->as_length ? (Cc => $cc->as_literal) : (),
        Subject => $subject,
        'Message-Id' => $_O->generate_message_id($self->req),
        _in_reply_to_value($self, $subject),
    });
    return (
        $board_only,
        $removed_sender,
        $other_recipients,
        $from_email,
    );
}

sub is_reply {
    return shift->unsafe_get('RealmMail.realm_file_id') ? 1 : 0;
}

sub mail_header_from {
    return shift->get('headers')->{_from};
}

sub mail_headers {
    my($h) = shift->get('headers');
    return [map(/^_/ ? () : [$_ => $h->{$_}], sort(keys(%$h)))];
}

sub mail_envelope_recipients {
    return shift->get('headers')->{_recipients};
}

sub map_attachments {
    my(undef, $op) = @_;
    return [map($op->("attachment$_"), 1..3)];
}

sub reply_query {
    my(undef, $who, $model) = @_;
    return {
        'ListQuery.this' => $model ? $model->get('RealmMail.realm_file_id')
            : ['RealmMail.realm_file_id'],
        $_QUERY_WHO => lc($_MRW->from_any($who)->as_uri),
    };
}

sub validate {
    my($self) = @_;
    shift->SUPER::validate(@_);
    my($type) = $self->get_field_type('cc');
    if (
        $self->field_error_equals(to => 'UNSPECIFIED')
        && $type->is_specified($self->unsafe_get('cc'))
    ) {
        $self->internal_clear_error('to');
        $self->internal_put_field(
            to => $self->get('cc'),
            cc => $type->from_literal_or_die(''),
        );
    }
    return;
}

sub _in_reply_to_value {
    my($self, $subject) = @_;
    my($rm) = $self->ureq('Model.RealmMail');
    return ()
        unless $rm;
    return ()
        unless $_MS->subject_lc_matches(
            $rm->to_subject_lc($subject), $rm->get('subject_lc'));
    return (
        'In-Reply-To' => $_RFC->format_angle_brackets($rm->get('message_id')),
    );
}

sub _remove_emails {
    my($email_array, $to_remove) = @_;
    my($res) = $email_array->exclude($to_remove);
    return ($res, $res->as_length != $email_array->as_length);
}

1;
