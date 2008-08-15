# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Xapian;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::IO::Trace;
use File::Spec ();
use Search::Xapian ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
#TODO: What is the actual max term length; I've seen errors in the 400 range
my($_MAX_WORD) = 240;
my($_LENGTH) = __PACKAGE__->use('Type.PageSize')->get_default;
my($_STEMMER) = Search::Xapian::Stem->new('english');
my($_FLAGS) = 0;
foreach my $f (qw(FLAG_BOOLEAN FLAG_PHRASE FLAG_LOVEHATE FLAG_WILDCARD)) {
    $_FLAGS |= Search::Xapian->$f();
}
__PACKAGE__->use('IO.Config')->register(my $_CFG = {
    db_path => __PACKAGE__->use('Biz.File')->absolute_path('Xapian'),
});
my($_F) = __PACKAGE__->use('IO.File');
my($_L) = __PACKAGE__->use('Model.Lock');
my($_GENERAL_ID) = __PACKAGE__->use('Auth.Realm')->get_general->get('id');
my($_MRF) = __PACKAGE__->use('Model.RealmFile');
my($_P) = __PACKAGE__->use('Search.Parser');
my($_A) = __PACKAGE__->use('IO.Alert');
my($_M) = b_use('Biz.Model');

sub delete_model {
    my($proto, $req, $model_or_id) = @_;
    my($id) = ref($model_or_id) ? $model_or_id->get_primary_id : $model_or_id;
    return _queue(
	$proto,
	$req,
	[delete_model => $id],
    ) unless ref($proto);
    _delete($proto, 'Q' . $id);
    return;
}

sub destroy_db {
    my(undef, $req) = @_;
    Bivio::Die->die('general lock must be acquired')
	unless $_L->new($req)->is_general_acquired;
    $_A->info($_CFG->{db_path}, ': deleting');
    $_F->rm_rf($_CFG->{db_path});
    return;
}

sub excerpt_model {
    my(undef, $model) = @_;
    return $_P->new_excerpt($model);
}

sub execute {
    my($proto, $req) = @_;
    my($self) = $req->get(ref($proto) || $proto);
    $_L->new($req)->acquire_general_unless_exists;
    unlink(File::Spec->catfile($_CFG->{db_path}, 'db_lock'));
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
    return 0;
}

sub handle_commit {
    my($self, $req) = @_;
    if ($req->isa('Bivio::Agent::HTTP::Request')) {
	$self->use('AgentJob.Dispatcher')->enqueue(
	    $req,
	    'JOB_XAPIAN_COMMIT',
	    {
		ref($self) => $self,
		auth_id => $_GENERAL_ID,
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
    return unless $model->unauth_load({$model->get_primary_id_name => $id});
    if ($model->can('is_searchable') && !$model->is_searchable) {
	# need to remove it, ex. archived searchable file
	$proto->delete_model($req, $model);
	return;
    }
    _replace(
	$proto,
	$req,
	$model->simple_package_name,
	$model->get('realm_id'),
	$model->get_primary_id,
	$_P->xapian_terms_and_postings($model),
    );
    return;
}

sub query {
    my($proto, $a) = @_;
    $a->{offset} ||= 0;
    $a->{length} ||= $_LENGTH;
    $a->{private_realm_ids} ||= [];
    $a->{public_realm_ids} ||= [];
    b_die($a, ': invalid public_realm_ids, private_realm_ids, and want_public')
	unless @{$a->{private_realm_ids}} || @{$a->{public_realm_ids}}
	|| $a->{want_all_public};
    my($db) = Search::Xapian::Database->new($_CFG->{db_path});
    my($qp) = Search::Xapian::QueryParser->new;
    $qp->set_stemmer($_STEMMER);
    $qp->set_stemming_strategy(Search::Xapian::STEM_ALL);
    $qp->set_default_op(Search::Xapian->OP_AND);
    my($q) = Search::Xapian::Query->new(
 	Search::Xapian->OP_AND,
 	$qp->parse_query($a->{phrase}, $_FLAGS),
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
    my($res) = [map({
	my($x) = $_;
	my($d) = $x->get_document;
	+{
	    map({
		my($m) = "get_$_";
		($_  => $x->$m());
	    } qw(percent rank collapse_count)),
	    simple_class => $d->get_value(0),
	    'RealmOwner.realm_id' => $d->get_value(1),
	    primary_id => $d->get_value(2),
	};
    } $db->enquire($q)->matches($a->{offset}, $a->{length}))];
    _trace([$q->get_terms], '->[', $a->{offset}, '..',
        $a->{offset} + $a->{length}, ']: ', $res,
    ) if $_TRACE;
    return $res;
}

sub query_list_model_initialize {
    my(undef, $list_model, $parent_info) = @_;
    return $list_model->merge_initialize_info($parent_info, {
	version => 1,
	$list_model->field_decl(
	    primary_key => [[qw(primary_id PrimaryId)]],
	    other => [
		qw(rank percent collapse_count),
		[simple_class => 'Name'],
	    ],
	    qw(Integer NOT_NULL),
	),
	auth_id => 'RealmOwner.realm_id',
    });
}

sub _delete {
    my($self, $primary_id, $req) = @_;
    return unless $primary_id;
    $self->get('db')->delete_document_by_term($primary_id);
    return;
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

sub _replace {
    my($self, $req, $class, $realm_id, $primary_id, $terms, $postings) = @_;
    return unless $terms;
    my($doc) = Search::Xapian::Document->new;
    $doc->set_data('');
    $doc->add_value(0, $class);
    $doc->add_value(1, $realm_id);
    $doc->add_value(2, $primary_id);
    $primary_id = "Q$primary_id";
    foreach my $t ($primary_id, @$terms) {
	$doc->add_term(substr($t, 0, $_MAX_WORD));
    }
    my($i) = 1;
    foreach my $p (@$postings) {
	my($s) = $_STEMMER->stem_word($p);
	next if length($p) > $_MAX_WORD;
	$doc->add_posting("$p", $i)
	    unless $s eq $p;
	$doc->add_posting($s, $i++);
    }
    $self->get('db')->replace_document_by_term($primary_id, $doc);
    return;
}

1;
