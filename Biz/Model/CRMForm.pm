# Copyright (c) 2008-2021 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::CRMForm;
use strict;
use Bivio::Base 'Model.MailForm';

my($_RFC) = b_use('Mail.RFC822');
my($_MA) = b_use('Mail.Address');
my($_EA) = b_use('Type.EmailArray');
my($_CTS) = b_use('Type.CRMThreadStatus');
my($_CT) = b_use('Model.CRMThread');
my($_BRM) = b_use('Action.BoardRealmMail');
my($_I) = b_use('Mail.Incoming');
my($_TAG_ID) = 'CRMThread.thread_root_id';
b_use('ClassWrapper.TupleTag')->wrap_methods(
    __PACKAGE__, __PACKAGE__->TUPLE_TAG_INFO);
#TODO: Verify that auth_realm is in the list of emails????
#TODO: Bounce handling
my($_TS) = b_use('Type.TupleSlot');
b_use('IO.Config')->register(my $_CFG = {
    want_status_email => 1,
});

sub TUPLE_TAG_INFO {
    return {
        moniker => $_CT->TUPLE_TAG_PREFIX,
        primary_id_field => $_TAG_ID,
    };
}

sub execute_empty {
    my($self) = @_;
    shift->SUPER::execute_empty(@_);
    my($status, $owner);
    $self->internal_put_field(
        _if_crm_thread(
            $self,
            sub {
                my($ct) = @_;
                $status = $ct->get('crm_thread_status');
                my($who) = $self->internal_query_who;
                _append_other_emails_to_cc($self)
                    if $who->eq_all;
                return (
                    crm_thread_status => _empty_status($status, $who->eq_realm),
                    owner_user_id => $ct->get('owner_user_id')
                        || $self->req('auth_user_id'),
                    subject => $ct->clean_subject($self->get('subject')),
                );
            },
            sub {
                return (
                    to => undef,
                    cc => $self->get('to'),
                    owner_user_id => $self->req('auth_user_id'),
                    crm_thread_status => $_CTS->OPEN,
                );
            },
        ),
    );
    return;
}

