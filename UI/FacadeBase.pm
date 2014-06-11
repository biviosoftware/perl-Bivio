# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeBase;
use strict;
use Bivio::Base 'UI.Facade';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
b_use('IO.Trace');
my($_C) = b_use('IO.Config');
my($_EASY_FORM_DIR) = 'Forms';
my($_RN) = b_use('Type.RealmName');
my($_FN) = b_use('Type.ForumName');
my($_D) = b_use('Bivio.Die');
my($_TI) = b_use('Agent.TaskId');
my($_SITE_WIKI_VIEW_URI) = '/bp';

sub BULLETIN_REALM_NAME {
    return 'bulletin';
}

sub HELP_WIKI_REALM_NAME {
    return shift->internal_site_name('help');
}

sub MAIL_RECEIVE_URI_PREFIX {
    return '_mail_receive';
}

sub MAIL_RECEIVE_PREFIX {
    return shift->MAIL_RECEIVE_URI_PREFIX . '_';
}

#TODO: use ForumName->join to create these.  Also, names should not
#      be used publicly.  They are only for init.  Always use vs_constant
#      to get the names.
sub SITE_CONTACT_REALM_NAME {
    return shift->internal_site_name('contact');
}

sub SITE_REALM_NAME {
    return 'site';
}

sub SITE_ADMIN_REALM_NAME {
    return shift->internal_site_name('admin');
}

sub SITE_REPORTS_REALM_NAME {
    return shift->internal_site_name('reports');
}

sub auth_realm_is_site {
    return _auth_realm_is(site => @_);
}

sub auth_realm_is_site_admin {
    return _auth_realm_is(site_admin => @_);
}

sub auth_realm_is_help_wiki {
    return _auth_realm_is(help_wiki => @_);
}

sub if_2014style {
    my(undef, $then, $else) = @_;
    my($res) = sub {
	my($v) = shift;
	return @$v
	    if ref($v) eq 'ARRAY';
	return $v->()
	    if ref($v) eq 'CODE';
	return defined($v) ? $v : ();
    };
    return shift->SUPER::if_2014style(
	sub {$res->($then)},
	sub {$res->($else)},
    );
}

sub internal_base_tasks {
    return [
	[CLIENT_REDIRECT => ['go/*', 'goto/*']],
	[CLUB_HOME => '?'],
	[FORUM_HOME => '?'],
	[DEFAULT_ERROR_REDIRECT => undef],
	[DEFAULT_ERROR_REDIRECT_FORBIDDEN => undef],
	[DEFAULT_ERROR_REDIRECT_NOT_FOUND => undef],
	[DEFAULT_ERROR_REDIRECT_MODEL_NOT_FOUND => undef],
	[DEFAULT_ERROR_REDIRECT_UPDATE_COLLISION => undef],
	[FAVICON_ICO => 'favicon.ico'],
	[APPLE_TOUCH_ICON => [
	    map((
		"apple-touch-icon${_}.png",
		"apple-touch-icon${_}-precomposed.png",
	    ), '', qw(-144x144 -114x114 -72x72)),
	]],
	[FORBIDDEN => undef],
	[PUBLIC_PING => 'pub/ping'],
	[LOCAL_FILE_PLAIN => [
	    'i/*',
	    __PACKAGE__->get_local_file_plain_app_uri('*'),
	    __PACKAGE__->get_local_file_plain_common_uri('*'),
	]],
	[MY_CLUB_SITE => undef],
	[MY_SITE => 'my-site/*'],
	[CLIENT_REDIRECT_PERMANENT_MAP => undef],
	[ROBOTS_TXT => 'robots.txt'],
	[SHELL_UTIL => undef],
	[SITE_CSS => 'pub/site.css'],
	[SITE_ROOT => '*'],
	[USER_HOME => '?'],
	[UNADORNED_PAGE => 'rp/*'],
	[PUBLIC_WIDGET_INJECTOR => 'pub/widget.js'],
	[JAVASCRIPT_LOG_ERROR_JSON => 'pub/javascript-error'],
 	[LOGGED_QUERY_REDIRECT => 'pub/go'],
	[API_JSON => 'api/*'],
    ];
}

sub internal_dav_tasks {
    return [
	[DAV => ['dav/*', 'dv/*']],
	[DAV_ROOT_FORUM_LIST => undef],
	[DAV_FORUM_LIST => undef],
	[DAV_FORUM_FILE => undef],
	[DAV_ROOT_FORUM_LIST_EDIT => undef],
	[DAV_FORUM_LIST_EDIT => undef],
	[DAV_FORUM_USER_LIST_EDIT => undef],
	[DAV_FORUM_CALENDAR_EVENT_LIST_EDIT => undef],
	[DAV_EMAIL_ALIAS_LIST_EDIT => undef],
    ];
}

sub internal_dav_text {
    return [
	[ForumList => [
	    'RealmOwner.name' => 'vs_ui_forum();',
	    'RealmOwner.display_name' => 'Title',
	    'Forum.forum_id' => 'Database Key',
	]],
	[ForumUserList => [
	    is_subscribed => 'Subscribed?',
	    file_writer => 'Write Files?',
	    administrator => 'Administrator?',
	    [qw(User.user_id RealmUser.user_id)] => 'Database Key',
	]],
	[EmailAliasList => [
	    'EmailAlias.incoming' => 'From Email',
	    'EmailAlias.outgoing' => 'To Email or vs_ui_forum();',
	    'primary_key' => 'Database Key',
	]],
    ];
}

