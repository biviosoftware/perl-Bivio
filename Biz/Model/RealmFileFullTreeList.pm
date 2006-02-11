# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileFullTreeList;
use strict;
use base 'Bivio::Biz::Model::FullTreeBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub LOAD_ALL_SIZE {
    return 5000;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
        primary_key => ['RealmFile.realm_file_id'],
        auth_id => 'RealmFile.realm_id',
	order_by => [qw(
	    RealmFile.path_lc
	    RealmFile.modified_date_time
            Email.email
	)],
	other => [
	    'RealmFile.path',
            [qw(RealmFile.user_id Email.realm_id)],
	    'RealmFile.is_folder',
	    {
		name => 'base_name',
		type => 'FilePath',
		constraint => 'NONE',
	    },
	],
    });
}

sub internal_load_rows {
    my($self) = shift;
    my($rows) = $self->SUPER::internal_load_rows(@_);
    my($pid) = {map(
	$_->{'RealmFile.is_folder'}
	    ? ($_->{'RealmFile.path_lc'} => $_->{'RealmFile.realm_file_id'})
	    : (),
       @$rows,
    )};
    return [map({
	my($p) = $_->{'RealmFile.path_lc'};
	$_->{parent_node_id} = $p eq '/' ? $self->ROOT_PARENT_NODE_ID
	    : $pid->{($p =~ m{(.*)/})[0] || '/'}
	    || Bivio::Die->die($_, ': parent_node_id not found');
	$_->{is_parent_node} = $_->{'RealmFile.is_folder'};
	$_->{base_name}
	    = Bivio::Type::FileName->get_tail($_->{'RealmFile.path'}) || '/';
	$_,
    } @$rows)];
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->EQ('Email.location', $self->get_instance('Email')->DEFAULT_LOCATION);
    # /Mail is probably large so we'll ignore it
    # dot-files are uninteresting, so we'll ignore them.
    # All are available via DAV
    my($mf) = lc($self->get_instance('Forum')->MAIL_FOLDER);
    $stmt->where(@{$stmt->map_invoke(
	NOT_LIKE => ['%/.%', $mf . '/%', $mf],
	['RealmFile.path_lc'],
    )});
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
