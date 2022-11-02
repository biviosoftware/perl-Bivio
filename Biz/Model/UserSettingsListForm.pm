# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserSettingsListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';
b_use('IO.ClassLoaderAUTOLOAD');

my($_NAME_FIELDS) = [map("User.${_}_name", qw(first middle last))];
my($_EV) = b_use('Model.EmailVerify');

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field(is_subscribed => _is_subscribed($self));
    return;
}

sub execute_empty_start {
    my($self) = @_;
    # subclasses might be in different realm
    _with_realm_as_user(
        $self,
        sub {
            foreach my $m (qw(RealmOwner User Email)) {
                $self->load_from_model_properties($self->new_other($m)->load);
            }
            $self->internal_put_field(
                'UserDefaultSubscription.subscribed_by_default'
                    => _user_default_subscription_status($self),
            );
            $self->internal_put_field(
                _map_row_tags(
                    $self,
                    sub {
                        my($field, $type) = @_;
                        return ($field => $type->row_tag_get($self->req));
                    }),
            );
        },
    );
    return;
}

sub execute_ok_end {
    my($self) = @_;
    return _with_realm_as_user(
        $self,
        sub {
            my($new_email) = $self->get('Email.email');
            return
                if $new_email eq $self->new_other('Email')->load->get('email');
            return {
                task_id => 'USER_EMAIL_VERIFY',
                query => {
                    $_EV->EMAIL_KEY => $new_email,
                },
            } unless $self->req->is_substitute_user;
            $self->new_other('Email')->load->update({
                email => $new_email,
            });
            return;
        }
    );
}

sub execute_ok_row {
    my($self) = @_;
    $self->new_other('UserRealmSubscription')->unauth_create_or_update({
        realm_id => $self->get_list_model->get('RealmUser.realm_id'),
        user_id => $self->req('auth_user_id'),
        is_subscribed => $self->get('is_subscribed'),
    });
    return;
}

sub execute_ok_start {
    my($self) = @_;
    _with_realm_as_user(
        $self,
        sub {
            $self->new_other('User')->load
                ->update($self->get_model_properties('User'));
            _map_row_tags(
                $self,
                sub {
                    my($field, $type) = @_;
                    $type->row_tag_replace($self->get($field), $self->req);
                    return;
                });
            if ($self->unsafe_get('show_name')) {
                $self->new_other('RealmOwner')->load
                    ->update($self->get_model_properties('RealmOwner'));
            }
        },
    );
    my($uds) = $self->new_other('UserDefaultSubscription');
    $uds->unauth_create_or_update({
        realm_id => $uds->default_subscription_realm_id(Auth_RealmType('FORUM')),
        user_id => $self->req('auth_user_id'),
        subscribed_by_default =>
            $self->get('UserDefaultSubscription.subscribed_by_default'),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'UserSubscriptionList',
        require_context => 1,
        visible => [
            @$_NAME_FIELDS,
            'RealmOwner.name',
            'Email.email',
            'UserDefaultSubscription.subscribed_by_default',
            $self->field_decl([
                [qw(page_size PageSize NOT_NULL)],
                [qw(time_zone_selector TimeZoneSelector NOT_NULL)],
                [qw(is_subscribed Boolean), {in_list => 1}],
            ]),
        ],
        other => [
            $self->field_decl([
                [qw(show_name Boolean NOT_NULL)],
            ]),
            'RealmOwner.realm_id',
        ],
    });
}

sub internal_initialize_list {
    return shift->new_other('UserSubscriptionList')->load_all_qualified_realms;
}

sub internal_pre_execute {
    my($self) = @_;
    my($req) = $self->req;
    $self->new_other('TimeZoneList')->load_all;
    $self->internal_put_field(
        show_name => $req->is_substitute_user || $req->is_super_user ? 1 : 0);
    return shift->SUPER::internal_pre_execute(@_);
}

sub validate_start {
    my($self) = @_;
    $self->internal_put_error('User.first_name', 'NULL')
        unless _is_name_set($self);
    $self->validate_time_zone_selector();
    $self->internal_clear_error('RealmOwner.name')
        unless $self->get('show_name');
    return;
}

sub validate_time_zone_selector {
    my($self, $model) = @_;
    $model ||= $self;
    my($enum) = $model->req('Model.TimeZoneList')
        ->unsafe_enum_for_display_name($model->get('time_zone_selector'));
    $model->internal_put_error(qw(time_zone_selector NOT_FOUND))
        if !$enum || $enum->equals_by_name('UNKNOWN');
    return;
}

sub validate_user_names {
    my($self, $model) = @_;
    $model ||= $self;
    $model->internal_put_error('User.first_name', 'NULL')
        unless _is_name_set($model);
    return;
}

sub _is_name_set {
    return _is_set(shift, $_NAME_FIELDS);
}

sub _is_set {
    my($model, $fields) = @_;
    foreach my $f (@$fields) {
        return 1
            if defined($model->unsafe_get($f));
    }
    return 0;
}

sub _is_subscribed {
    my($self) = @_;
    return $self->get_list_model
        ->get('UserRealmSubscription.is_subscribed')
            ? 1 : 0;
}

sub _map_row_tags {
    my($self, $op) = @_;
    return map(
        $op->($_, $self->get_field_type($_)),
        qw(page_size time_zone_selector),
    );
}

sub _user_default_subscription_status {
    my($self) = @_;
    return $self->new_other('UserDefaultSubscription')
        ->user_default_subscription_status(
            $self->req('auth_user_id'), Auth_RealmType('FORUM'));
}

sub _with_realm_as_user {
    my($self, $op) = @_;
    return $self->req->with_realm(
        $self->req('auth_user_id'),
        $op,
    );
}

1;
