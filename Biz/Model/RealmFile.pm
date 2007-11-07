# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFile;
use strict;
use Bivio::Base 'Biz.PropertyModel';
use Bivio::MIME::Type;
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_F) = __PACKAGE__->use('Biz.File');
my($_FP) = Bivio::Type->get_instance('FilePath');
my($_DFN) = Bivio::Type->get_instance('DocletFileName');
my($_TXN_PREFIX);
my($_DELETED_SENTINEL) = 'DELETED IN TRANSACTION';
Bivio::IO::Config->register(my $_CFG = {
    search_class => undef,
});

#DEPRECATED
sub MAIL_FOLDER {
    # Always is_read_only => 1
    return $_DFN->MAIL_FOLDER;
}

#DEPRECATED
sub PUBLIC_FOLDER {
    # Always is_public => 1
    return $_DFN->PUBLIC_FOLDER_ROOT;
}

sub append_content {
    my($self, $content) = @_;
#TODO: Optimize to only append the file.
    return $self->update_with_content({
	user_id => $self->get('user_id'),
    }, \(${$self->get_content} . $$content));
}

sub copy_deep {
    my($self, $dest) = @_;
#TODO: Die if $dest _in_version
    my($size) = 0;
    return _copy(
	$self, {
	    %{_copy_attrs($self)},
	    map(exists($dest->{$_}) ? ($_ => $dest->{$_}) : (),
		qw(path realm_id user_id is_read_only is_public)),
	},
	undef,
	\$size,
    );
}

sub create {
    my($self, $values) = @_;
    my($v) = {%$values};
    my($c) = delete($v->{_content});
    _create($self, $v);
    return $v->{is_folder} ? $self : _write($self, defined($c) ? $c : \(''));
}

sub create_folder {
    my($self, $values) = @_;
    return shift->create({
	%$values,
	is_folder => 1,
    });
}

sub create_or_update_with_content {
    my($self, $values) = _with_content(@_);
    return $self->create_or_update($values);
}

sub create_with_content {
    my($self, $values) = _with_content(@_);
    return $self->create($values);
}

sub delete {
    my($self, $values) = _delete_args(@_);
    return 0
	unless $self;
    $self->throw_die(FORBIDDEN => {
	entity => $self->get('path'),
	message => 'folder is not empty',
    }) unless $self->is_empty;
    return _delete_one($self, $values);
}

sub delete_all {
    my($self, $query) = @_;
    $self = $self->new
	unless $self->is_instance;
    my($req) = $self->get_request;
    my($realm);
    if ($query && $query->{realm_id}) {
 	$realm = $req->get('auth_realm');
 	delete($query->{realm_id});
    }
    $self->die('unsupported with a query: ', $query)
	if $query && %$query;
    my($op) = sub {
	my($d) = _realm_dir($req->get('auth_id'));
	_txn($self, _search_delete($self, [delete => glob("$d/[0-9]*[0-9]")]));
	return $self->SUPER::delete_all;
    };
    return $realm ? $req->with_realm($realm, $op) : $op->();
}

sub delete_deep {
    my($self, $values) = _delete_args(@_);
    return 0
	unless $self;
    return _delete_one($self, $values)
	unless $self->get('is_folder');
    my($count) = 0;
    my($v) = $self->get_shallow_copy;
    foreach my $child (@{
	$self->new_other('RealmFileList')->map_iterate(
	    sub {shift->get_model('RealmFile')},
	    unauth_iterate_start => {
		auth_id => $v->{realm_id},
		path_info => $v->{path},
	    },
	),
    }) {
	$count += $child->delete_deep(_child_attrs($values, $self));
    }
    return $count +_delete_one($self, $values)
}

sub get_content {
    return _read(_filename(@_));
}

sub get_content_length {
    return -s shift->get_os_path(@_);
}

sub get_content_type {
    my(undef, undef, $prefix, $values) = shift->internal_get_target(@_);
    return Bivio::MIME::Type->from_extension($values->{$prefix . 'path'});
}

sub get_handle {
    my($self) = shift;
    my($os_path) = $self->get_os_path(@_);
    return IO::File->new($os_path, 'r')
	|| ($self->internal_get_target(@_))[1]->throw_die(IO_ERROR => {
	    entity => $os_path,
	    message => "$!",
	});
}

sub get_os_path {
    # Use with caution: May be transaction file or actual file
    return _os_path(_filename(@_));
}

