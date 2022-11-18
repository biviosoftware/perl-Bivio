# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFeatureForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_RR) = b_use('ShellUtil.RealmRole');
my($_MSA) = b_use('Type.MailSendAccess');
my($_F) = b_use('UI.Facade');
my($_FEATURE_TYPE_MAP) = {
    map(($_ => b_use('Type.RealmFeature')), qw(
        feature_blog
        feature_calendar
        feature_mail
        feature_motion
        feature_tuple
    )),
    mail_want_reply_to => b_use('Type.MailWantReplyTo'),
    mail_send_access => b_use('Type.MailSendAccess'),
    mail_visibility => b_use('Type.MailVisibility'),
};
my($_IMPLICIT_FEATURE_TYPE_MAP) = {
    map(($_ => b_use('Type.RealmFeature')), qw(
        feature_dav
        feature_file
        feature_group_admin
        feature_wiki
    )),
};

sub ALL_FEATURES_WHICH_ARE_CATEGORIES {
    my($proto) = @_;
    return [grep(
        $_RR->is_category($_),
        sort(
            keys(%{$proto->FEATURE_TYPE_MAP}),
            keys(%{$proto->IMPLICIT_FEATURE_TYPE_MAP}),
        ),
    )];
}

sub FEATURE_TYPE_MAP {
    return $_FEATURE_TYPE_MAP;
}

sub IMPLICIT_FEATURE_TYPE_MAP {
    return $_IMPLICIT_FEATURE_TYPE_MAP;
}

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(%{_empty_values($self)});
    return;
}

sub execute_ok {
    my($self) = @_;
    b_die('cannot be executed in the general realm')
        if $self->req('auth_realm')->is_general;
    my($res) = shift->SUPER::execute_ok(@_);
    my($ev) = _empty_values($self);
    $self->map_feature_type(sub {
        my($field, $type) = @_;
        return
            unless $self->unsafe_get("allow_$field");
        my($v);
        if ($self->unsafe_get('force_default_values')) {
            $v = $ev->{$field};
        }
        else {
            return
                unless defined($v = $self->unsafe_get($field));
            return
                if $type->is_equal($v, $ev->{$field});
        }
        return $type->row_tag_replace($v, $self->req)
            if $type->can('ROW_TAG_KEY');
        $_RR->edit_categories(
            $type->can('as_realm_role_category')
                ? {$v->as_realm_role_category => 1}
                : {$field => $v},
        );
        return;
    });
    return $res;
}

sub internal_allow_field_value {
    return 1;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
            visible => $self->map_feature_type(sub {[@_]}),
            other => [
                [qw(force_default_values Boolean)],
                @{shift->map_feature_type(
                    sub {
                        my($f) = shift(@_);
                        return (
                            ['allow_' . $f, 'Boolean'],
                            ['super_user_' . $f, 'Boolean'],
                        );
                    },
                )},
            ],
        ),
        auth_id => ['RealmOwner.realm_id'],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
        @{$self->map_feature_type(
            sub {
                my($field) = @_;
                return (
                    "allow_$field" => $self->internal_allow_field_value(@_),
                    "super_user_$field" => $self->internal_super_user_field(@_),
                );
            },
        )},
    );
    return @res;
}

sub internal_super_user_field {
    return 0;
}

sub internal_use_general_realm_for_site_admin {
    my($self, $op) = @_;
    return $self->req->with_realm(undef, $op)
        if $_F->get_from_source($self)->auth_realm_is_site_admin($self->req)
        && $self->is_create;
    return $op->();
}

sub map_feature_type {
    my($self, $op) = @_;
    my($m) = {
        %{$self->FEATURE_TYPE_MAP},
        ref($self) && $self->unsafe_get('force_default_values')
            ? %{$self->IMPLICIT_FEATURE_TYPE_MAP} : (),
    };
    return [map($op ? $op->($_, $m->{$_}) : $_, sort(keys(%$m)))];
}

sub _empty_values {
    my($self) = @_;
    return {@{$self->map_feature_type(sub {
        my($field, $type) = @_;
        return ($field => $type->get_default);
    })}} if $self->req('auth_realm')->is_general
        || $self->unsafe_get('force_default_values');
    my($cats) = $_RR->list_enabled_categories;
    return {@{$self->map_feature_type(sub {
        my($field, $type) = @_;
        return (
            $field,
            $type->can('from_realm_role_enabled_categories')
                ? $type->from_realm_role_enabled_categories($cats)
                : $type->can('ROW_TAG_KEY')
                ? $type->row_tag_get($self->req)
                : grep($field eq $_, @$cats) ? 1 : 0,
        );
    })}};
}

1;