sub internal_merge {
    my($self) = shift;
    my($child) = pop;
    foreach my $cfg (reverse(@_)) {
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

sub internal_site_name {
    my($proto, $sub_forum) = @_;
    return $_FN->join($proto->SITE_REALM_NAME, $sub_forum);
}

sub is_site_realm_name {
    return shift->special_realm_name_equals(site => shift(@_));
}

sub mail_receive_task_list {
    my($self, @tasks) = @_;
    map({
	my($name, $uri_suffix) = ref($_) ? @$_
	    : ($_,
	       lc($_ =~ /MAIL_RECEIVE_(\w+)/ ? $1
	       : $_ =~ /_MAIL_RECEIVE$/ ? ''
	       : b_die($_, ': invalid mail_receive task name')));
	[$name => $_D->eval(qq{
	     sub {shift->get_facade->mail_receive_uri('$uri_suffix')}
	})];
    } @tasks);
}

sub mail_receive_uri {
    my($self, $suffix) = @_;
    return '?/' . $self->MAIL_RECEIVE_PREFIX . $suffix;
}

sub new {
    my($proto, $config) = @_;
    return $config->{clone} ? $proto->SUPER::new($config) : $proto->SUPER::new(
        $proto->internal_merge(
	    map({
		my($x) = \&{"_cfg_$_"};
		defined(&$x) ? $x->($proto) : ();
	    } @{b_use('Agent.TaskId')->included_components}),
	    $proto->is_html5
		? _html5_css($proto)
		: (),
	    $config,
	),
    );
}

sub special_realm_name_equals {
    my($self, $which, $realm_name) = @_;
    return $_RN->is_equal(
	$realm_name,
	$self->get('Constant')->get_value($which . '_realm_name'),
    );
}

sub _auth_realm_is {
    my($which, $self, $req) = @_;
    my($r) = $req->get('auth_realm');
    return $r->has_owner && $self->special_realm_name_equals($which, $r->get('owner_name'));
}

sub _cfg_base {
    return {
	clone => undef,
	is_production => 1,
	Email => [],
	Icon => [],
	WidgetSubstitute => [],
	ViewSupport => [],
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
	    [[qw(
	        off
		footer_border_top
		disabled
		b_progress_bar_background
	    )] => 0x999999],
	    [even_background => 0xeeeeee],
	    [odd_background => -1],
	    [[qw(a_link topic nav dock)] => 0x444444],
	    [dock_border_bottom => 0xccddff],
	    [a_hover => 0x888888],
	    [[qw(acknowledgement_border b_progress_bar_border)] => 0x0],
	    [[qw(err warn empty_list_border form_field_err)] => 0x990000],
	    [[qw(header_su_background super_user)] => 0x00ff00],
	    [[qw(form_desc form_sep_border sep_bar msg_parts_border text_byline)] => 0x666666],
            [help_wiki_background => 0x6b9fea],
	    [dd_menu => 0x444444],
	    [[qw(dd_menu_selected dd_menu_background)] => 0xffffff],
	    [dd_menu_border => 0x888888],
	    [dd_menu_selected_background => 0x888888],
	    [submit => 0x777777],
	    [submit_background => 0xe4e4e4],
	    [ok_button => 0xffffff],
	    [ok_button_background => 0x2181cf],
	    [[qw(error_background error_background_border_left)] => 0xfff4f4],
	    [[qw(error_border error_arrow_border_left)] => 0xd58a8a],
	    [input_border => 0xbfbfbf],
	    [input_focus_border => 0xa0a0a0],
	    [list_heading_background => 0xf0f9ff],
	    [list_heading_border => 0xe7f2fb],
	    [list_heading_border_top => 0x82cffa],
	    [list_heading_border_bottom => 0x96c4ea],
	    [list_row_border => 0xedf1f5],
	    [list_row_hover_background => 0xf5fbfe],
	    [list_row_hover_border => 0xc6d8e4],
	],
	Font => [
	    # See Bivio::UI::View::CSS
	    # Pass #1: Reset tag selectors (canonicalize browsers)
	    [reset_body => ['size=100%', 'style=padding: 0; margin: 0;']],
	    [reset_abbr => 'style=border: 0; border-style: none'],
	    [reset_address => 'style=font-family: inherit; font-size: inherit; font-style: inherit; font-weight: inherit'],
	    [reset_caption => [qw(left normal_weight)]],
	    [reset_ol => 'style=margin-left: 2.5em; list-style-type: decimal'],
	    [reset_pre => ['pre', 'style=line-height: 100%']],
	    [reset_table => 'style=border-collapse: collapse; border-spacing:0'],
	    [reset_textarea => 'pre'],
	    [reset_ul => 'style=margin-left: 2.5em; list-style-type: disc'],

	    # Pass #2: Style tag selectors (bOP's standard)
	    [a_hover => 'underline'],
	    [a_link => 'normal'],
	    [body => ['family=Verdana, Arial, Helvetica, Geneva, SunSans-Regular, sans-serif', 'small', 'style=margin-top: 0; margin-bottom: 0; margin-right: .5em; margin-left: .5em; min-width: 50em']],
	    [caption => [qw(bold center)]],
	    [text_excerpt => ['style=width:50em', qw(normal_weight normal_decoration)]],
	    [text_byline => [qw(normal_weight normal_decoration)]],
	    [[qw(code pre_text)] => [
		'family="Courier New",Courier,monospace,fixed',
		'120%',
	    ]],
	    [em => 'italic'],
	    [hn => 'style=margin: 1ex 0 .5ex 0'],
	    [h1 => ['140%', 'bold']],
	    [h2 => ['130%', 'bold']],
	    [h3 => ['120%', 'bold']],
	    [h4 => ['110%', 'bold']],
	    [[qw(h5 h6)] => ['size=100%', 'normal_weight']],
	    [p => 'style=margin-bottom: 1ex'],
	    [strong => 'bold'],
	    [table => 'left'],
	    [th => [qw(bold center), 'style=padding: .5em']],
	    [th_a => [qw(bold center)]],
	    [b_sort_arrow => []],
	    [b_mobile_toggler_selected => 'bold'],
	    [b_mobile_toggler_a => []],
	    [b_list_action => '85%'],

	    # Historical font names
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
	    # Newer font names
	    [normal => ['normal']],
	    [warn => 'italic'],
	    [err => 'bold'],
	    [tools => ['nowrap', 'inline']],
	    [embedded_prose_link => 'underline'],
	    [paragraph_text => 'normal_wrap'],
	    [form_err => 'bold'],
	    [form_label_ok => ['bold', 'nowrap']],
	    [form_field_err => ['normal', '80%']],
	    [form_label_err => ['italic', 'nowrap']],
	    [form_footer => ['smaller', 'italic']],
	    [footer => 'smaller'],
	    [header_su => 'larger'],
	    [[qw(selected task_menu_selected)] => 'bold'],
	    [topic => 'bold', 'larger'],
	    [byline => 'bold'],
	    [title => ['140%', 'bold']],
	    [nav => '120%'],
	    [dock => ['120%', 'nowrap']],
	    [[qw(off pager)] => []],
	    [dd_menu => ['normal']],
	    [user_state => ['120%', 'nowrap']],
	    [b_abtest_a => []],
	    [b_abtest_a_selected => 'bold'],
	],
	Constant => [
	    [is_2014style => __PACKAGE__->is_2014style],
	    map({
		my($id, $name) = @$_;
		(
		    [$name => sub {_unsafe_call(shift, $name)}],
		    [$id => sub {_unsafe_realm_id(shift, $name)}],
		);
	    }
	        [qw(help_wiki_realm_id HELP_WIKI_REALM_NAME)],
	        [qw(site_realm_id SITE_REALM_NAME)],
	        [qw(site_contact_realm_id SITE_CONTACT_REALM_NAME)],
	        [qw(site_admin_realm_id SITE_ADMIN_REALM_NAME)],
		[qw(site_reports_realm_id SITE_REPORTS_REALM_NAME)],
		[qw(bulletin_realm_id BULLETIN_REALM_NAME)],
	    ),
	    [xlink_back_to_top => {
		uri => '',
		anchor => 'top',
	    }],
	    [xlink_page_error_user => {
		task_id => 'MY_SITE',
		query => undef,
		path_info => undef,
	    }],
	    [xlink_page_error_visitor => {
		task_id => 'SITE_ROOT',
		query => undef,
		path_info => undef,
	    }],
	    [xlink_page_error_referer => {
		uri => ['Action.Error', 'uri'],
	    }],
	    [xlink_xhtml_logo_normal => {
		task_id => 'SITE_ROOT',
	    }],
	    [my_site_redirect_map => []],
	    [require_secure => 0],
	    [ThreePartPage_want_UserState => 1],
	    [ThreePartPage_want_ForumDropDown => 0],
	    [ThreePartPage_want_dock_left_standard => 0],
	    [robots_txt_allow_all => 1],
            [ActionError_default_view => 'Error->default'],
            [ActionError_want_wiki_view => 1],
	    [ViewBase_mobile_app_page => 0],
	],
	CSS => [
	    __PACKAGE__->if_2014style([
		[footer_height => '79px'],
		[error_background => '#c12929'],
		[empty_color => 'rgba<(>0, 0, 0, 0)'],
		['FormButton.submit' => ''],
		['StandardSubmit.standard_submit' => ''],
	    ]),
	    ['FormButton.submit' => q{
                margin: .5em;
                padding: 0 .5em;
                text-align: center;
	    }],
	    ['StandardSubmit.standard_submit' => q{
                margin: .5em;
                padding: 0 .5em;
                text-align: center;
            }],
	    [b_table_footer => q{
		text-align: center;
		border-top: 1px solid;
		Color('footer-border-top');
		margin: .5ex 0 .5ex 0;
		padding-top: .5ex;
		padding-bottom: 7ex;
            }],
	    [b_td_footer_center => q{ 
		vertical-align: top;
		text-align: center;
		font-size: 100%;
            }],
	    [menu_want_sep => q{
		padding-left: .3em;
		margin-left: .3em;
		border-left: 1px solid;
		Color('form_sep-border');
            }],
	    [b_logo_su_logo => q{
		text-align: left;
		display: block;
		height: Icon(qw(logo height));px;
		width: Icon(qw(logo width));px;
            }],
	    [b_td_header_left => q{
		background: Icon('logo'); left no-repeat;
		height: Icon(qw(logo height));px;
		width: Icon(qw(logo width));px;
            }],
	    [b_three_part_page_tables => q{
		width: 100%;
		margin: auto;
            }],
	    [b_table_main => q{
                margin-top: 1em;
                margin-bottom: 1em;
            }],
	    [menu_want_sep_clear => q{
		padding-left: 0;
		margin-left: 0;
		border-left: none;
            }],
	    [b_prose => q{
		margin: 1ex 0 1ex 0;
            }],
	    [b_input_field => q{
                padding: 2px;
            }],
	],
 	FormError => [
	    [NULL => 'You must supply a value for vs_fe("label");.'],
	    [EXISTS => 'vs_fe("label"); already exists in our database.'],
	    [NOT_FOUND => 'vs_fe("label"); was not found in our database.'],
	    ['UserPasswordQueryForm.Email.email.PERMISSION_DENIED' => 'You are not allowed to reset your password.  Please contact a system administrator for assistance.'],
	    ['image_file.TOO_MANY' => 'vs_fe("label"); contains multiple images, please upload a file which contains only one image.'],
	    ['image_file.EXISTS' => 'vs_fe("label"); image already exists.  Please choose another name.'],
	    ['image_file.SYNTAX_ERROR' => 'vs_fe("label"); unknown or invalid image format.  Please verify file, and change to an acceptable format (e.g. png, gif, jpg), and retry upload.'],
	    ['EmailAlias.incoming.SYNTAX_ERROR' => 'vs_fe("label"); must be in name@domain format or just an @domain'],
	    ['login.SYNTAX_ERROR' => 'Invalid login'],
	],
	HTML => [
	    [table_default_align => 'left'],
	],
	Task => __PACKAGE__->internal_base_tasks,
	Text => [
	    [support_email => 'support'],
	    [support_name => 'vs_site_name(); Support'],
#TODO:	    [support_phone => '(800) 555-1212'],
	    [[qw(prologue epilogue)] => ''],
	    [home_page_uri => $_SITE_WIKI_VIEW_URI],
	    [view_execute_uri_prefix => 'SiteRoot->'],
	    [favicon_uri => '/i/favicon.ico'],
	    [apple_touch_icon_prefix => '/i/apple-touch-icon'],
	    [form_error_title => 'Please correct the errors below:'],
	    [form_stale_data_title => 'The page contents were modified by another request. Please resubmit the form with new data.'],
	    [none => ' '],
	    [Image_alt => [
		none => 'none',
		dot => 'dot',
		sort_up => 'This column sorted in descending order',
		sort_down => 'This column sorted in ascending order',
	    ]],
	    [ok_button => '   OK   '],
	    [add_rows => 'More Rows'],
	    [cancel_button => ' Cancel '],
	    [unknown_label => 'Select Value'],
	    [[qw(Email.email login email)] => 'Email'],
	    [password => 'Password'],
	    [confirm_password => 'Re-enter Password'],
	    [display_name => 'Your Full Name'],
	    [first_name => 'First Name'],
	    [middle_name => 'Middle Name'],
	    [last_name => 'Last Name'],
	    [street1 => 'Street Line 1'],
	    [street2 => 'Street Line 2'],
	    [url => 'Link'],
	    [city => 'City'],
	    [state => 'State'],
	    [zip => 'Zip'],
	    [country => 'Country'],
            [phone => 'Phone'],
	    [empty_list_prose => 'This list is empty.'],
	    [http_too_many_requests => 'Too many requests'],
	    ['FormError.prose.detail_prefix' => '; additional info: '],
	    [[qw(actions list_actions)] => 'Actions'],
	    [[qw(time_zone time_zone_selector)] => 'Time Zone'],
	    ['AuthUserGroupSelectList.RealmOwner' => [
		[qw(display_name name)] => [
#TODO:		    select => 'Select vs_ui_forum();',
		    select => 'Select Forum',
		],
	    ]],
	    [vs_ui => [
		forum => 'Forum',
		wiki => 'Wiki',
		members => 'Members',
	    ]],
	    ['vs_selector_form.ok_button' => 'Refresh'],
	    [xlink => [
		back_to_top => 'back to top',
		SITE_ROOT => 'Home',
		page_error_referer => 'Go back to the previous page, and try something different.',
		page_error_user => 'Go back to your personal page.',
		page_error_visitor => 'Go to the home page.',
		xhtml_logo_normal => ' ',
	    ]],
	    [title => [
		[qw(DEFAULT_ERROR_REDIRECT_MODEL_NOT_FOUND DEFAULT_ERROR_REDIRECT_NOT_FOUND)] => 'Not Found',
		[qw(DEFAULT_ERROR_REDIRECT_FORBIDDEN FORBIDDEN)] => 'Access Denied',
		[qw(DEFAULT_ERROR_REDIRECT)] => 'Server Error',
		[qw(DEFAULT_ERROR_REDIRECT_UPDATE_COLLISION)] => 'Invalid Data',
	    ]],
	    [[qw(xlink title)] => [
		# Some of this should be in user_auth, but all apps
		# need these labels
		ADM_SUBSTITUTE_USER => 'Act as User',
		FORBIDDEN => 'Access denied',
		SITE_ROOT => 'Home',
		USER_PASSWORD  => 'Password',
		[qw(LOGIN my_site_login user_logged_out)] => 'Login',
		[qw(LOGOUT user_logged_in)] => 'Logout',
		[qw(USER_CREATE user_just_visitor)] => 'Register',
	    ]],
	    __PACKAGE__->if_2014style([
		[xlink => [
		    user_logged_out => q{LinkIcon('LOGIN');Login},
		]]
	    ]),
	    [SHELL_UTIL => ''],
	    [DieCode => [
		MODEL_NOT_FOUND => 'Not found',
	    ]],
	    [[qw(paged_detail paged_list)] => [
		prev => 'Back',
		next => 'Next',
		list => 'Back to list',
	    ]],
	    [AtomFeed => [
		entry_title => q{String(['->get_rss_title']);},
		entry_content => q{String(['->get_rss_summary']);},
		title => q{String(vs_site_name()); vs_text_as_prose('xhtml_title');},
	    ]],
	    [EmailVerifyForm => [
		'prose.prologue' => <<'EOF',
To change your email address you must first verify that you have access
to the given account.  Click 'Verify Email' to send a message containing
a link that will allow you to verify your access and change your email address.
EOF
		ok_button => 'Verify Email',
	    ]],
	    [MobileToggler => [
		desktop => 'Desktop',
		mobile => 'Mobile',
	    ]],
	    ['task_menu.title' => [
		[qw(sort_first sort_label_01)] => "\1",
		[qw(sort_second sort_label_02)] => "\2",
		[qw(sort_third sort_label_03)] => "\3",
		[qw(sort_fourth sort_label_04)] => "\4",
		[qw(sort_fifth sort_label_05)] => "\5",
		[qw(sort_sixth sort_label_06)] => "\6",
		[qw(sort_seventh sort_label_07)] => "\7",
		[qw(sort_eighth sort_label_08)] => "\10",
		[qw(sort_ninth sort_label_09)] => "\11",
		[qw(sort_first sort_label_10)] => "\12",
		[qw(sort_second sort_label_11)] => "\13",
		[qw(sort_third sort_label_12)] => "\14",
		[qw(sort_fourth sort_label_13)] => "\15",
		[qw(sort_fifth sort_label_14)] => "\16",
		[qw(sort_sixth sort_label_15)] => "\17",
		[qw(sort_seventh sort_label_16)] => "\20",
		[qw(sort_eighth sort_label_17)] => "\21",
		[qw(sort_ninth sort_label_18)] => "\22",
		[qw(sort_ninth sort_label_19)] => "\23",
		__PACKAGE__->if_2014style([
		    [qw(user_logged_in LOGOUT)] => q{LinkIcon('LOGOUT');Logout},
		]),
	    ]],
	    [prose => [
		ascend => ' &#9650;',
		[qw(descend drop_down_arrow)] => ' &#9660;',
		combo_box_arrow => '&#9660;',
		error_indicator => '&#9654;',
		page_error => [
		    [qw(not_found model_not_found)] => q{The page requested was not found or is not functioning properly.},
		    server_error => q{The server encountered an error.  The webmaster has been notified.},
		    forbidden => q{You do not have permission to access this page.},
		    update_collision => q{Your request cannot be fulfilled because the submitted data is no longer valid.},
		],
		@{__PACKAGE__->map_by_two(sub {
		    my($k, $v) = @_;
		    # Base. is deprecated usage
		    return ([$k, "Base.$k"] => $v);
	        }, [
		    xhtml_logo => q{vs_header_su_link(XLink('xhtml_logo_normal', 'logo'));},
		    xhtml_head_title => q{Title([vs_site_name(), vs_text_as_prose('xhtml_title')]);},
		    xhtml_title => q{Prose(vs_text([sub {"xhtml.title.$_[1]"}, ['task_id', '->get_name']]));},
		    xhtml_copyright_qualifier => q{Link('Software by bivio', 'http://www.bivio.biz');},
		    __PACKAGE__->if_2014style([
			xhtml_copyright => <<"EOF",
&copy; vs_text_as_prose('site_copyright');
EOF
		    ], [
			xhtml_copyright => <<"EOF",
Copyright &copy; vs_now_as_year(); vs_text_as_prose('site_copyright');<br />
All rights reserved.<br />
vs_text_as_prose('xhtml_copyright_qualifier');
EOF
		    ]),
		])},
	    ]],
	    [ECCreditCardPayment => [
		card_zip => "Card Owner's Zip Code",
		card_name => 'Full Name on Card',
		card_number => 'Credit Card Number',
		card_expiration_date => 'Card Expiration Date',
		processor_response => 'Processor Response',
	    ]],
	    [icon => [
		pager_next => 'b_icon_chevron_right',
		pager_prev => 'b_icon_chevron_left',
		back_to_list => 'b_icon_arrow_left',
		LOGOUT => 'b_icon_logout',
		LOGIN => 'b_icon_login',
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
	    [FORUM_BLOG_LIST => ['?/blog', '?/public-blog']],
	    [FORUM_BLOG_DETAIL => ['?/blog-entry/*', '?/public-blog-entry/*']],
	    [FORUM_BLOG_RSS => ['?/blog.atom', '?/blog.rss', '?/public-blog.rss']],
	],
	Text => [
	    [[qw(BlogCreateForm BlogEditForm)] => [
		'title' => 'Title',
		'content' => '',
		'RealmFile.is_public' => 'Public?',
	    ]],
	    [BlogList => [
		empty_list_prose => 'No entries in this blog.',
	    ]],
	    [title => [
		[qw(FORUM_BLOG_LIST FORUM_BLOG_RSS)] => 'Blog',
		FORUM_BLOG_DETAIL => 'Blog Detail',
	    ]],
	    [FORUM_BLOG_EDIT => 'Edit this entry'],
	    [FORUM_BLOG_CREATE => 'New blog entry'],
	    [acknowledgement => [
		FORUM_BLOG_CREATE => 'The blog entry has been added.',
		FORUM_BLOG_EDIT => 'The blog entry update has been saved.',
	    ]],
	    [icon => [
		FORUM_BLOG_LIST => 'b_icon_megaphone',
	    ]],
#TODO: Move this
	    [FORUM_ADM_FORUM_ADD => 'Add forum'],
	    __PACKAGE__->if_2014style([
		['task_menu.title' => [
		    FORUM_BLOG_LIST => q{LinkIcon('FORUM_BLOG_LIST');Blog},
		]],
	    ]),
	],
    };
}

sub _cfg_calendar {
    return {
	Color => [
	    [b_month_calendar_td_border => 0xdddddd],
	    [b_month_calendar_is_today_border => 0xff8888],
	    [[qw(b_date_other_month_background b_day_of_other_month_create_hidden)]
		=> 0xe6e6e6],
	    [b_date_other_month => 0x808080],
	    [[qw(
		b_day_of_month_create_hidden
	        b_month_calendar_th_background
		b_month_calendar_background
	    )] => __PACKAGE__->init_from_prior_group('body_background')],
	    [b_day_of_month_create_visible =>
		__PACKAGE__->init_from_prior_group('a_hover')],
	],
	Constant => [
	    ['Model.TimeZoneList.rows' => sub {[map(+{
		enum => $_,
		display_name => $_->as_display_name,
	    }, b_use('Type.TimeZone')->get_list)]}],
	    [xlink_set_time_zone => {
		task_id => 'USER_SETTINGS_FORM',
	    }],
	    ['Calendar.want_b_time_zone' => 1],
	],
	Font => [
	    [b_month_calendar_day_of_month => 'bold'],
	    [b_month_calendar_th => ['size=85%', 'center', 'style=padding: 0 0 .5ex 0']],
	    [b_date_other_month => []],
	    [b_event_name => ['size=85%', 'left']],
	    [b_datetime => 'nowrap'],
	    [[qw( b_day_of_month_create_visible)]
		=> [qw(normal_decoration size=85% nowrap)]],
	    [[qw(b_day_of_month_create_hidden )]
		=> [qw(normal_decoration size=85% nowrap)]],
	],
 	FormError => [
	    [recurrence_end_date => [
		EXISTS => q{vs_fe('label'); may only be set if vs_text_as_prose('CalendarEventForm.recurrence'); is set.},
		TOO_SHORT => q{vs_fe('label'); must fall at least one week after vs_text_as_prose('CalendarEventForm.end_date');.},
		TOO_LONG => q{vs_fe('label'); may not be more than a year after .vs_text_as_prose('CalendarEventForm.end_date');.},
	    ]],
	    ['CalendarEventForm.end_date.MUTUALLY_EXCLUSIVE' => q{The vs_fe('label'); must be after vs_text_as_prose('CalendarEventForm.start_date');.}],
	],
	Task => [
	    [FORUM_CALENDAR => ['?/calendar', '?/events-month', '?/calendar-month', '?/calendar-list', '?/my-calendar', '?/my-calendar-local', '?/events-local', '?/calendar-local', '?/events']],
	    [FORUM_CALENDAR_EVENT_DELETE => ['?/delete-calendar-event', '?/event-delete', '?/event-remove']],
	    [FORUM_CALENDAR_EVENT_DETAIL => ['?/calendar-event', '?/event-detail', '?/events-view', '?/calendar-view']],
	    [FORUM_CALENDAR_EVENT_FORM => ['?/edit-calendar-event', '?/event', '?/event-edit', '?/calendar-edit', '?/event-add', '?/calendar-add', '?/event-copy']],
	    [FORUM_CALENDAR_EVENT_ICS => ['?/calendar-event.ics', '?/event.ics']],
	    [FORUM_CALENDAR_EVENT_LIST_RSS => ['?/calendar.atom', '?/calendar.rss', '?/my-calendar.atom', '?/my-calendar.rss']],
	    [FORUM_CALENDAR_EVENT_LIST_ICS => ['?/calendar.ics', '?/events.ics']],
	    [FULL_CALENDAR_LIST_JSON => '?/fullcalendar-list.json'],
	    [FULL_CALENDAR_FORM_JSON => '?/fullcalendar.json'],
	],
	Text => [
	    [[qw(dtstart_tz dtstart_with_tz)] => 'Start'],
	    [[qw(dtend_tz dtend_with_tz)] => 'End'],
	    [[qw(
	        CalendarEventMonthList.owner.RealmOwner.display_name
		CalendarEventList.owner.RealmOwner.display_name
		CalendarEvent.realm_id
	    )] => 'vs_ui_forum();'],
	    [[qw(CalendarEventList CalendarEventMonthList CalendarEventForm)] => [
		'RealmOwner.display_name' => 'Title',
	    ]],
	    [CalendarEvent => [
		dtstart => 'Start',
		dtend => 'End',
		description => 'Description',
		location => 'Location',
		'location.desc' => 'Maximum length 500 characters',
		url => 'URL',
	    ]],
	    [CalendarEventContent => [
		field_label_separator => ': ',
	    ]],
	    [CalendarEventWeekList => [
		map(($_ => $_),
		    b_use('Type.DateTime')->english_day_of_week_list),
	    ]],
	    [MonthList => [
		this_month => 'Today',
		map(($_ => $_),
		    b_use('Type.DateTime')->english_month3_list),
	    ]],
	    [CalendarEventMonthForm => [
		b_list_view => 'View events in a list',
		b_time_zone => q{Show in Enum([qw(Model.CalendarEventMonthList ->auth_user_time_zone)]); time XLink('set_time_zone');},
	    ]],
	    [[qw(CalendarEventList CalendarEventMonthList)] => [
		[qw(paged_detail paged_list)] => [
		    list => 'Calendar',
		],
		AtomFeed => [
		    entry_title => q{String(['RealmOwner.display_name']); from DateTime(['CalendarEvent.dtstart'], 'to_string'); to DateTime(['CalendarEvent.dtend'], 'to_string');},
		    entry_content => q{CalendarEventContent();},
		],
		empty_list_prose => 'No events in this time period.',
	    ]],
	    [CalendarEventDeleteForm => [
		'prose.prologue' => q{Are you sure you want to remove SPAN_bold(String([qw(Model.CalendarEventDeleteForm RealmOwner.display_name)])); from the calendar?},
		ok_button => 'Delete',
	    ]],
	    [CalendarEventForm => [
		end_date => 'End Date',
		end_time => 'End Time',
		recurrence => 'Repeats',
		'recurrence.desc' => 'Note: repeating events cannot be edited at this time',
		recurrence_end_date => 'Repeat ends',
		start_date => 'Start Date',
		[qw(start_date end_date)] => [
		    desc => 'm/d/yy, d.m.yy, yyyy/m/d, d-mon-yyyy, or mmddyy',
		],
		start_time => 'Start Time',
		'start_time.desc' => 'In the selected Time Zone',
		ok_button => q{vs_text_as_prose('FORUM_CALENDAR_EVENT_FORM', ['Model.CalendarEventForm', '->form_mode_as_string']);},
	    ]],
	    ['title.FORUM_CALENDAR_EVENT_FORM' => q{vs_text_as_prose('FORUM_CALENDAR_EVENT_FORM', ['Model.CalendarEventForm', '->form_mode_as_string']); Event}],
	    [FORUM_CALENDAR_EVENT_FORM => [
		edit => 'Modify',
		create => 'Add',
		copy => 'Copy',
	    ]],
	    [[qw(task_menu.title list_action)] => [
		'FORUM_CALENDAR_EVENT_FORM.create' => 'Add Event',
		'FORUM_CALENDAR_EVENT_DELETE' => 'Delete',
		'FORUM_CALENDAR.user' => 'All vs_ui_forum();s',
	    ]],
	    __PACKAGE__->if_2014style([
		['task_menu.title' => [
		    FORUM_CALENDAR => q{LinkIcon('FORUM_CALENDAR');Calendar},
		    'forum.calendar' => q{LinkIcon('FORUM_CALENDAR');Events},
		]],
	    ]),
	    [[qw(title xlink)] => [
		[qw(
		    FORUM_CALENDAR
		    FORUM_CALENDAR_EVENT_LIST_RSS
	        )] => 'Calendar',
		FORUM_CALENDAR_EVENT_DELETE => 'Delete Event',
		FORUM_CALENDAR_EVENT_DETAIL => 'Event',
		[qw(FORUM_CALENDAR_EVENT_ICS FORUM_CALENDAR_EVENT_LIST_ICS)] => 'iCal',
		set_time_zone => '[change]',
	    ]],
	    [acknowledgement => [
		FORUM_CALENDAR_EVENT_DELETE => 'The event was deleted.',
		FORUM_CALENDAR_EVENT_FORM => [
		    create => 'The new event was added.',
		    copy => 'The event was copied.',
		    edit => 'The event was updated.',
		    recurrence => 'The recurring events were added.',
		],
	    ]],
	    [icon => [
		FORUM_CALENDAR => 'b_icon_calendar',
	    ]],
	],
    };
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
	    [FORUM_CRM_THREAD_ROOT_LIST_CSV => '?/tickets.csv'],
	],
	Text => [
	    [CRMQueryForm => [
		b_status => 'Any Status',
		b_owner_name => 'Any Owner',
	    ]],
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
		locked => 'Open (Locked)',
		open => 'Open',
		pending_customer => 'Pending Customer',
		new => 'New',
	    ]],
	    [CRMForm => [
		action_id => 'Action',
		ok_button => 'Send',
		update_only => 'Update Fields Only',
		crm_thread_status => 'Status',
		owner_user_id => 'Owner',
		empty_label => 'none',
	    ]],
	    ['task_menu.title' => [
		'FORUM_CRM_FORM.reply_all' => 'Answer',
		'FORUM_CRM_FORM.reply_realm' => 'Discuss Internally',
		FORUM_CRM_FORM => 'New Ticket',
		__PACKAGE__->if_2014style([
		    [
			'FORUM_CRM_THREAD_ROOT_LIST',
			'forum.crm_thread_root_list',
		    ] => q{LinkIcon('FORUM_CRM_THREAD_ROOT_LIST');Tickets},
		    CRMThreadList => [
			FORUM_CRM_THREAD_ROOT_LIST => q{LinkIcon('back_to_list');},
		    ],
		], [
		    CRMThreadList => [
			FORUM_CRM_THREAD_ROOT_LIST => 'Tickets',
		    ],
		]),
	    ]],
	    [[qw(title xlink)] => [
#TODO: Make into shortcut of widget
		FORUM_CRM_FORM => q{If(['->has_keys', 'Model.RealmMailList'], Join([Enum(['Model.CRMThread', 'crm_thread_status']), ' Ticket #', String(['Model.CRMThread', 'crm_thread_num'])]), 'New Ticket');},
		FORUM_CRM_THREAD_ROOT_LIST => 'Tickets',
		FORUM_CRM_THREAD_ROOT_LIST_CSV => 'Spreadsheet',
		FORUM_CRM_THREAD_LIST => q{Enum(['Model.CRMThreadList', '->get_crm_thread_status']); Ticket #String(['Model.CRMThreadList', '->get_crm_thread_num']); String(['Model.CRMThreadList', '->get_subject']);},
	    ]],
	    [acknowledgement => [
		FORUM_CRM_FORM => 'Your message was sent.',
	    ]],
	    [icon => [
		FORUM_CRM_THREAD_ROOT_LIST => 'b_icon_tags',
	    ]],
	],
    };
}

