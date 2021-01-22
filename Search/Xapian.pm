# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Xapian;
use strict;
use Bivio::Base 'Search.None';
use Bivio::IO::Trace;
use File::Spec ();
use Search::Xapian ();

our($_TRACE);
my($_F) = b_use('IO.File');
my($_P) = b_use('Search.Parser');
my($_A) = b_use('IO.Alert');
my($_M) = b_use('Biz.Model');
my($_LOCK_ID);
#TODO: What is the actual max term length; I've seen errors in the 400 range
my($_MAX_WORD) = 80;
my($_LENGTH) = b_use('Type.PageSize')->get_default;
my($_STEMMER) = Search::Xapian::Stem->new('english');
my($_FLAGS) = 0;
foreach my $f (qw(FLAG_BOOLEAN FLAG_PHRASE FLAG_LOVEHATE FLAG_WILDCARD FLAG_PURE_NOT FLAG_PARTIAL)) {
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
    modified_date_time => [8, 9],
};
b_use('IO.Config')->register(my $_CFG = {
    db_path => b_use('Biz.File')->absolute_path('Xapian'),
    max_changesets => 10,
});
my($_L) = b_use('Model.Lock');
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');

sub EXEC_REALM {
    return 'xapian_exec';
}

sub acquire_lock {
    my($proto, $req) = @_;
    $_M->new($req, 'Lock')->acquire_unless_exists(_lock_id($proto, $req));
    unlink(File::Spec->catfile($_CFG->{db_path}, 'db_lock'));
    return;
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
    local($ENV{XAPIAN_MAX_CHANGESETS}) = $_CFG->{max_changesets};
    $req->perf_time_op(__PACKAGE__, sub {
	foreach my $op (@{$self->get('ops')}) {
	    _trace($op) if $_TRACE;
	    my($method) = shift(@$op);
	    $self->$method($req, @$op);
	}
    });
    return 0;
}

sub get_db_path {
    return $_CFG->{db_path};
}

sub get_stemmer {
    return $_STEMMER;
}

sub get_values_for_primary_id {
    my($proto) = shift;
    return $proto->unsafe_get_values_for_primary_id(@_)
	|| $proto->SUPER::get_values_for_primary_id(@_);
}

