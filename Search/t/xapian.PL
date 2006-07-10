# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
do {
    config({
	'Bivio::Search::Xapian' => {
	    db_path => Bivio::IO::File->rm_rf(
		Bivio::IO::File->absolute_path('Xapian.tmp')),
	},
	'Bivio::Biz::Model::RealmFile' => {
	    search_class => 'Bivio::Search::Xapian',
	},
    });
    req()->set_realm_and_user(qw(demo demo));
    my($files) = [];
    my($root) = '/xapian';
    model('RealmFile')->delete_deep({path => $root});
    model('RealmFile')->delete_deep({path => "/public$root"});
    foreach my $x (
	'common word word',
	'common word abcz defz ghiz jklz',
	'common mnoz pqrz  words stuz vwxz',
	'common a.b.c. d.e.f. g.h.i. j.k.l. word ',
	'commonly worded m.n.o. worded place for p.q.r. s.t.u. v.w.x.',
	'a public green is a place for the common word',
    ) {
	push(@$files, model('RealmFile')->create_with_content(
	    {path => ($x =~ /public/ ? '/public' : '')
		 . "$root/" . @$files . '.txt'}, \$x)->get('realm_file_id'));
    }
    commit();
    $files;
}

