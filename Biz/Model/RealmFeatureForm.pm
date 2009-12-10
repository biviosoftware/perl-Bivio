# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFeatureForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RR) = b_use('ShellUtil.RealmRole');
my($_EMAIL_MODES) = [map(lc($_), b_use('Type.ForumEmailMode')->OPTIONAL_MODES)];
my($_CATEGORY_DEFAULTS) = {
#TODO: Define list here, but might be worth confirming against features
# supported in BConf category map
    feature_blog => 1,
    feature_calendar => 1,
    feature_crm => 0,
    feature_file => 1,
    feature_mail => 1,
    feature_motion => 1,
    feature_tuple => 1,
    feature_wiki => 1,
    map(($_ => 0), @$_EMAIL_MODES),
};
my($_CATEGORIES) = [sort(keys(%$_CATEGORY_DEFAULTS))];
my($_ENABLED_CATEGORIES) = [grep($_CATEGORY_DEFAULTS->{$_}, @$_CATEGORIES)];

sub CATEGORY_LIST {
    return @$_CATEGORIES;
}

sub execute_empty {
    my($self) = @_;
    $self->internal_put_categories(1);
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->internal_edit_categories;
    return;
}

sub internal_edit_categories {
    my($self) = @_;
    $_RR->edit_categories({map(($_ => $self->get($_)), @$_CATEGORIES)});
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    $self->field_decl(
		[@$_CATEGORIES],
		'NullBoolean',
	    ),
        ],
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
    return;
}

sub internal_put_field_category_defaults {
    return shift->internal_put_field(%$_CATEGORY_DEFAULTS)
}

sub internal_validate_email_modes {
    my($self) = @_;
    my($x) = [grep($self->unsafe_get($_), @$_EMAIL_MODES)];
    $self->internal_put_error($x->[1], 'MUTUALLY_EXCLUSIVE')
        if @$x > 1;
    return;
}

sub validate {
    my($self) = @_;
    $self->internal_validate_email_modes;
    return;
}

1;