sub _cfg_dav {
    my($proto) = @_;
    return {
	Task => $proto->internal_dav_tasks,
	Text => $proto->internal_dav_text,
    };
}


sub _cfg_dev {
    return {
	Task => [
	    [DEV_RESTART => 't*restart-server'],
	    [DEV_ACCEPTANCE_TEST_LIST => 't*atl'],
	    [DEV_ACCEPTANCE_TEST_DETAIL => 't*acceptance-test-detail/*'],
	    [DEV_ACCEPTANCE_TEST_HEADER => 't*acceptance-test-header/*'],
	    [DEV_ACCEPTANCE_TEST_TRANSACTION_LIST => 't*acceptance-test-transaction-list/*'],
	    [DEV_ACCEPTANCE_TEST_REQUEST => 't*acceptance-test-request/*'],
	    [DEV_ACCEPTANCE_TEST_RESPONSE => 't*acceptance-test-response/*'],
	    [DEV_DBACCESS_MODEL_LIST => 't*dbaccess'],
	    [DEV_DBACCESS_MODEL_FORM => 't*dbaccess-model-form/*'],
	    [DEV_DBACCESS_ROW_LIST => 't*dbaccess-row-list/*'],

	],
	Text => [
	    [AcceptanceTestList => [
		age => 'Age',
		timestamp => 'Timestamp',
		test_name => 'Test Name',
		outcome => 'Outcome',
	    ]],
	    [AcceptanceTestTransactionList => [
		request_response_number => 'Request Response Number',
		test_line_number => 'Test Line Number',
		http_status => 'HTTP Status',
		command => 'Command',
	    ]],
	    [DBAccessModelList => [
		name => 'Name',
	    ]],
	    [DBAccessModelForm => [
		clear_form_button => 'Clear Form',
		first_button => '|<<',
		prev_button => '<',
		search_button => 'Search',
		next_button => '>',
		last_button => '>>|',
		create_button => 'Create',
		delete_button => 'Delete',
		update_button => 'Update',
	    ]],
	    [DBAccessRowList => [
		index => 'Index',
	    ]],
	],
    };
}

