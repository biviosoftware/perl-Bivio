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
    $self->load(@_)
	unless $self->is_loaded;
    my($p) = _path($self);
    _txn($self, sub {
	# Don't check for errors, may not exist
	unlink($p);
    }) unless $self->get('is_folder');
    return $self->SUPER::delete;
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

sub get_content {
    my($self) = @_;
    return _f($self)->{content} ||= Bivio::IO::File->read(_path($self));
}

sub get_content_length {
    my($self) = @_;
    return _f($self)->{content_length} ||= -s $self->get_handle;
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

sub map_folder {
    my($self, $op) = @_;
    $self->die('not a folder')
	unless $self->get('is_folder');
    my($p) = $self->get('path_lc');
    $p .= '/'
	if $p ne '/';
    my($re) = qr{^\Q$p\E[^/]+$};
    $self->new->map_iterate(sub {
       my($it) = @_;
       return $it->get('path') =~ $re ? $op->($it) : ();
    }, 'path_lc', {
	map(($_ => $self->get($_)),
	    $self->get('is_public') ? 'is_public' : (),
	    'volume',
	    'realm_id',
	),
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
    my($o) = _path($self);
    my(@res) = $self->SUPER::update(_fix_values($self, $values));
    my($n) = _path($self);
    _txn($self, sub {
        Bivio::IO::File->rename($o, $n);
    }) unless $n eq $o;
    return @res;
}

sub _create {
    my($self, $values, $is_folder) = @_;
    my($req) = $self->get_request;
    # You must not reuse $self after this call
    $values->{is_folder} = $is_folder;
    $values->{is_public} ||= 0;
    return $self->SUPER::create(_fix_values($self, $values));
}

sub _f {
    return (shift->[$_IDI] ||= {});
}

sub _fix_values {
    my($self, $values) = @_;
    my($req) = $self->get_request;
    $values->{realm_id} ||= $req->get('auth_id');
    $values->{modified_date_time} ||= Bivio::Type::DateTime->now;
    $values->{user_id} ||= $req->get('auth_user_id');
    $values->{path_lc} = lc(
	$values->{path} = my $p = $_P->from_literal_or_die($values->{path}));
    unless ($p eq '/') {
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
	elsif (!$new->get('is_folder')) {
	    $new->throw_die(IO_ERROR => {
		entity => $values->{path},
		message => 'parent exists as a file, but must be a folder',
	    });
	}
    }
    return $values;
}

sub _path {
    my($self) = @_;
    return _f($self)->{path_lc} ||= _realm_dir($self->get('realm_id'))
	. '/'
	. lc($self->get('volume')->get_name)
	. '/'
	.  $self->get('realm_file_id')
	. $_P->to_os($self->get('path_lc'));
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

1;