sub handle_commit {
    return _txn_do(
	shift(@_),
	sub {
	    my($file, $txn_file) = @_;
	    return unless -r $txn_file;
	    _trace('rename(', $txn_file, ', ', $file, ')') if $_TRACE;
	    unlink($file);
	    Bivio::IO::File->rename($txn_file, $file);
	    return;
	},
	sub {
	    my($file, $txn_file) = @_;
	    _trace('unlink(', $txn_file, ', ', $file, ')') if $_TRACE;
	    unlink($file);
	    unlink($txn_file);
	    return;
	}
    );
}

sub handle_config {
    my($proto, $cfg) = @_;
    $proto->use($cfg->{search_class})
	if $cfg->{search_class};
    $_CFG = $cfg;
    return;
}

sub handle_rollback {
    return _txn_do(
	shift(@_),
	sub {
	    my(undef, $txn_file) = @_;
	    unlink($txn_file);
	    return;
	},
    );
}

sub init_realm {
    my($self) = shift;
    $self->die(DIE => {
	entity => \@_,
	message => 'init_realm must be called from within realm, use $req->with_realm',
    }) if @_;
    return $self->create_folder({
	path => '/',
	realm_id => $self->get_request->get('auth_id'),
    });
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
	as_string_fields => [qw(realm_id path)],
        columns => {
            realm_file_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
	    folder_id => ['PrimaryId', 'NONE'],
	    # Don't cascade when User.user_id is deleted
	    user_id =>  ['PrimaryId', 'NOT_NULL'],
            modified_date_time => ['DateTime', 'NOT_NULL'],
	    is_folder => ['Boolean', 'NOT_NULL'],
	    is_public => ['Boolean', 'NOT_NULL'],
	    is_read_only => ['Boolean', 'NOT_NULL'],
            path => ['FilePath', 'NOT_NULL'],
            path_lc => ['FilePath', 'NOT_NULL'],
        },
        auth_id => 'realm_id',
    });
}

sub internal_prepare_query {
    my($self, $query) = @_;
    foreach my $k (keys(%{_child_attrs($query)})) {
	delete($query->{$k});
    }
    # Only load by path_lc, and convert from_literal (which is idempotent)
    if (exists($query->{path})) {
	my($p) = delete($query->{path});
	$query->{path_lc} = $p
	    unless exists($query->{path_lc});
    }
    if (exists($query->{path_lc})) {
	# The value won't be found if it is illegal; Don't call parse_path
	my($p, $e) = $_FP->from_literal($query->{path_lc});
	_trace($query, ': path error ', $e)
	    if $e && $_TRACE;
	$query->{path_lc} = lc($p)
	    if $p;
    }
    _trace($query) if $_TRACE;
    return shift->SUPER::internal_prepare_query(@_);
}

sub internal_unique_load_values {
    my($self, $values) = @_;
    return {
	map(($_ => $values->{$_} || return),
	    'realm_id',
	    (grep($values->{$_}, qw(path_lc path)))[0] || return,
	),
    };
}

sub is_empty {
    _assert_loaded(@_);
    my($self) = @_;
    return 1
	unless $self->get('is_folder');
    my($got_one) = 0;
    $self->new_other('RealmFileList')->do_iterate(
	sub {$got_one++},
	{path_info => $self->get('path')},
    );
    return $got_one ? 0 : 1;
}

sub parse_path {
    my($proto, $path, $model) = @_;
    my($p, $e) = $_FP->from_literal(defined($path) ? $path : '/');
    ($model || $proto)->throw_die(
	CORRUPT_QUERY => {
	    message => 'invalid path',
	    type_error => $e,
	    entity => $path,
        },
    ) if $e;
    return $p ? $p : '/';
}

sub unauth_delete {
    # We don't support this to avoid the 'rm -rf /' problem that Unix has.
    # It's technically feasible, but not something you ever want to do.
    die('unsupported');
}

sub update {
    _assert_loaded(@_);
    my($self, $new_values) = @_;
    $self->throw_die(INVALID_OP => 'may not modify "is_folder"')
	if exists($new_values->{is_folder})
	&& $self->get('is_folder') ne $new_values->{is_folder};
    $self->throw_die(FORBIDDEN => 'may not change root path')
	if $self->get('path') eq '/' && exists($new_values->{path})
	&& ($new_values->{path} || 'invalid path') ne '/';
    $self->throw_die(FORBIDDEN => 'public files must live under /Public')
 	if $new_values->{is_public}
	&& ($new_values->{path}
	    || $self->get('path')) !~ m{^@{[$self->PUBLIC_FOLDER]}($|/)}oi;
#TODO: Die if new path _in_version
    return _update($self, {
	map(($_ => $self->get($_)),
 	    qw(is_folder path realm_id is_public is_read_only)),
 	user_id => $self->get_request->get('auth_user_id') ||
 	    $self->get('user_id'),
	%$new_values,
    });
}

