# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeBase;
use strict;
use base 'Bivio::UI::Facade';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = __PACKAGE__->use('IO.Config');
my($_WIKI_DATA_FOLDER) = __PACKAGE__->use('Type.WikiDataName')->PRIVATE_FOLDER;

sub HELP_WIKI_REALM_NAME {
    return 'site-help';
}

sub MAIL_RECEIVE_PREFIX {
    return '_mail_receive_';
}

sub SITE_CONTACT_REALM_NAME {
    return 'site-contact';
}

sub SITE_REALM_NAME {
    return 'site';
}

sub SITE_ADM_REALM_NAME {
    return shift->SITE_REALM_NAME;
}

sub new {
    my($proto, $config) = @_;
    return $config->{clone} ? $proto->SUPER::new($config) : $proto->SUPER::new(
	_merge(
	    map({
		my($x) = \&{"_cfg_$_"};
		$x->($proto);
	    } @{Bivio::Agent::TaskId->included_components}),
	    $config,
	),
    );
}

sub _cfg_base {
    return {
	clone => undef,
	is_production => 1,
	Color => [
	    [[qw(
		table_separator
		table_odd_row_bg
		table_even_row_bg
		page_alink
		page_link
		page_link_hover
		page_bg
		page_text
		page_vlink
		summary_line
		error
		warning
	    )] => -1],
	    # CSS
	    [body => 0],
	    [[qw(body_background header_su)] => 0xffffff],
	    [[qw(off footer_border_top)] => 0x999999],
	    [even_background => 0xeeeeee],
	    [odd_background => -1],
	    [[qw(a_link topic nav)] => 0x444444],
	    [a_hover => 0x888888],
	    [acknowledgement_border => 0x0],
	    [[qw(err warn empty_list_border form_field_err)] => 0x990000],
	    [header_su_background => 0x00ff00],
	    [[qw(form_desc form_sep_border msg_parts_border)] => 0x666666],
            [help_wiki_background => 0x6b9fea],
	    [dd_menu => 0x444444],
	    [[qw(dd_menu_selected dd_menu_background)] => 0xffffff],
	    [dd_menu_border => 0x888888],
	    [dd_menu_selected_background => 0x888888],
	],
	Font => [
	    map([$_->[0] => [qq{class=$_->[1]}]],
		[error => 'field_err'],
		[warning => 'warn'],
		[checkbox => 'check'],
		[form_submit => 'button'],
		[list_action => 'list_action'],
	    ),
	    [[qw{
		default
		form_field_checkbox
		form_field_description
		form_submit
		input_field
		mailto
		number_cell
		page_heading
		page_text
		radio
		search_field
		table_cell
		table_heading
		list_action
	    }] => []],
	    # HTML4
	    [a_hover => 'underline'],
	    [a_link => 'normal'],
	    [em => 'italic'],
	    [h1 => ['140%', 'bold']],
	    [h2 => ['130%', 'bold']],
	    [h3 => ['120%', 'bold']],
	    [h4 => ['110%', 'bold']],
	    [normal => ['normal']],
	    [strong => 'bold'],
	    # Our tags
	    [warn => 'italic'],
	    [err => 'bold'],
	    [body => ['family=Arial, Helvetica, Geneva, SunSans-Regular, sans-serif', 'small']],
	    [tools => ['nowrap', 'inline']],
	    [[qw(code pre_text)] => [
		'family="Courier New",Courier,monospace,fixed',
		'120%',
	    ]],
	    [form_err => 'bold'],
	    [form_label_ok => ['bold', 'nowrap']],
	    [form_field_err => ['normal', '80%']],
	    [form_label_err => ['italic', 'nowrap']],
	    [form_footer => ['smaller', 'italic']],
	    [footer => 'smaller'],
	    [header_su => 'larger'],
	    [selected => 'bold'],
	    [topic => 'bold', 'larger'],
	    [byline => 'bold'],
	    [title => ['140%', 'bold']],
	    [nav => '120%'],
	    [[qw(off pager)] => []],
	    [th => 'bold'],
	    [dd_menu => ['normal']],
	],
	Constant => [
	    [xlink_back_to_top => {
		uri => '',
		anchor => 'top',
	    }],
	    [my_site_redirect_map => []],
	    [ThreePartPage_want_UserState => 1],
	],
 	FormError => [
	    [NULL => 'You must supply a value for vs_fe("label");.'],
	    [EXISTS => 'vs_fe("label"); already exists in our database.'],
	    [NOT_FOUND => 'vs_fe("label"); was not found in our database.'],
	    ['UserPasswordQueryForm.Email.email.PERMISSION_DENIED' => 'You are not allowed to reset your password.  Please contact a system administrator for assistance.'],
	    ['image_file.TOO_MANY' => 'vs_fe("label"); contains multiple images, please upload a file which contains only one image.'],
	    ['image_file.EXISTS' => 'vs_fe("label"); image already exists.  Please choose another name.'],
	    ['image_file.SYNTAX_ERROR' => 'vs_fe("label"); unknown or invalid image format.  Please verify file, and change to an acceptable format (e.g. png, gif, jpg), and retry upload.'],
	],
	HTML => [
	    [want_secure => 0],
	    [table_default_align => 'left'],
	],
	Task => [
	    [CLIENT_REDIRECT => ['go/*', 'goto/*']],
	    [CLUB_HOME => '?'],
	    [DEFAULT_ERROR_REDIRECT_FORBIDDEN => undef],
 	    [DEFAULT_ERROR_REDIRECT_NOT_FOUND => undef],
 	    [DEFAULT_ERROR_REDIRECT_MODEL_NOT_FOUND => undef],
	    [FAVICON_ICO => 'favicon.ico'],
	    [FORBIDDEN => undef],
	    [PUBLIC_PING => 'pub/ping'],
	    [LOCAL_FILE_PLAIN => ['i/*', 'f/*']],
	    [MY_CLUB_SITE => undef],
	    [MY_SITE => 'my-site/*'],
	    [PERMANENT_REDIRECT => undef],
	    [ROBOTS_TXT => 'robots.txt'],
	    [SHELL_UTIL => undef],
	    [SITE_CSS => 'pub/site.css'],
	    [SITE_ROOT => '*'],
	    [TEST_BACKDOOR => ['test-backdoor', 'test_backdoor']],
	    [USER_HOME => '?'],
	    [TEST_TRACE => 'test-trace/*'],
	],
	Text => [
	    [support_email => 'support'],
	    [support_name => 'String(vs_site_name()); Support'],
#TODO:	    [support_phone => '(800) 555-1212'],
	    [[qw(prologue epilogue)] => ''],
	    [home_page_uri => '/hm/index'],
	    [view_execute_uri_prefix => 'SiteRoot->'],
	    [favicon_uri => '/i/favicon.ico'],
	    [form_error_title => 'Please correct the errors below:'],
	    [none => ''],
	    [Image_alt => [
		dot => '',
		sort_up => 'This column sorted in descending order',
		sort_down => 'This column sorted in ascending order',
	    ]],
	    [ok_button => '   OK   '],
	    [cancel_button => ' Cancel '],
	    [[qw(Email.email login email)] => 'Email'],
	    [password => 'Password'],
	    [confirm_password => 'Re-enter Password'],
	    [display_name => 'Your Full Name'],
	    [first_name => 'First Name'],
	    [middle_name => 'Middle Name'],
	    [last_name => 'Last Name'],
	    [street1 => 'Street Line 1'],
	    [street2 => 'Street Line 2'],
	    [city => 'City'],
	    [state => 'State'],
	    [zip => 'Zip'],
	    [country => 'Country'],
            [phone => 'Phone'],
	    [empty_list_prose => 'This list is empty.'],
	    [[qw(actions list_actions)] => 'Actions'],
	    [xlink => [
		back_to_top => 'back to top',
		SITE_ROOT => 'Home',
	    ]],
	    [title => [
		[qw(DEFAULT_ERROR_REDIRECT_MODEL_NOT_FOUND DEFAULT_ERROR_REDIRECT_NOT_FOUND)] => 'Page Not Found',
	    ]],
	    [[qw(paged_detail paged_list)] => [
		prev => 'Back',
		next => 'Next',
		list => 'Back to list',
	    ]],
	    [prose => [
		ascend => ' &#9650;',
		[qw(descend drop_down_arrow)] => ' &#9660;',
		error_indicator => '&#9654;',
		@{__PACKAGE__->map_by_two(sub {
		    my($k, $v) = @_;
		    # Base. is deprecated usage
		    return ([$k, "Base.$k"] => $v);
	        }, [
		    xhtml_logo => q{DIV_logo_su(If(
			['->is_substitute_user'],
			Link(
			    RoundedBox(Join([
				"Acting as User: <br />\n",
				String(['auth_user', 'display_name']),
				"<br />\nClick here to exit.\n",
			    ])),
			    Bivio::IO::Config->if_version(
                                5 => sub {URI({
                                    task_id => 'SITE_ADM_SUBSTITUTE_USER_DONE',
                                    realm => vs_constant('site_adm_realm_name'),
                                })},
                                sub {'LOGOUT'},
                            ),
			    'su',
			),
			Link(' ', '/', 'logo'),
		    ));},
		    xhtml_head_title => q{Title([vs_site_name(), vs_text_as_prose('xhtml_title')]);},
		    xhtml_title => q{Prose(vs_text([sub {"xhtml.title.$_[1]"}, ['task_id', '->get_name']]));},
		    xhtml_copyright => <<"EOF",
Copyright &copy; @{[__PACKAGE__->use('Type.DateTime')->now_as_year]} vs_text_as_prose('site_copyright');<br />
All rights reserved.<br />
Link('Software by bivio', 'http://www.bivio.biz');
EOF
		])},
	    ]],
	],
    };
}

