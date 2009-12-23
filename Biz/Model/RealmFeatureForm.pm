# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFeatureForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('UI.Facade');
my($_RR) = b_use('ShellUtil.RealmRole');
my($_EMAIL_MODES) = [map(lc($_), b_use('Type.ForumEmailMode')->OPTIONAL_MODES)];
my($_CATEGORY_DEFAULTS) = {
#TODO: Define list here, but might be worth confirming against features
# supported in BConf category map
    feature_blog => 1,
    feature_calendar => 1,
    feature_file => 1,
    feature_mail => 1,
    feature_motion => 1,
    feature_tuple => 1,
    map(($_ => 0), @$_EMAIL_MODES),
};
my($_CATEGORIES) = [sort(keys(%$_CATEGORY_DEFAULTS))];
my($_ENABLED_CATEGORIES) = [grep($_CATEGORY_DEFAULTS->{$_}, @$_CATEGORIES)];
my($_FEM) = b_use('Type.ForumEmailMode');

sub CATEGORY_LIST {
    return @$_CATEGORIES;
}

sub FEATURE_LIST {
    return grep(/^feature/, @$_CATEGORIES);
}

sub execute_empty {
    my($self) = @_;
    $self->internal_use_general_realm_for_site_admin(sub {
        $self->load_from_model_properties('RealmOwner')
            unless $self->req('auth_realm')->is_general;
        $self->internal_put_categories(1);
    });
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->internal_use_general_realm_for_site_admin(sub {
        my($x) = $self->get_model_properties('RealmOwner');
        foreach my $k (keys(%$x)) {
            delete($x->{$k})
                unless defined($x->{$k});
        }
        if ($self->req('auth_realm')->is_general) {
            my($forum, $ro) = $self->new_other('Forum')
                ->create_realm({}, $x, $self->req('auth_user_id'));
            $self->req->with_realm($ro, sub {
                $self->internal_edit_categories;
            })
        }
        else {
            $self->get_model('RealmOwner')->update($x)
                if keys(%$x);
            $self->internal_edit_categories;
        }
        return;
    });
    return;
}

sub internal_edit_categories {
    my($self) = @_;
    $_RR->edit_categories({
        feature_wiki => 1,
        map(($_ => $self->get($_)), @$_CATEGORIES),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
            $self->field_decl([
                [('RealmOwner.display_name')x2],
                [('RealmOwner.name')x2],
            ], undef, 'NONE'),
	    $self->field_decl(
		[
                    @$_CATEGORIES,
                    [email_mode => 'ForumEmailMode', 'NONE'],
                ],
		'NullBoolean',
	    ),
        ],
        require_context => 1,
	auth_id => ['RealmOwner.realm_id'],
    });
}

sub internal_put_categories {
    my($self, $overwrite) = @_;
    my($cats) = $self->req('auth_realm')->is_general
	? [@$_ENABLED_CATEGORIES]
	: $_RR->list_enabled_categories;
    foreach my $c (@$_CATEGORIES) {
	$self->internal_put_field($c => grep($_ eq $c, @$cats) ? 1 : 0)
	    if $overwrite || !defined($self->unsafe_get($c));
    }
    _put_email_mode($self);
    return;
}

sub internal_put_field_category_defaults {
    my($self) = @_;
    _put_default_email_mode($self);
    return shift->internal_put_field(%$_CATEGORY_DEFAULTS)
}

sub internal_use_general_realm_for_site_admin {
    my($self, $op) = @_;
    return $self->req->with_realm(undef, $op)
        if $_F->get_from_source($self)->auth_realm_is_site_admin($self->req);
    return $op->();
}

sub internal_validate_email_modes {
    my($self) = @_;
    if (my $mode = $self->unsafe_get('email_mode')) {
        $self->internal_put_field(
            map(($_ => $mode->equals_by_name($_) ? 1 : 0), @$_EMAIL_MODES),
        );
    }
    my($x) = [grep($self->unsafe_get($_), @$_EMAIL_MODES)];
    $self->internal_put_error($x->[1], 'MUTUALLY_EXCLUSIVE')
        if @$x > 1;
    return;
}

sub validate {
    my($self) = @_;
    $self->internal_use_general_realm_for_site_admin(sub {
        $self->internal_validate_email_modes;
        $self->validate_not_null('RealmOwner.name')
            if $self->req('auth_realm')->is_general;
    });
    return;
}

sub _is_auth_relam_general_or_site_admin {
    my($self) = @_;
    return $_F->get_from_source($self)->auth_realm_is_site_admin($self->req)
        || $self->req('auth_realm')->is_general;
}

sub _put_default_email_mode {
    my($self) = @_;
    my(@x) = $self->unsafe_get(qw(
        email_mode
        admin_only_forum_email
        system_user_forum_email
        public_forum_email
    ));
    return if @x;
    $self->internal_put_field(
        email_mode => $_FEM->DEFAULT);
    return;
}

sub _put_email_mode {
    my($self) = @_;
    my($email, $admin, $system, $public) = $self->unsafe_get(qw(
        email_mode
        admin_only_forum_email
        system_user_forum_email
        public_forum_email
    ));
    $self->internal_put_field(
        email_mode =>
            $admin && !$system && !$public ? $_FEM->ADMIN_ONLY_FORUM_EMAIL
            : !$admin && $system && !$public ? $_FEM->SYSTEM_USER_FORUM_EMAIL
            : !$admin && !$system && $public ? $_FEM->PUBLIC_FORUM_EMAIL
            : $_FEM->DEFAULT,
    );
    return;
}

1;
