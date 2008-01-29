# Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Util;
use strict;
use Bivio::Base 'ShellUtil.SQL';

# export BCONF=~/bconf/petshop.bconf
# cd files/ddl
# perl -w ../../b-petshop init_dbms
# perl -w ../../b-petshop create_test_db
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_R) = __PACKAGE__->use('Auth.Role');
my($_AR) = __PACKAGE__->use('Auth.Realm');
my($_S) = __PACKAGE__->use('Type.String');

sub BTEST_ADMIN {
    return 'btest_admin';
}

sub BTEST_READ {
    return 'btest_read';
}

sub TUPLE_FORUM {
    return 'tuple_forum';
}

sub TUPLE_USER {
    return 'tuple_user';
}

sub DEMO {
    return 'demo';
}

sub DEMO_EMAIL {
    my($proto) = @_;
    return $proto->format_email($proto->DEMO);
}

sub DEMO_LAST_NAME {
    return 'User';
}

sub FOUREM {
    return 'fourem';
}

sub GUEST {
    return 'guest';
}

sub MAIL_FORUM {
    return 'mail_forum';
}

sub MAIL_USER {
    return 'mail_user' . $_[1];
}

sub MULTI_ROLE_USER {
    return 'multi_role_user';
}

sub OTP {
    return 'otp';
}

sub PASSWORD {
    return 'password';
}

sub ROOT {
    return 'root';
}

sub ROOT_EMAIL {
    my($proto) = @_;
    return $proto->format_email($proto->ROOT);
}

sub USAGE {
    return shift->SUPER::USAGE . <<'EOF';
    demo_users -- lists demo user names
    demo_all_tuples -- clears tuple table in realm
EOF
}

sub XAPIAN_DEMO {
    return 'xapian_demo';
}

sub XAPIAN_GUEST {
    return 'xapian_guest';
}

sub ddl_files {
    return [map {
	my($base) = $_;
	map {
	    $base.'-'.$_.'.sql';
	} qw(tables constraints sequences);
    } qw(bOP petshop)];
}

sub delete_all_tuples {
    my($self) = @_;
    my($req) = $self->initialize_ui;
    $self->model('Tuple')->delete_all;
    return;
}

sub demo_users {
    my($self) = @_;
    return [
        map($self->$_(),
	    qw(DEMO GUEST XAPIAN_DEMO XAPIAN_GUEST MULTI_ROLE_USER
	       BTEST_ADMIN BTEST_READ OTP),
	    $self->get_request->is_production ? () : 'ROOT',
	),
    ];
}

sub format_email {
    my(undef, $user) = @_;
    return "$user\@bivio.biz";
}

sub initialize_db {
    return shift->call_super_before(\@_, sub {
        shift->new_other('SiteForum')->init;
	return;
    });
}

sub initialize_test_data {
    my($self) = @_;
    _init_demo_categories($self);
    _init_demo_products($self);
    _init_demo_items($self);
    _init_demo_users($self);
    _init_demo_files($self);
    _init_demo_calendar($self);
    _init_forum($self);
    _init_email_alias($self);
    _init_tuple($self);
    _init_logo($self);
    _init_default_tuple($self);
    _init_mail($self);
    return;
}

sub internal_upgrade_db {
    my($self) = @_;
    # Add time_zone field to CalendarEvent table
    $self->run(<<'EOF');
ALTER TABLE calendar_event_t
  ADD time_zone NUMERIC(4)
;
EOF
    return;
}

sub realm_role_config {
    my($self) = @_;
    # Add test realm roles
    return [
        @{$self->SUPER::realm_role_config()},
        <DATA>,
    ];
}

sub _init_default_tuple {
    my($self) = @_;
    my($req) = $self->req;
    _top_level_forum($self, $self->TUPLE_FORUM, [$self->TUPLE_USER], []);
    $self->model('TupleSlotType')->create_from_hash({
	Status => {
	    type_class => 'TupleSlot',
	    choices => [qw(Open Closed New)],
	    default_value => 'New',
	},
    });
    $self->model('TupleDef')->create_from_hash({
	'req#Requests' => [
	    {
		label => 'Title',
		type => 'String',
	    },
	    {
		label => 'Status',
		type => 'Status',
	    },
	],
    });
    $self->model('TupleUse')->create_from_label('Requests');
    $self->model('RowTag')->create_value(
	$req->get('auth_id'), 'DEFAULT_TUPLE_MONIKER', 'req');
    return;
}

