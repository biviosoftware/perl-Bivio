# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::TaskId;
use strict;
use base 'Bivio::Delegate::SimpleTaskId';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ALL_INFO {
    #DEPREDCATED
    return shift->all_components;
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
	    View.SiteRoot->execute_uri
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
            SITE_CSS
            54
	    GENERAL
	    ANYBODY
	    View.CSS->site_css
	)],
	[qw(
            FORUM_CSS
            55
	    FORUM
	    ANYBODY
	    View.CSS->realm_css
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

sub info_blog {
    return [
 	[qw(
 	    FORUM_BLOG_EDIT
 	    100
 	    FORUM
 	    DATA_READ&DATA_WRITE
            Model.BlogEditForm
	    View.Blog->edit
	    next=FORUM_BLOG_DETAIL
 	)],
 	[qw(
 	    FORUM_BLOG_CREATE
 	    101
 	    FORUM
 	    DATA_READ&DATA_WRITE
            Model.BlogCreateForm
	    View.Blog->create
	    next=FORUM_BLOG_DETAIL
	    want_query=0
 	)],
 	[qw(
 	    FORUM_BLOG_DETAIL
 	    102
 	    FORUM
 	    DATA_READ
	    Type.AccessMode->execute_private
            Model.BlogRecentList->execute_load_all
            Model.BlogList->execute_load_this
	    View.Blog->detail
 	)],
 	[qw(
 	    FORUM_BLOG_LIST
 	    103
 	    FORUM
 	    DATA_READ
	    Type.AccessMode->execute_private
            Model.BlogRecentList->execute_load_all
            Model.BlogList->execute_load_page
	    View.Blog->list
 	)],
 	[qw(
 	    FORUM_PUBLIC_BLOG_LIST
 	    104
 	    FORUM
 	    ANYBODY
	    Type.AccessMode->execute_public
            Model.BlogRecentList->execute_load_all
            Model.BlogList->execute_load_page
	    View.Blog->list
 	)],
 	[qw(
 	    FORUM_PUBLIC_BLOG_DETAIL
 	    105
 	    FORUM
 	    ANYBODY
	    Type.AccessMode->execute_public
            Model.BlogRecentList->execute_load_all
            Model.BlogList->execute_load_this
	    View.Blog->detail
 	)],
	[qw(
	    FORUM_PUBLIC_BLOG_RSS
            106
            FORUM
 	    ANYBODY
	    Type.AccessMode->execute_public
            Model.BlogList->execute_load_page
            View.Blog->recent_rss
        )],
	[qw(
	    FORUM_BLOG_RSS
            107
            FORUM
 	    DATA_READ
	    Type.AccessMode->execute_private
            Model.BlogList->execute_load_page
            View.Blog->recent_rss
        )],
#108-109 free
    ];
}

sub info_dav {
    return [
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
	    FORUM_CALENDAR_EVENT_LIST_RSS
            32
            FORUM
            DATA_READ
            Model.CalendarEventList->execute_load_page
            View.Calendar->event_list_rss
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
	    DAV_EMAIL_ALIAS_LIST_EDIT
	    36
	    GENERAL
	    ADMIN_READ
	    Model.EmailAliasList->execute_load_all
	    Model.EmailAliasEditDAVList
	)],
    ];
}

sub info_file {
    return [
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
 	    FORUM_FILE
 	    52
 	    FORUM
 	    DATA_READ
 	    Action.RealmFile
        )],
    ];
}

sub info_mail {
    return [
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
            FORUM_MAIL_REFLECTOR
            53
            FORUM
            MAIL_SEND
            Action.RealmMail->execute_reflector
        )],
    ];
}

sub info_motion {
    return [
 	[qw(
 	    FORUM_MOTION_LIST
 	    110
 	    FORUM
 	    MOTION_WRITE
            Model.MotionList->execute_load_page
	    View.Motion->list
 	)],
 	[qw(
 	    FORUM_MOTION_ADD
 	    111
 	    FORUM
 	    MOTION_ADMIN
	    Type.FormMode->execute_create
            Model.MotionForm
	    View.Motion->form
	    next=FORUM_MOTION_LIST
 	)],
 	[qw(
 	    FORUM_MOTION_EDIT
 	    112
 	    FORUM
 	    MOTION_ADMIN
	    Type.FormMode->execute_edit
	    Model.MotionList->execute_load_this
            Model.MotionForm
	    View.Motion->form
	    next=FORUM_MOTION_LIST
 	)],
 	[qw(
 	    FORUM_MOTION_VOTE
 	    113
 	    FORUM
 	    MOTION_WRITE
	    Model.MotionList->execute_load_this
            Model.MotionVoteForm
	    View.Motion->vote_form
	    next=FORUM_MOTION_LIST
 	)],
 	[qw(
 	    FORUM_MOTION_VOTE_LIST
 	    114
 	    FORUM
 	    MOTION_READ
	    Model.MotionList->execute_load_parent
            Model.MotionVoteList->execute_load_all_with_query
	    View.Motion->vote_result
 	)],
 	[qw(
 	    FORUM_MOTION_VOTE_LIST_CSV
 	    115
 	    FORUM
 	    MOTION_READ
            Model.MotionVoteList->execute_load_all_with_query
	    View.Motion->vote_result_csv
 	)],
#116-119 free
    ];
}

