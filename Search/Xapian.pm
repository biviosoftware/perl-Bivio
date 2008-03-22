# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Xapian;
use strict;
use base 'Bivio::Collection::Attributes';
use Bivio::Biz::File;
use Bivio::IO::Trace;
use Bivio::Type;
use File::Spec ();
use Search::Xapian ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
#TODO: What is the actual max term length; I've seen errors in the 400 range
my($_MAX_WORD) = 240;
my($_LENGTH) = Bivio::Type->get_instance('PageSize')->get_default;
my($_STEMMER) = Search::Xapian::Stem->new('english');
my($_FLAGS) = 0;
foreach my $f (qw(FLAG_BOOLEAN FLAG_PHRASE FLAG_LOVEHATE FLAG_WILDCARD)) {
    $_FLAGS |= Search::Xapian->$f();
}
our($_TRACE);
Bivio::IO::Config->register(my $_CFG = {
    db_path => Bivio::Biz::File->absolute_path('Xapian'),
});

sub delete_realm_file {
    my($proto, $realm_file_or_id, $req) = @_;
    return _queue(
	$proto, [
	    delete_realm_file =>
	    ref($realm_file_or_id) ? $realm_file_or_id->get('realm_file_id')
		: $realm_file_or_id,
	], $req
    ) unless ref($proto);
    _delete($proto, 'Q' . $realm_file_or_id, $req);
    return;
}

sub destroy_db {
    my(undef, $req) = @_;
    Bivio::Die->die('general lock must be acquired')
	unless Bivio::Biz::Model->new($req, 'Lock')->is_general_acquired;
    Bivio::IO::Alert->info($_CFG->{db_path}, ': deleting');
    Bivio::IO::File->rm_rf($_CFG->{db_path});
    return;
}

sub execute {
    my($proto, $req) = @_;
    my($self) = $req->get(ref($proto) || $proto);
    unlink(File::Spec->catfile($_CFG->{db_path}, 'db_lock'));
    my($db) = Search::Xapian::WritableDatabase->new(
	$_CFG->{db_path}, Search::Xapian->DB_CREATE_OR_OPEN);
    $self->put(db => $db);
    foreach my $op (@{$self->get('ops')}) {
	_trace($op) if $_TRACE;
	my($method) = shift(@$op);
	$self->$method(@$op);
    }
    $self->delete('db');
    $db->flush;
    return 0;
}

sub handle_commit {
    my($self, $req) = @_;
    if (Bivio::Biz::Model->new($req, 'Lock')->is_general_acquired) {
	$req->put(ref($self) => $self);
	$self->execute($req);
	return;
    }
    $self->use('Bivio::Agent::Job::Dispatcher')->enqueue(
	$req,
	'JOB_XAPIAN_COMMIT',
	{
	    ref($self) => $self,
	    auth_id => Bivio::Auth::Realm->get_general->get('id'),
	    auth_user_id => undef,
	},
    );
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

sub update_realm_file {
    my($proto, $realm_file, $req) = @_;
    return _queue(
	$proto,
	[update_realm_file => $realm_file->get('realm_file_id')],
	$realm_file->get_request,
    ) unless ref($proto);
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    return unless $rf->unauth_load({realm_file_id => $realm_file})
	&& !$rf->get('is_folder');
    _replace(
	$proto,
	$req,
	$rf->simple_package_name,
	$rf->get('realm_id'),
	$rf->get_primary_id,
	$proto->use('Bivio::Search::RealmFile')->parse_for_xapian($rf),
    );
    return;
}

sub query {
    my($proto, $phrase, $offset, $length, $private_realm_ids, $public_realm_ids_or_all) = @_;
    $offset ||= 0;
    $length ||= $_LENGTH;
    $private_realm_ids ||= [];
    my($db) = Search::Xapian::Database->new($_CFG->{db_path});
    my($qp) = Search::Xapian::QueryParser->new;
    $qp->set_stemmer($_STEMMER);
    $qp->set_stemming_strategy(Search::Xapian::STEM_ALL);
    $qp->set_default_op(Search::Xapian->OP_AND);
    my($q) = Search::Xapian::Query->new(
 	Search::Xapian->OP_AND,
 	$qp->parse_query($phrase, $_FLAGS),
	Search::Xapian::Query->new(
	    Search::Xapian->OP_OR,
	    map(Search::Xapian::Query->new("XREALMID:$_"), @$private_realm_ids),
	    ref($public_realm_ids_or_all) ? map(
		Search::Xapian::Query->new(
		    Search::Xapian->OP_AND,
		    Search::Xapian::Query->new("XREALMID:$_"),
		    Search::Xapian::Query->new('XISPUBLIC:1'),
		),
		@$public_realm_ids_or_all
	    ) : $public_realm_ids_or_all
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
    } $db->enquire($q)->matches($offset, $length))];
    _trace([$q->get_terms], '->[', $offset, '..', $offset + $length,
	   ']: ', $res) if $_TRACE;
    return $res;
}

sub query_list_model_initialize {
    my(undef, $list_model, $parent_info) = @_;
    return $list_model->merge_initialize_info($parent_info, {
	version => 1,
	@{$list_model->internal_initialize_local_fields(
	    primary_key => [[qw(primary_id PrimaryId)]],
	    other => [
		qw(rank percent collapse_count),
		[simple_class => 'Name'],
	    ],
	    qw(Integer NOT_NULL),
	)},
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
    my($proto, $op, $req) = @_;
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
