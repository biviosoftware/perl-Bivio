# Copyright (c) 2008-2026 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::CRMThreadRootList;
use strict;
use Bivio::Base 'Model.MailThreadRootList';

my($_LOCATION) = b_use('Model.Email')->DEFAULT_LOCATION->as_sql_param;
my($_C) = b_use('SQL.Connection');
my($_CRMQF) = b_use('Model.CRMQueryForm');
my($_E) = b_use('Type.Email');
my($_GENERAL_ID) = b_use('Auth.RealmType')->GENERAL->as_int;
my($_ADMINISTRATOR) = b_use('Auth.Role')->ADMINISTRATOR;
my($_REWRITE) = b_use('Action.MailForward')->REWRITE_FROM_DOMAIN_URI;
b_use('ClassWrapper.TupleTag')->wrap_methods(
    __PACKAGE__, b_use('Model.CRMForm')->TUPLE_TAG_INFO);

sub LIST_QUERY_FORM_CLASS {
    return $_CRMQF;
}

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    return $self->merge_initialize_info($info, {
        version => 1,
        primary_key => ['CRMThread.crm_thread_num'],
        order_by => [qw(
            CRMThread.modified_date_time
            CRMThread.crm_thread_num
            CRMThread.crm_thread_status
            CRMThread.subject_lc
        )],
        other_query_keys => $self->get_instance(
            $self->LIST_QUERY_FORM_CLASS)->filter_keys,
        other => [
            delete($info->{primary_key})->[0],
            'CRMThread.subject',
            ['RealmMail.thread_root_id', 'CRMThread.thread_root_id'],
            ['RealmMail.realm_id', 'CRMThread.realm_id'],
            {
                name => 'owner_name',
                type => 'Name',
                constraint => 'NONE',
                in_select => 1,
                select_value => '(
                    SELECT name
                    FROM realm_owner_t
                    WHERE realm_owner_t.realm_id = crm_thread_t.owner_user_id
                ) as owner_name',
            },
            {
                name => 'modified_by_name',
                type => 'Name',
                constraint => 'NONE',
            },
            {
                name => 'modified_by_email',
                type => 'Email.email',
                constraint => 'NONE',
                in_select => 1,
                select_value => "(
                    SELECT e.email
                    FROM email_t e
                    WHERE e.realm_id = crm_thread_t.modified_by_user_id
                    AND e.location = $_LOCATION
                ) AS modified_by_email",
            },
            'CRMThread.modified_by_user_id',
            $self->field_decl([
                [qw(modified_by_is_super_user Boolean)],
                [qw(from_user_id User.user_id)],
                [qw(from_is_super_user Boolean)],
            ]),
        ],
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($rows) = shift->SUPER::internal_load_rows(@_);
    _su_fields($self, $rows)
        if @$rows;
    return $rows;
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
        unless shift->SUPER::internal_post_load_row(@_);
    $row->{modified_by_name} = $_E->get_local_part($row->{modified_by_email});
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    if (my $qf = $self->req->unsafe_get($self->LIST_QUERY_FORM_CLASS)) {
        my($status, $owner, $num) = $qf->unsafe_get(qw(b_status b_owner b_crm_thread_num));
        $stmt->where(['CRMThread.crm_thread_num', [$num]])
            if defined($num);
        $stmt->where(['CRMThread.crm_thread_status', [
            $status->get_criteria_list,
        ]]) if $status;
        $stmt->where(['CRMThread.owner_user_id', [$owner]])
            if $owner;
    }
    return shift->SUPER::internal_prepare_statement(@_);
}

sub _iterate_in {
    my($self, $model, $field, $values, $op, $query) = @_;
    return
        unless @$values;
    $self->new_other($model)->do_iterate(
        sub {
            $op->(shift);
            return 1;
        },
        'unauth_iterate_start',
        $field,
        {%{$query || {}}, $field => $values},
    );
    return;
}

sub _su_fields {
    my($self, $rows) = @_;
    my($from) = 'RealmMail.from_email';
    my($modified_by) = 'CRMThread.modified_by_user_id';
    my($sender) = lc($self->new_other('RowTag')->get_value(
        $rows->[0]->{'RealmMail.realm_id'},
        'CANONICAL_SENDER_EMAIL',
    ) || '');
    my($rewrite_user_id) = {};
    my($is_email) = {};
    foreach my $email (map(lc($_->{$from} || ''), @$rows)) {
        next
            if !$email || $email eq $sender;
        if ($email =~ /^\Q$_REWRITE\E\*(\d+)\@/) {
            $rewrite_user_id->{$email} = $1;
        }
        else {
            $is_email->{$email} = 1;
        }
    }
    my($emails) = [keys(%$is_email)];
    my($is_user) = {};
    _iterate_in(
        $self,
        'User',
        'user_id',
        [values(%$rewrite_user_id)],
        sub {$is_user->{shift->get('user_id')} = 1},
    );
    my($email_user_id) = {map(
        ($_ => $rewrite_user_id->{$_}),
        grep($is_user->{$rewrite_user_id->{$_}}, keys(%$rewrite_user_id)),
    )};
    $_C->map_execute(
        sub {
            my($row) = @_;
            $email_user_id->{$row->[0]} = $row->[1];
            return;
        },
        'SELECT e.email, e.realm_id FROM email_t e, user_t u'
            . ' WHERE u.user_id = e.realm_id AND e.email IN ('
            . join(',', ('?') x int(@$emails))
            . ')',
        $emails,
    ) if @$emails;
    my($is_super) = {};
    _iterate_in(
        $self,
        'RealmUser',
        'user_id',
        [values(%$email_user_id), grep(defined, map($_->{$modified_by}, @$rows))],
        sub {$is_super->{shift->get('user_id')} = 1},
        {realm_id => $_GENERAL_ID, role => $_ADMINISTRATOR},
    );
    foreach my $row (@$rows) {
        $row->{from_user_id} = $email_user_id->{lc($row->{$from} || '')};
        $row->{from_is_super_user} = $row->{from_user_id} && $is_super->{$row->{from_user_id}}
            ? 1 : 0;
        my($updater) = $row->{$modified_by};
        $row->{modified_by_is_super_user} = $updater && $is_super->{$updater} ? 1 : 0;
    }
    return;
}

1;
