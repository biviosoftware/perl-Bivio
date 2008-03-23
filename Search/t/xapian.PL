# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
do {
    config({
	'Bivio::Search::Xapian' => {
	    db_path => Bivio::IO::File->absolute_path('Xapian.tmp'),
	},
	'Bivio::Biz::Model::RealmFile' => {
	    search_class => 'Search.Xapian',
	},
    });
    my($files) = [];
    my($root) = '/xapian';
    model('Lock')->execute_general(req());
    Bivio::Search::Xapian->destroy_db;
    commit();
    foreach my $op (
	[xapian_demo => [
	    'common word word albeit',
	    'common word abcz defz ghiz jklz albeit',
	    'common mnoz pqrz  words stuz vwxz albeit',
	    'common a.b.c. d.e.f. g.h.i. j.k.l. word albeit',
	    'commonly worded m.n.o. worded place for p.q.r. s.t.u. v.w.x. albeit',
	    'a public green is a place for the common word albeit',
	]],
	[xapian_guest => [
	    'a private place for the common man',
	    'a public place for the common man',
	]]
    ) {
	my($user, $data) = @$op;
	req()->set_realm_and_user($user, $user);
 	model('RealmMail')->delete_all;
 	model('RealmFile')->delete_all;
	foreach my $x (@$data) {
	    push(@$files, model('RealmFile')->create_with_content(
		{path => ($x =~ /public/ ? '/public' : '')
		     . "$root/" . @$files . '.txt'}, \$x
	    )->get('realm_file_id'));
	}
    }
    commit();
    $files;
}

