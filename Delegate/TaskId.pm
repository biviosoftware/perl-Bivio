# Copyright (c) 2007-2010 bivio Software, Inc.	All Rights Reserved.
# $Id$
package Bivio::Delegate::TaskId;
use strict;
use Bivio::Base 'Bivio.Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_INFO_RE) = qr{^info_(.*)};
my($_INCLUDED) = {};
my($_PS) = b_use('Auth.PermissionSet');
my($_C) = b_use('IO.Config');
my($_A) = b_use('IO.Alert');

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
    return shift->merge_task_info('base');
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
	    ANYBODY
	    Action.ClientRedirect->execute_next
	    next=FORUM_WIKI_VIEW
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
	    ANYBODY
	    Action.ClientRedirect->execute_next
	    next=FORUM_WIKI_VIEW
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
	    CLIENT_REDIRECT_PERMANENT_MAP
	    56
	    GENERAL
	    ANYBODY
	    Action.ClientRedirect->execute_permanent_map
	)],
	[qw(
	    PUBLIC_PING
	    57
	    GENERAL
	    ANYBODY
	    Action.PingReply
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
	[qw(
	    UNADORNED_PAGE
	    191
	    GENERAL
	    ANYBODY
	    Action.UnadornedPage
	)],
	[qw(
	    DEFAULT_ERROR_REDIRECT_UPDATE_COLLISION
	    192
	    GENERAL
	    ANYBODY
	    Action.Error
	)],
	[qw(
	    PUBLIC_WIDGET_INJECTOR
	    193
	    GENERAL
	    ANYBODY
	    View.WidgetInjector->public_xhtml_widget_js
	)],
	
#194-199 free
    ];
}

