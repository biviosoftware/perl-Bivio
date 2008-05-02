# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::TaskId;
use strict;
use base 'Bivio::Delegate::SimpleTaskId';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = __PACKAGE__->use('IO.Config');

sub ALL_INFO {
    #DEPREDCATED
    return shift->standard_components;
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
	    Action.SiteRoot->execute_realm_file
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
	[qw(
	    MY_SITE
	    4
	    GENERAL
	    ANY_USER
	    Action.MySite
	)],
	[qw(
	    USER_HOME
	    5
	    USER
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
	    MY_CLUB_SITE
	    6
	    GENERAL
	    ANY_USER
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
	    CLUB_HOME
	    7
	    CLUB
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
	    CLIENT_REDIRECT
	    8
	    GENERAL
	    ANYBODY
	    Action.ClientRedirect->execute_query_or_path_info
	    next=SITE_ROOT
	)],
	# 9: HELP
	[qw(
	    VIEW_AS_PLAIN_TEXT
	    10
	    GENERAL
	    ANYBODY
	    Action.ViewAsPlainText
	)],
	# 11: ADM_SUBSTITUTE_USER
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
	    Action.Error
        )],
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
	    Action.AssertClient
	    Action.TestBackdoor
	    Action.MailReceiveStatus
	)],
	[qw(
	    FORUM_HOME
	    17
	    FORUM
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	# 18: GENERAL_USER_PASSWORD_QUERY
	# 19: GENERAL_USER_PASSWORD_QUERY_MAIL
	# 20: USER_PASSWORD_RESET
	# 21: USER_PASSWORD
	# 22: GENERAL_USER_PASSWORD_QUERY_ACK
	# 23: DEFAULT_ERROR_REDIRECT_MISSING_COOKIES
	[qw(
	    CALENDAR_EVENT_HOME
	    24
	    CALENDAR_EVENT
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	# 25: DAV
	# 26: DAV_ROOT_FORUM_LIST
	# 27: DAV_FORUM_LIST
	# 28: DAV_FORUM_FILE
	# 29: DAV_ROOT_FORUM_LIST_EDIT
	# 30: DAV_FORUM_LIST_EDIT
	# 31: DAV_FORUM_USER_LIST_EDIT
	# 32: FORUM_CALENDAR_EVENT_LIST_RSS
	# 33: DAV_FORUM_CALENDAR_EVENT_LIST_EDIT
	# 34: free in info_dav
	# 35: free in info_dav
	# 36: DAV_EMAIL_ALIAS_LIST_EDIT
	# 37: MAIL_RECEIVE_DISPATCH
	# 38: MAIL_RECEIVE_NO_RESOURCES
	# 39: MAIL_RECEIVE_NOT_FOUND
	# 40: MAIL_RECEIVE_IGNORE
	# 41: MAIL_RECEIVE_FORWARD
	# 42: FORUM_MAIL_RECEIVE
	# 43: FORUM_EASY_FORM
	# 44: FORUM_PUBLIC_FILE
	# 45: GENERAL_CONTACT
	# 46: USER_MAIL_BOUNCE
	# 47: MAIL_RECEIVE_FORBIDDEN
	# 48: FORUM_WIKI_VIEW
	# 49: FORUM_WIKI_EDIT
	# 50: FORUM_WIKI_NOT_FOUND
	# 51: HELP_NOT_FOUND
	# 52: FORUM_FILE
	# 53: FORUM_MAIL_REFLECTOR
	[qw(
            SITE_CSS
            54
	    GENERAL
	    ANYBODY
	    View.CSS->site_css
	)],
	[qw(
            DEFAULT_ERROR_REDIRECT_NOT_FOUND
            55
	    GENERAL
	    ANYBODY
	    Action.Error
	)],
	[qw(
            PERMANENT_REDIRECT
            56
	    GENERAL
	    ANYBODY
	    Action.PermanentRedirect
	)],
	[qw(
	    PUBLIC_PING
	    57
	    GENERAL
	    ANYBODY
	    Action.EmptyReply
        )],
	[qw(
            DEFAULT_ERROR_REDIRECT_MODEL_NOT_FOUND
            58
	    GENERAL
	    ANYBODY
	    Action.Error
	)],
	[qw(
	    TEST_TRACE
            59
	    GENERAL
	    TEST_TRANSIENT
	    Action.TestTrace
	    Action.EmptyReply
	)],
	[qw(
            DEFAULT_ERROR_REDIRECT
            190
	    GENERAL
	    ANYBODY
	    Action.Error
	)],
#191-199 free
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
	$_C->if_version(
	    3 => sub {
		return (
		    [qw(
			FORUM_BLOG_DETAIL
			102
			FORUM
			ANYBODY
			Model.BlogRecentList->execute_load_all
			Model.BlogList->execute_load_this
			View.Blog->detail
		    )],
		    [qw(
			FORUM_BLOG_LIST
			103
			FORUM
			ANYBODY
			Model.BlogRecentList->execute_load_all
			Model.BlogList->execute_load_page
			View.Blog->list
		    )],
		    [qw(
			FORUM_BLOG_RSS
			107
			FORUM
			ANYBODY
			Model.BlogList->execute_load_page
			View.Blog->list_rss
			html_task=FORUM_BLOG_LIST
		    )],
		);
	    },
	    sub {
		return (
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
			View.Blog->list_rss
			html_task=FORUM_PUBLIC_BLOG_DETAIL
		    )],
		    [qw(
			FORUM_BLOG_RSS
			107
			FORUM
			DATA_READ
			Type.AccessMode->execute_private
			Model.BlogList->execute_load_page
			View.Blog->list_rss
			html_task=FORUM_BLOG_DETAIL
		    )],
		);
	    },
	),
#108-109 free
    ];
}