sub _cfg_test {
    return {
	Task => [
	    [TEST_BACKDOOR => 't*backdoor'],
	    [TEST_TRACE => 't*trace/*'],
	],
    };
}

sub _cfg_file {
    return {
	FormError => [
	    ['FileChangeForm.RealmFile.path_lc.EXISTS' =>
		 'A file with this name already exists.'],
	],
	Constant => [
	    [EasyForm_dir => $_EASY_FORM_DIR],
	],
	Task => [
	    [FORUM_EASY_FORM => "?/$_EASY_FORM_DIR/*"],
	    [FORUM_FILE => ['?/file/*', '?/public-file/*', '?/public/*', '?/Public/*', '?/pub/*']],
	    [FORUM_FILE_TREE_LIST => '?/files/*'],
	    [FORUM_FILE_MANAGER => '?/file-manager/*'],
	    [FORUM_FILE_MANAGER_AJAX => '?/file-manager-ajax/*'],
	    [FORUM_FILE_VERSIONS_LIST => '?/revision-history/*'],
	    [FORUM_FILE_CHANGE => '?/change-file/*'],
	    [FORUM_FILE_DELETE_PERMANENTLY_FORM => '?/delete-file-permanently/*'],
#	    [FORUM_FILE_OVERRIDE_LOCK => '?/override-lock/*'],
	    b_use('Model.RealmFileLock')->if_enabled(
	    	[FORUM_FILE_OVERRIDE_LOCK => '?/override-lock/*'],
	    ),
	    [FORUM_FILE_RESTORE_FORM => '?/restore-file/*'],
	    [FORUM_FILE_REVERT_FORM => '?/revert-file/*'],
	    [FORUM_FOLDER_FILE_LIST => '?/folder/*'],
	    [FORUM_FILE_UPLOAD_FROM_WYSIWYG => '?/upload-file-from-wysiwyg/*'],
	    [ROBOT_FILE_LIST => undef],
	],
	Text => [
	    [FileChangeForm => [
		name => 'Name',
		rename_name => 'New Name',
		file => 'File to upload',
		comment => 'Comments',
		content => __PACKAGE__->if_2014style('Text', ''),
		folder_id => 'New Parent Folder',
	    ]],
	    [[qw(RealmFileList RealmFileTreeList RealmFolderFileList)] => [
		'RealmFile.path' => 'Name',
		'RealmFile.modified_date_time' => 'Changed',
		[qw(Email_2.email RealmOwner_2.display_name)] => 'Who',
		node_collapsed => 'folder_collapsed',
		node_expanded => 'folder_expanded',
		node_empty => 'folder_empty',
		leaf_node => 'leaf_file',
		empty_list_prose => 'No files in this forum.',
		locked_leaf_node => 'leaf_file_locked',
		content_length => 'Size',
		actions => 'Actions',
		'list_action.FORUM_FILE_CHANGE' => 'Modify',
		'list_action.FORUM_FILE_DELETE_PERMANENTLY_FORM'
		    => 'Delete Permanently',
		'list_action.FORUM_FILE_RESTORE_FORM' => 'Restore',
		more_files => 'more ...',
	    ]],
	    [RealmFileLock => [
		comment => 'Comments',
	    ]],
	    [[qw(RealmFileVersionsList RealmFileVersionsListForm)] => [
		'RealmFile.path' => 'Revision',
		'revision_number' => 'Revision',
		'RealmFile.modified_date_time' => 'Checked In',
		[qw(Email_2.email RealmOwner_2.display_name
                    Email_3.email RealmOwner_3.display_name)] => 'Who',
		empty_list_prose => 'No files revisions.',
		selected => 'Selected',
		compare => 'Compare',
		ok_button => 'Compare',
		actions => 'Actions',
		'list_action.FORUM_FILE_REVERT_FORM' => 'Revert to Version',
	    ]],
	    [title => [
		FORUM_FILE => 'File',
		[qw(
                    FORUM_FILE_TREE_LIST
                    ROBOT_FILE_LIST
                    FORUM_FILE_MANAGER
                )] => 'Files',
		FORUM_FILE_VERSIONS_LIST => 'File Details',
		FORUM_FILE_CHANGE => 'Change',
		FORUM_FILE_OVERRIDE_LOCK => 'Override Lock',
		FORUM_FOLDER_FILE_LIST => q{Files for String(['Model.RealmFolderFileList', '->get_folder_path']);},
		FORUM_FILE_UPLOAD_FROM_WYSIWYG => 'Upload',
	    ]],
	    __PACKAGE__->if_2014style([
		['task_menu.title' => [
		    FORUM_FILE_TREE_LIST => q{LinkIcon('FORUM_FILE_TREE_LIST');Files},
		]],
	    ]),
	    [prose => [
		'EasyForm.update_mail' => [
		    from => q{Mailbox(['->format_email']);},
		    to => q{Mailbox(['Action.EasyForm', 'to']);},
		    subject => q{String(['Action.EasyForm', 'file_path']); submission},
		    body => q{With(['Action.EasyForm', 'hash_list'], Join([['key'], ': ', ['value'], "\n"]));},
		],
	    ]],
	    [icon => [
		FORUM_FILE_TREE_LIST => 'b_icon_folder_open',
	    ]],
        ],
    };
}

