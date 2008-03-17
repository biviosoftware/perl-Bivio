# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::SiteForum;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = __PACKAGE__->use('UI.Text');
my($_F) = __PACKAGE__->use('UI.Facade');

sub CONTACT_REALM {
    return Bivio::UI::Facade->get_default->SITE_CONTACT_REALM_NAME;
}

sub HELP_REALM {
    return Bivio::UI::Facade->get_default->HELP_WIKI_REALM_NAME;
}

sub SITE_REALM {
    return Bivio::UI::Facade->get_default->SITE_REALM_NAME;
}

sub USAGE {
    return <<'EOF';
usage: b-site-forum [options] command [args..]
commands
  make_admin [realm] -- add auth user as admin to site forums
  init -- create site forums, files, and aliases
  realm_names -- which realm names created by init
EOF
}

sub init {
    my($self) = @_;
    my($req) = $self->initialize_fully;
    $req->with_realm(undef, sub {
        $self->model('ForumForm', {
	    'RealmOwner.name' => $self->SITE_REALM,
	    'RealmOwner.display_name' => 'Web Site',
	});
	$self->new_other('RealmRole')->edit_categories('+feature_site_adm');
	return;
    });
    $req->with_realm($self->SITE_REALM, sub {
        $self->model('ForumForm', {
	   'RealmOwner.display_name' => $_T->get_value('support_name', $req),
	   'RealmOwner.name' => $self->CONTACT_REALM,
	   'Forum.want_reply_to' => 1,
	   'public_forum_email' => 1,
	});
	$self->new_other('RealmRole')->edit_categories('+feature_crm');
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
    $self->model('EmailAlias')->create({
	incoming => $req->format_email(
	    Bivio::UI::Text->get_value('support_email'), $req),
	outgoing => $self->CONTACT_REALM,
    });
    $req->with_realm(
	$_F->get_from_request_or_self($req)->SITE_ADM_REALM_NAME,
	sub {
	    $self->new_other('RealmRole')->edit_categories('+feature_site_adm');
	    return;
	},
    );
    return;
}

sub make_admin {
    my($self, $realm) = @_;
    $self->get_request->with_realm(
	$realm || $self->SITE_REALM,
	sub {
	    $self->model('ForumUserAddForm', {
		'RealmUser.realm_id' => $self->req('auth_id'),
		'User.user_id' => $self->req('auth_user_id'),
		administrator => 1,
	    });
	    return;
	},
    );
    return;
}

sub realm_names {
    my($self) = @_;
    $self->initialize_fully;
    return [
	$self->SITE_REALM,
	$self->CONTACT_REALM,
	$self->HELP_REALM,
    ];
}

1;
