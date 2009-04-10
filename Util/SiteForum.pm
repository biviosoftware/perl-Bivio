# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::SiteForum;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('IO.File');
my($_FN) = b_use('Type.ForumName');

sub ADMIN_REALM {
    return Bivio::UI::Facade->get_default->SITE_ADMIN_REALM_NAME;
}

sub BULLETIN_REALM {
    return 'bulletin';
}

sub BULLETIN_STAGING {
    return $_FN->join(shift->BULLETIN_REALM, 'staging');
}

sub CONTACT_REALM {
    return Bivio::UI::Facade->get_default->SITE_CONTACT_REALM_NAME;
}

sub HELP_REALM {
    return Bivio::UI::Facade->get_default->HELP_WIKI_REALM_NAME;
}

sub DEFAULT_MAKE_ADMIN_REALMS {
    return [shift->SITE_REALM];
}

sub REPORTS_REALM {
    return Bivio::UI::Facade->get_default->SITE_REPORTS;
}

sub SITE_REALM {
#TODO: Need to get this naming straight.  SITE_REALM_NAME should only 
    return 'site';
}

sub USAGE {
    return <<'EOF';
usage: b-site-forum [options] command [args..]
commands
  make_admin [realm] -- add auth user as admin to site forums
  init -- create site forums, files, and aliases
  init_admin_user -- creates admin user
  init_files -- import files for realm_names() in ddl directory
  init_realms -- creates site realms
  realm_names -- which realm names created by init
EOF
}

sub create_bulletin_forums {
    my($self) = @_;
    $self->req->with_realm(undef, sub {
        $self->model('ForumForm', {
	   'RealmOwner.display_name' => 'Bulletins',
	   'RealmOwner.name' => $self->BULLETIN_REALM,
	});
	$self->req->with_realm($self->BULLETIN_REALM, sub {
	    $self->model('RowTag')->create_value(MAIL_SUBJECT_PREFIX => '!');
            $self->new_other('RealmRole')
		->edit_categories('+admin_only_forum_email');
            $self->model('ForumForm', {
		'RealmOwner.display_name' => 'Bulletin Staging',
		'RealmOwner.name' => $self->BULLETIN_STAGING,
	    });
	});
	return;
    });
    return;
}

sub init {
    my($self) = @_;
    $self->init_admin_user;
    $self->init_realms;
    $self->init_files;
    return;
}

sub init_admin_user {
    my($self) = @_;
    my($req) = $self->initialize_fully;
    if ($req->is_test) {
	$self->new_other('TestUser')->init_adm;
    }
    else {
	$req->set_user(
	    $req->get_if_exists_else_put(__PACKAGE__ . '.admin' => sub {
	        return $req->unsafe_get_nested(qw(auth_user name))
		    || $self->new_other('RealmAdmin')->create_user(
			$self->convert_literal(
			    Email => $self->readline_stdin('Administrator email: '),
			),
		    ),
		},
            ),
	);
    }
    return $req;
}

sub init_files {
    my($self) = @_;
    $self->initialize_fully;
    $self->new_other('SQL')->assert_ddl;
    $self->req->with_user($self->new_other('TestUser')->ADM, sub {
        foreach my $realm (@{$self->realm_names}) {
	    $self->req->with_realm($realm, sub {
		$_F->do_in_dir($realm => sub {
		    $self->new_other('RealmFile')->import_tree('/');
		    return;
		}) if -d $realm;
		return;
	    });
	}
    });
    return;
}

sub init_realms {
    my($self) = @_;
    my($req) = $self->initialize_fully;
    $req->with_realm(undef, sub {
        $self->model('ForumForm', {
	    'RealmOwner.name' => $self->SITE_REALM,
	    'RealmOwner.display_name' => 'Web Site',
	});
	return;
    });
    $req->with_realm($self->SITE_REALM, sub {
        $self->model('ForumForm', {
	   'RealmOwner.display_name'
	       => b_use('UI.Text')->get_value('site_name', $req) . ' Support',
	   'RealmOwner.name' => $self->CONTACT_REALM,
	   'Forum.want_reply_to' => 1,
	   'public_forum_email' => 1,
	});
	$self->new_other('CRM')->setup_realm;
	return;
    });
    $req->with_realm($self->SITE_REALM, sub {
        $self->model('ForumForm', {
	   'RealmOwner.display_name' => 'Help',
	   'RealmOwner.name' => $self->HELP_REALM,
	   'Forum.want_reply_to' => 1,
	});
	return;
    });
    $self->req->with_realm($self->SITE_REALM, sub {
        $self->model('ForumForm', {
	   'RealmOwner.display_name' => 'User Admin',
	   'RealmOwner.name' => $self->ADMIN_REALM,
	   'Forum.want_reply_to' => 0,
	   'public_forum_email' => 1,
	});
	$self->new_other('RealmRole')->edit_categories('+feature_site_admin');
	return;
    });
    $self->create_bulletin_forums;
    $self->model('EmailAlias')->create({
	incoming => $req->format_email(
	    Bivio::UI::Text->get_value('support_email'), $req),
	outgoing => $self->CONTACT_REALM,
    });
    return;
}

sub make_admin {
    my($self, $realm) = shift->name_args(['?RealmName'], \@_);
    foreach my $r ($realm ? $realm : @{$self->DEFAULT_MAKE_ADMIN_REALMS}) {
	$self->get_request->with_realm(
	    $r,
	    sub {
		$self->model('ForumUserAddForm', {
		    'RealmUser.realm_id' => $self->req('auth_id'),
		    'User.user_id' => $self->req('auth_user_id'),
		    administrator => 1,
		});
		return;
	    },
	);
    }
    return;
}

sub realm_names {
    my($self) = @_;
    $self->initialize_fully;
    return [
	$self->SITE_REALM,
	$self->CONTACT_REALM,
	$self->HELP_REALM,
	$self->ADMIN_REALM,
	$self->BULLETIN_REALM,
	$self->BULLETIN_STAGING,
    ];
}

1;
