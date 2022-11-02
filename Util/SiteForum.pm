# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::SiteForum;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_F) = b_use('IO.File');
my($_FN) = b_use('Type.ForumName');
my($_T) = b_use('FacadeComponent.Text');
my($_RM) = b_use('Action.RealmMail');
my($_C) = b_use('IO.Config');
my($_WN) = b_use('Type.WikiName');
my($_ADMIN_USER_ATTR) = __PACKAGE__ . '.admin';

sub ADMIN_REALM {
    return _facade()->SITE_ADMIN_REALM_NAME;
}

sub CONTACT_REALM {
    return _facade()->SITE_CONTACT_REALM_NAME;
}

sub HELP_REALM {
    return _facade()->HELP_WIKI_REALM_NAME;
}

sub DEFAULT_MAKE_ADMIN_REALMS {
    return [shift->SITE_REALM];
}

sub REPORTS_REALM {
    return _facade()->SITE_REPORTS_REALM_NAME;
}

sub SITE_REALM {
    return _facade()->SITE_REALM_NAME;
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

sub add_default_staging_suffix {
    my($self, $name) = @_;
    return $_FN->join($name, 'staging');
}

sub add_users_to_site_admin {
    my($self) = @_;
    $self->initialize_fully;
    my($f) = _facade();
    my($req) = $self->req;
    $req->with_realm($f->SITE_ADMIN_REALM_NAME, sub {
        my($rid) = $req->get('auth_id');
        my($ro) = $self->model('RealmOwner');
        my($ru) = $self->model('RealmUser');
        $self->model('AdmUserList')->do_iterate(
            sub {
                my($it) = @_;
                return 1
                    if $ro->is_offline_user($it, 'RealmOwner.');
                my($uid) = $it->get('User.user_id');
                return 1
                    if $ru->rows_exist({user_id => $uid});
                $ru->create({
                    role => b_use('Auth.Role')->from_name(
                        $req->is_super_user($uid)
                        ? 'ADMINISTRATOR'
                        : 'USER',
                    ),
                    user_id => $uid,
                });
                return 1;
            },
        );
        return;
    });
    return;
}

sub admin_user {
    my($self) = @_;
    return $self->req($_ADMIN_USER_ATTR);
}

sub forum_config {
#TODO: NOT USED; need to convert init_realms to use this    
    my($self) = @_;
    my($req) = $self->initialize_fully;
    my($_EVERYBODY) = b_use('Type.MailSendAccess')->EVERYBODY;
    return [
        $self->SITE_REALM => {
            'RealmOwner.display_name' => 'Site',
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
                        _init_admin_features($self);
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
    $self->init_files
        if $_C->is_test;
    return;
}

sub init_admin_user {
    my($self) = @_;
    my($req) = $self->get_request;
    if ($_C->is_test) {
        $self->new_other('TestUser')->init_adm;
        $self->req->put($_ADMIN_USER_ATTR => $self->req(qw(auth_user name)));
    }
    else {
        $req->set_user(
            $req->get_if_exists_else_put($_ADMIN_USER_ATTR => sub {
                return $req->get('auth_user_id')
                    && !$req->get('auth_user')->is_default
                    && $req->unsafe_get_nested(qw(auth_user name))
                    || $self->new_other('RealmAdmin')->create_user(
                        $self->convert_literal(
                            Email => $self->readline_stdin('Administrator email: '),
                        ),
                    ),
                },
            ),
        );
    }
    $self->new_other('RealmRole')->make_super_user
        unless $req->is_super_user;
    return $req;
}

sub init_bulletin {
    my($self, $name, $display_name) = @_;
    my($req) = $self->initialize_fully;
    $name ||= b_use('FacadeComponent.Constant')->get_value('bulletin_realm_name', $req);
    $display_name ||= _site_name_prefix(ucfirst($name), $req);
    $req->with_realm(
        undef,
        sub {
            $self->set_user_to_any_online_admin;
            $self->model('ForumForm', {
               'RealmOwner.display_name' => $display_name,
               'RealmOwner.name' => $name,
               mail_want_reply_to => 1,
            });
            $self->model('RowTag')->map_invoke(create_value => [
                [MAIL_SUBJECT_PREFIX => $_RM->EMPTY_SUBJECT_PREFIX],
                [BULLETIN_MAIL_MODE => 1],
                [BULLETIN_BODY_TEMPLATE => 1],
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
                mail_want_reply_to => 1,
            });
            $self->model('RowTag')->map_invoke(create_value => [
                [MAIL_SUBJECT_PREFIX => $_RM->EMPTY_SUBJECT_PREFIX],
                [BULLETIN_MAIL_MODE => 1],
                [BULLETIN_BODY_TEMPLATE => 1],
            ]);
            $self->new_other('RealmRole')->edit_categories('+feature_bulletin');
            return;
        },
    );
    return $name;
}

sub init_files {
    sub INIT_FILES {[
        [
            'realm_names',
            'StringArray',
            sub {b_use('Type.StringArray')->from_literal_or_die(shift->realm_names)},
        ],
    ]}
    my($self, $bp) = shift->parameters(\@_);
    $self->initialize_fully;
    $self->new_other('SQL')->assert_ddl;
    $self->req->with_user(undef, sub {
        return $bp->{realm_names}->do_iterate(
            sub {
                my($realm) = @_;
                $self->req->with_realm($realm, sub {
                    $self->set_user_to_any_online_admin;
                    return $_F->do_in_dir($realm => sub {
                        $self->new_other('RealmFile')->import_tree('/');
                        return;
                    }) if -d $realm;
                    $self->model('RealmFile')
                        ->create_or_update_with_content(
                            {path => $_WN->to_absolute($_WN->START_PAGE, 1)},
                            \('Placeholder'),
                        );
                    return;
                });
                return 1;
            },
        );
    });
    return;
}

sub init_forum {
    my($self, $forum, $cfg) = @_;
    $cfg->{'RealmOwner.name'} = $forum;
    my($sub_forums) = delete($cfg->{sub_forums}) || [];
    my($post_create) = delete($cfg->{post_create}) || [];
    $self->req->with_realm_and_user(
        $_FN->is_top($forum) ? undef : $_FN->extract_top($forum),
#TODO: This shoulnd't be ADM but init_admin_user
        $self->new_other('TestUser')->ADM,
        sub {
            $self->model(ForumForm => $cfg)
                unless $self->model('RealmOwner')->unauth_load({
                    name => $forum,
                });
            $_F->do_in_dir(
                $forum,
                sub {
                    $self->new_other('RealmFile')->import_tree('/');
                    return;
                },
            ) if $_C->is_test && -d $forum;
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
    my($self) = @_;
    my($req) = $self->initialize_fully;
    $req->with_realm(undef, sub {
        $self->model('ForumForm', {
            'RealmOwner.name' => $self->SITE_REALM,
            'RealmOwner.display_name' => 'Web Site',
        });
        $self->internal_post_site_create;
        return;
    });
    $req->with_realm($self->SITE_REALM, sub {
        $self->model('ForumForm', {
           'RealmOwner.display_name' => _site_name_prefix('Support', $req),
           'RealmOwner.name' => $self->CONTACT_REALM,
           mail_want_reply_to => 1,
           mail_send_access => b_use('Type.MailSendAccess')->EVERYBODY,
        });
        $self->new_other('CRM')->setup_realm;
        return;
    });
    $req->with_realm($self->SITE_REALM, sub {
        $self->model('ForumForm', {
           'RealmOwner.display_name' => 'Help',
           'RealmOwner.name' => $self->HELP_REALM,
           mail_want_reply_to => 1,
        });
        return;
    }) unless $self->model('RealmOwner')->unauth_load({name => $self->HELP_REALM});
    $_C->if_version(3, sub {
        $self->new_other('HTTPStats')->init_forum($self->REPORTS_REALM);
        return;
    });
    $self->req->with_realm($self->SITE_REALM, sub {
        $self->model('ForumForm', {
           'RealmOwner.display_name' => 'Site Admin',
           'RealmOwner.name' => $self->ADMIN_REALM,
           mail_want_reply_to => 0,
           mail_send_access => b_use('Type.MailSendAccess')->EVERYBODY,
        });
        _init_admin_features($self);
        return;
    });
    $self->add_users_to_site_admin;
    # $self->model('EmailAlias')->create({
    #         incoming => _support_email($req),
    #         outgoing => $self->CONTACT_REALM,
    # });
    return;
}

sub internal_post_site_create {
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
    ];
}

sub _facade {
    return b_use('Agent.Request')
        ->get_current_or_die
        ->unsafe_get('UI.Facade')
        || b_use('UI.Facade')
        ->get_default;
}

sub _init_admin_features {
    my($self) = @_;
    $self->new_other('RealmRole')->edit_categories(
        '+feature_site_admin',
        b_use('Agent.TaskId')
            ->unsafe_from_name('GROUP_TASK_LOG')
            ? '+feature_task_log' : (),
    );
    return;
}

sub _site_name_prefix {
    my($suffix, $req) = @_;
    return $_T->get_value('site_name', $req) . " $suffix";
}

sub _support_email {
    my($req) = @_;
    return $req->format_email($_T->get_value('support_email', $req));
}

1;
