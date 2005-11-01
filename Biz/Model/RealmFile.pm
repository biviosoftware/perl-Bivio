# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFile;
use strict;
use base ('Bivio::Biz::PropertyModel');
use Bivio::MIME::Type;
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_P) = Bivio::Type->get_instance('FilePath');
our($_TRACE);

sub copy_deep {
    my($self, $dest) = @_;
    $dest = $_P->from_literal_or_die($dest);
    my($v) = $self->get_shallow_copy;
    $v->{path} = $dest;
    delete($v->{realm_file_id});
    my($new) = $self->new;
    $new->SUPER::create(_fix_values($new, $v));
    if ($self->is_empty) {
	$new->put_content($self->get_content)
	    unless $self->get('is_folder');
	return;
    }
    my($old_length) = length($self->get('path'));
    my($size) = 0;
    foreach my $x (@{$self->map_folder_deep(
	sub {
	    my($it) = @_;
	    my($res) = $it->get_shallow_copy;
	    unless ($res->{is_folder}) {
		$res->{content} = $it->get_content;
		$it->throw_die(NO_RESOURCES => {message => 'copy too large'})
		    if ($size += length(${$res->{content}})) > 30_000_000;
	    }
	    return $res;
	},
    )}) {
	delete($x->{realm_file_id});
	my($c) = delete($x->{content});
	$x->{path} = $dest . substr($x->{path}, $old_length);
	$x->{_parent_folder_exists} = 1;
	$new->SUPER::create(_fix_values($new, $x));
	$new->put_content($c)
	    if $c;
    }
    return;
}

sub create {
    die('unsupported; call create_with_content');
}

sub create_with_content {
    my($self, $values, $content) = @_;
    $self->throw_die(DIE => {
	entity => $content,
	message => 'content must be a scalar or scalar_ref',
    }) unless ref($content) eq 'SCALAR' || !ref($content) && defined($content);
    return _create($self, $values, 0)->put_content($content);
}

sub create_folder {
    my($self, $values) = @_;
    return _create($self, $values, 1);
}

sub delete {
    my($self) = shift;
    $self->is_loaded ? _fix_values($self, $self->get_shallow_copy)
	: $self->load(@_);
    $self->throw_die(DIE => {
	entity => $self->get('path'),
	message => 'folder is not empty',
    }) unless $self->is_empty;
    return _unlink($self)->SUPER::delete;
}

sub delete_all {
    my($self, $query) = @_;
    $self = $self->new
	unless $self->is_instance;
    my($req) = $self->get_request;
    my($realm);
    if ($query && $query->{realm_id}) {
 	$realm = $req->get('auth_realm');
 	$req->set_realm($query->{realm_id});
 	delete($query->{realm_id});
    }
    $self->die('unsupported with a query: ', $query)
	if $query && %$query;
    my($d) = _realm_dir($req->get('auth_id'));
    _txn($self, sub {
        Bivio::IO::File->rm_rf($d);
    });
    my(@res) = $self->SUPER::delete_all;
    $req->set_realm($realm)
	if $realm;
    return @res;
}

sub delete_deep {
    my($self) = @_;
    _assert_not_root($self);
    return $self->delete
	if $self->is_empty;
    foreach my $x (reverse(@{$self->map_folder_deep(
	sub {
	    my($it) = shift;
	    return $it->new->unauth_load_or_die({
		realm_file_id => $it->get('realm_file_id'),
	    });
	},
    )})) {
	$x->delete;
    }
    return $self->delete;
}

sub get_content {
    my($self) = @_;
    return _f($self)->{content} ||= Bivio::IO::File->read(_path($self));
}

sub get_content_length {
    return -s _path(shift);
}

sub get_content_type {
    my($self) = @_;
    return Bivio::MIME::Type->from_extension($self->get('path'));
#    my($t) = Bivio::MIME::Type->from_extension($self->get('path'));
#    Bivio::IO::Alert->info(-T $self->get_handle);
#    return $t eq 'application/octet-stream' && -T $self->get_handle
#	? 'text/plain' : $t,
}

sub get_handle {
    my($self) = @_;
    return IO::File->new(_path($self), 'r')
	|| $self->throw_die('IO_ERROR', {
	    entity => _path($self),
	    message => "$!",
	});
}

sub handle_commit {
    my($self) = @_;
    (_f($self)->{handle_commit} || sub {})->();
    return;
}

sub handle_rollback {
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
	    # Don't cascade when User.user_id is deleted
	    user_id =>  ['PrimaryId', 'NOT_NULL'],
	    volume => ['FileVolume', 'NOT_ZERO_ENUM'],
            modified_date_time => ['DateTime', 'NOT_NULL'],
	    is_folder => ['Boolean', 'NOT_NULL'],
	    is_public => ['Boolean', 'NOT_NULL'],
            path => ['FilePath', 'NOT_NULL'],
            path_lc => ['FilePath', 'NOT_NULL'],
        },
        auth_id => 'realm_id',
    });
}

sub internal_prepare_query {
    my($self, $query) = @_;
    # Only load by path_lc, and convert from_literal (which is idempotent)
    if (exists($query->{path})) {
	my($p) = delete($query->{path});
	$query->{path_lc} = $p
	    unless exists($query->{path_lc});
    }
    if (exists($query->{path_lc})) {
	my($p, $e) = $_P->from_literal($query->{path_lc});
	# The value won't be found if it is illegal
	_trace($query, ': path error ', $e)
	    if $e && $_TRACE;
	$query->{path_lc} = lc($p)
	    if $p;
    }
    return shift->SUPER::internal_prepare_query(@_);
}

sub is_empty {
    my($self) = @_;
    return $self->get('is_folder') && @{$self->map_folder(sub {1})} ? 0 : 1;
}

