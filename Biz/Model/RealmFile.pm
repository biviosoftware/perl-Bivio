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
    _txn($self, sub {
	# Don't check for errors, may not exist
	unlink(shift(@_));
    });
    return $self->SUPER::delete;
}

sub delete_all {
    my($self, $query) = @_;
    my($req) = $self->get_request;
    my($realm);
    if ($query && $query->{realm_id}) {
 	$realm = $req->get('auth_realm');
 	$req->set_realm($query->{realm_id});
 	delete($query->{realm_id});
    }
    $self->die('unsupported with a query: ', $query)
	if $query && %$query;
    my($d) = _realm_dir($self);
    _txn($self, sub {
        Bivio::IO::File->rm_rf($d);
    });
    my(@res) = $self->SUPER::delete_all;
    $req->set_realm($realm)
	if $realm;
    return @res;
}

sub get_content {
    my($self) = @_;
    return _f($self)->{content} ||= Bivio::IO::File->read(_path($self));
}

sub handle_commit {
    my($self) = @_;
    (_f($self)->{handle_commit} || sub {})->();
    $self->internal_clear_model_cache;
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
    _f($self)->{content} = ref($content) ? $content : \$content;
    $$content = ''
	unless defined($$content);
    $self->die('folder with content')
	if $self->get('is_folder') && length($$content);
    my($c) = $self->get_content;
    _txn($self, sub {
	my($p) = @_;
	Bivio::IO::File->mkdir_parent_only($p);
	Bivio::IO::File->write($p, $c);
    });
    return $self;
}

sub unauth_delete {
    die('unsupported');
}

sub update {
    die('unsupported');
}

sub _f {
    return (shift->[$_IDI] ||= {});
}

sub _path {
    my($self) = @_;
    return _f($self)->{path} ||= _realm_dir($self)
	. '/'
	. lc($self->get('volume')->get_name)
	. '/'
	.  $self->get('realm_file_id')
	. '-'
	. $_P->to_os($self->get('path'));
}

sub _realm_dir {
    my($self) = @_;
    return Bivio::UI::Facade->get_local_file_name(
	Bivio::UI::LocalFileType->REALM_DATA,
	$self->get('realm_id')
    );
}

sub _txn {
    my($self, $op) = @_;
    my($p) = _path($self);
    _f($self)->{handle_commit} = sub {
	$op->($p);
    };
    $self->get_request->push_txn_resource($self);
    return;
}

1;
