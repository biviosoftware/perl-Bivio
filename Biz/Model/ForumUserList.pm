# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumUserList;
use strict;
use Bivio::Base 'Model.GroupUserList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other => [
	    $self->field_decl(
		[qw(administrator mail_recipient file_writer)],
		Boolean => 'NOT_NULL',
	    ),
	],
    });
}

sub internal_post_load_row {
    my($self) = shift;
    return 0
	unless $self->SUPER::internal_post_load_row(@_);
    my($row) = @_;
    foreach my $x (qw(administrator mail_recipient file_writer)) {
	$row->{$x} = grep($_->equals_by_name($x), @{$row->{roles}}) ? 1 : 0;
    }
    return 1;
}

sub internal_qualify_role {
    my($self, $stmt) = @_;
    $stmt->where($stmt->NE('RealmUser.role', [Bivio::Auth::Role->WITHDRAWN]));
    return;
}

1;
