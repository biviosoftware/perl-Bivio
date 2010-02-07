# Copyright (c) 2009-2010 bivio Software, Inc.  All Rights Reserved.
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
  clear_calendar_btest
  init_calendar_btest
  init_search -- files for realm-file-search.btest
EOF
}

sub init_calendar_btest {
    my($self) = @_;
    $self->initialize_fully;
    $self->new_other('SQL')->map_invoke(
	create_user_with_account => [qw(
	    calendar_btest_user
	    calendar_btest_adm
	)],
    );
    _do_calendar_btest(sub {
	my($name) = @_;
	$self->req->set_realm(undef);
	$self->model('ForumForm', {
	    'RealmOwner.display_name'
		=> b_use('Type.String')->to_camel_case($name),
	    'RealmOwner.name' => $name,
	});
	$self->model(RealmUserAddForm => {
	    administrator => 1,
	    'User.user_id' => $self->unauth_realm_id('calendar_btest_adm'),
	});
	$self->model(RealmUserAddForm => {
	    administrator => 0,
	    'User.user_id' => $self->unauth_realm_id('calendar_btest_user'),
	    file_writer => 1,
	}) unless $name =~ /adm_only/;
	return 1;
    });
    return;
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

sub reset_calendar_btest {
    my($self) = @_;
    return _do_calendar_btest(sub {
	return $self->req->with_realm(shift, sub {
	    $self->model('CalendarEvent')->do_iterate(
	        sub {
		    shift->cascade_delete;
		    return 1;
		},
	    );
	    return;
        });
    });
}

sub _do_calendar_btest {
    my($op) = @_;
    foreach my $name (qw(
	calendar_btest_main
	calendar_btest_adm_only
	calendar_btest_other
    )) {
        $op->($name);
    }
    return;
}

1;
