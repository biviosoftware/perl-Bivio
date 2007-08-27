# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::SiteForum;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTACT_REALM {
    return 'site-contact';
}

sub HELP_REALM {
    return Bivio::UI::Facade->get_default->HELP_WIKI_REALM_NAME;
}

sub SITE_REALM {
    return 'site';
}

sub USAGE {
    return <<'EOF';
usage: b-site-forum [options] command [args..]
commands
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
    });
    $req->with_realm($self->SITE_REALM, sub {
        $self->model('ForumForm', {
	   'RealmOwner.display_name' => 'Web Contacts',
	   'RealmOwner.name' => $self->CONTACT_REALM,
	   'Forum.want_reply_to' => 1,
	   'public_forum_email' => 1,
	});
    });
    $req->with_realm($self->SITE_REALM, sub {
        $self->model('ForumForm', {
	   'RealmOwner.display_name' => 'Help',
	   'RealmOwner.name' => $self->HELP_REALM,
	   'Forum.want_reply_to' => 1,
	});
    });
    $self->model('EmailAlias')->create({
	incoming => $req->format_email(
	    Bivio::UI::Text->get_value('support_email'), $req),
	outgoing => $self->CONTACT_REALM,
    });
    return;
}

sub realm_names {
    my($self) = @_;
    $self->initialize_fully;
    return [
	$self->SITE_REALM,
	$self->CONTACT_REALM,
	Bivio::UI::Facade->get_default->HELP_WIKI_REALM_NAME,
    ];
}

1;