sub _init_demo_calendar {
    my($self) = @_;
    my($req) = $self->get_request;
    my($now) = $_DT->from_literal('1/1/2006 16:0:0');
    my($ce) = Bivio::Biz::Model->new($req, 'CalendarEvent');
    map(
	{
	    $self->set_realm_and_user($self->DEMO, $self->DEMO);
	    $ce->create_from_vevent(
		{
		    dtstart => $_DT->add_seconds($now, $_ * 3600),
		    dtend => $_DT->add_seconds($now, ($_ + 1) * 3600),
		    location => 'Location' . $_,
		    summary => 'Summary' . $_,
		}
	    );
	}
	qw{1 2}
    );
    return;
}

sub _init_demo_categories {
    my($self) = @_;
    # Initializes Model.Category.
    my($model) = Bivio::Biz::Model->new($self->get_request, 'Category');
    foreach my $enum (Bivio::Type->get_instance('Category')->get_list) {
	# Don't create the '0' (UNKNOWN) case
	next if $enum->as_int == 0;
	$model->create({
	    category_id => $enum->get_name,
	    name => $enum->get_short_desc,
	    description => $enum->get_long_desc,
	});
    }
    return;
}

sub _init_demo_files {
    my($self) = @_;
    my($req) = $self->get_request;
    Bivio::IO::File->chdir(
	Bivio::IO::File->mkdir_p(Bivio::IO::File->rm_rf(
	    my $d = File::Spec->rel2abs('demo_files.tmp'))));
    foreach my $x (
	['Public/file.txt' => 'text/plain'],
	['private/file.html' => '<html><body>text/html</body></html>'],
	['private/image.gif' => 'image/gif'],
    ) {
	my($f, $c) = @$x;
	Bivio::IO::File->mkdir_parent_only($f);
	Bivio::IO::File->write($f, $c);
    }
    foreach my $u (qw(DEMO XAPIAN_DEMO GUEST XAPIAN_GUEST BTEST_READ)) {
	$self->set_realm_and_user($self->$u(), $self->$u());
	$self->new_other('Bivio::Util::RealmFile')->import_tree('');
	Bivio::Biz::Model->new('RealmFile')->do_iterate(
	    sub {
		my($f) = @_;
		$f->update({is_public => 1})
		    if $f->get('path') =~ /public/i;
		return 1;
	    },
	    'path',
	);
    }
    Bivio::IO::File->chdir('..');
    return;
}

sub _init_demo_items {
    my($self) = @_;
    # Init Model.Item and Model.inventory.

    foreach my $record (@{$self->new_other('CSV')->parse_records(<<'EOF')}) {
item_id,product_id,list_price,unit_cost,attr1
EST-1,FI-SW-01,16.5,10,Large
EST-2,FI-SW-01,16.5,10,Small
EST-3,FI-SW-02,18.5,12,Toothless
EST-4,FI-FW-01,18.5,12,Spotted
EST-5,FI-FW-01,18.5,12,Spotless
EST-6,K9-BD-01,18.5,12,Male Adult
EST-7,K9-BD-01,18.5,12,Female Puppy
EST-8,K9-PO-02,18.5,12,Male Puppy
EST-9,K9-DL-01,18.5,12,Spotless Male Puppy
EST-10,K9-DL-01,18.5,12,Spotted Adult Female
EST-11,RP-SN-01,18.5,12,Venomless
EST-12,RP-SN-01,18.5,12,Rattleless
EST-13,RP-LI-02,18.5,12,Green Adult
EST-14,FL-DSH-01,58.5,12,Tailless
EST-15,FL-DSH-01,23.5,12,With tail
EST-16,FL-DLH-02,93.5,12,Adult Female
EST-17,FL-DLH-02,93.5,12,Adult Male
EST-18,AV-CB-01,193.5,92,Adult Male
EST-19,AV-SB-02,15.5,2,Adult Male
EST-20,FI-FW-02,5.5,2,Adult Male
EST-21,FI-FW-02,5.29,1,Adult Female
EST-22,K9-RT-01,135.5,100,Adult Male
EST-23,K9-RT-01,145.49,100,Adult Female
EST-24,K9-RT-02,255.5,92,Adult Male
EST-25,K9-RT-02,325.29,90,Adult Female
EOF
        $self->model('Inventory')->create({
	    item_id => $self->model('Item')->create($record)->get('item_id'),
	    quantity => 10_000,
	});
    }
    return;
}

