# Copyright (c) 2001-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::SimpleTaskId;
# DEPRECATED: Subclass Bivio::Delegate::TaskId for new projects.
#
# Defines the common tasks.  You subclass this module, and call merge_task_info
# as follows:
#	package MyProject::Delegate::TaskId;
#	sub get_delegate_info {
#	    return shift->merge_task_info(qw(base xapian), [
#	        Your tasks here.  Use numbers > 500
#	    ]);
#	}
use strict;
use Bivio::Base 'Bivio.Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_INFO_RE) = qr{^info_(.*)};
my($_INCLUDED) = {};
my($_PS) = b_use('Auth.PermissionSet');

sub all_components {
    Bivio::IO::Alert->warn_deprecated('use standard_components');
    return shift->standard_components;
}

sub bunit_validate_all {
    # Sanity check to make sure the the list of info_ methods don't collide
    my($proto) = @_;
    my($seen) = {};
    foreach my $c (@{$proto->standard_components}) {
	foreach my $t (@{_component_info($proto, $c) || []}) {
	    my($n) = $t->[0];
	    Bivio::Die->die($c, ' and ', $seen->{$n}, ': both define ', $n)
	        if $seen->{$n};
	    $seen->{$n} = $c;
	}
    }
    return;
}

sub get_delegate_info {
    # For backwards compatibility
    return shift->info_base(@_);
}

sub included_components {
    return [sort _sort keys(%$_INCLUDED)];
}

