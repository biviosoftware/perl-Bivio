# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeBase;
use strict;
use base 'Bivio::UI::Facade';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub HELP_WIKI_REALM_NAME {
    die('HELP_WIKI_REALM_NAME: must be defined if using wiki');
}

sub MAIL_RECEIVE_PREFIX {
    return '_mail_receive_';
}

sub new {
    my($proto, $config, @rest) = @_;
    return $proto->SUPER::new(
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
	],
	FormError => [
	    [NULL => 'You must supply a value for vs_fe("label");.'],
	],
	HTML => [
	    [want_secure => 0],
	    [table_default_align => 'left'],
	],
	Task => [
	    [CLUB_HOME => '?'],
	    [DEFAULT_ERROR_REDIRECT_FORBIDDEN => undef],
	    [FAVICON_ICO => 'favicon.ico'],
	    [FORBIDDEN => undef],
	    [LOCAL_FILE_PLAIN => ['i/*', 'f/*']],
	    [MY_SITE => 'my-site'],
	    [MY_CLUB_SITE => undef],
	    [SHELL_UTIL => undef],
	    [SITE_ROOT => '*'],
	    [USER_HOME => '?'],
	    [ROBOTS_TXT => 'robots.txt'],
	    [TEST_BACKDOOR => '_test_backdoor'],
	    [PERMANENT_REDIRECT => undef],
	],
	Text => [
	    [support_email => 'support'],
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
	    [['Email.email', 'login'] => 'Email'],
	    [password => 'Password'],
	    [confirm_password => 'Re-enter Password'],
	    [display_name => 'Your Full Name'],
	    [first_name => 'First Name'],
	    [middle_name => 'Middle Name'],
	    [street1 => 'Street Line 1'],
	    [street2 => 'Street Line 2'],
	    [city => 'City'],
	    [state => 'State'],
	    [zip => 'Zip'],
	    [country => 'Country'],
	    [empty_list_prose => 'This list is empty.'],
	    [xlink => [
		SITE_ROOT => 'Home',
	    ]],
	    [[qw(paged_detail paged_list)] => [
		prev => 'back',
		next => 'next',
		list => 'back to list',
	    ]],
	    [prose => [
		Base => [
		    support_name => 'String(vs_site_name()); Support',
		    xhtml_logo => q{DIV_logo_su(If(
			['->is_substitute_user'],
			Link(
			    RoundedBox(Join([
				"Acting as User: <br />\n",
				String(['auth_user', 'display_name']),
				"<br />\nClick here to exit.\n",
			    ])),
			    'LOGOUT',
			    'su',
			),
			Link(' ', '/', 'logo'),
		    ));},
		    xhtml_head_title => q{Title([vs_site_name(), Prose(vs_text([sub {"xhtml_head.title.$_[1]"}, ['task_id', '->get_name']]))]);},
		    xhtml_title => q{Prose(vs_text([sub {"xhtml.title.$_[1]"}, ['task_id', '->get_name']]));},
		    xhtml_copyright => <<"EOF",
Copyright &copy; @{[__PACKAGE__->use('Type.DateTime')->now_as_year]} vs_text('site_copyright');<br />
All rights reserved.<br />
Link('Developed by bivio', 'http://www.bivio.biz');
EOF
		],
		UserAuth => [
		    support_name => 'String(vs_site_name()); Support',
		    create_done => <<'EOF',
We have sent a confirmation email to
String(['Model.UserRegisterForm', 'Email.email']);.
Please follow the instructions in this email message to complete
your registration with vs_site_name();.
EOF
		    create_mail => <<'EOF',
Thank you for registering with vs_site_name();.
In order to complete your registration, please click on the following link:

String(['Model.UserRegisterForm', 'uri']);

For your security, this link may be used one time only to set your
password.

You may contact customer support by replying to this message.

Thank you,
vs_site_name(); Support
EOF
		    password_query_mail => <<'EOF',
Please follow the link to reset your password:

Join([['Model.UserPasswordQueryForm', 'uri']]);

For your security, this link may be used one time only to set your
password.

You may contact customer support by replying to this message.

Thank you,
vs_site_name(); Support
EOF
		    password_query_mail_subject => 'vs_site_name(); Password Assistance',
		    create_mail_subject => 'vs_site_name(); Registration Verification',
		],
	    ]],
	],
    };
}