sub handle_prepare_commit {
    my($self, $req) = @_;
    if (b_use('AgentJob.Dispatcher')->can_enqueue_job($req)) {
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
    my($postings) = $_P->xapian_terms_and_postings($model);
    $req->perf_time_op(__PACKAGE__, sub {
	_replace(
	    $proto,
	    $req,
	    $model,
	    $postings,
	);
	return;
    });
    return;
}

sub query {
    my($proto, $attr) = @_;
    my($q);
    my($res) = $attr->{req}->perf_time_op(__PACKAGE__, sub {
	$attr->{offset} ||= 0;
	$attr->{length} ||= $_LENGTH;
	$attr->{private_realm_ids} ||= [];
	$attr->{public_realm_ids} ||= [];
        $attr->{percent_cuttoff} ||= 0;
        $attr->{weight_cutoff} ||= 0;
	unless (@{$attr->{private_realm_ids}} || @{$attr->{public_realm_ids}}
		    || $attr->{want_all_public}) {
	    _trace($attr, ': no realms and not public') if $_TRACE;
	    return [];
	}
        $proto->acquire_lock($attr->{req});
	my($qp) = Search::Xapian::QueryParser->new;
	$qp->set_stemmer($_STEMMER);
	$qp->set_stemming_strategy(Search::Xapian::STEM_ALL());
	$qp->set_default_op(Search::Xapian->OP_AND);
	my($db) = Search::Xapian::Database->new($proto->get_db_path);
	$qp->set_database($db);
	foreach my $field (keys(%$_VALUE_MAP)) {
            $qp->add_valuerangeprocessor(
                Search::Xapian::DateValueRangeProcessor->new(
                    $_VALUE_MAP->{$field}->[1],
                    1,
                    $_DT->now_as_year - 80
                ))
                if ref($_VALUE_MAP->{$field}) eq 'ARRAY';
	}
	my($phrase) = $attr->{phrase};
        my($elite_set) = $attr->{elite_set};
        my($main_query);
        b_die("phrase and elite set are mutually incompatible")
            if defined($phrase) && defined($elite_set);
        b_die("one of phrase or elite_set is required")
            unless defined($phrase) || defined($elite_set);
        if (defined($phrase)) {
            $phrase =~ s/_/ /g;
            $main_query = $qp->parse_query($phrase, $_FLAGS);
        }
        else {
            $main_query = Search::Xapian::Query->new(
                Search::Xapian->OP_ELITE_SET,
                map(Search::Xapian::Query->new($_),
                    @$elite_set));
        }
	$q = Search::Xapian::Query->new( Search::Xapian->OP_AND,
	    defined($elite_set)
                ? Search::Xapian::Query->new(
                    Search::Xapian->OP_ELITE_SET,
                    map(Search::Xapian::Query->new($_),
                        @$elite_set))
                : $qp->parse_query($phrase, $_FLAGS),
	    $attr->{simple_class}
	    	? Search::Xapian::Query->new('XSIMPLECLASS:' . lc($attr->{simple_class}))
	    	: (),
	    Search::Xapian::Query->new(
	    	Search::Xapian->OP_OR,
	    	map(Search::Xapian::Query->new("XREALMID:$_"),
	    	    @{$attr->{private_realm_ids}}),
	    	map(
	    	    Search::Xapian::Query->new(
	    		Search::Xapian->OP_AND,
	    		Search::Xapian::Query->new("XREALMID:$_"),
	    		Search::Xapian::Query->new('XISPUBLIC:1'),
	    	    ),
	    	    @{$attr->{public_realm_ids}},
	    	),
	    	$attr->{want_all_public}
	    	    ? Search::Xapian::Query->new('XISPUBLIC:1')
	    	    : (),
	    ),
	);
	# Need to make a copy.  Xapian is using the Tie interface, and it's
	# implementing it in a strange way.
        my($enq) = _read(enquire => $q);
        $enq->set_cutoff($attr->{percent_cutoff}, $attr->{weight_cutoff})
	    if $attr->{percent_cutoff} || $attr->{weight_cutoff};
	my(@res) = $enq->matches($attr->{offset}, $attr->{length});
	return [map(_query_result($proto, $_, $attr->{req}, $attr), @res)];
    });
    _trace([$q->get_terms], '->[', $attr->{offset}, '..',
        $attr->{offset} + $attr->{length}, ']: ', $res,
    ) if $_TRACE;
    return $res;
}

sub unsafe_get_values_for_primary_id {
    my($proto, $primary_id, $model, $attr) = @_;
    my($req) = $model->req;
    my($res);
    my($die) = Bivio::Die->catch_quietly(sub {
        $res = $req->perf_time_op(
	    __PACKAGE__,
	    sub {
		return undef
		    unless my $query_result = _find($proto, $req, $primary_id);
		return _query_result($proto, $query_result, $req, $attr || {})
		    || undef;
	    },
	);
	return;
    });
    return $res
	unless $die;
    b_warn($die->get('attrs')->{message});
    return undef;
}

sub _delete {
    my($self, $primary_term, $req) = @_;
    return
	unless $primary_term;
    _write($self, $req, delete_document_by_term => $primary_term);
    return;
}

sub _find {
    my($proto, $req, $primary_id) = @_;
    $proto->acquire_lock($req);
    return (
	_read(enquire => Search::Xapian::Query->new(_primary_term($primary_id)))
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
    my($proto, $req, $res, $attr) = @_;
    return $res
	unless _query_model($proto, $res, $req, $attr);
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
    my($proto, $res, $req, $attr) = @_;
    return 0
	if $attr->{no_model};
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
    my($proto, $query_result, $req, $attr) = @_;
    my($d) = $query_result->get_document;
    return _query_author(
	$proto,
	$req,
	{
	    map({
		my($m) = "get_$_";
		($_  => $query_result->$m());
	    } qw(percent rank collapse_count weight)),
	    simple_class => $d->get_value(0),
	    'RealmOwner.realm_id' => $d->get_value(1),
	    primary_id => $d->get_value(2),
	    map(($_ => $d->get_value(
                ref($_VALUE_MAP->{$_}) eq 'ARRAY'
                ? $_VALUE_MAP->{$_}->[0]
                : $_VALUE_MAP->{$_}
            )), keys(%$_VALUE_MAP)),
	},
	$attr,
    );
}

sub _read {
    my($op) = shift;
    # assumes lock is already acquired
    return Search::Xapian::Database->new($_CFG->{db_path})->$op(@_);
}

sub _replace {
    my($self, $req, $model, $parser) = @_;
    return
	unless $parser;
    $self->acquire_lock($req);
    my($doc) = Search::Xapian::Document->new;
    $doc->set_data('');
    while (my($field, $index) = each(%$_VALUE_MAP)) {
        my($v) = $parser->get($field);
        if (ref($index) eq 'ARRAY') {
            $doc->add_value($index->[1],  $_D->to_file_name($v));
            $index = $index->[0];
        }
	$doc->add_value($index, defined($v) ? $v : '');
    }
    my($primary_term) = _primary_term($model->get_primary_id);
    foreach my $t ($primary_term, @{$parser->get('terms')}) {
	$doc->add_term(substr($t, 0, $_MAX_WORD));
    }
    my($i) = 1;
    foreach my $p (@{$parser->get('postings')}) {
	next
	    if length($p) > $_MAX_WORD;
	my($s) = $_STEMMER->stem_word($p);
	$doc->add_posting($p, $i)
	    unless $s eq $p;
	$doc->add_posting($s, $i);
	foreach my $syn (@{$parser->xapian_posting_synonyms($s)}) {
	    $doc->add_posting($syn, $i);
	}
	$i++;
    }
    _write($self, $req, replace_document_by_term => $primary_term, $doc);
    return;
}

sub _write {
    my($proto, $req, $op) = (shift, shift, shift);
    $proto->acquire_lock($req);
    my($db) = Search::Xapian::WritableDatabase->new(
	$_CFG->{db_path}, Search::Xapian->DB_CREATE_OR_OPEN,
    );
    $db->$op(@_);
    $db->flush;
    return;
}

1;
