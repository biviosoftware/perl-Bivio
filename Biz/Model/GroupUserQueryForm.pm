# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::GroupUserQueryForm;
use strict;
use Bivio::Base 'Model.FilterQueryForm';
b_use('IO.ClassLoaderAUTOLOAD');

my($_T) = b_use('FacadeComponent.Text');
my($_SUBSCRIBED) = 'is_subscribed';

sub get_privilege_role {
    return _specified_role(shift);
}

sub get_subscribed {
    my($role) = _specified_role(shift);
    return defined($role) && $role eq $_SUBSCRIBED;
}

sub internal_query_fields {
    return [
        @{shift->SUPER::internal_query_fields(@_)},
        [qw(b_privilege Text)],
    ];
}

sub internal_roles {
    return [grep(
        !$_->eq_mail_recipient, @{b_use('Model.RoleBaseList')->ROLES_ORDER})];
}

sub provide_select_choices {
    my($self) = @_;
    return [sort(keys(%{_role_map($self)}))];
}

sub to_html {
    my($self, $v) = @_;
    return b_use('Bivio::HTML')->escape($v);
}

sub _role_map {
    my($self) = @_;
    return {
        map({
            my($v) = Model_GroupUserList()
                ->privilege_name($_->get_name, $self->req);
            $v ? ($v => $_) : ();
        } @{$self->internal_roles}),
        Model_GroupUserList()
            ->privilege_name('UserRealmSubscription.is_subscribed', $self->req)
            => $_SUBSCRIBED,
    };
}

sub _specified_role {
    my($self) = @_;
    return _role_map($self)->{$self->unsafe_get('b_privilege') || ''};
}

1;