sub _cfg_blog {
    return {
	Task => [
	    [FORUM_BLOG_LIST => '?/blog'],
	    [FORUM_BLOG_DETAIL => '?/blog-entry/*'],
	    [FORUM_BLOG_CREATE => '?/add-blog-entry'],
	    [FORUM_BLOG_EDIT => '?/edit-blog-entry/*'],
	    [FORUM_BLOG_RSS => '?/blog.rss'],
	    [FORUM_PUBLIC_BLOG_LIST => '?/public-blog'],
	    [FORUM_PUBLIC_BLOG_DETAIL => '?/public-blog-entry/*'],
	    [FORUM_PUBLIC_BLOG_RSS => '?/public-blog.rss'],
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
		[qw(FORUM_BLOG_LIST FORUM_PUBLIC_BLOG_LIST FORUM_PUBLIC_BLOG_RSS)]
		    => 'Blog',
		[qw(FORUM_BLOG_DETAIL FORUM_PUBLIC_BLOG_DETAIL)]
		    => 'Blog Detail',
	    ]],
	    [FORUM_BLOG_EDIT => 'Edit This Entry'],
	    [FORUM_BLOG_CREATE => 'New Blog Entry'],
	    [rsspage => [
		[qw(BlogList BlogRecentList)] => [
		    title => 'vs_site_name(); Blog',
		    description => 'Recent Blog Entries at vs_site_name();',
		],
	    ]],
	    [FORUM_ADM_FORUM_ADD => 'Add Forum'],
	    [acknowledgement => [
		FORUM_BLOG_CREATE => 'The blog entry has been added.',
		FORUM_BLOG_EDIT => 'The blog entry update has been saved.',
	    ]],
	],
    };
}

