# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Util::TestData;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WDN) = b_use('Type.WikiDataName');
my($_WN) = b_use('Type.WikiName');

sub USAGE {
    return <<'EOF';
usage: bivio TestData [options] command [args..]
commands
  init_search -- files for realm-file-search.btest
EOF
}

sub init_search {
    my($self) = @_;
    $self->initialize_fully;
    my($sql) = $self->new_other('SQL');
    $self->req->with_realm_and_user('site', $sql->ROOT, sub {
        $sql->realm_file_create($_WN->to_absolute('SearchTest1', 1), <<'EOF');
@h1 Test Result One
Hello Wiki World!
EOF
        $sql->realm_file_create($_WDN->to_absolute('search_test2.txt', 1), <<'EOF');
Test Result Two
Hello Underscore World!
EOF
        $sql->realm_file_create($_WDN->to_absolute('search-test3.txt', 1), <<'EOF');
Test Result Three
Hello Hyphen World!
EOF
        $sql->realm_file_create($_WDN->to_absolute('search test 4.txt', 1), <<'EOF');
Test Result Four
Hello Space World!
EOF
        $sql->realm_file_create('SearchTest5.csv', <<'EOF');
Test,Result,Five
t,r,5
T,R,V
EOF
    });
    return;
}

1;
