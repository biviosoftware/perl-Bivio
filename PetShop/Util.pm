# Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Util;
use strict;
$Bivio::PetShop::Util::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Util::VERSION;

=head1 NAME

Bivio::PetShop::Util - initializes and manages PetShop

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Util;

=cut

=head1 EXTENDS

L<Bivio::Util::SQL>

=cut

use Bivio::Util::SQL;
@Bivio::PetShop::Util::ISA = ('Bivio::Util::SQL');

=head1 DESCRIPTION

C<Bivio::PetShop::Util> are utilities for initializing and
managing your PetShop.

How to create the database.  As root:

    su - postgres -c 'createuser --no-createdb --no-adduser --pwprompt petuser; createdb --owner petuser pet'

As you:

    cd files/ddl
    b-petshop create_db

=cut

=head1 CONSTANTS

=cut

=for html <a name="BTEST_READ"></a>

=head2 BTEST_READ : string

BTEST_READ user's name.

=cut

sub BTEST_READ {
    return 'btest_read';
}

=for html <a name="DEMO"></a>

=head2 DEMO : string

Returns 'demo'.

=cut

sub DEMO {
    return 'demo';
}

=for html <a name="DEMO_EMAIL"></a>

=head2 DEMO_EMAIL : string

Returns email for DEMO.

=cut

sub DEMO_EMAIL {
    my($proto) = @_;
    return $proto->format_email($proto->DEMO);
}

=for html <a name="DEMO_LAST_NAME"></a>

=head2 DEMO_LAST_NAME : string

Returns last name of DEMO

=cut

sub DEMO_LAST_NAME {
    return 'User';
}

=for html <a name="FOUREM"></a>

=head2 FOUREM : string

Fourem RealmOwner.name.

=cut

sub FOUREM {
    return 'fourem';
}

=for html <a name="GUEST"></a>

=head2 GUEST : string

Guest user's name.

=cut

sub GUEST {
    return 'guest';
}

=for html <a name="MULTI_ROLE_USER"></a>

=head2 MULTI_ROLE_USER : string

Test super user

=cut

sub MULTI_ROLE_USER {
    return 'multi_role_user';
}

=for html <a name="PASSWORD"></a>

=head2 PASSWORD : string

Default password.

=cut

sub PASSWORD {
    return 'password';
}

=for html <a name="ROOT"></a>

=head2 ROOT : string

Test super user

=cut

sub ROOT {
    return 'root';
}

=for html <a name="ROOT_EMAIL"></a>

=head2 ROOT_EMAIL : string

Test super user's email

=cut

sub ROOT_EMAIL {
    my($proto) = @_;
    return $proto->format_email($proto->ROOT);
}

=for html <a name="USAGE"></a>

=head2 USAGE : string

=cut

sub USAGE {
    return shift->SUPER::USAGE . <<'EOF';
    demo_users -- lists demo user names
EOF
}

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::Biz::Util::RealmRole;
use Bivio::Type::DateTime;

#=VARIABLES
my($_DT) = 'Bivio::Type::DateTime';

=head1 METHODS

=cut

=for html <a name="ddl_files"></a>

=head2 ddl_files() : array_ref

Returns DDL SQL files used to create/destroy database.

=cut

sub ddl_files {
    return [map {
	my($base) = $_;
	map {
	    $base.'-'.$_.'.sql';
	} qw(tables constraints sequences);
    } qw(bOP petshop)];
}

=for html <a name="demo_users"></a>

=head2 demo_users() : array_ref

Returns list of demo users.

=cut

sub demo_users {
    my($self) = @_;
    return [
        map($self->$_(),
	    qw(DEMO GUEST MULTI_ROLE_USER BTEST_READ),
	    $self->get_request->is_production ? () : 'ROOT',
	),
    ];
}

=for html <a name="format_email"></a>

=head2 static format_email(string user) : string

Formats email.

=cut

sub format_email {
    my(undef, $user) = @_;
    return "$user\@bivio.biz";
}

