# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Xapian;
use strict;
use base 'Bivio::Collection::Attributes';
use Bivio::Biz::File;
use Search::Xapian ();
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_LENGTH) = Bivio::Type->get_instance('PageSize')->get_default;
my($_STEMMER) = Search::Xapian::Stem->new('english');
my($_STOPPER) = Search::Xapian::SimpleStopper->new;
foreach my $w (qw(
    a about an and are as at be by en for from how i in is it of on or that
    the this to was what when where which who why will with
)) {
    $_STOPPER->add($w);
}
my($_FLAGS) = 0;
foreach my $f (qw(FLAG_BOOLEAN FLAG_PHRASE FLAG_PHRASE FLAG_LOVEHATE FLAG_WILDCARD)) {
    $_FLAGS += Search::Xapian->$f();
}
our($_TRACE);
Bivio::IO::Config->register(my $_CFG = {
    db_path => Bivio::Biz::File->absolute_path('Xapian'),
});

sub delete_realm_file {
    my($proto, $realm_file_or_id, $req) = @_;
    # IMPORTANT: Make sure you have a new instance for writes
    _delete(
	$proto,
	$req || $realm_file_or_id->get_request,
	$proto->use('Bivio::Search::RealmFile')->unique_term($realm_file_or_id),
    );
    return;
}

sub handle_commit {
    my($self) = @_;
    my($db) = Search::Xapian::WritableDatabase->new(
	$_CFG->{db_path}, Search::Xapian->DB_CREATE_OR_OPEN);
    foreach my $op (@{$self->get('ops')}) {
	my($method) = shift(@$op);
	$db->$method(@$op);
    }
    $db->flush;
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
    my($proto, $realm_file) = @_;
    # IMPORTANT: Make sure you have a new instance for writes
    _replace(
	$proto,
	$realm_file->get_request,
	$realm_file->simple_package_name,
	$proto->use('Bivio::Search::RealmFile')->parse_for_xapian($realm_file),
    );
    return;
}

sub query {
    my($proto, $phrase, $offset, $length, $realm_ids, $only_is_public) = @_;
# Need to narrow by realm_ids, is_public, etc.
    $offset ||= 0;
    $length ||= $_LENGTH;
    my($db) = Search::Xapian::Database->new($_CFG->{db_path});
    my($qp) = Search::Xapian::QueryParser->new();
    $qp->set_stemmer($_STEMMER);
    $qp->set_stopper($_STOPPER);
    $qp->set_default_op(Search::Xapian->OP_AND);
    my($q) = Search::Xapian::Query->new(
 	Search::Xapian->OP_AND,
 	$qp->parse_query($phrase, $_FLAGS),
	$realm_ids && @$realm_ids ? Search::Xapian::Query->new(
	    Search::Xapian->OP_OR,
	    map(Search::Xapian::Query->new("XREALMID:$_"), @$realm_ids),
	) : (),
	$only_is_public ? Search::Xapian::Query->new("XISPUBLIC:1") : (),
    );
    my($enq) = $db->enquire($q);
#    my($enq) = $db->enquire($qp->parse_query($phrase, $_FLAGS));
    #printf "Running query '%s'\n", $enq->get_query()->get_description();
    my($res) = [map({
	my($x) = $_;
	my($d) = $x->get_document;
	+{
	    map(
		($_ => $x->$_()),
		qw(get_percent get_rank get_collapse_count),
	    ),
	    simple_class => $d->get_value(0),
	    unique_id => $d->get_value(1),
	};
    } $enq->matches($offset, $length))];
    _trace($phrase, ', ', $offset, ', ', $length, ' => ', $res) if $_TRACE;
    return $res;
}

sub _op {
    my($proto, $op, $req) = @_;
    my($self) = $req->unsafe_get_txn_resource($proto);
    $req->push_txn_resource($self = $proto->new({ops => []}))
	unless $self;
    push(@{$self->get('ops')}, $op);
    return;
}

sub _delete {
    my($proto, $req, $unique) = @_;
    return unless $unique;
    _op($proto, [delete_document_by_term => $unique], $req);
    _trace($unique) if $_TRACE;
    return;
}

sub _replace {
    my($proto, $req, $class, $terms, $postings) = @_;
    return unless $terms;
    my($unique, $id) = map(/^(Q(.+))/, @$terms);
    Bivio::Die->die($terms, ': missing Q (unique) term')
        unless $unique;
    my($doc) = Search::Xapian::Document->new;
    $doc->set_data('');
    foreach my $t (@$terms) {
	$doc->add_term($t);
    }
    my($i) = 1;
    foreach my $p (@$postings) {
	next if length($p) > 64 || $_STOPPER->stop_word($p);
	my($s) = $_STEMMER->stem_word($p);
	$doc->add_posting("$p", $i)
	    unless $s eq $p;
	$doc->add_posting($s, $i++);
    }
    $doc->add_value(0, $class);
    $doc->add_value(1, $id);
    _op($proto, [replace_document_by_term => $unique, $doc], $req);
    _trace($unique) if $_TRACE;
    return;
}

1;