sub _cfg_group_admin {
    return {
	Task => [
	    [GROUP_USER_LIST => '?/users'],
	    [GROUP_USER_FORM => '?/edit-user'],
	    [GROUP_USER_ADD_FORM => '?/add-user'],
            [FORUM_CREATE_FORM => '?/create-forum'],
            [FORUM_EDIT_FORM => '?/edit-forum'],
            [REALM_FEATURE_FORM => '?/edit-features'],
	],
	Text => [
	    [realm_owner_site_admin => [
		 [qw(GroupUserList.privileges_name RoleSelectList.display_name)] => [
		    UNKNOWN => 'Select Privileges',
		    GUEST => 'Site Contractor',
		    MEMBER => 'Site Staff',
		    ACCOUNTANT => 'Site Manager',
		    ADMINISTRATOR => 'Site Admin',
		],
	    ]],
	    [[qw(GroupUserList.privileges_name RoleSelectList.display_name)]
	        => [
		    UNKNOWN => 'No Access',
		    USER => 'Registered User',
		    WITHDRAWN => 'Former Member',
		    GUEST => 'Guest',
		    MEMBER => 'Member',
		    FILE_WRITER => 'Editor',
		    ACCOUNTANT => 'Deputy',
		    ADMINISTRATOR => 'Admin',
		    UNAPPROVED_APPLICANT => 'Requested Access',
		    'UserRealmSubscription.is_subscribed' => 'Subscribed',
		],
	    ],
	    [RealmUserAddform => [
		'RealmOwner.display_name' => 'Full Name',
		'RealmOwner.display_name.desc' => 'Only required for new users',
		ok_button => 'Add',
	    ]],
	    [TaskLog => [
		date_time => 'Date',
		uri => 'Link',
		'Email.email' => 'Email',
	    ]],
	    [TaskLogList => [
		'RealmOwner.display_name' => 'Name',
		'super_user.RealmOwner.name' => 'Staff acting as user',
	    ]],
	    [GroupUserList => [
                'RealmOwner.creation_date_time' => 'Registration Date',
		display_name => 'Last, First Name',
		privileges => 'Privileges',
		'UserRealmSubscription.is_subscribed' => 'Subscribed',
		subscribed => 'Subscribed',
		unsubscribed => '',
		list_actions => 'Actions',
		list_action => [
		    edit => 'Edit',
		],
	    ]],
	    [[qw(UnapprovedApplicantForm GroupUserForm)] => [
		'RealmUser.role' => 'Access Level',
		file_writer => 'Write access to files (Editor)',
		is_subscribed => 'Receive mail sent to vs_ui_forum(); (Subscribed)',
	    ]],
 	    ['Forum.require_otp' => 'Require OTP?'],
	    [mail_send_access => 'Mail Sending Mode'],
	    [mail_visibility => 'Mail Visibility'],
	    [RealmFeatureForm => [
		feature_wiki => 'Wiki',
	    ]],
	    [feature_blog => 'Blog'],
	    [feature_motion => 'Poll'],
	    [feature_mail => 'Mail'],
	    [feature_file => 'File'],
	    [feature_calendar => 'Calendar'],
	    [feature_crm => 'Ticket'],
	    [feature_tuple => 'Tables'],
	    [feature_wiki => 'vs_ui_wiki();'],
	    [mail_want_reply_to => 'Mail replies go to the vs_ui_forum(); by default'],
            [ForumForm => [
                'RealmOwner.name' => 'vs_ui_forum();',
                'RealmOwner.display_name' => 'Title',
            ]],
	    [title => [
		GROUP_USER_LIST => 'Roster',
		GROUP_USER_ADD_FORM => 'Add Member',
		GROUP_USER_FORM => q{Privileges for String(['->req', 'Model.GroupUserList', 'RealmOwner.display_name']);},
                FORUM_CREATE_FORM => 'New vs_ui_forum();',
		[qw(FORUM_EDIT_FORM REALM_FEATURE_FORM)] => 'Features',
	    ]],
	    [clear_on_focus_hint => [
		GROUP_USER_LIST => 'Filter name or @email',
	    ]],
	    ['HelpWiki.title' => [
		GROUP_USER_FORM => 'Privileges for User',
	    ]],
	],
    };
}

sub _cfg_mail {
    return {
	Font => [
	    [mail_msg_field => 'bold'],
	    [msg_byline => [qw(120% bold)]],
	    [msg_summary_byline => __PACKAGE__->init_from_prior_group('text_byline')],
	    [msg_excerpt => __PACKAGE__->init_from_prior_group('text_excerpt')],
	],
	Color => [
	    [msg_byline => 0x0],
	    [mail_msg_border => __PACKAGE__->init_from_prior_group('form_sep_border')],
	],
	CSS => [
	    [msg_summary => q{
	        width: 50em;
	    }],
	],
	Task => [
	    __PACKAGE__->mail_receive_task_list(
		'FORUM_MAIL_RECEIVE',
		[USER_MAIL_BOUNCE => b_use('Model.RealmMailBounce')->TASK_URI],
		[ADMIN_REALM_MAIL_RECEIVE => b_use('Action.AdminRealmMail')->TASK_URI],
		[BOARD_REALM_MAIL_RECEIVE => b_use('Action.BoardRealmMail')->TASK_URI],
		[REWRITE_FROM_DOMAIN_REFLECTOR => b_use('Action.MailForward')->REWRITE_FROM_DOMAIN_URI],
	    ),
	    $_C->if_version(4 => sub {
		    return (
			[FORUM_MAIL_THREAD_ROOT_LIST => '?/mail'],
			[FORUM_MAIL_THREAD_LIST => '?/mail-thread'],
			[FORUM_MAIL_FORM => '?/compose-mail-msg'],
			[FORUM_MAIL_PART => '?/mail-msg-part/*'],
                        [FORUM_MAIL_SHOW_ORIGINAL_FILE => '?/original-msg/*'],
			[GROUP_MAIL_DELETE_FORM => '?/mail-delete'],
		    );
		},
	    ),
	    [GROUP_MAIL_RECEIVE_NIGHTLY_TEST_OUTPUT => undef],
	    [GROUP_MAIL_RECEIVE_WEEKLY_BUILD_OUTPUT => undef],
	    [MAIL_RECEIVE_DISPATCH =>
		 sub {shift->get_facade->MAIL_RECEIVE_URI_PREFIX . '/*'}],
	    [FORUM_MAIL_REFLECTOR => undef],
	    [ADMIN_REALM_MAIL_REFLECTOR => undef],
	    [MAIL_RECEIVE_FORWARD => undef],
	    [MAIL_RECEIVE_IGNORE => undef],
	    [MAIL_RECEIVE_NOT_FOUND => undef],
	    [MAIL_RECEIVE_NO_RESOURCES => undef],
	    [MAIL_RECEIVE_FORBIDDEN => undef],
	    [GROUP_BULLETIN_FORM => '?/publish-bulletin'],
	    [GROUP_BULLETIN_REFLECTOR => undef],
	    [GROUP_MAIL_TOGGLE_PUBLIC => '?/mail-toggle-public'],
	    [USER_MAIL_UNSUBSCRIBE_FORM => '?/unsubscribe/*'],
	],
	Text => [
	    ['MailReceiveDispatchForm.uri_prefix' =>
		 sub {shift->get_facade->MAIL_RECEIVE_PREFIX}],
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
	    [b_use('Biz.Model')->get_instance('MailForm')
	        ->map_attachments(sub {shift}) => 'Attach'],
	    [view_rfc822 => 'Show Original'],
	    [realm_mail_make_private => 'Public [change]'],
	    [realm_mail_make_public => 'Private [change]'],
	    [[qw(MailForm CRMForm)] => [
		board_only => 'Do not send message to vs_ui_forum(); vs_ui_members();',
		ok_button => 'Send',
	    ]],
	    ['MailForm.subject' => 'Topic'],
	    [BulletinForm => [
		ok_button => 'Send',
		prose => [
		    prologue => q{To send a test message, just change the To: list below.  To publish to this bulletin as is, click Send once.},
		],
	    ]],
	    [RealmMailDeleteForm => [
		ok_button => 'Delete',
		prose => [
		    prologue => q{Are you sure you want to delete message SPAN_bold(String([qw(Model.RealmMailDeleteForm realm_mail subject)])); from SPAN_bold(String([qw(Model.RealmMailDeleteForm realm_mail from_email)]));?},
		],
	    ]],
	    [RealmFileDeletePermanentlyForm => [
		ok_button => 'Delete Permanently',
		prose => [
		    prologue => q{Are you sure you want to delete SPAN_bold(String([qw(->req path_info)])); permanently?},
		],
	    ]],
	    [RealmFileRestoreForm => [
		ok_button => 'Restore',
		prose => [
		    prologue => q{Are you sure you want to restore SPAN_bold(String([qw(->req path_info)]));?},
#		    prologue => q{Are you sure you want to restore file?},
		],
	    ]],
	    [RealmFileRevertForm => [
		ok_button => 'Revert',
		prose => [
		    prologue => q{Are you sure you want to revert file SPAN_bold(String([qw(Model.RealmFileRevertForm realm_file path)])); to version SPAN_bold(String([qw(Model.RealmFileRevertForm new_version)]));?},
		],
	    ]],
	    [EmailVerifyForceForm => [
		ok_button => 'Force Verify',
		prose => [
		    prologue => q{Are you sure you want to force verification of SPAN_bold(String([qw(Model.EmailVerifyForceForm display_name)]));'s email address (SPAN_bold(String([qw(Model.EmailVerifyForceForm email)]));)?},
		],
	    ]],
	    [MailUnsubscribeForm => [
		prose => [
		    prologue => q{To remove yourself from String(['Model.MailUnsubscribeForm', 'realm_display_name']); mailings, click Unsubscribe below, or you can unsubscribe from all mailings from String(vs_site_name());.},
		],
		ok_button => 'Unsubscribe',
		all_button => 'Unsubscribe From All Mailings',
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
		     byline => q{DIV_byline(Join([SPAN_author(String(['->get_from_name'])), SPAN_label(' on '), DIV_date(DateTime(['->get_header', 'date']))]));},
		     forward => q{DIV_forward(Join([DIV_header('---------- Forwarded message ----------'), MailHeader()]));},
		     attachment => q{SPAN_label('Attachment:');SPAN_value(String(['->get_file_name']));},
		 ],
	    ]],
	    ['task_menu.title' => [
		'FORUM_MAIL_FORM.reply_all' => 'Reply to All',
		'FORUM_MAIL_FORM.reply_author' => 'Reply to Author',
		'FORUM_MAIL_FORM.reply_realm' => 'Reply',
		FORUM_MAIL_FORM => 'New Topic',
		__PACKAGE__->if_2014style([
		    [
			'FORUM_MAIL_THREAD_ROOT_LIST',
			'forum.mail_thread_root_list',
		    ] => q{LinkIcon('FORUM_MAIL_THREAD_ROOT_LIST');Mail},
		    MailThreadList => [
			FORUM_MAIL_THREAD_ROOT_LIST => q{LinkIcon('back_to_list');},
		    ],
		], [
		    FORUM_MAIL_THREAD_ROOT_LIST => 'Mail',
		    MailThreadList => [
			FORUM_MAIL_THREAD_ROOT_LIST => 'Mail',
		    ],
		]),
	    ]],
	    [title => [
		FORUM_MAIL_FORM => q{If(['->has_keys', 'Model.RealmMailList'], 'Reply', 'New Topic');},
		FORUM_MAIL_THREAD_ROOT_LIST => 'Mail',
		FORUM_MAIL_THREAD_LIST => q{Topic: String(['Model.MailThreadList', '->get_subject']);},
		FORUM_FILE_DELETE_PERMANENTLY_FORM => 'Delete File Permanantly',
		FORUM_FILE_RESTORE_FORM => 'Restore File',
		FORUM_FILE_REVERT_FORM => 'Revert File',
		USER_MAIL_UNSUBSCRIBE_FORM => 'Unsubscribe',
		GROUP_BULLETIN_FORM => 'Publish Bulletin',
		GROUP_MAIL_DELETE_FORM => 'Delete Message',
	    ]],
	    [acknowledgement => [
		FORUM_FILE_DELETE_PERMANENTLY_FORM => 'File deleted permanently.',
		FORUM_MAIL_FORM => 'Your message was sent.',
		FORUM_FILE_RESTORE_FORM => 'File restored.',
		FORUM_FILE_REVERT_FORM => 'File reverted.',
		GROUP_BULLETIN_FORM => q{The bulletin has been sent to String(['Model.BulletinForm', 'to']);.},
		GROUP_MAIL_DELETE_FORM => 'Message deleted',
		user_mail_unsubscribed => q{You have been unsubscribed.},
		user_mail_unsubscribed_all => q{You have been unsubscribed from ALL MAILINGS from String(vs_site_name());},
	    ]],
	    [icon => [
		FORUM_MAIL_THREAD_ROOT_LIST => 'b_icon_envelope',
	    ]],
	],
    };
}