sub update_with_content {
    my($self, $values) = _with_content(@_);
    return $self->update($values);
}

sub _assert_loaded {
    my($self) = @_;
    $self->die('not loaded')
	unless $self->is_loaded;
    return;
}

sub _assert_not_root {
    my($self) = @_;
    $self->throw_die(FORBIDDEN => 'cannot perform operation on root')
	if $self->get('path') eq '/';
    return;
}

sub _assert_writable {
    my($self, $values) = @_;
    $self->throw_die(FORBIDDEN => 'file or folder is read-only')
	if $self->unsafe_get('is_read_only')
        && !$values->{override_is_read_only};
    return;
}

sub _child_attrs {
    my($v, $parent) = @_;
    return {
	map(($_ => $v->{$_}), grep(/^_|override/, keys(%$v))),
	$parent ? (_parent => $parent) : (),
    };
}

sub _copy {
    my($self, $values, $size) = @_;
    my($dst) = $self->new;
    _assert_writable($dst, $values);
    $dst->create_or_update({
	%{_verify_and_fix($dst, $values)},
	$self->get('is_folder') ? () : (_content => $self->get_content),
    });
    _trace($self, ' -> ', $dst, '=', $dst->get_shallow_copy) if $_TRACE;
    return
	unless $dst->get('is_folder');
    my($old_length) = length($self->get('path'));
    foreach my $src (@{
	$self->new_other('RealmFileList')->map_iterate(
	    sub {shift->get_model('RealmFile')},
	    unauth_iterate_start => {
		auth_id => $self->get('realm_id'),
		path_info => $self->get('path'),
	    },
	),
    }) {
	# Allow copy of a single file of any size above, but cummulative
	# copies have to blow up at some point.
	$src->throw_die(NO_RESOURCES => {message => 'copy too large'})
	    if ($$size += $src->get_content_length || 0) > 30_000_000;
	_copy(
	    $src,
	    {
		%{_copy_attrs($src)},
		%{_child_attrs($values, $dst)},
		map(($_ => $dst->get($_)), qw(realm_id user_id)),
		path => $dst->get('path')
		    . substr($src->get('path'), $old_length),
	    },
	    $size,
	);
    }
    return;
}

sub _copy_attrs {
    my($self) = @_;
    return {
	@{$self->map_each(
	    sub {
		my(undef, $k, $v) = @_;
		return grep(
		    $k =~ /$_/,
		    qw(is_read_only is_public realm_file_id),
		) ? () : ($k =~ /(\w+)$/, $v);
	    },
	)},
    };
}

sub _create {
    my($self, $values) = @_;
    my($req) = $self->get_request;
    $values->{realm_id} ||= $req->get('auth_id');
    $values->{user_id} ||= $req->get('auth_user_id');
    $self->internal_unload;
    my($v) = {
	$values->{path} eq '/' ? (is_public => 0, is_read_only => 0) : (),
	%{_verify_and_fix($self, $values)},
    };
    _trace($v) if $_TRACE;
    return $self->SUPER::create($v);
}

sub _delete_one {
    my($self, $values) = @_;
    _trace($self) if $_TRACE;
    return $self->SUPER::delete
	if $self->get('is_folder');
    my($p) = $self->get('path');
    if (_in_versions($p)) {
	_txn($self, _search_delete($self, [delete => _filename($self)]));
    }
    else {
	my($p) = $_FP->join($_FP->VERSIONS_FOLDER, $p);
	$self->clone->update({
	    path => _next_version($self->get('realm_id'), $p),
	    override_is_read_only => 1,
	});
    }
    return 1;
}

sub _delete_args {
    my($self, $values) = @_;
    my($load_args) = _non_child_attrs($values || {});
    ($self = $self->new)->unsafe_load($values)
	if %$load_args;
    return unless $self->is_loaded;
    _assert_not_root($self);
    _assert_writable($self, $values);
    return ($self,
        _verify_and_fix(
	    $self,
	    {
		%{$self->get_shallow_copy},
		%{_child_attrs($values)},
	    },
	),
    );
}

sub _filename {
    my(undef, $model, $prefix, $values) = shift->internal_get_target(@_);
    my($d, $f) = map($values->{"$prefix$_"}, qw(realm_id realm_file_id));
    my($res) = _realm_dir($d) . '/' .  $f;
    _trace($res) if $_TRACE;
    return $res;
}

sub _in_mail {
    my($path) = @_;
    return $path =~ m{^\Q@{[$_FP->MAIL_FOLDER]}\E(?:/|$)}i ? 1 : 0;
}

