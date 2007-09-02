# Copyright (c) 2001-2007 bivio Software, Inc.  All Rights Reserved.
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
use base 'Bivio::Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_INFO_RE) = qr{^info_(.*)};
my($_INCLUDED) = {};

sub all_components {
    return [grep({$_ ne 'info_otp'} @{shift->grep_methods($_INFO_RE)})];
}

sub bunit_validate_all {
    # Sanity check to make sure the the list of info_ methods don't collide
    my($proto) = @_;
    my($seen) = {};
    foreach my $c (@{$proto->all_components}) {
	foreach my $t (@{_component_info($proto, $c)}) {
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
    return [sort(keys(%$_INCLUDED))];
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
	    DAV
	    25
	    GENERAL
	    ANYBODY
	    Action.BasicAuthorization
	    Action.DAV
	    next=DAV_ROOT_FORUM_LIST
	)],
	[qw(
	    DAV_ROOT_FORUM_LIST
	    26
	    GENERAL
	    DATA_READ
	    Model.UserForumDAVList
	    next=DAV_FORUM_LIST
	    forums_csv_task=DAV_ROOT_FORUM_LIST_EDIT
	    email_aliases_csv_task=DAV_EMAIL_ALIAS_LIST_EDIT
	)],
#	    mail_task=DAV_MAIL_FOLDER_LIST
	[qw(
	    DAV_FORUM_LIST
	    27
	    FORUM
	    DATA_READ
	    Model.UserForumDAVList
	    next=DAV_FORUM_LIST
	    files_task=DAV_FORUM_FILE
	    forums_csv_task=DAV_FORUM_LIST_EDIT
	    members_csv_task=DAV_FORUM_USER_LIST_EDIT
	    calendar_ics_task=DAV_FORUM_CALENDAR_EVENT_LIST_EDIT
	)],
	[qw(
	    DAV_FORUM_FILE
	    28
	    FORUM
	    DATA_READ
	    Model.RealmFileDAVList
	    require_dav=1
	)],
	[qw(
	    DAV_ROOT_FORUM_LIST_EDIT
	    29
	    GENERAL
	    ADMIN_READ
	    Model.Lock->execute_unless_acquired
	    Model.ForumList->execute_load_all
	    Model.ForumEditDAVList
	)],
	[qw(
	    DAV_FORUM_LIST_EDIT
	    30
	    FORUM
	    ADMIN_READ
	    Model.Lock->execute_unless_acquired
	    Model.ForumList->execute_load_all
	    Model.ForumEditDAVList
	)],
 	[qw(
	    DAV_FORUM_USER_LIST_EDIT
	    31
	    FORUM
	    ADMIN_READ
	    Model.Lock->execute_unless_acquired
	    Model.ForumUserList->execute_load_all
	    Model.ForumUserEditDAVList
	)],
	[qw(
	    FORUM_CALENDAR_EVENT_LIST_RSS
            32
            FORUM
            DATA_READ
            Model.CalendarEventList->execute_load_page
            View.calendar-event-list-rss
        )],
	[qw(
	    DAV_FORUM_CALENDAR_EVENT_LIST_EDIT
	    33
	    FORUM
	    DATA_READ
	    Model.Lock->execute_unless_acquired
	    Model.CalendarEventDAVList
	)],
# 	[qw(
# 	    DAV_MAIL_FOLDER_LIST
# 	    34
# 	    GENERAL
# 	    DATA_READ
# 	    Model.UserForumDAVList
# 	    next=DAV_MAIL_MESSAGE_LIST
# 	)],
# 	[qw(
# 	    DAV_MAIL_MESSAGE_LIST
# 	    35
# 	    FORUM
# 	    DATA_READ
# 	    Model.UserMailDAVList
# 	)],
 	[qw(
	    DAV_EMAIL_ALIAS_LIST_EDIT
	    36
	    GENERAL
	    ADMIN_READ
	    Model.EmailAliasList->execute_load_all
	    Model.EmailAliasEditDAVList
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
 	[qw(
 	    FORUM_PUBLIC_FILE
 	    44
 	    FORUM
 	    ANYBODY
 	    Action.RealmFile->execute_public
 	)],
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
 	    Action.RealmFile
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

sub info_otp {
    return [
	[qw(
	    OTP_PASSWORD
	    130
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.UserPasswordForm
            View.UserAuth->otp_password
	    next=SITE_ROOT
	)],
#131-139 free
    ];
}

sub info_tuple {
    Bivio::IO::Config->introduce_values({
	'Bivio::Biz::Model::RealmMail' => {
	    create_hook => sub {
		my($m) = @_;
		$m->get_instance('Tuple')->realm_mail_hook(@_);
		return;
	    },
	},
    });
    return [
	[qw(
	    FORUM_TUPLE_SLOT_TYPE_LIST
	    70
	    FORUM
	    TUPLE_ADMIN
	    Model.TupleSlotTypeList->execute_load_all_with_query
	    View.Tuple->slot_type_list
	)],
	[qw(
	    FORUM_TUPLE_SLOT_TYPE_EDIT
	    71
	    FORUM
	    TUPLE_ADMIN
	    Model.TupleSlotTypeListForm
	    View.Tuple->slot_type_edit
	    next=FORUM_TUPLE_SLOT_TYPE_LIST
	)],
	[qw(
	    FORUM_TUPLE_DEF_LIST
	    72
	    FORUM
	    TUPLE_ADMIN
	    Model.TupleDefList->execute_load_all_with_query
	    View.Tuple->def_list
	)],
	[qw(
	    FORUM_TUPLE_DEF_EDIT
	    73
	    FORUM
	    TUPLE_ADMIN
	    Model.TupleDefListForm
	    View.Tuple->def_edit
	    next=FORUM_TUPLE_DEF_LIST
	)],
	[qw(
	    FORUM_TUPLE_USE_LIST
	    74
	    FORUM
	    TUPLE_READ
	    Model.TupleUseList->execute_load_all_with_query
	    View.Tuple->use_list
	)],
	[qw(
	    FORUM_TUPLE_USE_EDIT
	    75
	    FORUM
	    TUPLE_ADMIN
	    Model.TupleUseForm
	    View.Tuple->use_edit
	    next=FORUM_TUPLE_USE_LIST
	)],
	[qw(
	    FORUM_TUPLE_LIST
	    76
	    FORUM
	    TUPLE_READ
	    Model.TupleList->execute_load_page
	    View.Tuple->list
	)],
	[qw(
	    FORUM_TUPLE_LIST_CSV
	    77
	    FORUM
	    TUPLE_READ
	    Model.TupleList->execute_load_all_with_query
	    View.Tuple->list_csv
	)],
	[qw(
	    FORUM_TUPLE_EDIT
	    78
	    FORUM
	    TUPLE_READ&TUPLE_WRITE
	    Model.TupleSlotListForm
	    View.Tuple->edit
	    next=FORUM_TUPLE_LIST
	)],
 	[qw(
	    FORUM_TUPLE_HISTORY
	    79
	    FORUM
	    TUPLE_READ
	    Model.TupleList->execute_load_history_list
	    View.Tuple->history_list
	)],
 	[qw(
	    FORUM_TUPLE_HISTORY_CSV
	    80
	    FORUM
	    TUPLE_READ
	    Model.TupleList->execute_load_history_list
	    View.Tuple->history_list_csv
	)],
    ];
#81-89 free
}

sub info_xapian {
    Bivio::IO::Config->introduce_values({
	'Bivio::Biz::Model::RealmFile' => {
	    search_class => 'Bivio::Search::Xapian',
	},
    });
    return [
	[qw(
	    JOB_XAPIAN_COMMIT
	    60
	    GENERAL
	    ANYBODY
	    Model.Lock
	    Bivio::Search::Xapian
	)],
  	[qw(
 	    SEARCH_LIST
 	    61
 	    GENERAL
 	    ANYBODY
	    Model.SearchForm
	    Model.SearchList->execute_load_page
	    View.Search->list
	    next=SEARCH_LIST
 	)],
#62-69 free
    ];
}

sub is_component_included {
    my(undef, $component) = @_;
    return $_INCLUDED->{$component} || 0;
}

sub merge_task_info {
    my($proto) = shift;
    my($seen) = {};
    return [map(
	$seen->{$_->[0]}++ ? () : $_,
	map(@{ref($_) ? $_
	    : ($_INCLUDED->{$_} = 1, _component_info($proto, $_))[1]},
	    reverse(@_),
	),
    )];
}

sub _component_info {
    my($proto, $component) = @_;
    my($m) = "info_$component";
    Bivio::Die->die($component, ': no such info_* component')
        unless $proto->can($m);
    return $proto->$m();
}

1;