sub info_user_auth {
    return [
	[qw(
	    ADM_SUBSTITUTE_USER
	    11
	    GENERAL
	    ADMIN_READ&ADMIN_WRITE
	    Model.AdmSubstituteUserForm
            View.UserAuth->adm_substitute_user
	    next=MY_SITE
	)],
	[qw(
	    GENERAL_USER_PASSWORD_QUERY
	    18
	    GENERAL
	    ANYBODY
	    Model.UserPasswordQueryForm
	    View.UserAuth->password_query
	    reset_task=USER_PASSWORD_RESET
	    next=GENERAL_USER_PASSWORD_QUERY_MAIL
	    cancel=SITE_ROOT
	)],
	[qw(
	    GENERAL_USER_PASSWORD_QUERY_MAIL
	    19
	    GENERAL
	    ANYBODY
	    View.UserAuth->password_query_mail
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
	[qw(
            DEFAULT_ERROR_REDIRECT_MISSING_COOKIES
	    23
	    GENERAL
	    ANYBODY
	    View.UserAuth->missing_cookies
	)],
        # forbidden errors are probably due to missing cookies.
        # for example, if user is resetting password from email link
        # with cookies disabled
	[qw(
	    USER_PASSWORD
	    21
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.UserPasswordForm
	    View.UserAuth->password
	    next=MY_SITE
            FORBIDDEN=DEFAULT_ERROR_REDIRECT_MISSING_COOKIES
	)],
	[qw(
	    GENERAL_USER_PASSWORD_QUERY_ACK
	    22
	    GENERAL
	    ANYBODY
	    View.UserAuth->password_query_ack
	)],
	[qw(
	    GENERAL_CONTACT
	    45
	    GENERAL
	    ANYBODY
	    Model.ContactForm
	    View.UserAuth->general_contact
	    next=SITE_ROOT
	)],
	[qw(
	    LOGIN
	    90
	    GENERAL
	    ANYBODY
	    Action.UserLogout
	    Model.UserLoginForm
	    View.UserAuth->login
            next=MY_SITE
	)],
	[qw(
	    LOGOUT
	    91
	    GENERAL
	    ANYBODY
	    Action.UserLogout
            Action.ClientRedirect->execute_next
            next=SITE_ROOT
	)],
	[qw(
	    USER_CREATE
	    92
	    GENERAL
	    ANYBODY
	    Action.UserLogout
	    Model.UserRegisterForm
	    View.UserAuth->create
	    next=USER_CREATE_DONE
	    reset_task=USER_PASSWORD_RESET
	    reset_next_task=GENERAL_USER_PASSWORD_QUERY_MAIL
	)],
	[qw(
	    USER_CREATE_DONE
	    93
	    GENERAL
	    ANYBODY
	    View.UserAuth->create_mail
	    View.UserAuth->create_done
	)],
#94-99
    ];
}

sub info_wiki {
    return [
 	[qw(
 	    HELP
 	    9
 	    GENERAL
 	    DATA_READ
 	    Action.WikiView->execute_help
	    View.Wiki->view
	    want_author=0
	    MODEL_NOT_FOUND=HELP_NOT_FOUND
 	)],
 	[qw(
 	    FORUM_WIKI_VIEW
 	    48
 	    FORUM
 	    DATA_READ
 	    Action.WikiView
	    View.Wiki->view
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
	    View.Wiki->edit
	    next=FORUM_WIKI_VIEW
 	)],
 	[qw(
 	    FORUM_WIKI_NOT_FOUND
 	    50
 	    FORUM
 	    ANYBODY
	    View.Wiki->not_found
	    view_task=FORUM_WIKI_VIEW
 	)],
 	[qw(
 	    HELP_NOT_FOUND
 	    51
 	    GENERAL
 	    DATA_READ
	    View.Wiki->not_found
	    view_task=HELP
 	)],
 	[qw(
 	    FORUM_PUBLIC_WIKI_VIEW
 	    120
 	    FORUM
 	    ANYBODY
	    Type.AccessMode->execute_public
 	    Action.WikiView
	    View.Wiki->view
	    MODEL_NOT_FOUND=FORUM_WIKI_NOT_FOUND
	    edit_task=FORUM_WIKI_EDIT
	    want_author=1
 	)],
    ];
#121-129 free
}

1;