sub execute_ok {
    my($self) = @_;
    my($res) = $self->unsafe_get('update_only') ? $self->internal_return_value
        : shift->SUPER::execute_ok(@_);
    return if $self->in_error;
    my($ct) = $self->req('Model.CRMThread');
    $self->internal_put_field(old_fields => {
        crm_thread_status => $ct->get('crm_thread_status'),
        owner_user_id => $ct->get('owner_user_id'),
    });
    my($cid) = $self->unsafe_get(
        qw(CRMThread.customer_realm_id));
    my($status) = $self->get('crm_thread_status');
    my($owner) = $self->get('owner_user_id');
    $ct->update({
        crm_thread_status => $status,
        owner_user_id => $owner,
        modified_by_user_id => $self->req('auth_user_id'),
        lock_user_id => undef,
        subject => $self->get('subject'),
        $cid ? (customer_realm_id => $cid) : (),
    });
    $self->internal_put_field(new_fields => {
        crm_thread_status => $status,
        owner_user_id => $owner,
    });
    $self->internal_put_field(
        $_TAG_ID => $ct->get('thread_root_id'));
    return $res;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub handle_tuple_tag_update_properties {
    my($self, $old, $new, $info) = @_;
    return
        if $self->in_error;
    $self->internal_put_field(
        map({
            my($which, $v) = @$_;
            ($which => {
                %{$self->get($which)},
                map((
                    $info->{$_}->{tuple_tag_label}
                        => [$v->{$_}, $info->{$_}->{type}],
                ), keys(%$info)),
            });
        } (['old_fields', $old], ['new_fields', $new])),
    );
    if ($_CFG->{want_status_email}
        && _fields_changed($self->get('old_fields'), $self->get('new_fields'))
    ) {
        my($board_only) = $self->internal_set_headers;
        return
            if $self->in_error;
        my($headers) = $self->get('headers');
        delete($headers->{_recipients});
        delete($headers->{Cc});
        $headers->{To} = $board_only
            ? $_BRM->format_email_for_realm($self->req)
            : $self->get('realm_email');
        $self->internal_put_field(headers => $headers);
        $board_only
            ? $self->internal_send_to_board(
                $self->internal_format_field_updates)
            : $self->internal_send_to_realm(
                $self->internal_format_field_updates);
    }
    return;
}

sub internal_format_field_updates {
    my($self) = @_;
    return b_use('UI.View')->render(
        $self->VIEW_CLASS . '->field_updates_imail', $self->req);
}

sub internal_format_from {
    my($self, @args) = @_;
    return $_RFC->format_mailbox(
        $self->new_other('EmailAlias')->format_realm_as_incoming,
        $self->req(qw(auth_user display_name)),
    );
}

sub internal_format_subject {
    my($self, @args) = @_;
    return _if_crm_thread(
        $self,
        sub {shift->make_subject($self->get('subject'))},
        sub {$self->SUPER::internal_format_subject(@args)},
    );
}

sub internal_get_reply_incoming {
    my($self, $in) = @_;
    return shift->SUPER::internal_get_reply_incoming(@_)
        unless $in;
    my($trid) = $self->get('RealmMail.thread_root_id');
    return shift->SUPER::internal_get_reply_incoming(@_)
        if $trid eq $self->get('RealmMail.realm_file_id');
    return $_I->new(
        $self->new_other('RealmMail')->load({realm_file_id => $trid}),
    );
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
            visible => [
                [qw(crm_thread_status CRMThreadStatus NOT_NULL)],
                [qw(owner_user_id PrimaryId NONE)],
                [qw(update_only OKButton)],
            ],
            other => [
                $_TAG_ID,
                [qw(crm_user_list Model.CRMUserList)],
                [qw(old_fields Hash)],
                [qw(new_fields Hash)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    if (my $trid = $self->get('RealmMail.thread_root_id')) {
        $self->internal_put_field($_TAG_ID => $trid);
        $self->new_other('CRMThread')->load({thread_root_id => $trid});
    }
    $self->internal_put_field(
        crm_user_list => $self->new_other('CRMUserList')->load_all,
        board_always => 1,
    );
    return @res;
}

sub validate {
    my($self) = @_;
    if ($self->unsafe_get('update_only')) {
        return $self->internal_put_error(to => 'MUTUALLY_EXCLUSIVE')
            unless $self->unsafe_get($_TAG_ID);
        foreach my $f (qw(to body)) {
            $self->internal_clear_error($f);
        }
    }
    else {
        shift->SUPER::validate(@_);
    }
    return;
}

sub _append_other_emails_to_cc {
    my($self) = @_;
    my($dups) = {
        %{$self->get('to')->as_hash},
        %{$self->get('cc')->as_hash},
        # board email only gets removed on execute_ok, and it
        # would get added here if there were any emails just to
        # the board.
        ($_BRM->format_email_for_realm($self->req) => 1),
    };
    my($res) = $self->get('cc')->as_array;
    $self->new_other('RealmMail')->do_iterate(
        sub {
            my($it) = @_;
            for my $x ($_I->new($it)->get_reply_email_arrays(
                $self->internal_query_who,
                $self->get(qw(realm_email realm_emails)),
                $self->req,
            )) {
                $x->do_iterate(
                    sub {
                        my($e) = @_;
                        if (!$dups->{$e}++) {
                            push(@$res, $e);
                        }
                        return 1;
                    },
                );
            }
            return 1;
        },
        'realm_file_id ASC',
        {
            'thread_root_id' => $self->get('RealmMail.thread_root_id'),
        },
    );
    $self->internal_put_field(cc => $_EA->new($res));
    return;
}

sub _fields_changed {
    my($old, $new) = @_;
    b_die('field mismatch')
        unless scalar(keys(%$old)) == scalar(keys(%$new));
    for (keys(%$new)) {
        return 1
            if $_TS->compare($old->{$_}, $new->{$_});
    }
    return 0;
}

sub _if_crm_thread {
    my($self, $true, $false) = @_;
    return $false && $false->()
        unless my $ct = $self->ureq('Model.CRMThread');
    return $true->($ct);
}

sub _empty_status {
    my($status, $discuss) = @_;
    # Force status to a limited set (POSIT: CRMThreadStatus.crm_form_choices)
    if ($discuss) {
        if ($status->equals_by_name('CLOSED', 'PENDING_CUSTOMER')) {
            return $status;
        }
        return $status->OPEN;
    }
    return $status->CLOSED,
}

1;