sub _in_public {
    my($path) = @_;
    return $path =~ m{^\Q@{[$_FP->PUBLIC_FOLDER]}\E(?:/|$)}i ? 1 : 0;
}

sub _in_versions {
    my($path) = @_;
    return $path =~ m{^\Q@{[$_FP->VERSIONS_FOLDER]}\E(?:/|$)}i ? 1 : 0;
}

sub _next_version {
    my($rid, $p) = @_;
    my($base) = lc($p);
    my($suffix) = $_FP->get_suffix($base);
    if (length($suffix)) {
	$suffix = ".$suffix";
        substr($base, -length($suffix)) = '';
    }
    my($max) = 0;
    Bivio::SQL::Connection->do_execute(
	sub {
	    my($v) = shift->[0] =~ /^\Q$base\E;(\d+)\Q$suffix\E$/s;
	    $max = $v
		if defined($v) && $v > $max;
	    return 1;
	},
	q{SELECT path_lc FROM realm_file_t
        WHERE realm_id = ?
        AND SUBSTRING(path_lc FROM 1 FOR LENGTH(?) + 1) = ?
        AND POSITION('/' IN SUBSTRING(path_lc FROM LENGTH(?) + 2)) = 0},
        [$rid, $base, $base . ';', $base]);
    substr($p, length($base), 0) = ';' . ++$max;
    return $p;
}
sub _non_child_attrs {
    my($v) = @_;
    return {map(($_ => $v->{$_}), grep(!/^_|override/, keys(%$v)))};
}

sub _os_path {
    my($file) = @_;
    my($txn_file) = _txn_filename($file);
    Bivio::Die->die(IO_ERROR => {
	entity => $file,
	message => 'file has been deleted in this transaction',
    }) if -l $txn_file && -e $txn_file;
    return  -r $txn_file ? $txn_file : $file;
}

sub _read {
    return Bivio::IO::File->read(_os_path(shift(@_)));
}

sub _realm_dir {
    my($realm_id) = @_;
    return $_F->absolute_path("RealmFile/$realm_id");
}

