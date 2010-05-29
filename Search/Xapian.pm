# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Xapian;
use strict;
use Bivio::Base 'Search.None';
use Bivio::IO::Trace;
use File::Spec ();
use Search::Xapian ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_F) = b_use('IO.File');
my($_P) = b_use('Search.Parser');
my($_A) = b_use('IO.Alert');
my($_M) = b_use('Biz.Model');
my($_LOCK_ID);
#TODO: What is the actual max term length; I've seen errors in the 400 range
my($_MAX_WORD) = 240;
my($_LENGTH) = b_use('Type.PageSize')->get_default;
my($_STEMMER) = Search::Xapian::Stem->new('english');
my($_FLAGS) = 0;
foreach my $f (qw(FLAG_BOOLEAN FLAG_PHRASE FLAG_LOVEHATE FLAG_WILDCARD)) {
    $_FLAGS |= Search::Xapian->$f();
}
my($_VALUE_MAP) = {
    simple_class => 0,
    'RealmOwner.realm_id' => 1,
    primary_id => 2,
    title => 3,
    excerpt => 4,
    author_user_id => 5,
    author => 6,
    author_email => 7,
};
b_use('IO.Config')->register(my $_CFG = {
    db_path => b_use('Biz.File')->absolute_path('Xapian'),
});
my($_L) = b_use('Model.Lock');

sub EXEC_REALM {
    return 'xapian_exec';
}

sub acquire_lock {
    my($proto, $req) = @_;
    return $_M->new($req, 'Lock')->acquire_unless_exists(_lock_id($proto, $req));
}

sub delete_model {
    my($proto, $req, $model_or_id) = @_;
    $req->perf_time_op(__PACKAGE__, sub {
	my($id) = ref($model_or_id) ? $model_or_id->get_primary_id : $model_or_id;
	return _queue(
	    $proto,
	    $req,
	    [delete_model => $id],
	) unless ref($proto);
	_delete($proto, _primary_term($id));
	return;
    });
    return;
}

sub destroy_db {
    my($proto, $req) = @_;
    $proto->acquire_lock($req);
    $_A->info($_CFG->{db_path}, ': deleting');
    $_F->rm_rf($_CFG->{db_path});
    return;
}

sub execute {
    my($proto, $req) = @_;
    my($self) = $req->get(ref($proto) || $proto);
    $proto->acquire_lock($req);
    unlink(File::Spec->catfile($_CFG->{db_path}, 'db_lock'));
    $req->perf_time_op(__PACKAGE__, sub {
        my($db) = Search::Xapian::WritableDatabase->new(
	    $_CFG->{db_path}, Search::Xapian->DB_CREATE_OR_OPEN);
	$self->put(db => $db);
	foreach my $op (@{$self->get('ops')}) {
	    _trace($op) if $_TRACE;
	    my($method) = shift(@$op);
	    $self->$method($req, @$op);
	}
	$self->delete('db');
	$db->flush;
    });
    return 0;
}

sub get_values_for_primary_id {
    my($proto, $primary_id, $model) = @_;
    my($req) = $model->req;
    return $req->perf_time_op(__PACKAGE__, sub {
	if (my $query_result = _find($primary_id)) {
	    if (my $res = _query_result($proto, $query_result, $req)) {
		return $res;
	    }
	}
    }) || return shift->SUPER::get_values_for_primary_id(@_);
}

