# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMailPublicForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MV) = b_use('Type.MailVisibility');

sub can_toggle_public {
    my($self) = @_;
    return $_MV->row_tag_get($self->req)->eq_always_is_private ? 0 : 1;
}

sub execute_empty {
    my($self) = @_;
    $self->new_other('RealmFile')
	->load({realm_file_id => $self->get_nested(qw(realm_mail realm_file_id))})
	->toggle_is_public;
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
	    $self->field_decl([[qw(realm_mail Model.RealmMail)]]),
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->throw_die('FORBIDDEN', 'Always is private')
	unless $self->can_toggle_public;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
	realm_mail => $self
	    ->new_other('RealmMail')
	    ->set_ephemeral
	    ->load_this_from_request,
    );
    return @res;
}

1;