sub _search_delete {
    my($self, $cmds) = @_;
    $_CFG->{search_class}->map_invoke(
	'delete_realm_file',
	[map(/(\w+)$/, @$cmds[1..$#$cmds])],
	undef,
	[$self->get_request],
    ) if $_CFG->{search_class};
    return $cmds;
}

sub _search_update {
    my($self) = @_;
    $_CFG->{search_class}->update_realm_file($self, $self->get_request)
	if $_CFG->{search_class};
    return $self;
}

sub _touch_parent {
    my($self, $values) = @_;
    return
	if $values->{_touch_parent} || $values->{path} eq '/';
    my($parent) = $self->new_other;
    my($parent_path) = ($values->{path} =~ m{(^/.+)/})[0] || '/';
    return $parent->create_folder({
	map(($_ => $values->{$_}), qw(user_id realm_id override_is_read_only)),
	path => $parent_path,
    }) unless $parent->unauth_load({
	realm_id => $values->{realm_id},
	path => $parent_path,
    });
    $parent->throw_die(IO_ERROR => {
	entity => $values->{path},
	message => 'parent exists as a file, but must be a folder',
    }) unless $parent->get('is_folder');
    # match case of folder that exists
    substr($values->{path}, 0, length($parent->get('path')))
	= $parent->get('path');
    if ($values->{_update}) {
	return $parent
	    unless $self->get('path') ne $values->{path}
		|| $self->get('realm_id') ne $values->{realm_id};
    }
    # touch director(ies); also asserts writable
    my($v) = _child_attrs($values);
    delete($v->{_parent});
    delete($v->{_update});
    _touch_parent(
	$self, {map(($_ => $self->get($_)), qw(realm_id path)), %$v},
    ) if $values->{_update};
    return $parent->update({%$v, _touch_parent => 1});
}

sub _txn {
    my($self) = shift;
    # Need to create $new, because callers may modify or re-use $self after call
    my($new) = $self->new;
    $new->[$_IDI] = [@_];
    $new->get_request->push_txn_resource($new);
    return _txn_do(
	$new,
        sub {
	    my($file, $txn_file, $content) = @_;
	    Bivio::IO::File->mkdir_parent_only($txn_file);
	    unlink($txn_file);
	    Bivio::IO::File->write($txn_file, $content);
	    return;
	},
	sub {
	    my($file, $txn_file) = @_;
	    Bivio::IO::File->mkdir_parent_only($txn_file);
	    unlink($txn_file);
	    symlink($_DELETED_SENTINEL, $txn_file);
	    return;
	},
    );
}

sub _txn_do {
    my($self, $create, $delete) = @_;
    return unless ref($self) and my $cmds = $self->[$_IDI];
    $delete ||= $create;
    foreach my $cmd (@$cmds) {
	my($op, @args) = @$cmd;
	if ($op eq 'create') {
	    # First time we get rid of content, which may be large.
	    pop(@$cmd)
		if $cmd->[2];
	    $create->($args[0], _txn_filename($args[0]), $args[1]);
	}
	elsif ($op eq 'delete') {
	    foreach my $f (@args) {
		$delete->($f, _txn_filename($f));
	    }
	}
	else {
	    Bivio::Die->die($cmd, ': program error');
	}
    }
    return;
}

sub _txn_filename {
    my($filename) = @_;
    $_TXN_PREFIX ||= '.' . Bivio::IO::File->unique_name_for_process . '#';
    $filename =~ s{(?=[^/]+$)}{$_TXN_PREFIX}o;
    return $filename;
}

sub _update {
    my($self, $values) = @_;
    _assert_writable($self, $values);
    my($c) = delete($values->{_content});
    my($method) = 'SUPER::update';
    my($versioned) = $c && _version($self, $self->get_shallow_copy);
    if ($versioned) {
	$method = 'SUPER::create';
	delete($values->{realm_file_id});
    }
    my($old_realm) = $self->get('realm_id');
    my($old_filename) = _filename($self);
    my($old_path) = $self->get('path');
    $values->{path} = $values->{_parent}->get('path')
	. substr($self->get('path'), $values->{old_path_length})
	if $values->{_parent} && $values->{old_path_length};
    $self->$method(
	_verify_and_fix($self, {
	    realm_id => $old_realm,
	    path => $old_path,
	    %$values,
	    _update => 1,
	}));
    _trace($old_realm, ', ', $old_path, ' -> ', $self->get_shallow_copy)
	if $_TRACE;
    my($new_filename) = _filename($self);
    unless ($self->get('is_folder')) {
	_txn($self,
	     # delete must come first for search to work right
	     [delete => $old_filename],
	     $c ? () : [create => $new_filename, _read($old_filename)],
	) unless $versioned || $new_filename eq $old_filename;
	return defined($c) ? _write($self, $c) : _search_update($self);
    }
    my($new_path) = $self->get('path');
    return $self
	if $old_realm eq $self->get('realm_id') && $old_path eq $new_path;
    foreach my $child (@{
	$self->new_other('RealmFileList')->map_iterate(
	    sub {shift->get_model('RealmFile')},
	    unauth_iterate_start => {
		auth_id => $old_realm,
		path_info => $old_path,
	    },
	),
    }) {
	_update($child, {
	    %{$child->get_shallow_copy},
	    realm_id => $self->get('realm_id'),
	    %{_child_attrs($values, $self)},
	    old_path_length => length($old_path),
	});
    }
    return $self;
}

sub _verify {
    my($self, $values) = @_;
    my($p) = $values->{path_lc}
	= lc($values->{path} = $self->parse_path($values->{path}));
    $values->{is_read_only} = 1
	if _in_versions($p) || _in_mail($p);
    $values->{is_public} = _in_public($p) ? 1 : 0;
    $values->{modified_date_time} ||= Bivio::Type::DateTime->now;
    return $values;
}

sub _verify_and_fix {
    my($self, $values) = @_;
    $values = _verify($self, {%$values});
    return $values
	unless $values->{_parent} ||= _touch_parent($self, $values);
    foreach my $k (qw(is_public is_read_only)) {
	$values->{$k} = $values->{_parent}->get($k)
	    unless exists($values->{$k});
    }
    $values->{folder_id} = $values->{_parent}->get('realm_file_id');
    _trace($values) if $_TRACE;
    return $values;
}

sub _version {
    my($self, $values) = @_;
    return $self->new->delete({
	%$values,
	override_is_read_only => 1,
	is_folder => 0,
	realm_file_id => $self->get('realm_file_id'),
	_update => 1,
    });
}

sub _with_content {
    my($self, $values, $content) = @_;
    return ($self, {
	$values ? %$values : (),
	is_folder => 0,
	_content => $content,
    });
}

sub _write {
    my($self, $content) = @_;
    $self->die('cannot put content on a directory')
	if $self->get('is_folder');
    $self->throw_die(DIE => {
	entity => $content,
	message => 'content must be a defined scalar_ref',
    }) unless ref($content) eq 'SCALAR' && defined($$content);
    _txn($self, [create => _filename($self), $content]);
    return _search_update($self);
}

1;