sub _init_demo_products {
    my($self) = @_;
    # Initializes Model.Product.

    foreach my $record (@{$self->new_other('CSV')->parse_records(<<'EOF')}) {
product_id,category_id,name,image_name,description
FI-SW-01,FISH,Angelfish,angelfish,Salt Water fish from Australia
FI-SW-02,FISH,Tiger Shark,tigershark,Salt Water fish from Australia
FI-FW-01,FISH,Koi,koi,Fresh Water fish from Japan
FI-FW-02,FISH,Goldfish,reeffish,Fresh Water fish from China
K9-BD-01,DOGS,Corgi,corgi,Friendly dog from Wales
K9-PO-02,DOGS,Poodle,poodle,Cute dog from France
K9-DL-01,DOGS,Dalmation,dalmation,Great dog for a Fire Station
K9-RT-01,DOGS,German Shepherd,shepherd,Great family dog
K9-RT-02,DOGS,Labrador Retriever,lab,Great hunting dog
RP-SN-01,REPTILES,Rattlesnake,rattlesnake,Doubles as a watch dog
RP-LI-02,REPTILES,Iguana,iguana,Friendly green friend
FL-DSH-01,CATS,Manx,manx,Great for reducing mouse populations
FL-DLH-02,CATS,Persian,persian,Friendly house cat, doubles as a princess
AV-CB-01,BIRDS,Amazon Parrot,parrot,Great companion for up to 75 years
AV-SB-02,BIRDS,Finch,finch,Great stress reliever
EOF
        $self->model('Product')->create($record);
    }
    return;
}

sub _init_demo_users {
    my($self) = @_;
    # Creates user demo@bivio.biz with password "password".  Creates user
    # root@bivio.biz.
    my($req) = $self->get_request;
    my($demo_id);
    foreach my $u (@{$self->demo_users()}) {
	$self->print("Created user $u\@bivio.biz\n");
	Bivio::Biz::Model->get_instance('UserAccountForm')->execute($req, {
	    'User.first_name' => ucfirst($u),
	    'User.last_name' => $self->DEMO_LAST_NAME,
	    'Email.email' => $self->format_email($u),
	    'Address.street1' => '1313 Mockingbird Lane',
	    'Address.street2' => undef,
	    'Address.city' => 'Boulder',
	    'Address.state' => 'CO',
	    'Address.zip' => '80304',
	    'Address.country' => 'US',
	    'Phone.phone' => '555-1212',
	    'RealmOwner.password' => $self->PASSWORD,
	    force_create => 1,
	});
	# test accounts have real names, for ease of logging in
	$req->get('auth_user')->update({
	    name => $u,
	    display_name => join(' ', ucfirst($u), $self->DEMO_LAST_NAME),
	});
	my($uid) = $req->get('auth_user_id');
	if ($u eq $self->DEMO || $u eq $self->XAPIAN_DEMO) {
	    $demo_id = $uid;
	}
	elsif ($u eq $self->ROOT) {
            $self->new_other('RealmRole')->make_super_user;
	    $self->new_other('SiteForum')->make_admin;
	}
	elsif ($u eq $self->GUEST || $u eq $self->XAPIAN_GUEST) {
            Bivio::Biz::Model->new($req, 'RealmUser')->create({
                realm_id => $demo_id || die('DEMO must come before GUEST'),
                user_id => $uid,
                role => $_R->GUEST,
            });
	}
	elsif ($u eq $self->MULTI_ROLE_USER) {
            Bivio::Biz::Model->new($req, 'RealmUser')->create({
                realm_id => $_AR->get_general->get('id'),
                user_id => $uid,
                role => $_R->TEST_ROLE1,
            });
            Bivio::Biz::Model->new($req, 'RealmUser')->create({
                realm_id => $_AR->get_general->get('id'),
                user_id => $uid,
                role => $_R->TEST_ROLE2,
            });
	}
	elsif ($u eq $self->OTP) {
	    $self->new_other('OTP')->reset_user;
	}
    }
    return;
}

sub _init_email_alias {
    my($self) = @_;
    my($req) = $self->get_request;
    foreach my $x (
	[qw(demo-alias@bivio.biz demo)],
	[qw(fourem-alias@bivio.biz fourem)],
	[qw(random-alias@bivio.biz random@example.com)],
    ) {
	Bivio::Biz::Model->new($req, 'EmailAlias')->create({
	    incoming => $x->[0],
	    outgoing => $x->[1],
	});
    }
    return;
}