sub info_calendar {
    return [
	[qw(
	    FORUM_CALENDAR_EVENT_LIST_RSS
            32
            FORUM
            DATA_READ
            Model.CalendarEventList->execute_load_page
            View.Calendar->event_list_rss
        )],
    ];
}

sub info_crm {
    return [
	[qw(
	    FORUM_CRM_THREAD_ROOT_LIST
            150
            FORUM
            DATA_READ&FEATURE_CRM
            Model.CRMThreadRootList->execute_load_page
            View.CRM->thread_root_list
	    thread_task=FORUM_CRM_THREAD_LIST
        )],
	[qw(
            FORUM_CRM_THREAD_LIST
            151
            FORUM
            DATA_READ&FEATURE_CRM
            Model.CRMThreadList->execute_load_page
            View.CRM->thread_list
        )],
	[qw(
            FORUM_CRM_FORM
            152
            FORUM
            DATA_READ&DATA_WRITE&MAIL_POST&FEATURE_CRM
	    Model.CRMForm
	    View.CRM->send_form
	    next=FORUM_CRM_THREAD_ROOT_LIST
        )],
#153-159
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
	    DAV_FORUM_CALENDAR_EVENT_LIST_EDIT
	    33
	    FORUM
	    DATA_READ
	    Model.Lock->execute_unless_acquired
	    Model.CalendarEventDAVList
	)],
#34: free
#35: free
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
	$_C->if_version(
	    3 => sub {
		return (
		    [qw(
			FORUM_FILE
			52
			FORUM
			ANYBODY
			Action.RealmFile->access_controlled_execute
			Model.RealmFileTreeList->execute_load_all_with_query
                        View.File->tree_list
			want_folder_fall_thru=1
			next=FORUM_FILE
		    )],
		);
	    },
	    sub {
		return (
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
			Action.RealmFile->execute_private
		    )],
		);
	    },
	),
 	[qw(
 	    FORUM_FILE_TREE_LIST
 	    171
 	    FORUM
 	    DATA_READ
	    Model.RealmFileTreeList->execute_load_all_with_query
 	    View.File->tree_list
	    next=FORUM_FILE
        )],
	[qw(
 	    FORUM_FILE_VERSIONS_LIST
 	    172
 	    FORUM
 	    DATA_READ
	    Model.RealmFileVersionsList->execute_load_all
 	    View.File->version_list
        )],
	[qw(
 	    FORUM_FILE_CHANGE
 	    173
 	    FORUM
            DATA_READ&DATA_WRITE
            Model.Lock
            Model.FileChangeForm
            Model.RealmFolderList->execute_load_all
	    View.File->file_change
            next=FORUM_FILE_TREE_LIST
        )],
	[qw(
 	    FORUM_FILE_OVERRIDE_LOCK
 	    174
 	    FORUM
            DATA_READ&DATA_WRITE
            Model.Lock
            Model.FileUnlockForm
	    View.File->file_unlock
            next=FORUM_FILE_TREE_LIST
        )],
