# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::SiteForum;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('IO.File');
my($_FN) = b_use('Type.ForumName');
my($_T) = b_use('FacadeComponent.Text');
my($_RM) = b_use('Action.RealmMail');
my($_C) = b_use('IO.Config');
my($_A) = b_use('IO.Alert');

sub ADMIN_REALM {
    return Bivio::UI::Facade->get_default->SITE_ADMIN_REALM_NAME;
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
    return Bivio::UI::Facade->get_default->SITE_REPORTS_REALM_NAME;
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
  init_forums -- creates site forums and imports the related files
EOF
}

sub add_default_staging_suffix {
    my($self, $name) = @_;
    return $_FN->join($name, 'staging');
}

sub forum_config {
    my($self) = @_;
    my($req) = $self->initialize_fully;
    my($_EVERYBODY) = b_use('Type.MailSendAccess')->EVERYBODY;
    return [
        $self->SITE_REALM => {
            'RealmOwner.display_name' => 'Web Site',
            sub_forums => [
                $self->CONTACT_REALM => {
                    'RealmOwner.display_name'
                        => _site_name_prefix('Support', $req),
                    mail_want_reply_to => 1,
                    mail_send_access => $_EVERYBODY,
                    post_create => [sub {
                        $self->new_other('CRM')->setup_realm;
                        return;
                    }],
                },
                $self->HELP_REALM => {
                    'RealmOwner.display_name' => 'Help',
                    mail_want_reply_to => 1,
                },
                $self->ADMIN_REALM => {
                    'RealmOwner.display_name' => 'Site Admin',
                    mail_want_reply_to => 0,
                    mail_send_access => $_EVERYBODY,
                    post_create => [sub {
                        $self->new_other('RealmRole')
                            ->edit_categories('+feature_site_admin');
                        return;
                    }],
                },
            ],
            post_create => [sub {
                $self->model('EmailAlias')->create({
                    incoming => _support_email($req),
                    outgoing => $self->CONTACT_REALM,
                });
                $_C->if_version(3, sub {
                    $self->new_other('HTTPStats')->init_forum(
                        $self->REPORTS_REALM);
                    return;
                });
                return;
            }],
        },
    ];
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

sub init_bulletin {
    my($self, $name, $display_name) = @_;
    my($req) = $self->initialize_fully;
    $display_name ||= _site_name_prefix(ucfirst($name), $req);
    $req->with_realm(undef, sub {
        $self->model('ForumForm', {
	   'RealmOwner.display_name' => $display_name,
	   'RealmOwner.name' => $name,
	   mail_want_reply_to => 1,
	});
	$self->model('RowTag')->map_invoke(create_value => [
	    [MAIL_SUBJECT_PREFIX => $_RM->EMPTY_SUBJECT_PREFIX],
	    [BULLETIN_MAIL_MODE => 1],
	]);
	$self->new_other('RealmRole')
	    ->edit_categories([qw(+mail_send_access_nobody +feature_bulletin)]);
	$self->model('EmailAlias')->create({
	    incoming => $req->format_email($req->format_email),
	    outgoing => _support_email($req),
	});
	$self->model('ForumForm', {
	    'RealmOwner.display_name' => $display_name . ' Staging',
	    'RealmOwner.name' => $self->add_default_staging_suffix($name),
	});
	$self->new_other('RealmRole')->edit_categories('+feature_bulletin');
	return;
    });
    return;
}

sub init_files {
    my($self) = @_;
    $self->new_other('SQL')->assert_ddl;
    $_A->warn_deprecated('use init_forums instead');
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

sub init_forum {
    my($self, $forum, $cfg) = @_;
    $cfg->{'RealmOwner.name'} = $forum;
    my($sub_forums) = delete($cfg->{sub_forums}) || [];
    my($post_create) = delete($cfg->{post_create}) || [];
    $self->req->with_realm(
        $_FN->is_top($forum) ? undef : $_FN->extract_top($forum),
        sub {
            $self->model(ForumForm => $cfg)
                unless $self->model('RealmOwner')->unauth_load({
                    name => $forum,
                });
            $self->req->with_user($self->new_other('TestUser')->ADM, sub {
                $_F->do_in_dir($forum => sub {
                    $self->new_other('RealmFile')->import_tree('/');
                    return;
                });
                return;
            })
                if $self->req->is_test && -d $forum;
            foreach my $op (@$post_create) {
                $op->($cfg);
            }
            return;
        },
    );
    $self->map_by_two(sub {
        my($sub_forum, $sub_cfg) = @_;
        # throw away any sub-sub-forums: we allow only one layer deep
        delete($sub_cfg->{sub_forums});
        $self->init_forum($sub_forum, $sub_cfg);
        return;
    }, $sub_forums);
    return;
}

sub init_forums {
    my($self) = @_;
    $self->map_by_two(sub {
        $self->init_forum(@_);
        return;
    }, $self->forum_config);
    return;
}

sub init_realms {
    $_A->warn_deprecated('use init_forums instead');
    return shift->init_forums(@_);
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
    $_A->warn_deprecated('use forum_config instead');
    $self->initialize_fully;
    return [
	$self->SITE_REALM,
	$self->CONTACT_REALM,
	$self->HELP_REALM,
	$self->ADMIN_REALM,
    ];
}

sub _site_name_prefix {
    my($suffix, $req) = @_;
    return b_use('UI.Text')->get_value('site_name', $req) . " $suffix";
}

sub _support_email {
    my($req) = @_;
    return $req->format_email($_T->get_value('support_email'), $req);
}

1;