sub handle_commit {
    my($self, $req) = @_;
    if ($req->isa('Bivio::Agent::HTTP::Request')) {
	b_use('AgentJob.Dispatcher')->enqueue(
	    $req,
	    'JOB_XAPIAN_COMMIT',
	    {
		ref($self) => $self,
		auth_id => _lock_id($self, $req),
		auth_user_id => undef,
	    },
	);
    }
    else {
	$req->put(ref($self) => $self);
	$self->execute($req);
    }
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub handle_rollback {
    return;
}

sub update_model {
    my($proto, $req) = (shift, shift);
    my($model) = @_;
    return _queue(
	$proto,
	$model->get_request,
	[update_model => $model->simple_package_name, $model->get_primary_id],
    ) unless ref($proto);
    my($class, $id) = @_;
    $model = $_M->new($req, $class);
    return
	unless $model->unauth_load({$model->get_primary_id_name => $id});
    if ($model->can('is_searchable') && !$model->is_searchable) {
	# need to remove it, ex. archived searchable file
	$proto->delete_model($req, $model);
	return;
    }
    $req->perf_time_op(__PACKAGE__, sub {
	_replace(
	    $proto,
	    $req,
	    $model,
	    $_P->xapian_terms_and_postings($model),
	);
	return;
    });
    return;
}

sub query {
    my($proto, $a) = @_;
    $proto->acquire_lock($a->{req});
    my($q);
    my($res) = $a->{req}->perf_time_op(__PACKAGE__, sub {
	$a->{offset} ||= 0;
	$a->{length} ||= $_LENGTH;
	$a->{private_realm_ids} ||= [];
	$a->{public_realm_ids} ||= [];
	unless (@{$a->{private_realm_ids}} || @{$a->{public_realm_ids}}
		    || $a->{want_all_public}) {
	    _trace($a, ': no realms and not public') if $_TRACE;
	    return [];
	}
	my($db) = Search::Xapian::Database->new($_CFG->{db_path});
	my($qp) = Search::Xapian::QueryParser->new;
	$qp->set_stemmer($_STEMMER);
	$qp->set_stemming_strategy(Search::Xapian::STEM_ALL());
	$qp->set_default_op(Search::Xapian->OP_AND);
	my($phrase) = $a->{phrase};
	$phrase =~ s/_/ /g;
	$q = Search::Xapian::Query->new(
	    Search::Xapian->OP_AND,
	    $qp->parse_query($phrase, $_FLAGS),
	    Search::Xapian::Query->new(
		Search::Xapian->OP_OR,
		map(Search::Xapian::Query->new("XREALMID:$_"),
		    @{$a->{private_realm_ids}}),
		map(
		    Search::Xapian::Query->new(
			Search::Xapian->OP_AND,
			Search::Xapian::Query->new("XREALMID:$_"),
			Search::Xapian::Query->new('XISPUBLIC:1'),
		    ),
		    @{$a->{public_realm_ids}},
		),
		$a->{want_all_public}
		    ? Search::Xapian::Query->new('XISPUBLIC:1')
		    : (),
	    ),
	);
	# Need to make a copy.  Xapian is using the Tie interface, and it's
	# implementing it in a strange way.
	my(@res) = $db->enquire($q)->matches($a->{offset}, $a->{length});
	return [map(_query_result($proto, $_, $a->{req}), @res)];
    });
    _trace([$q->get_terms], '->[', $a->{offset}, '..',
        $a->{offset} + $a->{length}, ']: ', $res,
    ) if $_TRACE;
    return $res;
}

sub _delete {
    my($self, $primary_term, $req) = @_;
    return
	unless $primary_term;
    $self->get('db')->delete_document_by_term($primary_term);
    return;
}

sub _find {
    my($primary_id) = @_;
    return (
	Search::Xapian::Database->new($_CFG->{db_path})
	    ->enquire(Search::Xapian::Query->new(_primary_term($primary_id)))
	    ->matches(0, 1),
    )[0];
}

sub _lock_id {
    my($proto, $req) = @_;
    return $_LOCK_ID ||= $_M->new($req, 'RealmOwner')
	->unauth_load_or_die({name => $proto->EXEC_REALM})
	->get('realm_id');
}

sub _primary_term {
    my($id) = @_;
    return "Q$id";
}

sub _queue {
    my($proto, $req, $op) = @_;
    my($self) = $req->unsafe_get_txn_resource($proto);
    $req->push_txn_resource($self = $proto->new({ops => []}))
	unless $self;
    _trace($op) if $_TRACE;
    push(@{$self->get('ops')}, $op);
    return;
}

sub _query_author {
    my($proto, $req, $res) = @_;
    return
	unless _query_model($proto, $res, $req);
    return $res
	if defined($res->{author}) && length($res->{author})
	|| !(my $uid = $res->{author_user_id});
    my($e) = $_M->new($req, 'Email');
    my($ro) = $_M->new($req, 'RealmOwner');
    return $res
	unless $e->unauth_load({realm_id => $uid})
	&& $ro->unauth_load({realm_id => $uid});
    $res->{author_email} = $e->get('email');
    $res->{author} = $ro->get('display_name');
    return $res;
}

sub _query_model {
    my($proto, $res, $req) = @_;
    my($m) = $_M->new($req, $res->{simple_class});
    # There's a possibility that the the search db is out of sync with db
    return 0
	unless $m->unauth_load({$m->get_primary_id_name => $res->{primary_id}});
    $res->{model} = $m;
    unless ($res->{author_user_id}) {
	my($p) = $proto->excerpt_model($m);
	foreach my $field (keys(%$_VALUE_MAP)) {
	    $res->{$field} = $p->get($field);
	}
    }
    return 1;
}

sub _query_result {
    my($proto, $query_result, $req) = @_;
    my($d) = $query_result->get_document;
    return _query_author($proto, $req, {
	map({
	    my($m) = "get_$_";
	    ($_  => $query_result->$m());
	} qw(percent rank collapse_count)),
	simple_class => $d->get_value(0),
	'RealmOwner.realm_id' => $d->get_value(1),
	primary_id => $d->get_value(2),
	map(($_ => $d->get_value($_VALUE_MAP->{$_})), keys(%$_VALUE_MAP)),
    });
}

sub _replace {
    my($self, $req, $model, $parser) = @_;
    return
	unless $parser;
    my($doc) = Search::Xapian::Document->new;
    $doc->set_data('');
    while (my($field, $index) = each(%$_VALUE_MAP)) {
        my($v) = $parser->get($field);
	$doc->add_value($index, defined($v) ? $v : '');
    }
    my($primary_term) = _primary_term($model->get_primary_id);
    foreach my $t ($primary_term, @{$parser->get('terms')}) {
	$doc->add_term(substr($t, 0, $_MAX_WORD));
    }
    my($i) = 1;
    foreach my $p (@{$parser->get('postings')}) {
	my($s) = $_STEMMER->stem_word($p);
	next if length($p) > $_MAX_WORD;
	$doc->add_posting("$p", $i)
	    unless $s eq $p;
	$doc->add_posting($s, $i++);
    }
    $self->get('db')->replace_document_by_term($primary_term, $doc);
    return;
}

1;