#175-179 free
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
            Action.MailReceiveStatus
        )],
	[qw(
            MAIL_RECEIVE_FORWARD
            41
	    GENERAL
	    ANYBODY
	    Action.MailForward
            Action.MailReceiveStatus
	)],
	[qw(
            FORUM_MAIL_RECEIVE
            42
            FORUM
            MAIL_SEND
            Action.RealmMail->execute_receive
            Action.MailReceiveStatus
        )],
	[qw(
            USER_MAIL_BOUNCE
            46
            USER
            ANYBODY
            Model.RealmMailBounce
            Action.MailReceiveStatus
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
	[qw(
            FORUM_MAIL_THREAD_ROOT_LIST
            140
            FORUM
            DATA_READ
            Model.MailThreadRootList->execute_load_page
            View.Mail->thread_root_list
	    thread_task=FORUM_MAIL_THREAD_LIST
        )],
	[qw(
            FORUM_MAIL_THREAD_LIST
            141
            FORUM
            DATA_READ
            Model.MailThreadList->execute_load_page
            View.Mail->thread_list
        )],
	[qw(
            FORUM_MAIL_PART
            142
            FORUM
            DATA_READ
	    Model.MailPartList->execute_part
        )],
	[qw(
            FORUM_MAIL_FORM
            143
            FORUM
            DATA_READ&MAIL_POST
	    Model.MailForm
	    View.Mail->send_form
	    next=FORUM_MAIL_THREAD_ROOT_LIST
        )],
#144-149 free
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

sub info_otp {
    return [
	[qw(
	    USER_OTP
	    130
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.UserOTPForm
            View.OTP->form
	    next=MY_SITE
	)],
#131-139 free
    ];
}

sub info_site_adm {
    return [
	[qw(
	    SITE_ADM_USER_LIST
            160
            FORUM
            ADMIN_READ&FEATURE_SITE_ADM
            Model.AdmUserList->execute_load_page
            View.SiteAdm->user_list
        )],
	[qw(
	    SITE_ADM_SUBSTITUTE_USER
	    161
	    FORUM
	    ADMIN_READ&ADMIN_WRITE&FEATURE_SITE_ADM&SUPER_USER_TRANSIENT
	    Model.SiteAdmSubstituteUserForm
            View.SiteAdm->substitute_user_form
	    next=MY_SITE
        )],
	[qw(
	    SITE_ADM_SUBSTITUTE_USER_DONE
	    162
	    FORUM
	    ANYBODY
	    Action.UserLogout
	    su_task=SITE_ADM_USER_LIST
	)],
#163-169
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
            DEFAULT_ERROR_REDIRECT_MISSING_COOKIES
	    23
	    GENERAL
	    ANYBODY
	    View.UserAuth->missing_cookies
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
            cancel=SITE_ROOT
	    reset_task=USER_PASSWORD_RESET
	    user_exists_task=GENERAL_USER_PASSWORD_QUERY
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
	[qw(
	    USER_SETTINGS_FORM
	    94
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.UserSettingsForm
	    View.UserAuth->settings_form
	    next=MY_SITE
	)],
#95-99
    ];
}

sub info_wiki {
    return [
 	[qw(
 	    HELP
 	    9
 	    FORUM
 	    ANYBODY
            View.Wiki->help
 	)],
	$_C->if_version(
	    3 => sub {
		return (
		    [qw(
			FORUM_WIKI_VIEW
			48
			FORUM
			ANYBODY
			Action.WikiView->execute_prepare_html
			View.Wiki->view
			MODEL_NOT_FOUND=FORUM_WIKI_NOT_FOUND
			edit_task=FORUM_WIKI_EDIT
			want_author=1
		    )],
		);
	    },
	    sub {
		return (
		    [qw(
			FORUM_PUBLIC_WIKI_VIEW
			120
			FORUM
			ANYBODY
			Action.WikiView->execute_prepare_html
			View.Wiki->view
			MODEL_NOT_FOUND=FORUM_WIKI_NOT_FOUND
			edit_task=FORUM_WIKI_EDIT
			want_author=1
		    )],
		    [qw(
			FORUM_WIKI_VIEW
			48
			FORUM
			DATA_READ
			Action.WikiView->execute_prepare_html
			View.Wiki->view
			MODEL_NOT_FOUND=FORUM_WIKI_NOT_FOUND
			edit_task=FORUM_WIKI_EDIT
			want_author=1
		    )],
		);
	    },
	),
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
	    SITE_WIKI_VIEW
	    121
	    GENERAL
	    ANYBODY
	    Action.SiteForum
	    Action.WikiView->execute_prepare_html
	    View.Wiki->site_view
	    want_author=0
        )],
    ];
#122-129 free
}

sub info_xapian {
    Bivio::IO::Config->introduce_values({
	'Bivio::Biz::Model::RealmFile' => {
	    search_class => 'Search.Xapian',
	},
    });
    return [
	[qw(
	    JOB_XAPIAN_COMMIT
	    60
	    GENERAL
	    ANYBODY
	    Search.Xapian
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

1;
