# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::SiteForum;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CONTACT_REALM {
    return 'site-contact';
}

sub SITE_REALM {
    return 'site';
}

sub USAGE {
    return <<'EOF';
usage: b-site-forum [options] command [args..]
commands
  init -- create site forums, files, and aliases
EOF
}

sub init {
    my($self) = @_;
    my($req) = $self->initialize_fully;
    $req->with_realm(undef, sub {
        $self->model('ForumForm', {
	    'RealmOwner.name' => $self->SITE_REALM,
	    'RealmOwner.display_name' => 'Web Site Forum',
	});
    });
    $req->with_realm($self->SITE_REALM, sub {
        $self->model('ForumForm', {
	   'RealmOwner.display_name' => 'Web Contact Forum',
	   'RealmOwner.name' => $self->CONTACT_REALM,
	   'Forum.want_reply_to' => 1,
	   'public_forum_email' => 1,
	});
    });
    $self->model('EmailAlias')->create({
	incoming => $req->format_email(
	    Bivio::UI::Text->get_value('support_email'), $req),
	outgoing => $self->CONTACT_REALM,
    });
    return;
}

1;
