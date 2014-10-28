# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TaskRateLimit;
use strict;
use Bivio::Base 'Biz.PropertyModel';
use Digest::MD5 ();
b_use('IO.ClassLoaderAUTOLOAD');
b_use('IO.Trace');

my($_IDI) = __PACKAGE__->instance_data_index;
my($_COOKIE_KEY) = 'b_trl';
my($_REQ_KEY) = __PACKAGE__ . '.queue';
IO_Config()->register(my $_CFG = {
    register_with_agent_task => 0,
    buckets => [
	# [re, count, seconds]
	[qr{^User-.+}, 5, 1],
#TODO: How many requests per second for a task?
#	[qr{Task-LOGIN}, 5, 1],
	[qr{^Task-.+}, 20, 1],
	[qr{^Client-.+}, 20, 1],
    ],
});
our($_TRACE);

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = {
	register_with_agent_task => $cfg->{register_with_agent_task},
	buckets => [map(
	    +{
		regexp => $_->[0],
		allowance => $_->[1],
		seconds => $_->[2],
	    },
	    @{$cfg->{buckets}},
	)],
    };
    if ($_CFG->{register_with_agent_task}) {
	Type_DateTime()->register_with_agent_task;
	Agent_Task()->register(__PACKAGE__);
    }
    return;
}

sub handle_garbage_collector {
    my($self) = @_;
    $self->new_other('TaskRateLimitObsoleteList')
	->do_iterate(
	    sub {
		my($it) = @_;
		$it->delete({bucket_key => $it->get('bucket_key')});
		return 1;
	    },
	);
    return;
}

sub handle_pre_execute_task {
    my($proto, $task, $req) = @_;
    return
	if $req->unsafe_get($_REQ_KEY);
    $req->put_durable($_REQ_KEY => 1);
    return
	unless $req->are_defined(qw(uri auth_id));
    return _discard($proto, $task, $req)
	unless _buckets_ok($proto, $task, $req);
    return;
}

sub handle_process_cleanup {
    my($self, $req) = @_;
    my($fields) = $self->[$_IDI];
    return
	if $fields->{is_create} && _create($self, $req);
    _load_for_update($self);
    _trace($fields->{bucket_date_time}) if $_TRACE;
    _calculate($self);
    $fields->{bucket_date_time} = $fields->{now};
    $self->update(_values($fields));
    _trace($fields->{bucket_date_time}) if $_TRACE;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'task_rate_limit_t',
	columns => {
	    bucket_key => [qw(Line PRIMARY_KEY)],
	    bucket_allowance => [qw(Amount NOT_NULL)],
	    bucket_date_time => [qw(DateTime NOT_NULL)],
	},
    });
}

sub _is_bucket_allowance_exceeded {
    my($self) = _init(@_);
    return 0
	unless $self;
    return _calculate($self);
}

sub _buckets_ok {
    my($proto, $task, $req) = @_;
    my($now) = Type_DateTime()->now;
    my($too_many) = 0;
    foreach my $key (
	_key(Task => $task->get('id')->get_name),
	_key(User => _user($req)),
	_key(Client => $req->unsafe_get('client_addr')),
    ) {
	foreach my $bucket (@{$_CFG->{buckets}}) {
	    next
		unless $key =~ $bucket->{regexp};
	    _trace($bucket) if $_TRACE;
	    next
		unless my $x
		= _is_bucket_allowance_exceeded($proto, $key, $bucket, $now, $req);
	    b_warn($key, ': HTTP_TOO_MANY_REQUESTS: ', $bucket, ' ', $req)
		unless $too_many;
	    $too_many += $x;
	}
    }
    return !$too_many;
}

sub _calculate {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    my($d) = Type_DateTime()->diff_seconds($fields->{now}, $fields->{bucket_date_time});
    $fields->{bucket_allowance} += $d * ($fields->{count} / $fields->{seconds});
    $fields->{bucket_allowance} = $fields->{count}
	if $fields->{bucket_allowance} > $fields->{count};
    _trace({diff_seconds => $d, allowance => $fields->{bucket_allowance}}) if $_TRACE;
    return 1
	if $fields->{bucket_allowance} < 1;
    $fields->{bucket_allowance}--;
    return 0;
}

sub _cookie_key {
    my($cookie, $req) = @_;
    my($in) = $cookie->unsafe_get($_COOKIE_KEY) || 0;
    my($out) = $req->unsafe_get('auth_user_id')
	|| $in
	|| Agent_RequestId()->current($req);
    $cookie->put($_COOKIE_KEY => $out)
	unless $in eq $out;
    return $out;
}

sub _create {
    my($self, $req) = @_;
    my($fields) = $self->[$_IDI];
    _calculate($self);
    unless (Bivio_Die()->catch(
	sub {$self->create(_values($fields))},
    )) {
	_trace($self->get_shallow_copy) if $_TRACE;
	return 1;
    }
    _trace('create failed: rollback') if $_TRACE;
    Agent_Task()->rollback($req);
    return 0;
}

sub _discard {
    my($proto, $task, $req) = @_;
    b_warn($task, ': DISCARDED ', $req);
    return Action_EmptyReply()->execute(
	$req,
	'HTTP_TOO_MANY_REQUESTS',
	FacadeComponent_Text('http_too_many_requests'),
    );
}

sub _init {
    my($proto, $key, $bucket, $now, $req) = @_;
    my($self) = $proto->new($req);
    my($fields) = $self->[$_IDI] = {
	bucket_key => $key,
	bucket_allowance => $bucket->{allowance},
	bucket_date_time => $now,
	count => $bucket->{allowance},
	seconds => $bucket->{seconds},
	now => $now,
	is_create => 1,
    };
    $req->push_process_cleanup($self);
    return
	unless $self->unsafe_load({bucket_key => $fields->{bucket_key}});
    $fields->{is_create} = 0;
    _update_fields($self);
    return $self;
}

sub _key {
    my($label, $key) = @_;
    return
	unless $key;
    return "$label-$key";
}

sub _load_for_update {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    my($row) = SQL_Connection()->execute_one_row_hashref(
	"SELECT bucket_key,
         bucket_allowance,
         @{[Type_DateTime()->from_sql_value('bucket_date_time')]} as bucket_date_time
         FROM task_rate_limit_t
         WHERE bucket_key = ?
         FOR UPDATE",
	[$fields->{bucket_key}],
	$self,
    );
    $self->load_from_properties({%$row});
    _update_fields($self);
    return;
}

sub _no_cookie_key {
    my($req) = @_;
    return
	unless my $r = $req->unsafe_get('r');
    return
	unless my $ip = $req->unsafe_get('client_addr');
    return $ip
	unless my $ua = $r->header_in('user-agent');
    return $ip . Digest::MD5::md5_hex($ua);
}

sub _update_fields {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $self->map_each(
	sub {
	    my(undef, $k, $v) = @_;
	    $fields->{$k} = $v;
	    return;
	},
    );
    _trace($self->get_shallow_copy) if $_TRACE;
    return;
}

sub _user {
    my($req) = @_;
    return _no_cookie_key($req)
	unless my $cookie = $req->unsafe_get('cookie');
    return _cookie_key($cookie, $req);
}

sub _values {
    my($fields) = @_;
    return {map(
	($_ => $fields->{$_}),
	grep($_ =~ /^bucket_/, keys(%$fields)),
    )};
}

1;