sub _cfg_blog {
    return {
	Font => [
	    [blog_list_heading => ['size=100%', 'bold']],
	],
	Task => [
	    [FORUM_BLOG_CREATE => '?/add-blog-entry'],
	    [FORUM_BLOG_EDIT => '?/edit-blog-entry/*'],
	    $_C->if_version(
		3 => sub {
		    return (
			[FORUM_BLOG_LIST => ['?/blog', '?/public-blog']],
			[FORUM_BLOG_DETAIL => ['?/blog-entry/*', '?/public-blog-entry/*']],
			[FORUM_BLOG_RSS => ['?/blog.rss', '?/public-blog.rss']],
		    );
		},
		sub {
		    return (
			[FORUM_BLOG_LIST => '?/blog'],
			[FORUM_BLOG_DETAIL => '?/blog-entry/*'],
			[FORUM_BLOG_RSS => '?/blog.rss'],
			[FORUM_PUBLIC_BLOG_LIST => '?/public-blog'],
			[FORUM_PUBLIC_BLOG_DETAIL => '?/public-blog-entry/*'],
			[FORUM_PUBLIC_BLOG_RSS => '?/public-blog.rss'],
		    );
		},
	    ),
	],
	Text => [
	    [[qw(BlogCreateForm BlogEditForm)] => [
		'title' => 'Title',
		'body' => '',
		'RealmFile.is_public' => 'Public?',
	    ]],
	    [BlogList => [
		empty_list_prose => 'No entries in this blog.',
	    ]],
	    [title => [
		[qw(FORUM_BLOG_LIST FORUM_PUBLIC_BLOG_LIST FORUM_BLOG_RSS FORUM_PUBLIC_BLOG_RSS)]
		    => 'Blog',
		[qw(FORUM_BLOG_DETAIL FORUM_PUBLIC_BLOG_DETAIL)]
		    => 'Blog Detail',
	    ]],
	    [FORUM_BLOG_EDIT => 'Edit this entry'],
	    [FORUM_BLOG_CREATE => 'New blog entry'],
	    [prose => [
		[qw(BlogList BlogRecentList)] => [
		    title => 'vs_site_name(); Blog',
		    tagline => 'Recent Blog Entries at vs_site_name();',
		],
	    ]],
	    [acknowledgement => [
		FORUM_BLOG_CREATE => 'The blog entry has been added.',
		FORUM_BLOG_EDIT => 'The blog entry update has been saved.',
	    ]],
#TODO: Move this
	    [FORUM_ADM_FORUM_ADD => 'Add forum'],
	],
    };
}