sub _init_forum {
    my($self) = @_;
    my($req) = $self->get_request;
    $req->set_realm(undef);
    $req->set_user($self->ROOT);
    $self->model('ForumForm', {
        'RealmOwner.display_name' => 'RealmFile2',
	'RealmOwner.name' => 'realmfile2',
    });
    $req->set_realm(undef);
    $self->model('ForumForm', {
        'RealmOwner.display_name' => 'Unit Test Forum',
	'RealmOwner.name' => $self->FOUREM,
    });
    # Must agree with easy-form.btest (or test will fail)
    $self->model('RealmFile')->create_with_content({
	path => 'Public/EasyForm-btest.html',
	is_public => 1,
    }, \(<<'EOF'));
<html>
<body>
<form method="POST" action="/fourem/Forms/btest?goto=/fourem/pub/EasyForm-btest-done.html">
<table>
<tr>
<td>Input:</td>
<td><input type="text" name="input" /></td>
</tr><tr>
<td><input type="submit" name="ok" value="OK" /></td>
</tr>
</table>
</form>
</body>
</html>
EOF
    $self->model('RealmFile')->create_with_content({
	path => 'Public/EasyForm-btest-done.html',
	is_public => 1,
    }, \(<<'EOF'));
<html>
<body>
completed
</body>
</html>
EOF
    $self->model('RealmFile')->create_with_content({
	path => 'Forms/btest.csv',
    }, \(<<'EOF'));
&date,&email,input,ok
EOF
    $self->model('RealmFile')->create_with_content({
	path => Bivio::Type->get_instance('WikiName')->to_absolute('PrivatePage'),
    }, \(<<'EOF'));
My Example Page.
EOF
    $self->model('RealmFile')->create_with_content({
	path => Bivio::Type->get_instance('BlogFileName')->to_absolute('20071225000000', 1),
    }, \(<<'EOF'));
@h3 Merry Xmas
Ho, ho, ho!
EOF
    $self->model('ForumForm', {
        'RealmOwner.display_name' => 'Unit Test Forum Sub1',
	'RealmOwner.name' => $self->FOUREM . '-sub1',
    });
    $self->model('ForumForm', {
        'RealmOwner.display_name' => 'Unit Test Forum Sub1-1',
	'RealmOwner.name' => $self->FOUREM . '-sub1-1',
    });
    $req->set_user($self->BTEST_READ);
    $self->model('ForumUserAddForm', {
	'RealmUser.realm_id' => $req->get('auth_id'),
	'User.user_id' => $req->get('auth_user_id'),
    });
    $req->set_realm($self->FOUREM);
    $self->model('ForumForm', {
        'RealmOwner.display_name' => 'Unit Test Forum Sub2',
	'RealmOwner.name' => $self->FOUREM . '-sub2',
    });
    $req->set_user($self->BTEST_ADMIN);
    $self->model('ForumUserAddForm', {
	'RealmUser.realm_id' => $req->get('auth_id'),
	'User.user_id' => $req->get('auth_user_id'),
	administrator => 1,
    });
    $req->set_user($self->BTEST_READ);
    $self->model('ForumUserAddForm', {
	'RealmUser.realm_id' => $req->get('auth_id'),
	'User.user_id' => $req->get('auth_user_id'),
    });
    foreach my $realm (
	$self->new_other('SiteForum')->SITE_REALM,
	$self->FOUREM,
    ) {
	$req->set_realm($realm);
	foreach my $mode (qw(public private)) {
	    my($p) = $mode eq 'public' ? 1 : 0;
	    foreach my $fv (
		[qw(WikiName base.css), $p, ".${realm}_wiki_${mode} {}"],
		[qw(FilePath my.css), $p, ".${realm}_my_${mode} {}"],
	    ) {
		$self->model('RealmFile')->create_with_content({
		    path => $self->use('Type.' . shift(@$fv))
			->to_absolute(splice(@$fv, 0, 2)),
		}, \(shift(@$fv)));
	    }
	}
    }
    $req->set_realm($self->new_other('SiteForum')->HELP_REALM);
    foreach my $fv (
	['base.css', <<'EOF'],
^Not.*Found.*Wiki {font-size: 100%}
^.*Help {background-color: purple}
EOF
	['WikiView1', <<'EOF'],
@h1 Wiki View One
First page
EOF
	['WikiView2', <<'EOF'],
@h1
Wiki View
@strong Two
@/h1
Second page
EOF
	['WikiView3', <<'EOF'],
@h1 class=hello abc
Third page
EOF
    ) {
	$self->model('RealmFile')->create_with_content({
	    path => $self->use('Type.WikiName')->to_absolute($fv->[0], 1),
	}, \($fv->[1]));
    }
    $self->model('RealmFile')->create_with_content({
	path => Bivio::Type->get_instance('WikiName')->to_absolute('Shell_Util_Help', 1),
    }, \(<<'EOF'));
Shell utility help.
EOF
    return;
}