=for html <a name="initialize_test_data"></a>

=head2 initialize_test_data()

=cut

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
    return;
}

=for html <a name="internal_upgrade_db"></a>

=head2 internal_upgrade_db()

Add time_zone field to CalendarEvent table

=cut

sub internal_upgrade_db {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE calendar_event_t
  ADD time_zone NUMERIC(4)
;
EOF
    return;
}

=for html <a name="realm_role_config"></a>

=head2 realm_role_config() : array_ref

Add test realm roles

=cut

sub realm_role_config {
    my($self) = @_;
    return [
        @{$self->SUPER::realm_role_config()},
        <DATA>,
    ];}


#=PRIVATE METHODS

# _init_demo_calendar(self)
#
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

# _init_demo_categories(self)
#
# Initializes Model.Category.
#
sub _init_demo_categories {
    my($self) = @_;
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

# _init_demo_items()
#
# Init Model.Item and Model.inventory.
#
sub _init_demo_items {
    my($self) = @_;
    my($item) = Bivio::Biz::Model->new($self->get_request, 'Item');
    my($inventory) = Bivio::Biz::Model->new($self->get_request, 'Inventory');
    my($status) = Bivio::Type->get_instance('ItemStatus')->OK;
    foreach my $row (
	    'EST-1:FI-SW-01:16.5:10:Large',
	    'EST-2:FI-SW-01:16.5:10:Small',
	    'EST-3:FI-SW-02:18.5:12:Toothless',
	    'EST-4:FI-FW-01:18.5:12:Spotted',
	    'EST-5:FI-FW-01:18.5:12:Spotless',
	    'EST-6:K9-BD-01:18.5:12:Male Adult',
	    'EST-7:K9-BD-01:18.5:12:Female Puppy',
	    'EST-8:K9-PO-02:18.5:12:Male Puppy',
	    'EST-9:K9-DL-01:18.5:12:Spotless Male Puppy',
	    'EST-10:K9-DL-01:18.5:12:Spotted Adult Female',
	    'EST-11:RP-SN-01:18.5:12:Venomless',
	    'EST-12:RP-SN-01:18.5:12:Rattleless',
	    'EST-13:RP-LI-02:18.5:12:Green Adult',
	    'EST-14:FL-DSH-01:58.5:12:Tailless',
	    'EST-15:FL-DSH-01:23.5:12:With tail',
	    'EST-16:FL-DLH-02:93.5:12:Adult Female',
	    'EST-17:FL-DLH-02:93.5:12:Adult Male',
	    'EST-18:AV-CB-01:193.5:92:Adult Male',
	    'EST-19:AV-SB-02:15.5:2:Adult Male',
	    'EST-20:FI-FW-02:5.5:2:Adult Male',
	    'EST-21:FI-FW-02:5.29:1:Adult Female',
	    'EST-22:K9-RT-01:135.5:100:Adult Male',
	    'EST-23:K9-RT-01:145.49:100:Adult Female',
	    'EST-24:K9-RT-02:255.5:92:Adult Male',
	    'EST-25:K9-RT-02:325.29:90:Adult Female',
	   ) {
	my(@col) = split(/:/, $row);
	$item->create({
	    item_id => $col[0],
	    product_id => $col[1],
	    list_price => $col[2],
	    unit_cost => $col[3],
	    status => $status,
	    attr1 => $col[4],
	});
	$inventory->create({
	    item_id => $col[0],
	    quantity => 10_000,
	});
    }
    return;
}

# _init_demo_products(self)
#
# Initializes Model.Product.
#
sub _init_demo_products {
    my($self) = @_;
    my($cat) = Bivio::Type->get_instance('Category');
    my($model) = Bivio::Biz::Model->new($self->get_request, 'Product');
    foreach my $row (
	    'FI-SW-01:FISH:Angelfish:angelfish:Salt Water fish from Australia',
	    'FI-SW-02:FISH:Tiger Shark:tigershark:Salt Water fish from Australia',
	    'FI-FW-01:FISH:Koi:koi:Fresh Water fish from Japan',
	    'FI-FW-02:FISH:Goldfish:reeffish:Fresh Water fish from China',
	    'K9-BD-01:DOGS:Corgi:corgi:Friendly dog from Wales',
	    'K9-PO-02:DOGS:Poodle:poodle:Cute dog from France',
	    'K9-DL-01:DOGS:Dalmation:dalmation:Great dog for a Fire Station',
	    'K9-RT-01:DOGS:German Shepherd:shepherd:Great family dog',
	    'K9-RT-02:DOGS:Labrador Retriever:lab:Great hunting dog',
	    'RP-SN-01:REPTILES:Rattlesnake:rattlesnake:Doubles as a watch dog',
	    'RP-LI-02:REPTILES:Iguana:iguana:Friendly green friend',
	    'FL-DSH-01:CATS:Manx:manx:Great for reducing mouse populations',
	    'FL-DLH-02:CATS:Persian:persian:Friendly house cat, doubles as a princess',
	    'AV-CB-01:BIRDS:Amazon Parrot:parrot:Great companion for up to 75 years',
	    'AV-SB-02:BIRDS:Finch:finch:Great stress reliever') {

	my(@col) = split(/:/, $row);
	$model->create({
	    product_id => $col[0],
	    category_id => $cat->from_name($col[1])->get_name,
	    name => $col[2],
	    image_name => $col[3],
	    description => $col[4],
	});
    }
    return;
}

# _init_demo_files(self)
#
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
    foreach my $u (qw(DEMO GUEST BTEST_READ)) {
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

# _init_demo_users(self)
#
# Creates user demo@bivio.biz with password "password".  Creates user
# root@bivio.biz.
#
sub _init_demo_users {
    my($self) = @_;
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
	    display_name => ucfirst($u) . ' User',
	});
	my($uid) = $req->get('auth_user_id');
	if ($u eq $self->DEMO) {
	    $demo_id = $uid;
	}
	elsif ($u eq $self->ROOT) {
	    Bivio::Biz::Util::RealmRole->make_super_user;
	}
	elsif ($u eq $self->GUEST) {
            Bivio::Biz::Model->new($req, 'RealmUser')->create({
                realm_id => $demo_id || die('DEMO must come before GUEST'),
                user_id => $uid,
                role => Bivio::Auth::Role->GUEST,
            });
	}
	elsif ($u eq $self->MULTI_ROLE_USER) {
            Bivio::Biz::Model->new($req, 'RealmUser')->create({
                realm_id => Bivio::Auth::Realm->get_general->get('id'),
                user_id => $uid,
                role => Bivio::Auth::Role->TEST_ROLE1,
            });
            Bivio::Biz::Model->new($req, 'RealmUser')->create({
                realm_id => Bivio::Auth::Realm->get_general->get('id'),
                user_id => $uid,
                role => Bivio::Auth::Role->TEST_ROLE2,
            });
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
<form method="POST" action="/fourem/EasyForm/btest?goto=/fourem/pub/EasyForm-btest-done.html">
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
	path => 'EasyForm/btest.csv',
    }, \(<<'EOF'));
&date,&email,input,ok
EOF
    $self->model('RealmFile')->create_with_content({
	path => Bivio::Type->get_instance('WikiName')->to_absolute('ShellUtilHelp'),
    }, \(<<'EOF'));
Shell utility help.
EOF
    $self->model('RealmFile')->create_with_content({
	path => Bivio::Type->get_instance('WikiName')->to_absolute('base.css'),
    }, \(<<'EOF'));
.fourem_wiki {}
EOF
    $self->model('ForumForm', {
        'RealmOwner.display_name' => 'Site Help Forum',
	'RealmOwner.name' => $self->FOUREM . '-site-help',
    });
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
    $self->model('ForumUserAddForm', {
	'RealmUser.realm_id' => $req->get('auth_id'),
	'User.user_id' => $req->get('auth_user_id'),
    });
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

=head1 COPYRIGHT

Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

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