sub _cfg_motion {
    return {
	Task => [
	    [FORUM_MOTION_LIST => ['?/polls/*', '?/votes']],
	    [FORUM_MOTION_FORM => ['?/poll', '?/edit-poll', '?/edit-vote', '?/vote-edit']],
	    [FORUM_MOTION_COMMENT => '?/poll-comment'],
	    [FORUM_MOTION_VOTE => ['?/poll-vote', '?/vote']],
	    [FORUM_MOTION_VOTE_LIST => ['?/poll-results', '?/vote-results', '?/results']],
	    [FORUM_MOTION_VOTE_LIST_CSV => ['?/poll-results.csv', '?/vote-results.csv', '?/results.csv']],
	    [FORUM_MOTION_COMMENT_LIST => '?/poll-comments'],
	    [FORUM_MOTION_COMMENT_LIST_CSV => '?/poll-comments.csv'],
	    [FORUM_MOTION_STATUS => '?/poll-status'],
	    [FORUM_MOTION_COMMENT_DETAIL => '?/poll-comment-detail'],
	    [FORUM_MOTION_IS_CLOSED => '?/poll-is-closed'],
	],
	Text => [
	    [Motion => [
		name => 'Name',
		question => 'Question',
		status => 'Status',
		type => 'Type',
		motion_file_id => 'Document',
		start_date_time => 'Start',
		end_date_time => 'End',
		tuple_def_id => 'Comment Format',
		is_closed => 'The requested poll is now closed.  Votes and comments are no longer being accepted.',
	    ]],
	    [MotionForm => [
		file => q{If(And(
                    [['->req', 'form_model'], '->is_edit'],
                    [['->req', 'form_model'], 'Motion.motion_file_id'],
                ),
                    'Replace Document',
                    'Document',
                );},
                end_date_string => "End",
	    ]],
	    [MotionComment => [
		comment => 'Comment',
		creation_date_time => 'Date',
	    ]],
	    [MotionCommentList => [
		'RealmOwner.display_name' => 'Name',
	    ]],
	    [MotionCommentDetail => [
		name => 'Name',
		question => 'Question',
		comment => 'Comment',
	    ]],
	    [MotionVote => [
		vote => 'Vote',
		comment => 'Comment',
		creation_date_time => 'Date',
	    ]],
	    [MotionList => [
		empty_list_prose => 'No polls to display.',
		vote_count => 'Votes [Y/N/A]',
	    ]],
	    [MotionStatus => [
		name => 'Name',
		question => 'Question',
		file => 'File',
		start_date_time => 'Start time',
		end_date_time => 'End time',
		yes_count => 'Yes',
		no_count => 'No',
		abstain_count => 'Abstain',
		vote_list => 'Votes',
		comment_list => 'Comments',
	    ]],
	    [MotionVoteList => [
		empty_list_prose => 'No poll results.',
	    ]],
	    [acknowledgement => [
		FORUM_MOTION_FORM => 'The poll has been saved.',
		FORUM_MOTION_VOTE =>
		    'Thank you for your participation in the poll.',
	    ]],
	    [list_action => [
		FORUM_MOTION_FORM => 'Edit',
		FORUM_MOTION_VOTE => 'Vote',
		FORUM_MOTION_COMMENT => 'Comment',
		FORUM_MOTION_STATUS => 'Status',
	    ]],
	    [title => [
		FORUM_MOTION_LIST => 'Polls',
		FORUM_MOTION_FORM => 'New Poll',
		FORUM_MOTION_COMMENT => 'Comment',
		FORUM_MOTION_VOTE => 'Vote',
		FORUM_MOTION_VOTE_LIST => 'Poll Results',
		FORUM_MOTION_COMMENT_LIST => 'Poll Comments',
		FORUM_MOTION_STATUS => 'Poll Status',
		FORUM_MOTION_COMMENT_DETAIL => 'Poll Comment Detail',
		FORUM_MOTION_IS_CLOSED => 'Poll is Closed',
	    ]],
	    ['task_menu.title' => [
		FORUM_MOTION_VOTE_LIST_CSV => 'Vote spreadsheet',
		FORUM_MOTION_COMMENT_LIST_CSV => 'Comment spreadsheet',
		__PACKAGE__->if_2014style([
		    FORUM_MOTION_LIST => q{LinkIcon('FORUM_MOTION_LIST');Polls},
		    FORUM_MOTION_FORM => 'New',
		]),
	    ]],
	    [icon => [
		FORUM_MOTION_LIST => 'b_icon_thumbs_up',
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

sub _cfg_site_admin {
    return {
        Constant => [
            map({
		my($n, $task, $control, $realm) = @$_;
		$realm ||= 'SITE_ADMIN_REALM_NAME';
		$control = $_TI->unsafe_from_name($task) ? 1 : 0
		    unless defined($control);
		(
		    ["xlink_$n" => sub {
                        my($f) = shift->get_facade;
                        return {
                            task_id => $task,
                            $f->can($realm) ? (realm => $f->$realm()) : (),
                        };
                    }],
		    ["want_$n" => $control],
		);
	    }
		$_C->if_version(10 =>
		    sub {[qw(all_users GROUP_USER_LIST)]},
		    sub {[qw(all_users SITE_ADMIN_USER_LIST)]},
		),
                [qw(substitute_user SITE_ADMIN_SUBSTITUTE_USER)],
		[qw(task_log SITE_ADMIN_TASK_LOG)],
		[qw(remote_copy REMOTE_COPY_FORM), sub {
		     my($fc) = @_;
		     return $_D->eval(sub {
			 my($id) = $fc->unsafe_get_value('site_admin_realm_id');
			 return $id
			     && b_use('Model.RemoteCopyList')->new(
				 $fc->get_facade->req
			     )->unauth_if_setting_available($id) ? 1 : 0;
		     });
		}],
                [qw(applicants SITE_ADMIN_UNAPPROVED_APPLICANT_LIST), sub {
		     return b_use('Model.UserCreateForm')
			 ->if_unapproved_applicant_mode(sub {1}, sub {0});
		}],
		[
		    'site_reports',
		    'FORUM_FILE_TREE_LIST',
		    sub {_unsafe_realm_id(shift, 'SITE_REPORTS_REALM_NAME')},
		    'SITE_REPORTS_REALM_NAME',
		],
            ),
	    [xlink_email_alias => 'EMAIL_ALIAS_LIST_FORM'],
        ],
	FormError => [
	    ['RemoteCopyListForm.want_realm' => [
		NOT_FOUND => 'Local realm does not exist.',
		PERMISSION_DENIED => 'You do not have write access to the local realm.',
		EMPTY => 'No folders specified in RemoteCopy.csv for this realm',
		SYNTAX_ERROR => q{Errors accessing remote system:BR();String(vs_fe('detail'));},
	    ]],
	],
	Task => [
	    [REMOTE_COPY_GET => '?/remote-copy-get/*'],
	    [REMOTE_COPY_FORM => '?/remote-copy'],
	    [SITE_ADMIN_USER_LIST => '?/admin-users'],
	    [SITE_ADMIN_SUBSTITUTE_USER => '?/admin-su'],
	    [SITE_ADMIN_SUBSTITUTE_USER_DONE => '?/admin-su-exit'],
	    [SITE_ADMIN_UNAPPROVED_APPLICANT_LIST => => '?/admin-applicants'],
	    [SITE_ADMIN_UNAPPROVED_APPLICANT_FORM => => '?/admin-assign-applicant'],
	    [EMAIL_ALIAS_LIST_FORM => 'adm/email-aliases'],
	],
	Text => [
            [xlink => [
                applicants => 'Site Applicants',
                all_users => 'All Users',
                site_reports => 'Web Stats',
                substitute_user => 'Act as User',
		remote_copy => 'Remote Copy',
            ]],
	    [[qw(AdmUserList UnapprovedApplicantList)] => [
		display_name => 'Name',
		privileges => 'Privileges',
	    ]],
	    [[qw(EmailAliasList EmailAliasListForm)] => [
		EmailAlias => [
		    incoming => 'From Email',
		    outgoing => 'To Email or vs_ui_forum();',
		],
	    ]],
	    [UnapprovedApplicantList => [
                'RealmOwner.creation_date_time' => 'Registration Date',
	    ]],
	    [[qw(RemoteCopyListForm RemoteCopyList)] => [
		prose => [
		    prologue => q{If([qw(Model.RemoteCopyListForm prepare_ok)], q{Copy Phase: Update local system with remote files}, q{Preparation Phase: Select realms to compare remote and local files});},
		],
		empty_realm => 'This realm is up to date.',
		empty_list_prose => q{You need to create Settings/RemoteCopy.csv in order to perform this operation.},
		to_update => 'Files to replace:',
		to_delete => 'Files to delete:',
		to_create => 'New files to copy:',
		ok_button => q{If([qw(Model.RemoteCopyListForm prepare_ok)], 'Copy', 'Prepare');},
		want_realm => '',
	    ]],
	    [UnapprovedApplicantForm => [
		mail_subject => [
		    UNAPPROVED_APPLICANT => '',
		    default => 'Registration Confirmed',
		],
		mail_body => [
		    default => <<'EOF',
You have been granted access to our site.  If you have any questions,
you may contact support by replying to this message.

Thank you,
vs_site_name(); Support
EOF
		],
		'RealmUser.role' => 'Access Level',
		file_writer => 'Write access to files (Editor)',
		is_subscribed => 'Receive mail sent to group (Subscribed)',
	    ]],

	    [title => [
		REMOTE_COPY_FORM => 'Remote Copy',
		SITE_ADMIN_USER_LIST => 'All Users',
		SITE_ADMIN_SUBSTITUTE_USER => 'Act as User',
		SITE_ADMIN_UNAPPROVED_APPLICANT_LIST => 'Site Applicants',
		SITE_ADMIN_UNAPPROVED_APPLICANT_FORM => q{Applicant String(['->req', 'Model.UnapprovedApplicantList', 'RealmOwner.display_name']);},
		EMAIL_ALIAS_LIST_FORM => 'Email Aliases',
	    ]],
	    [prose => [
		unapproved_applicant_form_mail_subject => 'vs_site_name(); Registration Confirmed',
	    ]],
	    [[qw(prose.SiteAdminDropDown_label
		 task_menu.title.SiteAdminDropDown_label)] => 'Admin'],
	    [acknowledgement => [
		REMOTE_COPY_FORM => 'Local system updated.',
		REMOTE_COPY_FORM_no_update => 'Remote and local systems are identical.  Nothing to update.',
		EMAIL_ALIAS_LIST_FORM => 'Email Aliases Updated',
	    ]],
	],
    };
}

sub _cfg_task_log {
    return {
	Task => [
	    [SITE_ADMIN_TASK_LOG => '?/admin-hits'],
	    [SITE_ADMIN_TASK_LOG_CSV => '?/admin-hits.csv'],
	    [GROUP_TASK_LOG => '?/hits'],
	    [GROUP_TASK_LOG_CSV => '?/hits.csv'],
	],
	Text => [
            [xlink => [
		task_log => 'Site Hits',
            ]],
	    [clear_on_focus_hint => [
		map(($_ => 'Filter name, >date, @email, /link, or x.y.z.'),
		    map(($_, $_ . '_CSV'),
			qw(SITE_ADMIN_TASK_LOG GROUP_TASK_LOG))),
	    ]],
	    [title => [
		SITE_ADMIN_TASK_LOG => 'Site Hits',
		GROUP_TASK_LOG => 'Hits',
		SITE_ADMIN_TASK_LOG_CSV => 'Spreadsheet',
		GROUP_TASK_LOG_CSV => 'Spreadsheet',
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
		TupleHistoryList => [
		    FORUM_TUPLE_EDIT => 'Modify record',
		    FORUM_TUPLE_LIST => 'Back to list',
		],
		__PACKAGE__->if_2014style([
		    FORUM_TUPLE_USE_LIST => q{LinkIcon('FORUM_TUPLE_USE_LIST');Tables},
		], [
		    FORUM_TUPLE_USE_LIST => 'Tables',
		]),
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
		FORUM_TUPLE_EDIT => 'The record has been saved.',
	    ]],
	    [icon => [
		FORUM_TUPLE_USE_LIST => 'b_icon_tasks',
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
	    ['TupleDefListForm.TupleSlotDef.tuple_slot_type_id.EXISTS' =>
		'New required fields must use a Type with a default value.'],
	    ['TupleDefListForm.TupleSlotDef.tuple_slot_type_id.SYNTAX_ERROR' =>
		'The type does not accept the existing record data.'],
	    ['TupleUseForm.TupleUse.tuple_def_id.EXISTS' =>
		'This Table is in use so you cannot change the Schema.'],
	    [[qw(TupleSlotDef TupleSlotType)] => [
		'label' => [
		    SYNTAX_ERROR => 'Labels must be at least two characters and begin with a uppercase letter, consist of letters, numbers, dashes<(>-), or underscores',
		],
	    ]],
	    [[qw(TupleDef TupleUse)] => [
		'label' => [
		    SYNTAX_ERROR => 'Labels must be at least two characters and begin with a letter, consist of letters, numbers, dashes<(>-), or underscores',
		],
		'moniker' => [
		    SYNTAX_ERROR => 'Mail prefixes must be at least two characters and begin with a lowercase letter, consist of letters, numbers, or underscores',
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
	    [ThreePartPage_want_UserSettingsForm => $_C->if_version(5 => sub {1},
		sub {0},
	    )],
	],
	FormError => [
	    ['UserSettingsListForm.User.first_name.NULL' => 'You must supply at least one of First, Middle, or Last Names.'],
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
	    [USER_EMAIL_VERIFY => '?/verify-email'],
	    [USER_EMAIL_VERIFY_FORCE_FORM => undef],
	    [USER_EMAIL_VERIFY_SENT => undef],
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
	    [confirm_password => 'Re-enter Password'],
	    ['confirm_password.field_description' => q{Enter your password again.}],
	    [[qw(UserCreateForm UserRegisterForm)] => [
		ok_button => 'Register',
		prose => [
		    prologue => __PACKAGE__->if_2014style(
			'', q{P(XLink('GENERAL_USER_PASSWORD_QUERY'));}),
		    epilogue => q{P(XLink('login_no_context'));},
		],
	    ]],
	    __PACKAGE__->if_2014style([
		[UserCreateForm => [
		    'confirm_password.desc' => q{Re-enter your password},
		    prose => [
			epilogue => '',
		    ],
		]],
		[UserRegisterForm => [
		    prose => [
			epilogue => q{
			DIV_trailer(
			    Link(
				'Already registered?',
				'LOGIN',
			    ),
			);
		    },
		    ],
		]],
	    ]),
	    [old_password => 'Current Password'],
	    [new_password => 'New Password'],
	    [confirm_new_password => 'Re-enter New Password'],
	    [email_verified_date_time => 'Last Verified'],
	    [UserPasswordForm => [
		ok_button => 'Update',
	    ]],
	    ['page_size' => 'List Size'],
	    [[qw(UserSettingsListForm UserSubscriptionList)] => [
		'RealmOwner.name' => 'User Id',
		'RealmOwner.display_name' => 'vs_ui_forum();',
		is_subscribed => 'Subscribed?',
		'UserDefaultSubscription.subscribed_by_default'
		    => 'Subscribe by default when added to a new forum?',
		'RealmOwner.name.desc' => 'Field only visible to system administrators.',
		'separator.password' => 'Fill in to change your password; otherwise, leave blank',
		prose => [
		    user_password => q{Link('Click here to change your password.', 'USER_PASSWORD');},
		],
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
		USER_SETTINGS_FORM => 'Your settings have been updated.',
		email_verified => q{Your email address has been updated.},
		USER_EMAIL_VERIFY_FORCE_FORM => 'Email address verified.',
	    ]],
	    [title => [
		GENERAL_USER_PASSWORD_QUERY => 'Password Assistance',
		USER_CREATE_DONE => 'Registration Email Sent',
		USER_EMAIL_VERIFY => 'Verify Email Address',
		USER_EMAIL_VERIFY_FORCE_FORM => 'Force Verify Email Address',
		USER_EMAIL_VERIFY_SENT => 'Check Your Email',
	    ]],
	    [[qw(title xlink)] => [
		GENERAL_CONTACT => 'Contact',
		GENERAL_USER_PASSWORD_QUERY_ACK => 'Password Assistance Sent',
		USER_SETTINGS_FORM => 'Personal Information and Settings',
		DEFAULT_ERROR_REDIRECT_MISSING_COOKIES => 'Your Browser is Missing Cookies',
	    ]],
	    [xlink => [
		GENERAL_USER_PASSWORD_QUERY => 'Forgot password?',
		login_no_context => 'Already registered?  Click here to login.',
		user_create_no_context => 'Not registered? Click here to register.',
		USER_CREATE_DONE => 'Check Your Email',
	    ]],
	    __PACKAGE__->if_2014style([
		['xhtml.title' => [
		    LOGIN => 'vs_site_name(); Login',
		    USER_CREATE => 'vs_site_name(); Registration',
		    GENERAL_CONTACT => 'Contact',
		    USER_PASSWORD  => 'Password',
		    SITE_ROOT => '',
		]],
	    ], [
		[[qw(page3.title xhtml.title)] => [
		    LOGIN => 'Please Login',
		    USER_CREATE => 'Please Register',
		    GENERAL_CONTACT => 'Please Contact Us',
		    USER_PASSWORD  => 'Your Password',
		    SITE_ROOT => '',
		]],
	    ]),
	    [[qw(task_menu.title HelpWiki.title)] => [
		DEFAULT_ERROR_REDIRECT_MISSING_COOKIES => 'Browser Missing Cookies',
		USER_SETTINGS_FORM => 'Settings',
	    ]],
	    [prose => [
		UserAuth => [
		    general_contact_mail => [
			subject => q{vs_site_name(); Web Contact},
		    ],
		    password_query_mail => [
			to => q{Mailbox(['Model.UserPasswordQueryForm', 'Email.email']);},
			subject => 'vs_site_name(); Password Assistance',
			body => <<'EOF',
Please follow the link to reset your password:

Join([['Model.UserPasswordQueryForm', 'uri']]);

For your security, this link may be used one time only to set your
password.

You may contact customer support by replying to this message.

Thank you,
vs_site_name(); Support
EOF
		    ],
		    'create_done.body' => <<'EOF',
We have sent a confirmation email to
String(['Model.UserRegisterForm', 'Email.email']);.
Please follow the instructions in this email message to complete
your registration with vs_site_name();.
EOF
		    create_mail => [
			to => q{Mailbox(['Model.UserRegisterForm', 'Email.email']);},
			subject => 'vs_site_name(); Registration Verification',
			body => <<'EOF',
Thank you for registering with vs_site_name();.
In order to complete your registration, please click on the
following link:

String(['Model.UserRegisterForm', 'uri']);

For your security, this link may be used one time only to set your
password.

You may contact customer support by replying to this message.

Thank you,
vs_site_name(); Support
EOF
		    ],
		    'missing_cookies.body' => <<'EOF',
Join([
    P('It seems that your browser does not support cookies, or cookies have been disabled. Cookies are required for you to sign-in.'),
    H3('Enabling Cookies in your Browser'),
    P(q{This application requires the use of Cookies. By default, cookies are enabled in your browser. If you were directed to this page by our software, you or someone else has disabled cookies in your browser. The following instructions are meant as a guide only. Please consult your browser's help system for a complete description. Scroll down this page until you find your browser. We apologize if your browser isn't in our list yet.}),
    map((
	H4(shift(@$_)),
	OL(Join([map(LI($_), @$_)])),
    ), [
	'Internet Explorer 6.0',
	'Click on the Tools menu (at the very top of your window)',
	'Select Internet Options',
	'Switch to the Privacy tab',
	'Slide the vertical slider to Medium',
    ], [
	'AOL 6.0 and above',
	'Click on My AOL at the top of the AOL window',
	'Select Preferences from the menu',
	'Click on the WWW icon',
	'Switch to the Privacy tab',
	'Slide the vertical slider to Medium',
    ], [
	'Older Internet Explorer Versions',
	'Click on the Tools menu (at the very top of your window)',
	'Select Internet Options',
	'Switch to the Security tab',
	'Click on Internet in the Select a Web content zone',
	'Further down, press the Custom Level button',
	'Scroll down to the Cookies section in the Settings box',
	'Click on Enable for Allow cookies that are stored option',
	'Click on Enable for Allow per-session cookies option',
    ], [
	'Older AOL Versions',
	'Click on My AOL at the top of the AOL window',
	'Select Preferences from the menu',
	'Click on the WWW icon',
	'Click on Internet in the Select a Web content zone',
	'Further down, press the Custom Level button',
	'Scroll down to the Cookies section in the Settings box',
	'Click on Enable for Allow cookies that are stored option',
	'Click on Enable for Allow per-session cookies option',
    ], [
	'Netscape Communicator',
	'Click on the Edit menu (at the very top of your window)',
	'Select Preferences',
	'Click on Advanced in the Category box',
	'Click on Accept all cookies in the Cookies box',
    ]),
]);
EOF
		],
	    ]],

	],
    };
}

sub _cfg_wiki {
    return {
	Task => [
	    [FORUM_WIKI_EDIT => '?/edit-wiki/*'],
	    [FORUM_WIKI_VIEW => ['?/bp/*', '?/wiki/*', '?/public-wiki/*']],
	    [FORUM_WIKI_NOT_FOUND => undef],
	    [FORUM_WIKI_VERSIONS_LIST => '?/wiki-history/*'],
	    [FORUM_WIKI_VERSIONS_DIFF => '?/wiki-diff'],
	    [HELP => '?/help/*'],
	    [HELP_NOT_FOUND => undef],
	    [SITE_WIKI_VIEW => $_SITE_WIKI_VIEW_URI . '/*'],
	],
	Color => [
	    [same_background => 0xF2F2F2],
	    [different_background => 0xE6E6E6],
	],
	Constant => [
	    [ThreePartPage_want_HelpWiki => 1],
	],
	CSS => [
	    [b_help_wiki_main_left => q{
                width: 32em;
            }],
	    [b_help_index => q{
                padding-top: 0.5ex;
	        text-align: left;
	        width: 30em;
                padding-left: 1em;
            }],
	    [b_help_index_text_indent => q{
                text-indent: -1em;
            }],
	    [b_help_index_title => q{
                margin-bottom: .5ex;
            }],
	    [b_help_index_item => q{
                margin-bottom: .3ex;
            }],
	    [b_wiki_width => q{}],
	],
	Font => [
	    [help_wiki_body => ['95%']],
	    [help_wiki_tools => ['95%']],
	    [help_wiki_header => ['bold', '140%', 'uppercase']],
	    [help_wiki_iframe_body => ['small']],
	    [b_help_index_title => ['80%', 'bold']],
	    [b_help_index_item => ['80%']],
	],
	Text => [
	    [WikiValidator => [
		title => 'vs_ui_wiki(); errors:',
		subject => q{vs_ui_wiki(); Errors},
	    ]],
	    ['WikiView.start_page' => 'StartPage'],
	    [WikiForm => [
		'RealmFile.path_lc' => 'Title',
		'content' => '',
		'RealmFile.is_public' => 'Make this article publicly available?',
 		'ok_button' => q{If(
		    Or(['->is_super_user'], ['->is_substitute_user']),
		    'Validate',
		    'OK',
		);},
 		'ok_no_validate_button' => 'Save',
	    ]],
	    [title => [
		FORUM_WIKI_NOT_FOUND => 'vs_ui_wiki(); Page Not Found',
		HELP_NOT_FOUND => 'Help Page Not Found',
		HELP => 'Help',
		FORUM_WIKI_EDIT => 'Edit vs_ui_wiki(); Page',
		FORUM_WIKI_VERSIONS_LIST => 'vs_ui_wiki(); Page History',
		FORUM_WIKI_VERSIONS_DIFF => 'vs_ui_wiki(); Versions Comparison',
		FORUM_WIKI_VIEW => 'vs_ui_wiki();',
		SITE_WIKI_VIEW => '',
		forum_wiki_data => 'Files',
	    ]],
	    [RealmDropDown => [
		forum => 'vs_ui_forum();',
		user => 'User',
	    ]],
	    ['task_menu.title' => [
		SITE_WIKI_VIEW => 'Home',
		__PACKAGE__->if_2014style([
		    FORUM_WIKI_VIEW => q{LinkIcon('FORUM_WIKI_VIEW');vs_ui_wiki();},
		    FORUM_WIKI_EDIT => 'New',
		    FORUM_WIKI_EDIT_PAGE => 'Edit',
		    FORUM_WIKI_VERSIONS_LIST => 'History',
		    FORUM_WIKI_CURRENT => 'Back',
		], [
		    FORUM_WIKI_EDIT => 'Add new page',
		    FORUM_WIKI_EDIT_PAGE => 'Edit this page',
		    FORUM_WIKI_VERSIONS_LIST => 'Page history',
		    FORUM_WIKI_CURRENT => 'Back to current',
		]),
	    ]],
	    [acknowledgement => [
		FORUM_WIKI_EDIT => 'Update accepted.  Please proofread for formatting errors.',
		FORUM_WIKI_NOT_FOUND => 'Wiki page not found.  Please create it.',
	    ]],
	    [prose => [
		help_wiki_add => 'Add Help',
		help_wiki_page => 'Help',
		help_wiki_close => 'Close',
		help_wiki_edit => 'Edit',
		help_wiki_footer => '',
		help_wiki_header => 'Help',
		help_wiki_open => 'Help',
		wiki_view_topic_base => q{Simple(['Action.WikiView', 'title']);},
		wiki_view_topic => q{vs_text_as_prose('wiki_view_topic_base');},
		wiki_view_byline_base => q{If(
		    ['->can_user_execute_task', 'FORUM_WIKI_EDIT'],
		    Join([
		        'edited ',
		        DateTime(['Action.WikiView', 'modified_date_time']),
		        ' by ',
		        MailTo(['Action.WikiView', 'author']),
		    ])
		);},
		wiki_view_byline => q{vs_text_as_prose('wiki_view_byline_base');},
		wiki_view_tools_base => qq{TaskMenu([
                    {
	                task_id => 'FORUM_WIKI_EDIT',
		        path_info => [qw(Action.WikiView name)],
		        label => 'forum_wiki_edit_page',
		        control => [qw(Action.WikiView can_edit)],
		    },
		    'FORUM_WIKI_EDIT',
                    {
	                task_id => 'FORUM_WIKI_VERSIONS_LIST',
		        path_info => [qw(Action.WikiView wiki_args path)],
		    },
		]);},
		wiki_view_tools => q{vs_text_as_prose('wiki_view_tools_base');},
		wiki_diff_topic_base => q{Join([
		        String([qw(Model.RealmFileTextDiffList ->get_selected_name)]),
		        ' (+) compared to ',
		        String([qw(Model.RealmFileTextDiffList ->get_compare_name)]),
		        ' (-)',
		    ]);
                },
		wiki_diff_topic => q{vs_text_as_prose('wiki_diff_topic_base');},
		wiki_diff_tools_base => qq{TaskMenu([
                    {
		        task_id => 'FORUM_WIKI_VIEW',
		        label => 'forum_wiki_current',
    		        path_info => [qw(Model.RealmFileTextDiffList ->get_versionless_name)],
		    },
		]);},
		wiki_diff_tools => q{vs_text_as_prose('wiki_diff_tools_base');},
                xhtml_site_admin_drop_down_standard => q{SiteAdminDropDown();},
		xhtml_dock_left_standard => q{FeatureTaskMenu();},
	    ]],
	    [icon => [
		FORUM_WIKI_VIEW => 'b_icon_file',
	    ]],
#DEPRECATED:
	    [HelpWiki => [
		header => 'Help',
		footer => '',
	    ]],
            ['ActionError.wiki_name' => [
                FORBIDDEN => 'ForbiddenError',
                [qw(MODEL_NOT_FOUND NOT_FOUND)] => 'NotFoundError',
                [qw(default SERVER_ERROR)] => 'ServerError',
            ]],
	],
    };
}

sub _cfg_xapian {
    return {
	Constant => [
	    [ThreePartPage_want_SearchForm => __PACKAGE__->if_2014style(0, 1)],
	],
	Color => [
	    [[qw(search_result_title search_result_excerpt)] => 0],
	    [search_results_background => 0xffffff],
	    [search_result_byline => __PACKAGE__->init_from_prior_group('text_byline')],
	],
	Font => [
	    [search_result_title => [qw(bold)]],
	    [search_result_excerpt => __PACKAGE__->init_from_prior_group('text_excerpt')],
	    [search_result_byline => __PACKAGE__->init_from_prior_group('text_byline')],
	],
	Task => [
	    [SEARCH_LIST => 'pub/search'],
	    [GROUP_SEARCH_LIST => '?/search'],
	    [JOB_XAPIAN_COMMIT => undef],
	    [SEARCH_SUGGEST_LIST_JSON => 'pub/search-suggest-json'],
	    [GROUP_SEARCH_SUGGEST_LIST_JSON => '?/search-suggest-json'],
	],
	Text => [
	    [SearchList => [
		empty_list_prose => 'Your search did not match any documents.',
	    ]],
	    [SearchForm => [
		search => '',
		b_realm_only => 'Only in String([qw(->req auth_realm owner display_name)]);',
		ok_button => 'Search',
	    ]],
	    [title => [
		[qw(SEARCH_LIST GROUP_SEARCH_LIST SEARCH_SUGGEST_LIST_JSON GROUP_SEARCH_SUGGEST_LIST_JSON)] => 'Search Results',
	    ]],
	    [icon => [
		SEARCH => 'b_icon_search',
	    ]],
	],
    };
}

sub _html5_css {
    return {
	CSS => [
	    [b_submit_button => q{
                padding:5px 16px;
                font-size:13px;
                font-weight:600;
                cursor:pointer;
                overflow:visible;
                Color('submit');
            }],
	    [['FormButton.submit', 'Tag.b_button_link'] => {
		'' => q{
	            BorderAttr({
	                border => '1px solid',
		        radius => '3px',
		        color => vs_color('submit'),
	            });
                    ShadowAttr({
                        box => '0 1px 0px #efefef,inset 0 1px 0px #fff',
                        text => '#fff 0 1px 0',
		        gradient => vs_color('submit_background'),
	            });
                    margin: .5em;
                    padding: 0 .5em;
                    text-align: center;
                    CSS('b_submit_button');
                    text-decoration: none;
                },
		hover => q{
	            BorderAttr({
		        color => vs_lighter_color(vs_color('submit'), -0x22),
	            });
                    ShadowAttr({
		        gradient => vs_lighter_color(vs_color('submit_background'), 0x0a),
	            });
                },
		active => q{
	            BorderAttr({
		        color => vs_lighter_color(vs_color('submit'), -0x22),
	            });
                    ShadowAttr({
                        box => '0 1px 0 #fff,inset 0 1px 3px rgba(101,101,101,0.3)',
                    });
                }
	    }],
	    [['FormButton.b_ok_button', 'Tag.b_ok_button_link'] => {
		'' => q{
		    Color('ok_button');
                    ShadowAttr({
                        box => '0 1px 0 #ddd,inset 0 1px 0 rgba(255,255,255,0.2)',
                        text => 'rgba(0,0,0,0.2) 0 1px 0',
		        gradient => vs_color('ok_button_background'),
	            });
                },
		hover => q{
                    ShadowAttr({
		        gradient => vs_lighter_color(vs_color('ok_button_background'), 0x0a),
	            });
                },
	    }],
	    ['StandardSubmit.standard_submit' => q{
                margin: .5em;
                padding: 0 .5em;
                text-align: right;
            }],
	],
    };
}

sub _unsafe_call {
    my($fc, $method) = @_;
    my($self) = $fc->get_facade;
    return $self->can($method) ? $self->$method() : undef;
}

sub _unsafe_realm_id {
    my($fc, $name) = @_;
    my($self) = $fc->get_facade;
    my($n) = _unsafe_call($fc, $name);
    return undef
	unless $n;
    my($req) = $self->req;
    my($res);
    $_D->catch_quietly(sub {
        my($ro) = b_use('Model.RealmOwner')->new($req);
	return $res = $ro->get('realm_id')
	    if $ro->unauth_load({name => $n});
	return;
    });
    return $res
	if $res;
    _trace($n, ': realm not found') if $_TRACE;
    return 0;
}

1;