sub _cfg_calendar {
    return {};
}

sub _cfg_crm {
    return {
        FormError => [
	    ['CRMForm.action_id.SYTNAX_ERROR' => q{Action is not valid (browser bug?)}],
	    ['CRMForm.to.MUTUALLY_EXCLUSIVE' => q{vs_text('CRMForm.update_only'); not allowed for new tickets.}],
	],
	Task => [
	    [FORUM_CRM_THREAD_ROOT_LIST => '?/tickets'],
	    [FORUM_CRM_THREAD_LIST => '?/ticket'],
	    [FORUM_CRM_FORM => '?/compose-ticket-msg'],
	],
	Text => [
	    [CRMThreadRootList => [
		'CRMThread.subject' => 'Subject',
		'RealmFile.modified_date_time' => 'Initiated',
		'RealmMail.from_email' => 'Initiated by',
		'CRMThread.crm_thread_num' => 'Ticket',
		'CRMThread.modified_date_time' => 'Last Update',
		'modified_by_name' => 'Updated by',
		'CRMThread.crm_thread_status' => 'Status',
		'owner_name' => 'Assigned to',
	    ]],
	    ['CRMActionList.label' => [
		assign_to => 'Assign to ',
		closed => 'Close',
		locked => 'Keep Locked',
		open => 'Unlock',
	    ]],
	    [CRMForm => [
		action_id => 'Action',
		ok_button => 'Send',
		update_only => 'Update Fields Only',
	    ]],
	    ['task_menu.title' => [
		'FORUM_CRM_FORM.reply_all' => 'Answer',
		'FORUM_CRM_FORM.reply_realm' => 'Discuss Internally',
		FORUM_CRM_FORM => 'New Ticket',
	    ]],
	    [[qw(title xlink)] => [
#TODO: Make into shortcut of widget
		FORUM_CRM_FORM => q{If(['->has_keys', 'Model.RealmMailList'], Join([Enum(['Model.CRMThread', 'crm_thread_status']), ' Ticket #', String(['Model.CRMThread', 'crm_thread_num'])]), 'New Ticket');},
		FORUM_CRM_THREAD_ROOT_LIST => 'Tickets',
		FORUM_CRM_THREAD_LIST => q{Enum(['Model.CRMThreadList', '->get_crm_thread_status']); Ticket #String(['Model.CRMThreadList', '->get_crm_thread_num']); String(['Model.CRMThreadList', '->get_subject']);},
	    ]],
	    [acknowledgement => [
		FORUM_CRM_FORM => 'Your message was sent.',
	    ]],
	],
    };
}

sub _cfg_dav {
    return {
	Task => [
	    [DAV => ['dav/*', 'dv/*']],
	],
	Text => [
	    [ForumList => [
		'RealmOwner.name' => 'Forum',
		'RealmOwner.display_name' => 'Title',
		'Forum.want_reply_to' => 'Reply-To List?',
		'admin_only_forum_email' => 'Admin Only Email?',
		'system_user_forum_email' => 'System User Email?',
		'public_forum_email' => 'Public Email?',
		'Forum.forum_id' => 'Database Key',
#TODO: Make visible only if OTP is enabled.  Requires change to DAVList
		'Forum.require_otp' => 'Require OTP?',
	    ]],
	    [ForumUserList => [
		mail_recipient => 'Subscribed?',
		file_writer => 'Write Files?',
		administrator => 'Administrator?',
		'RealmUser.user_id' => 'Database Key',
	    ]],
	    [EmailAliasList => [
		'EmailAlias.incoming' => 'From Email',
		'EmailAlias.outgoing' => 'To Email or Forum',
		'primary_key' => 'Database Key',
	    ]],
	],
    };
}

sub _cfg_file {
    return {
	Task => [
	    [FORUM_EASY_FORM => '?/Forms/*'],
	    $_C->if_version(
		3 => sub {
		    return (
			[FORUM_FILE => ['?/file/*', '?/public-file/*', '?/public/*', '?/Public/*', '?/pub/*']],
		    );
		},
		sub {
		    return (
			[FORUM_FILE => '?/file/*'],
			[FORUM_PUBLIC_FILE => ['?/public-file/*', '?/public/*', '?/Public/*', '?/pub/*']],
		    );
		},
	    ),
	    [FORUM_FILE_TREE_LIST => '?/files/*'],
	    [FORUM_TEXT_FILE_FORM => '?/edit-file/*'],
	    [FORUM_FILE_FOLDER_ADD => '?/folder-add/*'],
	    [FORUM_FILE_DELETE => '?/file-remove/*'],
	    [FORUM_FILE_ADD => '?/file-add/*'],
	    [FORUM_FILE_LOCK => '?/file-lock/*'],
	    [FORUM_FILE_UNLOCK => '?/file-unlock/*'],
	    [FORUM_FILE_UPDATE => '?/file-update/*'],
	    [FORUM_FILE_RENAME => '?/file-rename/*'],
	    [FORUM_FILE_UNLOCK_OVERRIDE => '?/file-unlock-override/*'],
	    [FORUM_FILE_VERSIONS_LIST => '?/file-details/*'],
	],
	Text => [
	    [[qw(FileAddForm FileUpdateForm)] => [
		file => 'File to upload',
		comment => 'Comments',
	    ]],
	    [FileRenameForm => [
		name => 'New name',
		comment => 'Comments',
	    ]],
	    [FolderAddForm => [
		name => 'Folder name',
	    ]],
	    [TextFileForm => [
		content => '',
		ok_button => 'Save',
	    ]],
	    [[qw(RealmFileList RealmFileTreeList)] => [
		'RealmFile.path' => 'Name',
		'RealmFile.modified_date_time' => 'Last Modified',
		[qw(Email.email RealmOwner_2.display_name)] => 'Owner',
		node_collapsed => 'folder_collapsed',
		node_expanded => 'folder_expanded',
		leaf_node => 'leaf_file',
		empty_list_prose => 'No files in this forum.',
		locked_leaf_node => 'leaf_file_locked',
	    ]],
	    [RealmFileVersionsList => [
		'RealmFile.path' => 'Revision',
		'RealmFile.modified_date_time' => 'Checked In',
		[qw(Email.email RealmOwner_2.display_name)] => 'Owner',
		'comment', 'Comments',
		empty_list_prose => 'No files revisions.',
	    ]],
	    [title => [
		FORUM_FILE_TREE_LIST => 'Files',
		FORUM_TEXT_FILE_FORM => 'Text Edit',
		FORUM_FILE => 'Files',
		FORUM_FILE_FOLDER_ADD => 'New Folder',
		FORUM_FILE_DELETE => 'Remove File',
		FORUM_FILE_ADD => 'Add File',
		FORUM_FILE_LOCK => 'Lock File',
		[qw(FORUM_FILE_UNLOCK FORUM_FILE_UNLOCK_OVERRIDE)] =>
		    'Unlock File',
		FORUM_FILE_UPDATE => 'Check In File',
		FORUM_FILE_RENAME => 'Rename File',
		FORUM_FILE_VERSIONS_LIST => 'File Details',
	    ]],
	    [acknowledgement => [
		FORUM_TEXT_FILE_FORM => 'The file was saved.',
		FORUM_FILE_FOLDER_ADD => 'The folder has been added.',
		FORUM_FILE_ADD => 'The file has been added.',
		FORUM_FILE_UPDATE => 'The file has been updated.',
		FORUM_FILE_RENAME => 'The file has been renamed.',
		FORUM_FILE_DELETE => 'The file has been removed.',
		FORUM_FILE_LOCK => q{The file has been locked - Link('download the file here', [qw(Model.FileLockForm file_uri)]);.},
		[qw(FORUM_FILE_UNLOCK FORUM_FILE_UNLOCK_OVERRIDE)] =>
		    'The file has been unlocked.',
	    ]],
        ],
    };
}

sub _cfg_mail {
    return {
	Font => [
#TODO: Old?
	    [mail_msg_field => 'bold'],
	    [msg_byline => [qw(120% bold)]],
	],
	Color => [
	    [msg_byline => 0x0],
#TODO: Alias this to form_sep_border
	    [mail_msg_border => 0x666666],
	],
	Task => [
	    [FORUM_MAIL_RECEIVE => sub {
		 return '?/' . shift->get_facade->MAIL_RECEIVE_PREFIX;
	    }],
	    $_C->if_version(
		4 => sub {
		    return (
			[FORUM_MAIL_THREAD_ROOT_LIST => '?/mail'],
			[FORUM_MAIL_THREAD_LIST => '?/mail-thread'],
			[FORUM_MAIL_FORM => '?/compose-mail-msg'],
			[FORUM_MAIL_PART => '?/mail-msg-part/*'],
		    );
		},
	    ),
	    [FORUM_MAIL_REFLECTOR => undef],
	    [MAIL_RECEIVE_DISPATCH => '_mail_receive/*'],
	    [MAIL_RECEIVE_FORWARD => undef],
	    [MAIL_RECEIVE_IGNORE => undef],
	    [MAIL_RECEIVE_NOT_FOUND => undef],
	    [MAIL_RECEIVE_NO_RESOURCES => undef],
	    [USER_MAIL_BOUNCE => sub {
		 return '?/' . shift->get_facade->MAIL_RECEIVE_PREFIX
		     . Bivio::Biz::Model->get_instance('RealmMailBounce')
			 ->TASK_URI;
	    }],
	],
	Text => [
	    ['MailReceiveDispatchForm.uri_prefix' => sub {
		 return shift->get_facade->MAIL_RECEIVE_PREFIX;
	    }],
	    [MailThreadRootList => [
		'RealmMail.subject' => 'Topic',
		'RealmMail.subject_lc' => 'Topic',
		'RealmFile.modified_date_time' => 'First Post',
		'RealmMail.from_email' => 'Author',
		reply_count => 'Replies',
		'RealmFile_2.modified_date_time' => 'Last Post',
	    ]],	
	    [to => 'To'],
	    [cc => 'Cc'],
	    [subject => 'Subject'],
	    [body => 'Text'],
	    [Bivio::Biz::Model->get_instance('MailForm')
	        ->map_attachments(sub {shift}) => 'Attach'],
	    [view_rfc822 => 'Show Original'],
	    [MailForm => [
		subject => 'Topic',
		ok_button => 'Send',
	    ]],
	    [prose => [
		MailHeader => [
		    to => 'To:',
		    from => 'From:',
		    cc => 'Cc:',
		    subject => 'Subject:',
		    date => 'Date:',
		],
	        MailPartList => [
		     byline => q{DIV_byline(Join([SPAN_author(String(['->get_from_name'])), SPAN_label(' on '), SPAN_date(DateTime(['->get_header', 'date']))]));},
		     forward => q{DIV_forward(Join([DIV_header('---------- Forwarded message ----------'), MailHeader()]));},
		     attachment => q{SPAN_label('Attachment:');SPAN_value(String(['->get_file_name']));},
		 ],
	    ]],
	    ['task_menu.title' => [
		'FORUM_MAIL_FORM.reply_all' => 'Reply to All',
		'FORUM_MAIL_FORM.reply_author' => 'Reply to Author',
		'FORUM_MAIL_FORM.reply_realm' => 'Reply',
		FORUM_MAIL_FORM => 'New Topic',
		FORUM_MAIL_THREAD_ROOT_LIST => 'Mail',
	    ]],
	    [title => [
		FORUM_MAIL_FORM => q{If(['->has_keys', 'Model.RealmMailList'], 'Reply', 'New Topic');},
		FORUM_MAIL_THREAD_ROOT_LIST => 'Mail',
		FORUM_MAIL_THREAD_LIST => q{Topic: String(['Model.MailThreadList', '->get_subject']);},
	    ]],
	    [acknowledgement => [
		FORUM_MAIL_FORM => 'Your message was sent.',
	    ]],
	],
    };
}

sub _cfg_motion {
    return {
	Task => [
	    [FORUM_MOTION_LIST => '?/votes'],
	    [FORUM_MOTION_ADD => ['?/add-vote', '?/vote-add']],
	    [FORUM_MOTION_EDIT => ['?/edit-vote', '?/vote-edit']],
	    [FORUM_MOTION_VOTE => '?/vote'],
	    [FORUM_MOTION_VOTE_LIST => ['?/vote-results', '?/results']],
	    [FORUM_MOTION_VOTE_LIST_CSV => ['?/vote-results.csv', '?/results.csv']],
	],
	Text => [
	    [Motion => [
		name => 'Name',
		question => 'Question',
		status => 'Status',
		type => 'Type',
	    ]],
	    [MotionVote => [
		vote => 'Vote',
		comment => 'Comment',
		creation_date_time => 'Date',
	    ]],
	    [MotionList => [
		empty_list_prose => 'No votes to display.',
	    ]],
	    [MotionVoteList => [
		empty_list_prose => 'No vote results.',
	    ]],
	    [acknowledgement => [
		FORUM_MOTION_EDIT => 'Vote updates have been saved.',
		FORUM_MOTION_VOTE =>
		    'Thank you for your participation in the vote.',
	    ]],
	    [title => [
		FORUM_MOTION_LIST => 'Votes',
		FORUM_MOTION_ADD => 'Add vote',
		FORUM_MOTION_EDIT => 'Edit vote',
		FORUM_MOTION_VOTE => 'Vote',
		FORUM_MOTION_VOTE_LIST => 'Vote Results',
	    ]],
	    ['task_menu.title' => [
		FORUM_MOTION_VOTE_LIST_CSV => 'Spreadsheet',
	    ]],
	    [ListActions => [
		FORUM_MOTION_VOTE => 'Vote',
		FORUM_MOTION_EDIT => 'Edit',
		FORUM_MOTION_VOTE_LIST => 'Results',
	    ]],
	],
    };
}

sub _cfg_otp {
    return {
        FormError => [
	    ['UserLoginForm.RealmOwner.password.OTP_PASSWORD_MISMATCH' => q{OTP challenge: String(['Model.OTP', '->get_challenge']);}],
	    ['UserOTPForm.new_password.NOT_ZERO' => q{You must set a passphrase (password) in your OTP client.  Please enter a value in the Password field of WinKey and re-compute a Response.}],
	],
	Task => [
	    [USER_OTP => '?/setup-otp'],
	],
	Text => [
	    [UserOTPForm => [
		old_password => 'Current Password/Key',
		new_password => 'New Key',
		confirm_new_password => 'Confirm Key',
		prose => [
		    prologue => <<'EOF',
Join([
    If([sub {
        my($undef, $otp) = @_;
        return $otp && $otp->should_reinit;
    }, ['->unsafe_get', 'Model.OTP']],
        String('You MUST re-initialize your one-time password now. '),
    ),
    'To start or re-initialize your one-time password process, you need to enter your current password or the last OTP key you used',
]);
EOF
		    challenge => <<'EOF',
If([['form_model'], '->unsafe_get', 'otp_challenge'],
    Join([
        'Last OTP challenge: ',
        String(['Model.UserOTPForm', 'otp_challenge']),
    ]),
);
EOF
		    new_challenge => q{New OTP challenge: String(['Model.UserOTPForm', 'new_otp_challenge']);},
		],
	    ]],
	    [title => [
		USER_OTP => 'Set up One-Time Password',
	    ]],
	    [acknowledgement => [
		USER_OTP => 'Your One-Time Password has been updated.',
	    ]],
	],
    };
}

sub _cfg_site_adm {
    return {
	Task => [
	    [SITE_ADM_USER_LIST => '?/admin-users'],
	    [SITE_ADM_SUBSTITUTE_USER => '?/admin-su'],
	    [SITE_ADM_SUBSTITUTE_USER_DONE => '?/admin-su-exit'],
	],
	Text => [
	    [AdmUserList => [
		display_name => 'Name',
		empty_list_prose => qq{No user last names begin with "String([['Model.AdmUserList', '->get_query'], 'search']);".},
	    ]],
	    ['task_menu.title' => [
		SITE_ADM_USER_LIST => 'Users',
	    ]],
	    [title => [
		SITE_ADM_USER_LIST => 'All Users',
		SITE_ADM_SUBSTITUTE_USER => 'Act as User',
	    ]],
	],
    };
}

sub _cfg_tuple {
    return {
 	FormError => [
	    [NOT_FOUND => 'vs_fe("label"); is not a valid choice.'],
	],
	Task => [
	    [FORUM_TUPLE_DEF_EDIT => '?/edit-db-schemas'],
	    [FORUM_TUPLE_DEF_LIST => '?/db-schemas'],
	    [FORUM_TUPLE_EDIT => '?/edit-db-record'],
	    [FORUM_TUPLE_HISTORY => '?/db-record-history'],
	    [FORUM_TUPLE_HISTORY_CSV => '?/db-record-history.csv'],
	    [FORUM_TUPLE_LIST => '?/db-records'],
	    [FORUM_TUPLE_LIST_CSV => '?/db-records.csv'],
	    [FORUM_TUPLE_SLOT_TYPE_EDIT => '?/edit-db-type'],
	    [FORUM_TUPLE_SLOT_TYPE_LIST => '?/db-types'],
	    [FORUM_TUPLE_USE_EDIT => '?/edit-db-table'],
	    [FORUM_TUPLE_USE_LIST => '?/db-tables'],
	],
	Text => [
	    [title => [
		FORUM_TUPLE_DEF_EDIT => 'Modify database schema',
		FORUM_TUPLE_DEF_LIST => 'Database schemas',
		FORUM_TUPLE_EDIT =>
		    q{Edit String([qw(Model.TupleUseList TupleUse.label)]); record},
		FORUM_TUPLE_LIST =>
		    q{String([qw(Model.TupleUseList TupleUse.label)]); records},
		FORUM_TUPLE_HISTORY =>

		    q{String([qw(Model.TupleUseList TupleUse.label)]); record #String([qw(Model.TupleList Tuple.tuple_num)]); history},
		FORUM_TUPLE_MAIL_THREAD =>
		    q{String([qw(Model.TupleUseList TupleUse.label)]); Record #String([qw(Model.Tuple tuple_num)]);},
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Modify database type',
		FORUM_TUPLE_SLOT_TYPE_LIST => 'Database types',
		FORUM_TUPLE_USE_EDIT => 'Modify table',
		FORUM_TUPLE_USE_LIST => 'Database tables',
	    ]],
	    ['task_menu.title' => [
		FORUM_TUPLE_DEF_EDIT => 'Add schema',
		FORUM_TUPLE_DEF_LIST => 'Schemas',
		FORUM_TUPLE_LIST => 'Records',
		[qw(FORUM_TUPLE_LIST_CSV FORUM_TUPLE_HISTORY_CSV)]
		    => 'Spreadsheet',
		FORUM_TUPLE_EDIT => 'Add Record',
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Add type',
		FORUM_TUPLE_SLOT_TYPE_LIST => 'Types',
		FORUM_TUPLE_USE_EDIT => 'Add table',
		FORUM_TUPLE_USE_LIST => 'Tables',
		TupleHistoryList => [
		    FORUM_TUPLE_EDIT => 'Modify record',
		    FORUM_TUPLE_LIST => 'Back to list',
		],
	    ]],
	    [TupleHistoryList => [
		'RealmFile.modified_date_time' => 'Date',
		'RealmMail.from_email' => 'Who',
		slot_headers => 'Updated Fields',
		comment => 'Comment',
	    ]],
	    [[qw(TupleDefList TupleDefListForm)] => [
		'TupleDef.label' => 'Schema Name',
		'TupleDef.moniker' => 'Mail Prefix',
	    ]],
	    ['TupleUseForm.separator' => [
		optional => '(OPTIONAL) Fields will default to Schema values',
	    ]],
	    [[qw(TupleUseList TupleUseForm)] => [
		'TupleUse.label' => 'Table Name',
		'TupleUse.moniker' => 'Mail Prefix',
		'list_action.FORUM_TUPLE_EDIT' => 'Add Record',
		[qw(TupleUse.tuple_def_id TupleDef.label)] => 'Schema',
	    ]],
	    [TupleUseList => [
		empty_list_prose => 'No database Tables have been added.',
	    ]],
	    [TupleDefList => [
		empty_list_prose => 'No database Schemas have been defined.',
	    ]],
	    [TupleSlotListForm => [
		'Tuple.tuple_num' => 'Record#',
	    ]],
	    [[qw(TupleList TupleSlotListForm)] => [
		'Tuple.modified_date_time' => 'Last Update',
		comment => 'Comment',
		empty_list_prose => 'No database Records have been added.',
	    ]],
	    [TupleList => [
		'Tuple.tuple_num' => 'Record',
	    ]],
	    [[qw(TupleSlotTypeListForm TupleDefListForm TupleUseForm TupleSlotListForm)] => [
		ok_button => 'Save',
	    ]],
	    [[qw(TupleSlotDefList TupleDefListForm)] => [
		'TupleSlotDef.label' => 'Field',
		[qw(TupleSlotDef.tuple_slot_type_id TupleSlotType.label)]
		    => 'Type',
		'TupleSlotDef.is_required' => 'Required?',
	    ]],
	    [[qw(TupleSlotTypeList TupleDefList TupleUseList TupleList)] => [
		list_actions => 'Actions',
	    ]],
	    [TupleSlotTypeList => [
		empty_list_prose => 'No types have been defined.',
		'TupleSlotType.label' => 'Type Name',
		'TupleSlotType.default_value' => 'Default Value',
		'TupleSlotType.choices' => 'Pick List',
#TODO: Allow override
	    ]],
	    [TupleSlotTypeListForm => [
		'TupleSlotType.label' => 'Type Name',
		'TupleSlotType.type_class' => 'Class',
		'TupleSlotType.default_value' => 'Default Value',
	    ]],
	    [[qw(TupleSlotChoiceList TupleSlotTypeListForm)] => [
		choice => 'Pick List',
	    ]],
	    [list_action => [
		[qw(FORUM_TUPLE_DEF_EDIT FORUM_TUPLE_SLOT_TYPE_EDIT FORUM_TUPLE_USE_EDIT FORUM_TUPLE_EDIT)]
		    => 'Modify',
		FORUM_TUPLE_LIST => 'Records',
		FORUM_TUPLE_HISTORY => 'History',
	    ]],
	    [acknowledgement => [
		FORUM_TUPLE_DEF_EDIT => 'Schema definition has been saved.',
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Type definition has been saved.',
		FORUM_TUPLE_USE_EDIT => 'Table definition has been saved.',
		FORUM_TUPLE_EDIT => 'An email was sent to update the record.  Please wait a few seconds and the browser will update this listing.',
	    ]],
	],
	FormError => [
	    ['TupleSlotTypeListForm.TupleSlotType.default_value.NOT_FOUND' =>
		'Default value must be a value in the Pick List'],
	    ['TupleSlotTypeListForm.choice.EXISTS' =>
		'Duplicate Pick List value.  All values must be distinct.'],
	    ['TupleSlotTypeListForm.TupleSlotType.type_class.MUTUALLY_EXCLUSIVE' =>
		'You can only relax the Class of an existing Type, e.g. String is always accceptable'],
	    ['TupleDefListForm.TupleSlotDef.label.EXISTS' =>
		'Duplicate Field label.  All fields must be distinct.'],
	    ['TupleDefListForm.TupleSlotDef.label.NOT_FOUND' =>
		'You must specify at least one Field.'],
	    ['TupleUseForm.TupleUse.tuple_def_id.EXISTS' =>
		'This Table is in use so you cannot change the Schema.'],
	    [[qw(Tuple TupleSlotDef TupleSlotType)] => [
		[qw(label moniker)] => [
		    SYNTAX_ERROR => 'Labels must be at least two characters and begin with a letter, consist of letters, numbers, dashes(-), or underscores',
		],
	    ]],
	],
    };
}

sub _cfg_user_auth {
    return {
	Constant => [
	    map([$_->[0] => {
		task_id => $_->[1],
		query => undef,
		path_info => undef,
		no_context => 1,
	    }],
		[[qw(xlink_my_site_login xlink_user_logged_out)] => 'MY_SITE'],
		[xlink_login_no_context => 'LOGIN'],
		[[qw(xlink_user_create_no_context xlink_user_just_visitor)]
		     => 'USER_CREATE'],
		[xlink_user_logged_in => 'LOGOUT'],
	    ),
	    [ThreePartPage_want_UserSettingsForm => $_C->if_version(
		5 => sub {1},
		sub {0},
	    )],
	],
	Font => [
	    [user_state => ['120%', 'nowrap']],
	],
	FormError => [
	    ['UserSettingsForm.User.first_name.NULL' => 'You must supply at least one of First, Middle, or Last Names.'],
	    [[qw(ContextlessUserLoginForm UserLoginForm)] => [
		'RealmOwner.password.PASSWORD_MISMATCH' => 
		 q{The password you entered does not match the value stored in our database. Please remember that passwords are case-sensitive, i.e. "HELLO" is not the same as "hello".},
	    ]],
	],
	Task => [
	    [LOGIN => 'pub/login'],
	    [LOGOUT => 'pub/logout'],
	    [USER_CREATE => 'pub/register'],
	    [GENERAL_CONTACT => 'pub/contact'],
	    [USER_CREATE_DONE => undef],
	    [GENERAL_USER_PASSWORD_QUERY => 'pub/forgot-password'],
	    [GENERAL_USER_PASSWORD_QUERY_MAIL => undef],
	    [GENERAL_USER_PASSWORD_QUERY_ACK => undef],
	    [USER_PASSWORD_RESET => '?/new-password'],
	    [USER_PASSWORD => '?/password'],
	    [USER_SETTINGS_FORM => '?/settings'],
	    [ADM_SUBSTITUTE_USER => 'adm/su'],
	    [DEFAULT_ERROR_REDIRECT_MISSING_COOKIES => 'pub/missing-cookies'],
	],
	Text => [
	    [[qw(UserLoginForm ContextlessUserLoginForm)] => [
		ok_button => 'Login',
		prose => [
		    prologue => q{P(XLink('user_create_no_context'));},
		    epilogue => q{P(XLink('GENERAL_USER_PASSWORD_QUERY'));},
		],
	    ]],
	    [password => 'Password'],
	    [[qw(UserCreateForm UserRegisterForm)]  => [
		ok_button => 'Register',
		'confirm_password.field_description' => q{Enter your password again.},
		confirm_password => 'Re-enter Password',
		prose => [
		    prologue => q{P(XLink('GENERAL_USER_PASSWORD_QUERY'));},
		    epilogue => q{P(XLink('login_no_context'));},
		],
	    ]],
	    [[qw(UserPasswordForm UserSettingsForm)] => [
		old_password => 'Current Password',
		new_password => 'New Password',
		confirm_new_password => 'Re-enter New Password',
		ok_button => 'Update',
	    ]],
	    [UserSettingsForm => [
		'RealmOwner.name' => 'User Id',
		'RealmOwner.name.desc' => 'Field only visible to system administrators.',
		'separator.password' => 'Fill in to change your password; otherwise, leave blank',
	    ]],
	    [UserPasswordQueryForm => [
		ok_button => 'Reset Password',
	    ]],
	    [ContactForm => [
		from => 'Your Email',
		text => 'Message',
		ok_button => 'Send',
	    ]],
	    [acknowledgement => [
		user_exists => 'Your email is already in the database.  Please use the form below to reset your password.',
		GENERAL_USER_PASSWORD_QUERY => q{An email has been sent to String([qw(Model.UserPasswordQueryForm Email.email)]); with a link to reset your password.},
		USER_PASSWORD_RESET => q{Your password has been reset.  Please choose a new one.},
		USER_PASSWORD => q{Your password has been changed.},
		password_nak => q{We're sorry, but the "vs_text('xlink.GENERAL_USER_PASSWORD_QUERY');" link you clicked is no longer valid.  You will need to reset your password again.},
		USER_FORUM_TREE => q{Your subscriptions have been updated.},
		user_create_password_reset => q{You are already registered.  Your password has been reset.  An email has been sent to String([qw(Model.UserPasswordQueryForm Email.email)]); with a link to choose a new password.},
		GENERAL_CONTACT => 'Your inquiry has been sent.  Thank you!',
	    ]],
	    [title => [
		 GENERAL_USER_PASSWORD_QUERY => 'Password Assistance',
		 USER_CREATE_DONE => 'Registration Email Sent',
	    ]],
	    [[qw(title xlink)] => [
		GENERAL_CONTACT => 'Contact',
		USER_PASSWORD  => 'Password',
		[qw(LOGIN my_site_login user_logged_out)] => 'Login',
		[qw(LOGOUT user_logged_in)] => 'Logout',
		[qw(USER_CREATE user_just_visitor)] => 'Register',
		GENERAL_USER_PASSWORD_QUERY_ACK => 'Password Assistance Sent',
		ADM_SUBSTITUTE_USER => 'Act as User',
		SITE_ROOT => 'Home',
		USER_SETTINGS_FORM => 'Personal Information and Settings',
		DEFAULT_ERROR_REDIRECT_MISSING_COOKIES => 'Your Browser is Missing Cookies',
	    ]],
	    [xlink => [
		GENERAL_USER_PASSWORD_QUERY => 'Forgot password?',
		login_no_context => 'Already registered?  Click here to login.',
		user_create_no_context => 'Not registered? Click here to register.',
		USER_CREATE_DONE => 'Check Your Mail',
	    ]],
	    [[qw(page3.title xhtml.title)] => [
		LOGIN => 'Please Login',
		USER_CREATE => 'Please Register',
		GENERAL_CONTACT => 'Please Contact Us',
		USER_PASSWORD  => 'Your Password',
		SITE_ROOT => '',
	    ]],
	    [[qw(task_menu.title HelpWiki.title)] => [
		DEFAULT_ERROR_REDIRECT_MISSING_COOKIES => 'Browser Missing Cookies',
		USER_SETTINGS_FORM => 'Settings',
	    ]],
	    [prose => [
		password_query_mail_subject => 'vs_site_name(); Password Assistance',
		create_mail_subject => 'vs_site_name(); Registration Verification',
	    ]],
	],
    };
}

sub _cfg_wiki {
    return {
	Task => [
	    [FORUM_WIKI_EDIT => '?/edit-wiki/*'],
	    $_C->if_version(
		3 => sub {
		    return (
			[FORUM_WIKI_VIEW => ['?/wiki/*', '?/public-wiki/*']],
		    );
		},
		sub {
		    return (
			[FORUM_WIKI_VIEW => ['?/wiki/*']],
			[FORUM_PUBLIC_WIKI_VIEW => ['?/public-wiki/*']],
		    );
		},
	    ),
	    [FORUM_WIKI_NOT_FOUND => undef],
	    [HELP => '?/help/*'],
	    [HELP_NOT_FOUND => undef],
	    [SITE_WIKI_VIEW => 'bp/*'],
	],
	Constant => [
	    map({
		my($id, $name) = @$_;
		(
		    [$name => sub {shift->get_facade->$name()}],
		    [$id => sub {
			 my($f) = shift->get_facade;
			 my($req) = $f->req;
			 my($res) = Bivio::Die->eval(sub {
			     my($ro) = Bivio::Biz::Model->new($req, 'RealmOwner');
			     return $ro->get('realm_id')
			         if $ro->unauth_load({name => $f->$name()});
			     return;
			 });
			 return $res
			     if $res;
			 Bivio::IO::Alert->warn($f->$name(), ': realm not found');
			 return 1;
		    }],
		);
	    }
	        [qw(help_wiki_realm_id HELP_WIKI_REALM_NAME)],
	        [qw(site_realm_id SITE_REALM_NAME)],
	        [qw(site_contact_realm_id SITE_CONTACT_REALM_NAME)],
	        [qw(site_adm_realm_id SITE_ADM_REALM_NAME)],
	    ),
	    [ThreePartPage_want_HelpWiki => 1],
	],
	Font => [
	    [help_wiki_body => ['95%']],
	    [help_wiki_tools => ['95%']],
	    [help_wiki_header => ['bold', '140%', 'uppercase']],
	    [help_wiki_iframe_body => ['small']],
	],
	Text => [
	    ['WikiView.start_page' => 'StartPage'],
	    ['WikiStyle.css_file_name' => 'base.css'],
	    [WikiForm => [
		'RealmFile.path_lc' => 'Title',
		'content' => '',
		'RealmFile.is_public' => 'Make this article publicly available?',
	    ]],
	    [title => [
		FORUM_WIKI_NOT_FOUND => 'Wiki Page Not Found',
		HELP_NOT_FOUND => 'Help Page Not Found',
		HELP => 'Help',
		FORUM_WIKI_EDIT => 'Edit Wiki Page',
		[qw(FORUM_WIKI_VIEW FORUM_PUBLIC_WIKI_VIEW)] => 'Wiki',
		SITE_WIKI_VIEW => '',
		forum_wiki_data => 'Files',
	    ]],
	    ['task_menu.title' => [
		FORUM_WIKI_EDIT => 'Add new page',
		FORUM_WIKI_EDIT_PAGE => 'Edit this page',
	    ]],
	    [acknowledgement => [
		FORUM_WIKI_EDIT => 'Update accepted.  Please proofread for formatting errors.',
		FORUM_WIKI_NOT_FOUND => 'Wiki page not found.  Please create it.',
	    ]],
	    [prose => [
		help_wiki_add => 'Add Help',
		help_wiki_close => 'Close',
		help_wiki_edit => 'Edit',
		help_wiki_footer => '',
		help_wiki_header => 'Help',
		help_wiki_open => 'Help',
		wiki_view_byline => q{edited DateTime(['Action.WikiView', 'modified_date_time']); by MailTo(['Action.WikiView', 'author']);},
		wiki_view_tools => qq{TaskMenu([
                    {
	                task_id => 'FORUM_WIKI_EDIT',
		        path_info => [qw(Action.WikiView name)],
		        label => 'forum_wiki_edit_page',
		    },
		    'FORUM_WIKI_EDIT',
                    {
                        task_id => 'FORUM_FILE',
                        path_info => '$_WIKI_DATA_FOLDER',
                        label => 'forum_wiki_data',
                    },
		]);},
		wiki_view_topic => q{Simple(['Action.WikiView', 'title']);},
	    ]],
#DEPRECATED:
	    [HelpWiki => [
		header => 'Help',
		footer => '',
	    ]],
	],
    };
}

sub _cfg_xapian {
    return {
	Constant => [
	    [ThreePartPage_want_SearchForm => 1],
	],
	Task => [
	    [SEARCH_LIST => 'pub/search'],
	    [JOB_XAPIAN_COMMIT => undef],
	],
	Text => [
	    [SearchList => [
		'RealmFile.modified_date_time' => 'Date',
		'result_title' => 'Title',
		'result_excerpt' => 'Excerpt',
		'result_who' => 'Who',
	    ]],
	    [SearchForm => [
		search => '',
		ok_button => 'Search',
	    ]],
	    [title => [
		SEARCH_LIST => 'Search Results',
	    ]],
	],
    };
}

sub _merge {
    my($child) = pop(@_);
    foreach my $cfg (@_) {
	foreach my $k (keys(%$cfg)) {
	    if (ref($child->{$k}) eq 'ARRAY') {
		unshift(@{$child->{$k} ||= []}, @{$cfg->{$k}});
	    }
	    elsif (!defined($child->{$k})) {
		$child->{$k} = $cfg->{$k};
	    }
	}
    }
    return $child;
}

1;
