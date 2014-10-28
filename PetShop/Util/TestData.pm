# Copyright (c) 2009-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Util::TestData;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_WDN) = b_use('Type.WikiDataName');
my($_WN) = b_use('Type.WikiName');
my($_C) = b_use('FacadeComponent.Constant');

sub USAGE {
    return <<'EOF';
usage: bivio TestData [options] command [args..]
commands
  clear_crm_threads
  init
  init_calendar_btest
  init_mail_references
  init_search -- files for realm-file-search.btest
  init_seo_btest
  reset_calendar_btest
EOF
}

sub clear_crm_threads {
    my($self) = @_;
    $self->assert_test;
    $self->model('CRMThread')
	->do_iterate(
	    sub {
		shift->cascade_delete;
		return 1;
	    },
	);
    return;
}

sub init {
    my($self) = @_;
    $self->init_search;
    $self->init_calendar_btest;
    $self->reset_seo_btest;
    $self->init_mail_references;
    return;
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
	    file_writer => $name =~ /read_only/ ? 0 : 1,
	}) unless $name =~ /adm_only/;
	return 1;
    });
    return;
}

sub init_mail_references {
    my($self) = @_;
    $self->req->with_realm_and_user(
	undef,
	$self->new_other('TestUser')->ADM,
	sub {
	    $self->model('ForumForm', {
		'RealmOwner.display_name' => 'Mail References',
		'RealmOwner.name' => 'mail_references',
	    }) unless $self->model('RealmOwner')
		->unauth_rows_exist({name => 'mail_references'});
	    $self->new_other('SiteForum')
		->put(force => 1)
		->init_files('mail_references');
	    return;
	},
    );
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
    $self->req->with_realm('calendar_btest_user', sub {
        b_use('Type.TimeZone')->row_tag_replace(
	    $self->req('auth_user_id'), $self->req);
    });
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

sub reset_seo_btest {
    my($self) = @_;
    $self->initialize_fully;
    my($req) = $self->req;
    $req->with_realm_and_user(
	undef,
	$self->new_other('TestUser')->ADM,
	sub {
	    $self->model('ForumForm', {
		'RealmOwner.display_name' => 'SEO Btest',
		'RealmOwner.name' => 'seo_btest',
	    }) unless $self->model('RealmOwner')
		->unauth_rows_exist({name => 'seo_btest'});
	    $req->set_realm('seo_btest');
	    $self->model('RealmFile')->create_or_update_with_content({
		path => '/Public/Wiki/StartPage',
	    }, \('content does not matter'));
	    $req->set_realm($_C->get_value('site_realm_name', $req));
	    # Didn't want to export from SEOPrefixList, because no need except
	    # for this class (private unless necessary public)
	    $self->model('RealmFile')->create_or_update_with_content({
		path => '/Settings/SEOPrefix.csv',
	    }, <<'EOF');
URI,Prefix
/seo_btest,forum home
/seo_btest/bp,wiki home
/seo_btest/bp/StartPage,start page
EOF
	},
    );
    $self->commit_or_rollback;
    return;
}

sub _do_calendar_btest {
    my($op) = @_;
    foreach my $name (qw(
	calendar_btest_main
	calendar_btest_adm_only
	calendar_btest_other
        calendar_btest_read_only
    )) {
        $op->($name);
    }
    return;
}

1;