sub info_blog {
    return [
	[qw(
	    FORUM_BLOG_EDIT
	    100
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&FEATURE_BLOG
	    Model.BlogEditForm
	    View.Blog->edit
	    next=FORUM_BLOG_DETAIL
	)],
	[qw(
	    FORUM_BLOG_CREATE
	    101
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&FEATURE_BLOG
	    Model.BlogCreateForm
	    View.Blog->create
	    next=FORUM_BLOG_DETAIL
            cancel=FORUM_BLOG_LIST
	    want_query=0
	)],
	$_C->if_version(
	    3 => sub {
		return (
		    [qw(
			FORUM_BLOG_DETAIL
			102
			ANY_OWNER
			FEATURE_BLOG
			Model.BlogRecentList->execute_load_all
			Model.BlogList->execute_load_this
			View.Blog->detail
		    )],
		    [qw(
			FORUM_BLOG_LIST
			103
			ANY_OWNER
			FEATURE_BLOG
			Model.BlogRecentList->execute_load_all
			Model.BlogList->execute_load_page
			View.Blog->list
		    )],
		    [qw(
			FORUM_BLOG_RSS
			107
			ANY_OWNER
			FEATURE_BLOG
			Model.BlogList->execute_load_page
			View.Blog->list_rss
			html_task=FORUM_BLOG_LIST
                        html_detail_task=FORUM_BLOG_DETAIL
		    )],
		);
	    },
	    sub {
		return (
		    [qw(
			FORUM_BLOG_DETAIL
			102
			ANY_OWNER
			DATA_READ&FEATURE_BLOG
			Type.AccessMode->execute_private
			Model.BlogRecentList->execute_load_all
			Model.BlogList->execute_load_this
			View.Blog->detail
		    )],
		    [qw(
			FORUM_BLOG_LIST
			103
			ANY_OWNER
			DATA_READ&FEATURE_BLOG
			Type.AccessMode->execute_private
			Model.BlogRecentList->execute_load_all
			Model.BlogList->execute_load_page
			View.Blog->list
		    )],
		    [qw(
			FORUM_PUBLIC_BLOG_LIST
			104
			ANY_OWNER
			ANYBODY&FEATURE_BLOG
			Type.AccessMode->execute_public
			Model.BlogRecentList->execute_load_all
			Model.BlogList->execute_load_page
			View.Blog->list
		    )],
		    [qw(
			FORUM_PUBLIC_BLOG_DETAIL
			105
			ANY_OWNER
			ANYBODY&FEATURE_BLOG
			Type.AccessMode->execute_public
			Model.BlogRecentList->execute_load_all
			Model.BlogList->execute_load_this
			View.Blog->detail
		    )],
		    [qw(
			FORUM_PUBLIC_BLOG_RSS
			106
			ANY_OWNER
			ANYBODY&FEATURE_BLOG
			Type.AccessMode->execute_public
			Model.BlogList->execute_load_page
			View.Blog->list_rss
			html_task=FORUM_PUBLIC_BLOG_LIST
                        html_detail_task=FORUM_PUBLIC_BLOG_DETAIL
		    )],
		    [qw(
			FORUM_BLOG_RSS
			107
			ANY_OWNER
			DATA_READ&FEATURE_BLOG
			Type.AccessMode->execute_private
			Model.BlogList->execute_load_page
			View.Blog->list_rss
                        html_task=FORUM_BLOG_LIST
			html_detail_task=FORUM_BLOG_DETAIL
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
	    ANY_OWNER
	    DATA_READ&FEATURE_CALENDAR
	    Model.CalendarEventList->execute_load_page
	    View.Calendar->event_list_rss
            html_task=FORUM_CALENDAR
	    html_detail_task=FORUM_CALENDAR_EVENT_DETAIL
            want_basic_authorization=1
	)],
	[qw(
	    FORUM_CALENDAR
	    180
	    ANY_OWNER
	    DATA_READ&FEATURE_CALENDAR
	    Model.CalendarEventMonthForm
	    Model.CalendarEventMonthList->execute_load_all_with_query
	    View.Calendar->list
	    next=FORUM_CALENDAR
	)],
	[qw(
	    FORUM_CALENDAR_EVENT_FORM
	    181
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&FEATURE_CALENDAR
	    Model.CalendarEventForm
	    View.Calendar->event_form
	    next=FORUM_CALENDAR
	    read_task=FORUM_CALENDAR_EVENT_DETAIL
	)],
	[qw(
	    FORUM_CALENDAR_EVENT_DETAIL
	    182
	    ANY_OWNER
	    DATA_READ&FEATURE_CALENDAR
	    Model.CalendarEventList->execute_load_this
	    View.Calendar->event_detail
	    next=FORUM_CALENDAR
	    CORRUPT_QUERY=FORUM_CALENDAR
	)],
	[qw(
	    FORUM_CALENDAR_EVENT_DELETE
	    183
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&FEATURE_CALENDAR
	    Model.CalendarEventDeleteForm
	    View.Calendar->event_delete
	    next=FORUM_CALENDAR
	    cancel=FORUM_CALENDAR_EVENT_DETAIL
	)],
	[qw(
	    FORUM_CALENDAR_EVENT_ICS
	    184
	    ANY_OWNER
	    DATA_READ&FEATURE_CALENDAR
	    Model.CalendarEventList->execute_load_this
	    Action.CalendarEventICS
	)],
	[qw(
	    FORUM_CALENDAR_EVENT_LIST_ICS
	    185
	    ANY_OWNER
	    DATA_READ&FEATURE_CALENDAR
	    Model.CalendarEventList->execute_load_all
	    Action.CalendarEventICS
            want_basic_authorization=1
	)],
# 186-189 free
    ];
}

sub info_crm {
    return [
	[qw(
	    FORUM_CRM_THREAD_ROOT_LIST
	    150
	    ANY_OWNER
	    DATA_READ&FEATURE_CRM
	    Model.CRMQueryForm
	    Model.CRMThreadRootList->execute_load_page
	    View.CRM->thread_root_list
	    thread_task=FORUM_CRM_THREAD_LIST
	    update_task=FORUM_CRM_FORM
	    next=FORUM_CRM_THREAD_ROOT_LIST
	)],
	[qw(
	    FORUM_CRM_THREAD_LIST
	    151
	    ANY_OWNER
	    DATA_READ&FEATURE_CRM
	    Model.CRMThreadList->execute_load_page
	    View.CRM->thread_list
	)],
	[qw(
	    FORUM_CRM_FORM
	    152
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&MAIL_POST&FEATURE_CRM
	    Model.CRMForm
	    View.CRM->send_form
	    next=FORUM_CRM_THREAD_ROOT_LIST
	    mail_reflector_task=FORUM_MAIL_REFLECTOR
	)],
	[qw(
	    FORUM_CRM_THREAD_ROOT_LIST_CSV
	    153
	    ANY_OWNER
	    DATA_READ&FEATURE_CRM
	    Model.CRMQueryForm
	    View.CRM->thread_root_list_csv
	    next=FORUM_CRM_THREAD_ROOT_LIST
	)],
#154-159
    ];
}

sub info_dav {
    return [
	[qw(
	    DAV
	    25
	    GENERAL
	    ANYBODY
	    Action.DAV
	    next=DAV_ROOT_FORUM_LIST
	    want_basic_authorization=1
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
	    ANY_OWNER
	    DATA_READ&FEATURE_DAV
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
	    ANY_OWNER
	    DATA_READ&FEATURE_DAV
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
	    ANY_OWNER
	    ADMIN_READ&FEATURE_DAV
	    Model.Lock->execute_unless_acquired
	    Model.ForumList->execute_load_all
	    Model.ForumEditDAVList
	)],
	[qw(
	    DAV_FORUM_USER_LIST_EDIT
	    31
	    ANY_OWNER
	    ADMIN_READ&FEATURE_DAV
	    Model.Lock->execute_unless_acquired
	    Model.ForumUserList->execute_load_all
	    Model.ForumUserEditDAVList
	)],
	[qw(
	    DAV_FORUM_CALENDAR_EVENT_LIST_EDIT
	    33
	    ANY_OWNER
	    DATA_READ&FEATURE_DAV
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

sub info_dev {
    my($self) = @_;
    return
	if $_C->is_production || !-w __FILE__;
    return [
	[qw(
	    DEV_RESTART
            220
            GENERAL
            ANYBODY
            Action.DevRestart
	)],
#221-229
    ];
}

sub info_file {
    return [
	[qw(
	    FORUM_EASY_FORM
	    43
	    ANY_OWNER
	    ANYBODY&FEATURE_FILE
	    Action.EasyForm
	)],
	[qw(
	    FORUM_FILE
	    52
	    ANY_OWNER
	    ANYBODY&FEATURE_FILE
	    Action.RealmFile->access_controlled_execute
	)],
	[qw(
	    FORUM_FILE_TREE_LIST
	    170
	    ANY_OWNER
	    DATA_READ&DATA_BROWSE&FEATURE_FILE
	    Action.RealmFile->access_controlled_execute
	    Model.RealmFileTreeList->execute_load_all_with_query
	    View.File->tree_list
	    want_folder_fall_thru=1
	    next=FORUM_FILE
	    write_task=FORUM_FILE_CHANGE
	)],
# TODO: Separate tree list so permissions check by task data explore
#	is a bit on the file?  STill need data_explore on the task
	[qw(
	    FORUM_FILE_VERSIONS_LIST
	    171
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&FEATURE_FILE
	    Model.RealmFileVersionsList->execute_load_page
	    View.File->version_list
	)],
	[qw(
	    FORUM_FILE_CHANGE
	    172
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&FEATURE_FILE
	    Model.Lock
	    Model.FileChangeForm
	    Model.RealmFolderList->execute_load_all
	    View.File->file_change
	    next=FORUM_FILE_TREE_LIST
	)],
#TODO: b_use('Model.RealmFileLock')->if_enabled() causes a circular import problem
	[qw(
	    FORUM_FILE_OVERRIDE_LOCK
	    173
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&FEATURE_FILE
	    Model.Lock
	    Model.FileUnlockForm
	    View.File->file_unlock
	    next=FORUM_FILE_TREE_LIST
	)],
#174-179 free
    ];
}

sub info_group_admin {
    return [
	[qw(
	    GROUP_USER_LIST
	    200
	    ANY_OWNER
	    ADMIN_READ&FEATURE_GROUP_ADMIN
            Model.GroupUserQueryForm
	    Model.GroupUserList->execute_load_page
	    View.GroupAdmin->user_list
            next=GROUP_USER_LIST
            require_secure=1
	)],
	[qw(
	    GROUP_USER_FORM
	    201
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_GROUP_ADMIN
	    Model.GroupUserForm
	    View.GroupAdmin->user_form
	    next=GROUP_USER_LIST
	)],
	[qw(
	    GROUP_USER_ADD_FORM
	    202
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_GROUP_ADMIN
	    Model.RealmUserAddForm
	    View.GroupAdmin->user_add_form
	    next=GROUP_USER_LIST
	)],
	[qw(
	    FORUM_CREATE_FORM
	    203
	    FORUM
	    ADMIN_READ&ADMIN_WRITE&FEATURE_GROUP_ADMIN
	    Type.FormMode->execute_create
	    Model.ForumForm
	    View.GroupAdmin->forum_form
	    next=GROUP_USER_LIST
	)],
	[qw(
	    FORUM_EDIT_FORM
	    204
	    FORUM
	    ADMIN_READ&ADMIN_WRITE&FEATURE_GROUP_ADMIN
	    Type.FormMode->execute_edit
	    Model.ForumForm
	    View.GroupAdmin->forum_form
	    next=GROUP_USER_LIST
	)],
	[qw(
	    REALM_FEATURE_FORM
	    205
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_GROUP_ADMIN
	    Type.FormMode->execute_edit
	    Model.RealmFeatureForm
	    View.GroupAdmin->feature_form
	    next=GROUP_USER_LIST
	)],
    ];
#206-209 free
    return;
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
	    ANY_OWNER
	    MAIL_SEND&FEATURE_MAIL
	    Action.RealmMail->execute_receive
	    Action.MailReceiveStatus
	    FORBIDDEN=MAIL_RECEIVE_FORBIDDEN
	    mail_reflector_task=FORUM_MAIL_REFLECTOR
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
	    ANY_OWNER
	    MAIL_SEND&FEATURE_MAIL
	    Action.RealmMail->execute_reflector
	)],
	[qw(
	    FORUM_MAIL_THREAD_ROOT_LIST
	    140
	    ANY_OWNER
	    ANYBODY&FEATURE_MAIL
	    Model.RealmMail->assert_mail_visibility
	    Model.MailThreadRootList->execute_load_page
	    View.Mail->thread_root_list
	    thread_task=FORUM_MAIL_THREAD_LIST
	    update_task=FORUM_MAIL_FORM
	)],
	[qw(
	    FORUM_MAIL_THREAD_LIST
	    141
	    ANY_OWNER
	    ANYBODY&FEATURE_MAIL
	    Model.RealmMail->assert_mail_visibility
	    Model.MailThreadList->execute_load_page
	    View.Mail->thread_list
	)],
	[qw(
	    FORUM_MAIL_PART
	    142
	    ANY_OWNER
	    ANYBODY&FEATURE_MAIL
	    Model.RealmMail->assert_mail_visibility
	    Model.MailPartList->execute_part
	)],
	[qw(
	    FORUM_MAIL_FORM
	    143
	    ANY_OWNER
	    MAIL_POST&FEATURE_MAIL
	    Model.MailForm
	    View.Mail->send_form
	    next=FORUM_MAIL_THREAD_ROOT_LIST
	    mail_reflector_task=FORUM_MAIL_REFLECTOR
	)],
	[qw(
	    FORUM_MAIL_SHOW_ORIGINAL_FILE
	    144
	    ANY_OWNER
	    ANYBODY&FEATURE_MAIL
	    Model.RealmMail->assert_mail_visibility
	    Action.RealmFile->execute_show_original
	)],
	[qw(
            GROUP_BULLETIN_FORM
            145
            ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_MAIL&FEATURE_BULLETIN
            Model.BulletinForm
            View.Bulletin->form
            next=FORUM_MAIL_THREAD_ROOT_LIST
	    mail_reflector_task=GROUP_BULLETIN_REFLECTOR
	)],
	[qw(
	    GROUP_BULLETIN_REFLECTOR
	    146
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_MAIL&FEATURE_BULLETIN
	    Action.RealmMail->execute_reflector
	)],
	[qw(
	    ADMIN_REALM_MAIL_RECEIVE
	    147
	    ANY_OWNER
	    MAIL_SEND&FEATURE_MAIL
	    Action.AdminRealmMail->execute_receive
	    Action.MailReceiveStatus
	    FORBIDDEN=MAIL_RECEIVE_FORBIDDEN
	    mail_reflector_task=ADMIN_REALM_MAIL_REFLECTOR
	)],
	[qw(
	    ADMIN_REALM_MAIL_REFLECTOR
	    148
	    ANY_OWNER
	    MAIL_SEND&FEATURE_MAIL
	    Action.AdminRealmMail->execute_reflector
	)],
	[qw(
	    BOARD_REALM_MAIL_RECEIVE
	    149
	    ANY_OWNER
	    MAIL_SEND&FEATURE_MAIL
	    Action.BoardRealmMail->execute_receive
	    Action.MailReceiveStatus
	    FORBIDDEN=MAIL_RECEIVE_FORBIDDEN
	)],
	[qw(
	    GROUP_MAIL_RECEIVE_NIGHTLY_TEST_OUTPUT
	    230
	    ANY_OWNER
	    MAIL_SEND&FEATURE_MAIL
	    Action.NightlyTestOutput
	    Action.MailReceiveStatus
	    FORBIDDEN=MAIL_RECEIVE_FORBIDDEN
        )],
	[qw(
	    GROUP_MAIL_TOGGLE_PUBLIC
	    231
	    ANY_OWNER
	    MAIL_READ&MAIL_WRITE&FEATURE_MAIL
	    Model.RealmMailPublicForm
	    next=FORUM_MAIL_THREAD_ROOT_LIST
	)],
	[qw(
	    USER_MAIL_UNSUBSCRIBE_FORM
	    232
	    USER
	    ANYBODY
	    Model.MailUnsubscribeForm
	    View.Mail->unsubscribe_form
	    next=SITE_ROOT
	)],
#233-239
    ];
}

sub info_motion {
    return [
	[qw(
	    FORUM_MOTION_LIST
	    110
	    ANY_OWNER
	    MOTION_WRITE&FEATURE_MOTION
	    Model.MotionList->execute_load_page
	    View.Motion->list
	)],
	[qw(
	    FORUM_MOTION_ADD
	    111
	    ANY_OWNER
	    MOTION_ADMIN&FEATURE_MOTION
	    Type.FormMode->execute_create
	    Model.MotionForm
	    View.Motion->form
	    next=FORUM_MOTION_LIST
	)],
	[qw(
	    FORUM_MOTION_EDIT
	    112
	    ANY_OWNER
	    MOTION_ADMIN&FEATURE_MOTION
	    Type.FormMode->execute_edit
	    Model.MotionList->execute_load_this
	    Model.MotionForm
	    View.Motion->form
	    next=FORUM_MOTION_LIST
	)],
	[qw(
	    FORUM_MOTION_VOTE
	    113
	    ANY_OWNER
	    MOTION_WRITE&FEATURE_MOTION
	    Model.MotionList->execute_load_this
	    Model.MotionVoteForm
	    View.Motion->vote_form
	    next=FORUM_MOTION_LIST
	)],
	[qw(
	    FORUM_MOTION_VOTE_LIST
	    114
	    ANY_OWNER
	    MOTION_READ&FEATURE_MOTION
	    Model.MotionList->execute_load_parent
	    Model.MotionVoteList->execute_load_all_with_query
	    View.Motion->vote_result
	)],
	[qw(
	    FORUM_MOTION_VOTE_LIST_CSV
	    115
	    ANY_OWNER
	    MOTION_READ&FEATURE_MOTION
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
	    require_secure=1
	)],
#131-139 free
    ];
}

sub info_site_admin {
    return [
	[qw(
	    SITE_ADMIN_USER_LIST
	    160
	    ANY_OWNER
	    ADMIN_READ&FEATURE_SITE_ADMIN
	    Model.AdmUserList->execute_load_page
	    View.SiteAdmin->user_list
	    require_secure=1
	)],
	[qw(
	    SITE_ADMIN_SUBSTITUTE_USER
	    161
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_SITE_ADMIN
	    Model.SiteAdminSubstituteUserForm
	    View.SiteAdmin->substitute_user_form
	    next=MY_SITE
	    require_secure=1
	)],
	[qw(
	    SITE_ADMIN_SUBSTITUTE_USER_DONE
	    162
	    ANY_OWNER
	    ANYBODY&FEATURE_SITE_ADMIN
	    Action.UserLogout
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	),
	    $_C->if_version(10,
		sub {'su_task=GROUP_USER_LIST'},
		sub {'su_task=SITE_ADMIN_USER_LIST'},
	    ),

	],
	[qw(
	    SITE_ADMIN_UNAPPROVED_APPLICANT_LIST
	    163
	    ANY_OWNER
	    ADMIN_READ&FEATURE_SITE_ADMIN
	    Model.UnapprovedApplicantList->execute_load_page
	    View.SiteAdmin->unapproved_applicant_list
	    require_secure=1
	)],
	[qw(
	    SITE_ADMIN_UNAPPROVED_APPLICANT_FORM
	    164
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_SITE_ADMIN
	    Model.Lock
	    Model.UnapprovedApplicantForm
	    View.SiteAdmin->unapproved_applicant_form
	    next=SITE_ADMIN_UNAPPROVED_APPLICANT_LIST
	    require_secure=1
	)],
	[qw(
	    REMOTE_COPY_GET
	    165
	    ANY_OWNER
	    DATA_READ&DATA_BROWSE&FEATURE_FILE
	    Action.RemoteCopy
	    want_basic_authorization=1
	    require_secure=1
	)],
	[qw(
	    REMOTE_COPY_FORM
	    166
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&DATA_BROWSE&FEATURE_FILE
	    Model.RemoteCopyListForm
	    View.SiteAdmin->remote_copy_form
	    next=FORUM_FILE_TREE_LIST
	    require_secure=1
	)],
#167-169,
    ];
}

sub info_task_log {
    return [
	[qw(
	    SITE_ADMIN_TASK_LOG
	    210
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_SITE_ADMIN&FEATURE_TASK_LOG
	    Model.FilterQueryForm
	    Model.TaskLogList->execute_unauth_load_page
	    View.TaskLog->list
	    next=SITE_ADMIN_TASK_LOG
            csv_task=SITE_ADMIN_TASK_LOG_CSV
	    require_secure=1
	)],
	[qw(
	    SITE_ADMIN_TASK_LOG_CSV
	    211
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_SITE_ADMIN&FEATURE_TASK_LOG
	    Model.FilterQueryForm
	    Model.TaskLogList->execute_unauth_iterate_start
	    View.TaskLog->list_csv
	    next=SITE_ADMIN_TASK_LOG_CSV
            csv_task=SITE_ADMIN_TASK_LOG_CSV
	    require_secure=1
	)],
	[qw(
	    GROUP_TASK_LOG
	    212
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_TASK_LOG
	    Model.FilterQueryForm
	    Model.TaskLogList->execute_load_page
	    View.TaskLog->list
	    next=GROUP_TASK_LOG
            csv_task=GROUP_TASK_LOG_CSV
	    require_secure=1
	)],
	[qw(
	    GROUP_TASK_LOG_CSV
	    213
	    ANY_OWNER
	    ADMIN_READ&ADMIN_WRITE&FEATURE_TASK_LOG
	    Model.FilterQueryForm
	    Model.TaskLogList->execute_iterate_start
	    View.TaskLog->list_csv
	    next=GROUP_TASK_LOG_CSV
            csv_task=GROUP_TASK_LOG_CSV
	    require_secure=1
	)],
#214-219
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
	    ANY_OWNER
	    TUPLE_ADMIN&FEATURE_TUPLE
	    Model.TupleSlotTypeList->execute_load_all_with_query
	    View.Tuple->slot_type_list
	)],
	[qw(
	    FORUM_TUPLE_SLOT_TYPE_EDIT
	    71
	    ANY_OWNER
	    TUPLE_ADMIN&FEATURE_TUPLE
	    Model.TupleSlotTypeListForm
	    View.Tuple->slot_type_edit
	    next=FORUM_TUPLE_SLOT_TYPE_LIST
	)],
	[qw(
	    FORUM_TUPLE_DEF_LIST
	    72
	    ANY_OWNER
	    TUPLE_ADMIN&FEATURE_TUPLE
	    Model.TupleDefList->execute_load_all_with_query
	    View.Tuple->def_list
	)],
	[qw(
	    FORUM_TUPLE_DEF_EDIT
	    73
	    ANY_OWNER
	    TUPLE_ADMIN&FEATURE_TUPLE
            Model.TupleSlotTypeList->execute_load_all
	    Model.TupleDefListForm
	    View.Tuple->def_edit
	    next=FORUM_TUPLE_DEF_LIST
	)],
	[qw(
	    FORUM_TUPLE_USE_LIST
	    74
	    ANY_OWNER
	    TUPLE_READ&FEATURE_TUPLE
	    Model.TupleUseList->execute_load_all_with_query
	    View.Tuple->use_list
	)],
	[qw(
	    FORUM_TUPLE_USE_EDIT
	    75
	    ANY_OWNER
	    TUPLE_ADMIN&FEATURE_TUPLE
	    Model.TupleUseForm
	    View.Tuple->use_edit
	    next=FORUM_TUPLE_USE_LIST
	)],
	[qw(
	    FORUM_TUPLE_LIST
	    76
	    ANY_OWNER
	    TUPLE_READ&FEATURE_TUPLE
	    Model.TupleList->execute_load_page
	    View.Tuple->list
	)],
	[qw(
	    FORUM_TUPLE_LIST_CSV
	    77
	    ANY_OWNER
	    TUPLE_READ&FEATURE_TUPLE
	    Model.TupleList->execute_load_all_with_query
	    View.Tuple->list_csv
	)],
	[qw(
	    FORUM_TUPLE_EDIT
	    78
	    ANY_OWNER
	    TUPLE_READ&TUPLE_WRITE&FEATURE_TUPLE
	    Model.TupleSlotListForm
	    View.Tuple->edit
	    next=FORUM_TUPLE_LIST
	    mail_reflector_task=FORUM_MAIL_REFLECTOR
	)],
	[qw(
	    FORUM_TUPLE_HISTORY
	    79
	    ANY_OWNER
	    TUPLE_READ&FEATURE_TUPLE
	    Model.TupleList->execute_load_history_list
	    View.Tuple->history_list
	)],
	[qw(
	    FORUM_TUPLE_HISTORY_CSV
	    80
	    ANY_OWNER
	    TUPLE_READ&FEATURE_TUPLE
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
	    require_secure=1
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
	    require_secure=1
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
	    require_secure=1
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
	    require_secure=1
	)],
	[qw(
	    USER_CREATE_DONE
	    93
	    GENERAL
	    ANYBODY
	    Action.UserCreateDone
	)],
	[qw(
	    USER_SETTINGS_FORM
	    94
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.UserSettingsListForm
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
	    ANY_OWNER
	    ANYBODY&FEATURE_WIKI
	    View.Wiki->help
	)],
	$_C->if_version(
	    3 => sub {
		return (
		    [qw(
			FORUM_WIKI_VIEW
			48
			ANY_OWNER
			ANYBODY&FEATURE_WIKI
			Action.WikiView->execute_prepare_html
			View.Wiki->view
			MODEL_NOT_FOUND=FORUM_WIKI_NOT_FOUND
			want_author=1
		    )],
		);
	    },
	    sub {
		return (
		    [qw(
			FORUM_PUBLIC_WIKI_VIEW
			120
			ANY_OWNER
			ANYBODY&FEATURE_WIKI
			Action.WikiView->execute_prepare_html
			View.Wiki->view
			MODEL_NOT_FOUND=FORUM_WIKI_NOT_FOUND
			edit_task=FORUM_WIKI_EDIT
			want_author=1
		    )],
		    [qw(
			FORUM_WIKI_VIEW
			48
			ANY_OWNER
			DATA_READ&FEATURE_WIKI
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
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&FEATURE_WIKI
	    Model.WikiForm
	    View.Wiki->edit
	    next=FORUM_WIKI_VIEW
	)],
	[qw(
	    FORUM_WIKI_NOT_FOUND
	    50
	    ANY_OWNER
	    ANYBODY&FEATURE_WIKI
	    Action.WikiView->execute_not_found
	    View.Wiki->not_found
	    edit_task=FORUM_WIKI_EDIT
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
	    want_author=1
	)],
	[qw(
	    FORUM_WIKI_VERSIONS_LIST
	    122
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&FEATURE_WIKI
	    Action.WikiView->execute_load_history
	    Model.RealmFileVersionsList->execute_load_page
	    Model.RealmFileVersionsListForm
	    View.Wiki->version_list
	    next=FORUM_WIKI_VERSIONS_DIFF
	    cancel=FORUM_WIKI_VIEW
	)],
	[qw(
	    FORUM_WIKI_VERSIONS_DIFF
	    123
	    ANY_OWNER
	    DATA_READ&DATA_WRITE&FEATURE_WIKI
            Model.RealmFileTextDiffList->execute_load_all
	    View.Wiki->versions_diff
	)],
    ];
#124-129 free
}

sub info_xapian {
    return [
	[qw(
	    JOB_XAPIAN_COMMIT
	    60
	    ANY_OWNER
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
	[qw(
	    GROUP_SEARCH_LIST
	    62
	    ANY_OWNER
	    ANYBODY
	    Model.SearchForm
	    Model.SearchList->execute_load_page
	    View.Search->list
	    next=GROUP_SEARCH_LIST
	)],
#62-69 free
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
	$only_once->([map($info->($_), reverse(@cfg))]),
    );
}

sub standard_components {
    return [sort
        _sort
	grep(
	    $_ ne 'otp'
		&& $_C->if_version(10, 1, sub {$_ ne 'task_log'}),
	    @{shift->grep_methods($_INFO_RE)},
	),
    ];
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
	    if ($c->{permissions}) {
		$_A->warn_deprecated($c->{name}, ': permissions deprecated, use permission_set');
		$c->{permission_set} = delete($c->{permissions});
	    }
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
		permission_set => shift(@$c),
		items => [grep(!/=/, @$c)],
		map(split(/=/, $_, 2), grep(/=/, @$c)),
	    };
	}
	else {
	    b_die($c, ': invalid config format');
	}
    }
    return [sort({$a->{int} <=> $b->{int}} values(%$map))];
}

sub _sort {
    return $a eq $b ? 0
	: $a eq 'base' ? -1
	: $b eq 'base' ? +1
	: $a cmp $b;
}

1;
