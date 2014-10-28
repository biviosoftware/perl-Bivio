# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMailPublicForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_MV) = b_use('Type.MailVisibility');

sub can_toggle_public {
    my($self) = @_;
    return $_MV->row_tag_get($self->req)->eq_always_is_private ? 0 : 1;
}

sub execute_empty {
    my($self) = @_;
    $self->get('realm_file')->toggle_is_public;
    return $self->internal_redirect_next;
}

sub execute_ok {
    b_die('should not get here');
    # DOES NOT RETURN
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	other => [
	    $self->field_decl([
		[qw(realm_mail Model.RealmMail)],
		[qw(realm_file Model.RealmFile)],
	    ]),
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($rm) = $self
	->new_other('RealmMail')
	->set_ephemeral
	->load_this_from_request;
    my($rf) = $rm->get_model('RealmFile');
    $self->internal_put_field(
	realm_mail => $rm,
	realm_file => $rf,
    );
    $self->throw_die('FORBIDDEN', 'Always is private')
	unless $rf->get('is_public') or $self->can_toggle_public;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    return @res;
}

1;
