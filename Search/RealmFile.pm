# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::RealmFile;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_P) = __PACKAGE__->use('Search.Parseable');
my($_RF) = __PACKAGE__->use('SearchParser.RealmFile');
my($_DT) = __PACKAGE__->use('Type.DateTime');

sub parse_content {
    my($proto, $realm_file) = @_;
    return $_RF->parse($_P->new($realm_file));
}

sub parse_for_xapian {
    my($proto, $realm_file) = @_;
    return
	unless my $attr = $proto->parse_content($realm_file);
    return (
	_terms($proto, $realm_file, $attr),
	_postings(\$attr->{title}, $attr->{text}),
    );
}

sub _field_term {
    my($m, $f, $t) = @_;
    ($t = $f) =~ s/[^a-z]//ig
	unless $t;
    return 'X' . uc($t) . ':' . lc($m->get_or_default($f, ''));
}

sub _omega_terms {
    my($proto, $rf, $attr, $author, $newsgroup) = @_;
    my($d) = $_DT->to_local_file_name($rf->get('modified_date_time'));
    return (
	 'A' . lc($author),
	 'G' . lc($newsgroup),
#TODO: 'H' . ?????
	 # Q set by caller, since used in general to delete/add docs
	 'P' . $rf->get('path_lc'),
	 $attr->{title} ? 'S' . lc($attr->{title}) : (),
	 'T' . lc($attr->{type}),
	 map({
	     my($t, $l) = split(//, $_);
	     $t . substr($d, 0, $l);
	 } qw(D8 M6 Y4)),
    );
}

sub _postings {
    use bytes;
    return [
	map(
	    map(
		map(
		    length($_) ? lc($_) : (),
		    $_ =~ /^\W*((?:[A-Z]\.){2,10})\W*$/ ? $1 : split(/\W+/, $_),
		),
		split(/\s+/, $$_),
	    ),
	    @_,
	),
    ];
}

sub _terms {
    my($proto, $rf, $attr) = @_;
    my($e) = $rf->new_other('Email');
    my($r) = $rf->new_other('RealmOwner');
    my($newsgroup, $author);
    return [
	_field_term($rf, 'realm_id'),
	_field_term($rf, 'user_id'),
	_field_term($rf, 'is_public'),
	_field_term($rf, 'is_read_only'),
	$e->unauth_load({realm_id => $rf->get('user_id')})
	    ? _field_term($e, 'email') : (),
	map({
	    my($f) = $_;
	    $r->unauth_load_or_die({realm_id => $rf->get($f . '_id')});
	    $newsgroup ||= $r->get('name');
	    $author = $r->get('display_name');
	    (
		_field_term($r, 'name', $f),
		_field_term($r, 'display_name', $f . 'fullname'),
	    );
	} qw(realm user)),
	_omega_terms(
	    $proto,
	    $rf,
	    $attr,
	    $author . ' ' . $e->get_or_default('email', ''),
	    $newsgroup),
    ];
}

1;