sub _cfg_dav {
    return {
	Task => [
	    [DAV => 'dv/*'],
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
	    ]],
	    [ForumUserList => [
		'Email.email' => 'Email',
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

sub _cfg_mail {
    my($proto) = @_;
    return {
	Task => [
	    [FORUM_EASY_FORM => '?/Forms/*'],
	    [FORUM_FILE => '?/file/*'],
	    [FORUM_MAIL_RECEIVE => '?/' . $proto->MAIL_RECEIVE_PREFIX],
	    [FORUM_MAIL_REFLECTOR => undef],
	    [FORUM_PUBLIC_FILE => '?/public/*'],
	    [MAIL_RECEIVE_DISPATCH => '_mail_receive/*'],
	    [MAIL_RECEIVE_FORWARD => undef],
	    [MAIL_RECEIVE_IGNORE => undef],
	    [MAIL_RECEIVE_NOT_FOUND => undef],
	    [MAIL_RECEIVE_NO_RESOURCES => undef],
	    [USER_MAIL_BOUNCE => '?/' . $proto->MAIL_RECEIVE_PREFIX . Bivio::Biz::Model->get_instance('RealmMailBounce')->TASK_URI],
	],
	Text => [
	    ['MailReceiveDispatchForm.uri_prefix' => $proto->MAIL_RECEIVE_PREFIX],
	],
    };
}

sub _cfg_motion {
    return {
	Task => [
	    [FORUM_MOTION_LIST => '?/votes'],
	    [FORUM_MOTION_ADD => '?/vote-add'],
	    [FORUM_MOTION_EDIT => '?/vote-edit'],
	    [FORUM_MOTION_VOTE => '?/vote'],
	    [FORUM_MOTION_VOTE_LIST => '?/results'],
	    [FORUM_MOTION_VOTE_LIST_CSV => '?/results.csv'],
	],
	Text => [
	    [MotionList => [
		empty_list_prose => 'No votes for this forum.',
		'Motion.name' => 'Name',
		'Motion.question' => 'Question',
		'Motion.status' => 'Status',
	    ]],
	    [MotionForm => [
		'Motion.name' => 'Name',
		'Motion.question' => 'Question',
		'Motion.status' => 'Status',
		'Motion.type' => 'Type',
	    ]],
	    [MotionVoteForm => [
		'MotionVote.vote' => 'Vote',
	    ]],
	    [MotionVoteList => [
		empty_list_prose => 'No vote results.',
		'MotionVote.creation_date_time' => 'Date',
		'MotionVote.vote' => 'Vote',
		'Email.email' => 'Email',
	    ]],
	    [acknowledgement => [
		FORUM_MOTION_EDIT => 'Vote updates have been saved.',
		FORUM_MOTION_VOTE =>
		    'Thank you for your participation in the vote.',
	    ]],
	    [title => [
		FORUM_MOTION_LIST => 'Votes',
		FORUM_MOTION_ADD => 'Add Vote',
		FORUM_MOTION_EDIT => 'Edit Vote',
		FORUM_MOTION_VOTE => 'Vote',
		FORUM_MOTION_VOTE_LIST => 'Vote Results',
	    ]],
	    ['task_menu.title' => [
		FORUM_MOTION_VOTE_LIST_CSV => 'Download .csv',
	    ]],
	],
    };
}

sub _cfg_tuple {
    return {
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
		FORUM_TUPLE_DEF_EDIT => 'Modify Database Schema',
		FORUM_TUPLE_DEF_LIST => 'Database Schemas',
		FORUM_TUPLE_EDIT =>
		    q{Edit String([qw(Model.TupleUseList TupleUse.label)]); Record},
		FORUM_TUPLE_LIST =>
		    q{String([qw(Model.TupleUseList TupleUse.label)]); Records},
		FORUM_TUPLE_HISTORY =>

		    q{String([qw(Model.TupleUseList TupleUse.label)]); Record #String([qw(Model.TupleList Tuple.tuple_num)]); History},
		FORUM_TUPLE_MAIL_THREAD =>
		    q{String([qw(Model.TupleUseList TupleUse.label)]); Record #String([qw(Model.Tuple tuple_num)]);},
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Modify Database Type',
		FORUM_TUPLE_SLOT_TYPE_LIST => 'Database Types',
		FORUM_TUPLE_USE_EDIT => 'Modify Table',
		FORUM_TUPLE_USE_LIST => 'Database Tables',
	    ]],
	    ['task_menu.title' => [
		FORUM_TUPLE_DEF_EDIT => 'Add Schema',
		FORUM_TUPLE_DEF_LIST => 'Schemas',
		FORUM_TUPLE_LIST => 'Records',
		[qw(FORUM_TUPLE_LIST_CSV FORUM_TUPLE_HISTORY_CSV)]
		    => 'Download .csv',
		FORUM_TUPLE_EDIT => 'Add Record',
		FORUM_TUPLE_SLOT_TYPE_EDIT => 'Add Type',
		FORUM_TUPLE_SLOT_TYPE_LIST => 'Types',
		FORUM_TUPLE_USE_EDIT => 'Add Table',
		FORUM_TUPLE_USE_LIST => 'Tables',
		TupleHistoryList => [
		    FORUM_TUPLE_EDIT => 'Modify Record',
		    FORUM_TUPLE_LIST => 'back to list',
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
	    [xlink_my_site_login => {
		task_id => 'MY_SITE',
	    }],
	    [xlink_login_no_context => {
		task_id => 'LOGIN',
		no_context => 1,
	    }],
	    [xlink_user_create_no_context => {
		task_id => 'USER_CREATE',
		no_context => 1,
	    }],
	],
	FormError => [
	    ['UserLoginForm.RealmOwner.password.PASSWORD_MISMATCH' => 
		 q{The password you entered does not match the value stored in our database. Please remember that passwords are case-sensitive, i.e. "HELLO" is not the same as "hello".},],
	],
	Task => [
	    [LOGIN => 'pub/login'],
	    [LOGOUT => 'pub/logout'],
	    [USER_CREATE => 'pub/register'],
	    [USER_CREATE_DONE => undef],
	    [GENERAL_USER_PASSWORD_QUERY => 'pub/forgot-password'],
	    [GENERAL_USER_PASSWORD_QUERY_MAIL => undef],
	    [GENERAL_USER_PASSWORD_QUERY_ACK => undef],
	    [USER_PASSWORD_RESET => '?/new-password'],
	    [USER_PASSWORD => '?/password'],
	    [ADM_SUBSTITUTE_USER => 'adm/su'],
	    [DEFAULT_ERROR_REDIRECT_MISSING_COOKIES => 'pub/missing-cookies'],
	],
	Text => [
	    [UserLoginForm => [
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
	    [UserPasswordForm => [
		old_password => 'Current Password',
		new_password => 'New Password',
		confirm_new_password => 'Re-enter New Password',
		ok_button => 'Update',
	    ]],
	    [UserPasswordQueryForm => [
		ok_button => 'Reset Password',
	    ]],
	    [acknowledgement => [
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
	     ]],
	    [[qw(title xlink )] => [
		GENERAL_CONTACT => 'Contact Us',
		USER_PASSWORD  => 'Password',
		[qw(LOGIN my_site_login)] => 'Login',
		LOGOUT => 'Logout',
		USER_CREATE => 'Register',
		GENERAL_USER_PASSWORD_QUERY_ACK => 'Password Assistance Sent',
		ADM_SUBSTITUTE_USER => 'Act as User',
		SITE_ROOT => 'Home',
	    ]],
	    [xlink => [
		GENERAL_USER_PASSWORD_QUERY => 'Forgot password?',
		login_no_context => 'Already registered?  Click here to login.',
		user_create_no_context => 'Not registered? Click here to register.',
	    ]],
	    [[qw(page3.title xhtml_head.title xhtml.title)] => [
		LOGIN => 'Please Login',
		USER_CREATE => 'Please Register',
		GENERAL_CONTACT => 'Please Contact Us',
		USER_PASSWORD  => 'Your Password',
		USER_CREATE_DONE => 'Registration Email Sent',
		SITE_ROOT => '',
	    ]],
	],
    };
}

sub _cfg_wiki {
    my($proto) = @_;
    return {
	Task => [
	    [FORUM_WIKI_EDIT => '?/edit-wiki/*'],
	    [FORUM_WIKI_VIEW => ['?/wiki/*']],
	    [FORUM_WIKI_NOT_FOUND => undef],
	    [HELP => 'help/*'],
	    [HELP_NOT_FOUND => undef],

	],
	Constant => [
	    [help_wiki_realm_id => sub {
		 my($req) = shift->get_request;
		 return Bivio::Die->eval(
		     sub {
			 return Bivio::Biz::Model->new($req, 'RealmOwner')
			     ->unauth_load_or_die({
				 name => $proto->HELP_WIKI_REALM_NAME
			     })->get('realm_id');
		     },
		 ) || 1;
	    }],
	],
	Text => [
	    [HelpWiki => [
		header => 'Help',
		footer => '',
	    ]],
	    [WikiForm => [
		'RealmFile.path_lc' => 'Title',
		'content' => '',
		'RealmFile.is_public' => 'Make this article publicly available?',
	    ]],
	    [prose => [
		Wiki => [
		    not_found => <<'EOF',
The page Tag(strong => String(['Action.WikiView', 'name'])); was not
found, and you do not have permission to create it.  Please
Link('contact us', 'GENERAL_CONTACT'); for more information about this error.
<br /><br />
To return to the previous page, click on your browser's back button, or
Link('click here', [['->get_request'], 'task', 'view_task']); to
return to the start page.
EOF
		],
	    ]],
	    [acknowledgement => [
		FORUM_WIKI_EDIT => 'Update accepted.  Please proofread for formatting errors.',
		FORUM_WIKI_NOT_FOUND => 'Page not found.  Please create it.',
	    ]],
	    [title => [
		FORUM_WIKI_NOT_FOUND => 'Wiki Page Not Found',
		HELP_NOT_FOUND => 'Help Page Not Found',
		HELP => 'Help',
		FORUM_WIKI_EDIT => 'Edit Wiki Page',
		FORUM_WIKI_VIEW => 'Wiki',
	    ]],
	    ['task_menu.title' => [
		FORUM_WIKI_EDIT => 'Add New Page',
		FORUM_WIKI_EDIT_PAGE => 'edit this page',
	    ]],
	    [acknowledgement => [
		FORUM_WIKI_EDIT => 'Update accepted.  Please proofread for formatting errors.',
		FORUM_WIKI_NOT_FOUND => 'Wiki page not found.  Please create it.',
	    ]],
	],
    };
}

sub _cfg_xapian {
    return {
	Task => [
	    [SEARCH_LIST => 'pub/search'],
	    [JOB_XAPIAN_COMMIT => undef],
	],
	Text => [
	    [SearchList => [
		'RealmFile.modified_date_time' => 'Last Update',
		'RealmFile.path' => 'Description',
	    ]],
	    [SearchForm => [
		search => '',
		ok_button => 'Search',
	    ]],
	],
    };
}

sub _merge {
    my($child) = pop(@_);
    foreach my $cfg (@_) {
	foreach my $k (keys(%$cfg)) {
	    if (ref($child->{$k}) eq 'ARRAY') {
		unshift(@{$child->{$k}}, @{$cfg->{$k}});
	    }
	    else {
		$child->{$k} = $cfg->{$k};
	    }
	}
    }
    return $child;
}

1;
