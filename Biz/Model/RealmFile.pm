# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFile;
use strict;
use base ('Bivio::Biz::PropertyModel');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_P) = Bivio::Type->get_instance('FilePath');

sub create {
    die('unsupported; call create_with_content');
}

sub create_with_content {
    my($self, $values, $content) = @_;
    # You must not reuse $self after this call
    $values->{creation_date_time} ||= Bivio::Type::DateTime->now;
    $values->{realm_id} ||= $self->get_request->get('auth_id');
    $values->{is_folder} ||= 0;
    return $self->SUPER::create($values)->put_content($content);
}

sub delete {
    my($self) = shift;
    # You must not reuse $self after this call
    $self->load(@_)
	unless $self->is_loaded;
    $self->internal_clear_model_cache;
    $self->get_request->push_txn_resource($self);
    return $self->SUPER::delete;
}

sub delete_all {
    die('unsupported');
}

sub get_content {
    my($self) = @_;
    return ($self->[$_IDI] ||= {})->{content}
	||= Bivio::IO::File->read(_path($self))
}

sub handle_commit {
    my($self) = @_;
    my($p) = _path($self);
    if (my $fields = $self->[$_IDI]) {
	my($c) = $self->get_content;
	$self->internal_clear_model_cache;
	Bivio::IO::File->mkdir_parent_only($p);
	Bivio::IO::File->write($p, $c);
    }
    else {
	# May not be there, so don't check result
	unlink($p);
    }
    return;
}

sub handle_rollback {
    shift->internal_clear_model_cache;
    return;
}

sub internal_clear_model_cache {
    my($self) = @_;
    $self->[$_IDI] = undef;
    return shift->SUPER::internal_clear_model_cache(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'realm_file_t',
        columns => {
            realm_file_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
	    volume => ['FileVolume', 'NOT_ZERO_ENUM'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
	    is_folder => ['Boolean', 'NOT_NULL'],
            path => ['FilePath', 'NOT_NULL'],
        },
        auth_id => 'realm_id',
    });
}

sub put_content {
    my($self, $content) = @_;
    ($self->[$_IDI] ||= {})->{content}
	= ref($content) ? $content : \$content;
    $$content = ''
	unless defined($$content);
    $self->die('folder with content')
	if $self->get('is_folder') && length($$content);
    $self->get_request->push_txn_resource($self);
    return $self;
}

sub unauth_delete {
    die('unsupported');
}

sub update {
    die('unsupported');
}

sub _path {
    my($self) = @_;
    return $self->[$_IDI]->{path} ||= Bivio::UI::Facade->get_local_file_name(
	Bivio::UI::LocalFileType->REALM_DATA,
	$self->get('realm_id')
	. '/'
	. lc($self->get('volume')->get_name)
	. '/'
	.  $self->get('realm_file_id')
	. '-'
	. $_P->to_os($self->get('path')),
    );
}

1;
