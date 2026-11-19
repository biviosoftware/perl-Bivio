# Copyright (c) 2008-2026 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::CRMThreadRootList;
use strict;
use Bivio::Base 'Model.MailThreadRootList';

my($_LOCATION) = b_use('Model.Email')->DEFAULT_LOCATION->as_sql_param;
my($_CRMQF) = b_use('Model.CRMQueryForm');
my($_E) = b_use('Type.Email');
my($_GENERAL_ID) = b_use('Auth.RealmType')->GENERAL->as_int;
my($_ADMINISTRATOR) = b_use('Auth.Role')->ADMINISTRATOR->as_sql_param;
my($_CANONICAL_SENDER) = b_use('Type.RowTagKey')->CANONICAL_SENDER_EMAIL->as_sql_param;
my($_REWRITE) = b_use('Action.MailForward')->REWRITE_FROM_DOMAIN_URI;
my($_FROM_USER_ID) = "CASE WHEN EXISTS (
        SELECT rt.primary_id
        FROM row_tag_t rt
        WHERE rt.primary_id = realm_mail_t.realm_id
        AND rt.key = $_CANONICAL_SENDER
        AND LOWER(rt.value) = LOWER(realm_mail_t.from_email)
    ) THEN NULL ELSE COALESCE(
        (
            SELECT u.user_id
            FROM user_t u
            WHERE u.user_id = CAST(
                SUBSTRING(realm_mail_t.from_email FROM '^$_REWRITE\[*]([0-9]+)\@') AS NUMERIC)
        ),
        (
            SELECT e.realm_id
            FROM email_t e, user_t u
            WHERE e.email = realm_mail_t.from_email
            AND u.user_id = e.realm_id
        )
    ) END";
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
            {
                name => 'modified_by_is_super_user',
                type => 'Boolean',
                constraint => 'NONE',
                in_select => 1,
                select_value => "EXISTS (
                    SELECT ru.user_id
                    FROM realm_user_t ru
                    WHERE ru.realm_id = $_GENERAL_ID
                    AND ru.user_id = crm_thread_t.modified_by_user_id
                    AND ru.role = $_ADMINISTRATOR
                ) AS modified_by_is_super_user",
            },
            {
                name => 'from_user_id',
                type => 'User.user_id',
                constraint => 'NONE',
                in_select => 1,
                select_value => "($_FROM_USER_ID) AS from_user_id",
            },
            {
                name => 'from_is_super_user',
                type => 'Boolean',
                constraint => 'NONE',
                in_select => 1,
                select_value => "EXISTS (
                    SELECT ru.user_id
                    FROM realm_user_t ru
                    WHERE ru.realm_id = $_GENERAL_ID
                    AND ru.role = $_ADMINISTRATOR
                    AND ru.user_id = ($_FROM_USER_ID)
                ) AS from_is_super_user",
            },
        ],
    });
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

1;