sub _init_logo {
    my($self) = @_;
    my($req) = $self->get_request;
    $req->set_realm($self->FOUREM);
    $req->set_user($self->ROOT);
    my($logo) = Bivio::IO::File->read('fourem.png');
    foreach my $x (
	[png => $logo],
	[bad => $logo],
	[gif => \('not an image')],
    ) {
	# Need different modified_date_time
	sleep(1);
	$self->model('RealmFile')->create_with_content({
	    path => "/Public/logo.$x->[0]",
	}, $x->[1]);
    }
    return;
}

sub _init_mail {
    my($self) = @_;
    _top_level_forum(
	$self, $self->MAIL_FORUM, [$self->MAIL_USER(1)], [$self->MAIL_USER(2)]);
    return;
}

sub _init_tuple {
    my($self) = @_;
    my($req) = $self->get_request;
    $req->set_realm($self->FOUREM);
    $req->set_user($self->ROOT);
    $self->model('TupleSlotType')->create_from_hash({
	Status => {
	    type_class => 'TupleSlot',
	    choices => [qw(s0 s1 s2 s3)],
	    default_value => 's1',
	},
    });
    $self->model('TupleDef')->create_from_hash({
	'PSR#PetShopReport' => [
	    {
		label => 'Author',
		type => 'Email',
		is_required => 1,
	    },
	    {
		label => 'Status',
		type => 'Status',
	    },
	],
    });
    $self->model('TupleUse')->create_from_label('PetShopReport');
    return;
}

sub _realm_id {
    my($self, $name) = @_;
    my($ro) = $self->model('RealmOwner');
    return $ro->unauth_load({name => $name}) ? $ro->get('realm_id')
	:  $self->create_test_user($name);
}

sub _top_level_forum {
    my($self, $name, $admins, $users) = @_;
    $self->req->set_realm(undef);
    $self->model('ForumForm', {
        'RealmOwner.display_name' => $_S->to_camel_case($name),
	'RealmOwner.name' => $name,
    });
    my($rid) = $self->req('auth_id');
    $self->model('ForumUserDeleteForm', {
	'RealmUser.realm_id' => $rid,
	'User.user_id' => _realm_id($self, $self->ROOT),
    });
    foreach my $user (@$admins, @$users) {
	$self->model('ForumUserAddForm', {
	    'RealmUser.realm_id' => $rid,
	    'User.user_id' => _realm_id($self, $user),
	    administrator => grep($_ eq $_, @$admins) ? 1 : 0,
	});
    }
    return;
}

1;

__DATA__
# The following is returned by realm_role_config().
b-realm-role -r GENERAL edit TEST_ROLE1 - \
    +TEST_PERMISSION1
b-realm-role -r GENERAL edit TEST_ROLE2 - \
    +TEST_PERMISSION2
b-realm-role -r ORDER -u user edit ANONYMOUS - \
    +ANYBODY
b-realm-role -r ORDER -u user edit USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role -r ORDER -u user edit WITHDRAWN - \
    +USER
b-realm-role -r ORDER -u user edit GUEST - \
    +WITHDRAWN
b-realm-role -r ORDER -u user edit MEMBER - \
    +GUEST \
    +ADMIN_READ \
    +DATA_READ \
    +DATA_WRITE
b-realm-role -r ORDER -u user edit ACCOUNTANT - \
    +MEMBER \
    +ADMIN_WRITE
b-realm-role -r ORDER -u user edit ADMINISTRATOR - \
    +ACCOUNTANT
b-realm-role -r USER -u user edit GUEST - \
    +WITHDRAWN \
    +DATA_READ
b-realm-role -r USER -u user edit TEST_ROLE1 -
b-realm-role -r USER -u user edit TEST_ROLE2 -