sub map_folder {
    return _map_folder(0, @_);
}

sub map_folder_deep {
    return _map_folder(1, @_);
}

sub put_content {
    my($self, $content) = @_;
    _f($self)->{content} = ref($content) ? $content : \$content;
    $$content = ''
	unless defined($$content);
    $self->die('folder with content')
	if $self->get('is_folder') && length($$content);
    my($c) = $self->get_content;
    my($p) = _path($self);
    _txn($self, sub {
	Bivio::IO::File->mkdir_parent_only($p);
	Bivio::IO::File->write($p, $c);
    });
    return $self;
}

sub unauth_delete {
    die('unsupported');
}

sub update {
    my($self, $values) = @_;
    my($req) = $self->get_request;
    $self->die('may not change is_folder value')
	if exists($values->{is_folder})
	&& $self->get('is_folder') ne $values->{is_folder};
    $values->{is_folder} = $self->get('is_folder');
    $values->{path} ||= $self->get('path');
    $values->{volume} ||= $self->get('volume');
    $values->{realm_id} ||= $self->get('realm_id');
    $values->{user_id} ||= $self->get('user_id');
    my($children) = $self->get('is_folder')
	&& grep(
	    $values->{$_} && $values->{$_} ne $self->get($_),
	    qw(realm_id volume path),
	) ? $self->map_folder_deep(sub {shift->get('realm_file_id')})
	: [];
    my($old_length) = length($self->get('path_lc'));
    my(@res) = $self->SUPER::update(_fix_values($self, $values));
    foreach my $cid (@$children) {
	my($child) = $self->new;
	next unless $child->unauth_load({realm_file_id => $cid});
	# Don't want recursion, because we are doing deep.
	my($method) = ($child->get('is_folder') ? 'SUPER::' : '') . 'update';
	$child->$method({
	    # Communicate with _fix_values
	    $method eq 'update' ? (_parent_folder_exists => 1) : (),
	    map(($_ => $child->get($_)), qw(modified_date_time)),
	    map(($_ => $self->get($_)), qw(realm_id volume)),
	    map(($_ => $self->get($_) . substr($child->get($_), $old_length)),
		qw(path path_lc),
	    ),
	});
    }
    return @res;
}

sub update_with_content {
    my($self, $values, $content) = @_;
    return _unlink($self)->put_content($content)->update($values || {});
}

sub _assert_not_root {
    my($self) = @_;
    $self->die('cannot perform operation on root')
	if $self->get('path') eq '/';
    return;
}

sub _create {
    my($self, $values, $is_folder) = @_;
    my($req) = $self->get_request;
    # You must not reuse $self after this call
    $values->{is_folder} = $is_folder;
    $values->{is_public} ||= 0;
    $values->{realm_id} ||= $req->get('auth_id');
    $values->{user_id} ||= $req->get('auth_user_id');
    return $self->SUPER::create(_fix_values($self, $values));
}

sub _f {
    return (shift->[$_IDI] ||= {});
}

sub _fix_values {
    my($self, $values) = @_;
    my($req) = $self->get_request;
    $values->{modified_date_time} ||= Bivio::Type::DateTime->now;
    $values->{path_lc} = lc(
	$values->{path} = my $p = $_P->from_literal_or_die($values->{path}));
    unless ($p eq '/' || delete($values->{_parent_folder_exists})) {
	$p =~ s{[^/]+$}{} || $self->die('logic error');
	my($new) = $self->new;
	unless ($new->unauth_load({
	    realm_id => $values->{realm_id},
	    volume => $values->{volume},
	    path_lc => lc($p),
	})) {
	    $new->create_folder({
		%$values,
		path => $p,
	    });
	}
	elsif ($new->get('is_folder')) {
	    # match case of folder that exists
 	    substr($values->{path}, 0, length($new->get('path')))
		= $new->get('path');
	    # touch directory
	    $new->update({});
	}
	else {
	    $new->throw_die(IO_ERROR => {
		entity => $values->{path},
		message => 'parent exists as a file, but must be a folder',
	    });
	}
    }
    return $values;
}

sub _map_folder {
    my($deep, $self, $op) = @_;
    $self->die('not a folder')
	unless $self->get('is_folder');
    my($p) = $self->get('path_lc');
    $p .= '/'
	if $p ne '/';
    my($re) = $deep ? qr{^\Q$p} : qr{^\Q$p\E[^/]+$};
    return $self->new->map_iterate(sub {
       my($it) = @_;
       return $it->get('path_lc') =~ $re ? $op->($it) : ();
    }, unauth_iterate_start => path_lc => {
	map(($_ => $self->get($_)),
	    $self->get('is_public') ? 'is_public' : (),
	    'volume',
	    'realm_id',
	),
    });
}

sub _path {
    my($self) = @_;
    return _f($self)->{path_lc} ||= _realm_dir($self->get('realm_id'))
	. '/'
	. lc($self->get('volume')->get_name)
	. '/'
	.  $self->get('realm_file_id');
}

sub _realm_dir {
    my($realm_id) = @_;
    return Bivio::UI::Facade->get_local_file_name(
	Bivio::UI::LocalFileType->REALM_DATA,
	$realm_id,
    );
}

sub _txn {
    my($self, $op) = @_;
    # Need to create $new, because callers may modify or re-use $self after call
    my($new) = $self->new;
    _f($new)->{handle_commit} = $op;
    $new->get_request->push_txn_resource($new);
    return;
}

sub _unlink {
    my($self) = @_;
    my($p) = _path($self);
    _txn($self, sub {
	# Don't check for errors, may not exist
	unlink($p);
    }) unless $self->get('is_folder');
    return $self;
}

1;