sub info_base {
    return [
	[qw(
	    SHELL_UTIL
	    1
	    GENERAL
	    ANYBODY
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
            cancel=SITE_ROOT
	)],
	[qw(
	    SITE_ROOT
	    2
	    GENERAL
	    ANYBODY
	    Action.ClientRedirect->execute_home_page_if_site_root
	    Action.LocalFilePlain->execute_uri_as_view
	)],
	[qw(
	    LOCAL_FILE_PLAIN
	    3
	    GENERAL
	    ANYBODY
	    Action.LocalFilePlain
	    want_query=0
	)],
	# used by UI::Task
	[qw(
	    MY_SITE
	    4
	    GENERAL
	    ANY_USER
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	# used by Model::RealmOwner
	[qw(
	    USER_HOME
	    5
	    USER
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	# used by UI::Task
	[qw(
	    MY_CLUB_SITE
	    6
	    GENERAL
	    ANY_USER
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	# used by Model.RealmOwner
	[qw(
	    CLUB_HOME
	    7
	    CLUB
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	# Redirects to a uri supplied in the query
	[qw(
	    CLIENT_REDIRECT
	    8
	    GENERAL
	    ANYBODY
	    Action.ClientRedirect->execute_query
	    next=SITE_ROOT
	)],
 	[qw(
 	    HELP
 	    9
 	    GENERAL
 	    DATA_READ
 	    Action.WikiView->execute_help
	    View.wiki
	    want_author=0
	    MODEL_NOT_FOUND=HELP_NOT_FOUND
 	)],
	# Handy for demos and such.  You need to provide a link in the
	# "plain" space to the view source, e.g.
	#    cd plain; ln -s ../view vs
	[qw(
	    VIEW_AS_PLAIN_TEXT
	    10
	    GENERAL
	    ANYBODY
	    Action.ViewAsPlainText
	)],
	[qw(
	    ADM_SUBSTITUTE_USER
	    11
	    GENERAL
	    ADMIN_READ&ADMIN_WRITE
	    Model.AdmSubstituteUserForm
            View.adm-substitute-user
	    next=MY_SITE
	)],
	# To make this visible, add this to Task section of your facade:
	#   $t->group(FAVICON_ICO => '/favicon.ico');
        # and in the Text section:
	#   $t->group(favicon_uri => '/i/favicon.ico');
	[qw(
            FAVICON_ICO
            12
            GENERAL
            ANYBODY
            Action.LocalFilePlain->execute_favicon
        )],
	[qw(
            DEFAULT_ERROR_REDIRECT_FORBIDDEN
            13
            GENERAL
            ANYBODY
            Model.ForbiddenForm
            next=FORBIDDEN
	    login_task=LOGIN
        )],
        [qw(
            FORBIDDEN
            14
            GENERAL
            ANYBODY
            Action.Forbidden
        )],
        # Add this to the Task section of your facade:
        #   $t->group(ROBOTS_TXT => 'robots.txt');
	[qw(
            ROBOTS_TXT
            15
            GENERAL
            ANYBODY
            Action.LocalFilePlain->execute_robots_txt
        )],
	[qw(
	    TEST_BACKDOOR
	    16
	    GENERAL
	    TEST_TRANSIENT
	    Action.TestBackdoor
	    Action.MailReceiveStatus
	)],
	# used by Model.RealmOwner
	[qw(
	    FORUM_HOME
	    17
	    FORUM
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
	    GENERAL_USER_PASSWORD_QUERY
	    18
	    GENERAL
	    ANYBODY
	    Model.UserPasswordQueryForm
	    View.user-password-query
	    reset_task=USER_PASSWORD_RESET
	    next=GENERAL_USER_PASSWORD_QUERY_MAIL
	    cancel=SITE_ROOT
	)],
	[qw(
	    GENERAL_USER_PASSWORD_QUERY_MAIL
	    19
	    GENERAL
	    ANYBODY
	    View.user-password-query-mail
	    Action.ServerRedirect->execute_next
	    next=GENERAL_USER_PASSWORD_QUERY_ACK
	)],
	[qw(
	    USER_PASSWORD_RESET
	    20
	    USER
	    ANYBODY
	    Action.UserPasswordQuery
	    password_task=USER_PASSWORD
	    NOT_FOUND=GENERAL_USER_PASSWORD_QUERY
	)],
        # forbidden errors are probably due to missing cookies.
        # for example, if user is resetting password from email link
        #   with cookies disabled
	[qw(
	    USER_PASSWORD
	    21
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.UserPasswordForm
	    View.user-password
	    next=MY_SITE
            FORBIDDEN=DEFAULT_ERROR_REDIRECT_MISSING_COOKIES
	)],
	[qw(
	    GENERAL_USER_PASSWORD_QUERY_ACK
	    22
	    GENERAL
	    ANYBODY
	    View.user-password-query-ack
	)],
	[qw(
            DEFAULT_ERROR_REDIRECT_MISSING_COOKIES
	    23
	    GENERAL
	    ANYBODY
	    View.missing-cookies
	)],
	# used by Model.RealmOwner
	[qw(
	    CALENDAR_EVENT_HOME
	    24
	    CALENDAR_EVENT
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
            MAIL_RECEIVE_DISPATCH
            37
	    GENERAL
	    ANYBODY
	    Model.MailReceiveDispatchForm
            next=MAIL_RECEIVE_NOT_FOUND
            NOT_FOUND=MAIL_RECEIVE_NOT_FOUND
            MODEL_NOT_FOUND=MAIL_RECEIVE_NOT_FOUND
            NO_RESOURCES=MAIL_RECEIVE_NO_RESOURCES
	    FORBIDDEN=MAIL_RECEIVE_FORBIDDEN
	    email_alias_task=MAIL_RECEIVE_FORWARD
	    ignore_task=MAIL_RECEIVE_IGNORE
	)],
	[qw(
            MAIL_RECEIVE_NO_RESOURCES
            38
            GENERAL
            ANYBODY
            Action.MailReceiveStatus->execute_no_resources
        )],
	[qw(
            MAIL_RECEIVE_NOT_FOUND
            39
            GENERAL
            ANYBODY
            Action.MailReceiveStatus->execute_not_found
        )],
	[qw(
            MAIL_RECEIVE_IGNORE
            40
            USER
            ANYBODY
            Action.MailReceiveStatus->execute
        )],
	[qw(
            MAIL_RECEIVE_FORWARD
            41
	    GENERAL
	    ANYBODY
	    Action.MailForward
            Action.MailReceiveStatus->execute
	)],
	[qw(
            FORUM_MAIL_RECEIVE
            42
            FORUM
            MAIL_SEND
            Action.RealmMail->execute_receive
            Action.MailReceiveStatus->execute
        )],
	[qw(
            FORUM_EASY_FORM
            43
            FORUM
            ANYBODY
            Action.EasyForm
        )],
# 44
	[qw(
	    GENERAL_CONTACT
	    45
	    GENERAL
	    ANYBODY
	    Model.ContactForm
	    View.contact
	    next=SITE_ROOT
	)],
	[qw(
            USER_MAIL_BOUNCE
            46
            USER
            ANYBODY
            Model.RealmMailBounce
            Action.MailReceiveStatus->execute
        )],
	[qw(
            MAIL_RECEIVE_FORBIDDEN
            47
            GENERAL
            ANYBODY
            Action.MailReceiveStatus->execute_forbidden
        )],
 	[qw(
 	    FORUM_WIKI_VIEW
 	    48
 	    FORUM
 	    DATA_READ
 	    Action.WikiView
	    View.wiki
	    MODEL_NOT_FOUND=FORUM_WIKI_NOT_FOUND
	    edit_task=FORUM_WIKI_EDIT
	    want_author=1
 	)],
  	[qw(
 	    FORUM_WIKI_EDIT
 	    49
 	    FORUM
 	    DATA_READ&DATA_WRITE
 	    Model.WikiForm
	    View.wiki-edit
	    next=FORUM_WIKI_VIEW
 	)],
 	[qw(
 	    FORUM_WIKI_NOT_FOUND
 	    50
 	    FORUM
 	    DATA_READ
	    View.wiki-not-found
	    view_task=FORUM_WIKI_VIEW
 	)],
 	[qw(
 	    HELP_NOT_FOUND
 	    51
 	    GENERAL
 	    DATA_READ
	    View.wiki-not-found
	    view_task=HELP
 	)],
 	[qw(
 	    FORUM_FILE
 	    52
 	    FORUM
 	    DATA_READ
 	    Action.RealmFile->execute_private
        )],
	[qw(
            FORUM_MAIL_REFLECTOR
            53
            FORUM
            MAIL_SEND
            Action.RealmMail->execute_reflector
        )],
 	[qw(
 	    FORUM_BLOG_VIEW
 	    54
 	    FORUM
 	    DATA_READ
            Model.BlogEntryList->execute_load_entry_or_page
	    View.blog
 	)],
  	[qw(
 	    FORUM_BLOG_EDIT
 	    55
 	    FORUM
 	    DATA_READ&DATA_WRITE
 	    Model.BlogForm
	    View.blog-edit
	    next=FORUM_BLOG_VIEW
 	)],
	[qw(
            PERMANENT_REDIRECT
            56
	    GENERAL
	    ANYBODY
	    Action.PermanentRedirect
	)],
#57-59 free
    ];
}

sub is_component_included {
    my(undef, $component) = @_;
    return $_INCLUDED->{$component} || 0;
}

sub merge_task_info {
    my($proto, @cfg) = @_;
    my($only_once) = sub {
	my($cfg) = @_;
	my($seen) = {};
	return [map(
	    ref($_) ne 'HASH' && $seen->{$_->[0]}++ ? () : $_,
	    @$cfg,
        )];
    };
    my($info) = sub {
	my($component) = @_;
	return @$component
	    if ref($component);
	return
	    unless my $tasks = _component_info($proto, $component);
	$_INCLUDED->{$component} = 1;
	return @$tasks;
    };
    return _merge_modifiers(
	$proto,
	$only_once->(
	    [map($info->($_), reverse(@cfg))]),
    );
}

sub standard_components {
    return [sort _sort grep($_ ne 'otp', @{shift->grep_methods($_INFO_RE)})];
}

sub _component_info {
    my($proto, $component) = @_;
    my($m) = "info_$component";
    b_die($component, ': no such info_* component')
        unless $proto->can($m);
    return $proto->$m();
}

sub _merge_modifiers {
    my($self, $cfg) = @_;
    my($map) = {};
    foreach my $c (reverse(@$cfg)) {
	if (ref($c) eq 'HASH') {
	    $map->{$c->{name}} = {
		%{$map->{$c->{name}} || b_die($c->{name}, ': not found')},
		%$c,
	    };
	}
	elsif (ref($c) eq 'ARRAY') {
	    my($n) = shift(@$c);
	    $map->{$n} = {
		name => $n,
		int => shift(@$c),
		realm_type => shift(@$c),
		permissions => shift(@$c),
		items => [grep(!/=/, @$c)],
		map(split(/=/, $_, 2), grep(/=/, @$c)),
	    };
	}
	else {
	    b_die($c, ': invalid config format');
	}
    }
    return [map({
	my($c) = $_;
	[
	    delete(@$c{qw(
		name
		int
		realm_type
		permissions
	    )}),
	    @{delete($c->{items})},
	    $c,
	];
    } sort({$a->{int} <=> $b->{int}} values(%$map)))];
}

sub _sort {
    return $a eq $b ? 0
	: $a eq 'base' ? -1
	: $b eq 'base' ? +1
	: $a cmp $b;
}

1;
