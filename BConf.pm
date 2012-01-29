# Copyright (c) 2001-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::BConf;
use strict;
use Cwd ();
use File::Basename ();
use Sys::Hostname ();

# C<Bivio::BConf> provides a basic configuration.  You bivio.bconf file
# would look like:
#
#    use Bivio::BConf;
#    Bivio::BConf->merge({});
#
# Set your $BCONF variable to point to this file, e.g. for bash:
#
#    export BCONF=$PWD/bivio.bconf

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CURRENT_VERSION {
    return 10;
}

sub DELEGATE_ROOT_PREFIX {
    return shift(@_) =~ /^(.*)::\w*BConf$/;
}

sub default_merge_overrides {
    my($proto) = shift;
    my($args) = @_;
    unless (ref($args) eq 'HASH') {
	my($root, $prefix, $owner) = @_;
	$args = {
	    version => 0,
	    root => $root,
	    prefix => $prefix,
	    owner => $owner,
	};
    }
    my($uri) = $args->{uri} ||= lc(($args->{root} =~ /(\w+)$/)[0]);
    my($res) = Bivio::IO::Config->merge_list({
	'Bivio::Biz::File' => {
	    root => "/var/db/$uri",
	    backup_root => "/var/bkp/$uri",
	},
	'Bivio::Ext::DBI' => {
	    database => $args->{prefix},
	    user => "$args->{prefix}user",
	    password => "$args->{prefix}pass",
	    connection => 'Bivio::SQL::Connection::Postgres',
	    template1 => {
		database => 'template1',
		user => 'postgres',
		password => 'pgpass',
	    },
	    dbms => {
		user => 'postgres',
		password => 'pgpass',
	    },
	},
	'Bivio::IO::Log' => {
	    directory => "/var/log/bop/$uri",
	},
	'Bivio::Test::Language::HTTP' => {
	    home_page_uri => "http://test.$uri.bivio.biz",
	},
	'Bivio::Test::Util' => {
	    nightly_output_dir => "/home/btest/$uri",
	    nightly_cvs_dir => "perl/$args->{root}",
	},
	'Bivio::UI::Facade' => {
	    default => $args->{root},
	},
	'Bivio::Util::Release' => {
	    projects => [
		[$args->{root}, $args->{prefix}, $args->{owner}],
	    ],
	},
	'Bivio::Delegate::Cookie' => {
	    tag => uc($args->{prefix}),
	},
	'Bivio::IO::Config' => {
	    version => $args->{version},
	},
	'Bivio::IO::Trace' => {
	    config => {
		# This doesn't actually exist, b/c Config is second module
		# to load (after UNIVERSAL) so it can't register (ever).
		# However, --trace=config is rather convenient
		package_filter => '/^Bivio::IO::Config$/',
	    },
	    html_attrs => {
		call_filter => '$sub =~ /vs_html_attrs_render_one/',
		package_filter => '/^Bivio::UI::HTML::ViewShortcuts$/',
	    },
	    perf => {
		call_filter => '$sub =~ /\bperf_time/',
		package_filter => '/^Bivio::Agent::Request$/',
	    },
	    search => {
		package_filter => '/::Search/',
	    },
	    sql => {
		call_filter => '$sub =~ /_trace_sql|_commit_or_rollback/',
		package_filter => '/^Bivio::SQL::Connection$/',
	    },
	    stack => {
		call_filter => '$sub =~ /_print_stack/',
		package_filter => '/^Bivio::Die$/',
	    },
	    bunit_case => {
		call_filter => '$sub =~ /_eval$/',
		package_filter => '/^Bivio::Test$/',
	    },
	    all => {
		package_filter => '/./',
	    },
	},
    }, {
	$args->{version} < 9 ? () : (
	    'Bivio::SQL::PropertySupport' => {
		unused_classes => [],
	    },
	    'Bivio::Test::Language::HTTP' => {
		deprecated_text_patterns => 0,
	    },
	),
    });
    return $args->{version} < 2 ? %$res : $res;
}

sub dev {
    my($proto, $http_port, $overrides) = @_;
    print(STDERR $http_port, ": using odd numbered port not advised, will be 'secure'\n")
	if $http_port % 2;
    my($pwd) = Cwd::getcwd();
    my($host) = Sys::Hostname::hostname();
    my($user) = eval{getpwuid($>)} || $ENV{USER} || 'nobody';
    my($home) = $ENV{HOME} || $pwd;
    my($root, $files_root) = $proto->dev_root;
    return _validate_config(Bivio::IO::Config->merge_list(
	$overrides || {},
	Bivio::IO::Config->bconf_dir_hashes,
	$proto->dev_overrides($pwd, $host, $user, $http_port),
	{
	    'Bivio::Agent::Request' => {
		can_secure => 0,
	    },
	    'Bivio::Biz::File' => {
		root => "$files_root/db",
		backup_root => "$files_root/bkp",
	    },
	    'Bivio::IO::Alert' => {
		want_time => 0,
	    },
	    'Bivio::IO::Config' => {
		is_dev => 1,
	    },
	    'Bivio::IO::Log' => {
		directory => "$files_root/log",
	    },
	    'Bivio::Mail::Common' => {
		sendmail => 'bivio test -input - mock_sendmail',
	    },
	    'Bivio::Test::Language::HTTP' => {
		home_page_uri => "http://$host:$http_port",
		server_startup_timeout => 60,
	    },
	    'Bivio::UI::FacadeComponent' => {
		die_on_error => 1,
	    },
	    'Bivio::UI::Facade' => {
		local_file_root => $files_root,
		want_local_file_cache => 0,
		http_suffix => "$host:$http_port",
		mail_host => $host,
	    },
	    'Bivio::Util::HTTPLog' => {
		email => '',
		error_file => 'stderr.log',
		pager_email => '',
	    },
	    'Bivio::Util::Release' => {
		rpm_home_dir => "$home/tmp/b-release/home",
		rpm_user => $user,
		tmp_dir => "$home/tmp/b-release/build",
	    },
    	    main => {
		http => {
		    port => $http_port,
		},
	    },
     	    'Bivio::Util::HTTPD' => {
		port => $http_port,
	    },
	},
	$proto->merge_overrides($host),
	_base($proto),
    ));
}

sub dev_root {
    my($proto) = @_;
    (my $root = ref($proto) || $proto) =~ s,::,/,g;
    $root = ($INC{"$root.pm"} =~ m{(.+)/.+?.pm})[0];
    my($files_root) = "$root/files";
    mkdir($files_root);
    return ($root, $files_root);
}

sub dev_overrides {
    # Returns any overrides to the development configuration, called by
    # L<dev|"dev">.  Returns an empty hash by default.
    return {};
}

sub merge {
    my($proto, $overrides) = @_;
    # Uses I<overrides> config to override default config defined in this
    # module.
    return Bivio::IO::Config->merge_list(
	$overrides || {},
	$proto->merge_overrides(Sys::Hostname::hostname()),
	_base($proto),
    );
}

sub merge_class_loader {
    my($proto, $overrides) = @_;
    # Merges L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader> config by prefixing
    # I<maps> array refs with values standard values.  Other values overwritten.
    # Returns the array:
    #
    #     'Bivio::IO::ClassLoader' => {
    #         merged configuration,
    #     },
    #
    # Usage in your BConf.pm
    #
    #     ...
    #     $proto->merge_class_loader({
    #         maps => {
    #              Facade => ['OurSite::Facade'],
    #              Model => ['OurSite::Model'],
    #              ...,
    #         },
    #     }),
    #     ...
    $overrides ||= {};
    $overrides->{delegates} = {map(
	($_ => join('::', $proto->DELEGATE_ROOT_PREFIX, 'Delegate', $_ =~ /(\w+)$/)),
	@{$overrides->{delegates}},
    )} if ref($overrides->{delegates}) eq 'ARRAY';
    return (
	'Bivio::IO::ClassLoader' => Bivio::IO::Config->merge(
	    $overrides,
	    {
		delegates => {
		    'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::Cookie',
		    'Bivio::Agent::TaskId' => 'Bivio::Delegate::TaskId',
		    'Bivio::Auth::Permission' => 'Bivio::Delegate::SimplePermission',
		    'Bivio::Auth::RealmType' => 'Bivio::Delegate::RealmType',
		    'Bivio::Auth::Role' => 'Bivio::Delegate::Role',
		    'Bivio::Auth::Support' => 'Bivio::Delegate::SimpleAuthSupport',
		    'Bivio::Type::ECService' => 'Bivio::Delegate::NoECService',
		    'Bivio::Type::FailoverWorkQueueOperation' => 'Bivio::Delegate::FailoverWorkQueueOperation',
		    'Bivio::Type::Location' => 'Bivio::Delegate::SimpleLocation',
		    'Bivio::Type::MotionStatus' => 'Bivio::Delegate::SimpleMotionStatus',
		    'Bivio::Type::MotionType' => 'Bivio::Delegate::SimpleMotionType',
		    'Bivio::Type::MotionVote' => 'Bivio::Delegate::SimpleMotionVote',
		    'Bivio::Type::RealmDAG' => 'Bivio::Delegate::RealmDAG',
		    'Bivio::Type::RealmName' => 'Bivio::Delegate::SimpleRealmName',
		    'Bivio::Type::RowTagKey' => 'Bivio::Delegate::RowTagKey',
		    'Bivio::TypeError' => 'Bivio::Delegate::SimpleTypeError',
		    'Bivio::UI::HTML::WidgetFactory' => 'Bivio::Delegate::SimpleWidgetFactory',
		},
		maps => {
		    Action => ['Bivio::Biz::Action'],
		    Agent => ['Bivio::Agent'],
		    AgentEmbed => ['Bivio::Agent::Embed'],
		    AgentHTTP => ['Bivio::Agent::HTTP'],
		    AgentJob => ['Bivio::Agent::Job'],
		    Auth => ['Bivio::Auth'],
		    Bivio => ['Bivio'],
		    Biz => ['Bivio::Biz'],
		    CSSWidget => ['Bivio::UI::Text::Widget', 'Bivio::UI::Widget'],
		    Cache => ['Bivio::Cache'],
		    ClassWrapper => ['Bivio::ClassWrapper'],
		    Collection => ['Bivio::Collection'],
		    Delegate => ['Bivio::Delegate'],
		    Ext => ['Bivio::Ext'],
		    FacadeComponent => ['Bivio::UI'],
		    GIS => ['Bivio::GIS'],
		    HTML => ['Bivio::HTML'],
		    HTMLFormat => ['Bivio::UI::HTML::Format'],
		    HTMLWidget => ['Bivio::UI::HTML::Widget', 'Bivio::UI::Widget'],
		    IO => ['Bivio::IO'],
		    JavaScriptWidget => ['Bivio::UI::JavaScript::Widget', 'Bivio::UI::Widget'],
		    MIME => ['Bivio::MIME'],
		    Mail => ['Bivio::Mail'],
		    MailWidget => ['Bivio::UI::Mail::Widget', 'Bivio::UI::Text::Widget', 'Bivio::UI::Widget'],
		    MainErrors => ['Bivio::UI::XHTML::Widget::MainErrors'],
		    Model => ['Bivio::Biz::Model'],
		    SQL => ['Bivio::SQL'],
		    Search => ['Bivio::Search'],
		    SearchParser => ['Bivio::Search::Parser'],
		    SearchParserRealmFile => ['Bivio::Search::Parser::RealmFile'],
		    ShellUtil => ['Bivio::Util', 'Bivio::Biz::Util'],
		    Test => ['Bivio::Test'],
		    TestHTMLParser => ['Bivio::Test::HTMLParser'],
		    TestLanguage => ['Bivio::Test::Language'],
		    TestUnit => ['Bivio::Test'],
		    TextWidget => ['Bivio::UI::Text::Widget', 'Bivio::UI::Widget'],
		    Type => ['Bivio::Type', 'Bivio::Auth'],
		    UI => ['Bivio::UI'],
		    UICSS => ['Bivio::UI::CSS'],
		    UIHTML => ['Bivio::UI::HTML'],
		    UIXHTML => ['Bivio::UI::XHTML', 'Bivio::UI::HTML'],
		    Util => ['Bivio::Util', 'Bivio::Biz::Util'],
		    View => ['Bivio::UI::View'],
		    Widget => ['Bivio::UI::Widget'],
		    WikiText => ['Bivio::UI::XHTML::Widget::WikiText'],
		    XHTMLWidget => ['Bivio::UI::XHTML::Widget', 'Bivio::UI::HTML::Widget', 'Bivio::UI::Widget'],
		    XMLWidget => ['Bivio::UI::XML::Widget', 'Bivio::UI::XHTML::Widget', 'Bivio::UI::HTML::Widget', 'Bivio::UI::Text::Widget', 'Bivio::UI::Widget'],
		},
	    },
	    1,
	),
    );
}

sub merge_dir {
    my($proto, $overrides) = @_;
    # Reads the /etc/bconf.d directory for *.bconf files.  Merges in reverse
    # alphabetical order.  I<overrides> take precedence over dir, and dir
    # takes precedence over the rest.
    return Bivio::IO::Config->merge_list(
	$overrides || {},
	Bivio::IO::Config->bconf_dir_hashes,
	$proto->merge_overrides(Sys::Hostname::hostname()),
	_base($proto));
}

sub merge_http_log {
    my($proto, $overrides) = @_;
    # Merges L<Bivio::Util::HTTPLog|Bivio::Util::HTTPLog> config by prefixing
    # standard array refs (ignore, critical, error) with standard valus.  Other
    # values overwritten.  Returns the array:
    #
    #     'Bivio::Util::HTTPLog' => {
    #         merged configuration,
    #     },
    #
    # Usage in your BConf.pm
    #
    #     ...
    #     $proto->merge_http_log({
    #         ignore_list => [
    #         ],
    #     }),
    #     ...
    return (
	'Bivio::Util::HTTPLog' => Bivio::IO::Config->merge(
	    $overrides || {}, {
		ignore_list => [
		    # Standard apache debug and info
		    '\] \[(?:info|debug)\] ',
		    '\[notice\] Apache/\S+ configured -- resuming normal operations',
		    '\[notice\] Accept mutex',
		    'Dispatcher::.* JOB_(?:START|END):',
		    # Virii and such
		    '(?:File does not exist:|DieCode::NOT_FOUND:).*(?:robots.txt|system32|\.asp|_vti|default\.ida|/sumthin|/scripts|/cgi|root.exe|/instmsg|/favicon2|site_root/default.bview|\.php$|Assert not robot)',
		    '::NOT_FOUND:.*view..site_root/(\w+.html|robots.txt).bview',
		    'DAVList:.*::MODEL_NOT_FOUND',
		    'DieCode::MISSING_COOKIES',
		    'client sent HTTP/1.1 request without hostname',
		    'mod_ssl: SSL handshake timed out',
		    'mod_ssl: SSL handshake failed: HTTP spoken on HTTPS port',
		    'mod_ssl: SSL handshake interrupted by system',
		    'Apache2::RequestIO.*Software caused connection abort',	    
		    'request failed: URI too long',
		    'Invalid method in request',
		    'Bivio::UI::Task::.* unknown facade uri',
                    'access to /favicon.ico failed',
		    'Bivio::DieCode::FORBIDDEN',
		    'Invalid URI in request',
		    'Action::RealmFile:.*::MODEL_NOT_FOUND:.*model.*::RealmFile',
		    'MODEL_NOT_FOUND: model.*::RealmOwner.*task=MAIL_RECEIVE_DISPATCH',
		    'Directory index forbidden by rule:',
		    '_update_status.*DECLINED:',
		    'command died with non-zero status entity=>(?:catdoc|catppt|docx2txt|ldat|pdfinfo|pdftotext)',
		],
		error_list => [
		    # Don't add errors that we don't want counts on, e.g.
		    # login_error.  Not ignored, so shows up in email, but
		    # never goes criticial
		    'Bivio::DieCode::DIE.*',
		    'Bivio::DieCode::CONFIG_ERROR.*',
		],
		critical_list => [
		    'Bivio::DieCode::DB_ERROR.*',
		],
		# These errors are not a problem unless they occur "too often"
		# See ignore_unless_count_list
		ignore_unless_count_list => [
		    'Bivio::DieCode::CLIENT_ERROR',
		    'Bivio::DieCode::CORRUPT_QUERY',
		    'Bivio::DieCode::UPDATE_COLLISION',
		    'form_errors=\{',
		    'Bivio::Biz::FormContext::_parse_error',
		    'HTTP::Query::_correct.*correcting query',
		    'request aborted, rolling back',
		    'Unable to parse address',
                    'Connection reset by peer',
		    'reconnecting to database: pid=',
		    'caught SIGTERM, shutting down',
		    'server reached MaxClients setting, consider raising',
		],
	    },
	    1,
	),
    );
}

sub merge_overrides {
    # Returns any overrides to the base configuration, called by
    # L<merge|"merge">.  Returns an empty hash by default.
    return {};
}

sub merge_realm_role_category_map {
    my($proto, $new) = @_;
    return 'Bivio::Biz::Util::RealmRole' => {
	category_map => sub {return [
	    map(
		[
		    $_->as_realm_role_category =>
			['*everybody-' . $_->as_realm_role_category_role_group
			     => [qw(-MAIL_SEND -MAIL_POST)]],
			['*' . $_->as_realm_role_category_role_group
			     => [qw(+MAIL_SEND +MAIL_POST)]],
		],
		Bivio::IO::ClassLoader->map_require('Type.MailSendAccess')
		    ->get_non_zero_list,
	    ),
            map([
		"feature_$_" => ['*everybody' => uc("feature_$_")],
	    ], qw(
		blog
		bulletin
		calendar
		dav
		file
		group_admin
		mail
		task_log
		wiki
	    )),
	    [
		feature_crm =>
		    '+mail_send_access_everybody',
		    ['*everybody' => 'FEATURE_CRM'],
	    ], [
		feature_site_admin =>
		    ['*everybody' => 'FEATURE_SITE_ADMIN'],
		    ['*all_members' => [qw(ADMIN_WRITE ADMIN_READ)]],
	    ], [
		feature_tuple =>
		    ['*everybody' => 'FEATURE_TUPLE'],
		    ['*all_admins' => [qw(TUPLE_ADMIN)]],
		    ['*all_members' => [qw(TUPLE_WRITE)]],
		    ['*all_guests' => [qw(TUPLE_READ)]],
	    ], [
#DEPRECATED: Need to fix apps which use this, and use feature_tuple instead
		tuple =>
		    '+feature_tuple',
	    ], [
		common_results_motion =>
		    ['*everybody' => 'FEATURE_MOTION'],
		    ['*all_members' => 'MOTION_WRITE'],
		    ['*all_admins' => [qw(MOTION_ADMIN MOTION_READ)]],
	    ], [
		open_results_motion =>
		    '+common_results_motion',
		    ['*all_guests-all_admins' => '+MOTION_READ'],
	    ], [
		closed_results_motion =>
		    '+common_results_motion',
		    ['*all_guests-all_admins' => '-MOTION_READ'],
	    ], [
		feature_motion =>
		    '+open_results_motion',
	    ],
	    $new ? @{$new->()} : (),
        ]},
    };
}

sub _base {
    my($proto) = @_;
    # Returns _base configuration.
    return {
	$proto->merge_realm_role_category_map(),
	'Bivio::Die' => {
	    stack_trace_error => 1,
	},
	'Bivio::Ext::DBI' => {
	    database => 'none',
	    user => 'none',
	    password => 'none',
	    connection => 'Bivio::SQL::Connection::None',
	},
	'Bivio::IO::Alert' => {
	    intercept_warn => 1,
	    stack_trace_warn => 1,
	    want_pid => 0,
	    want_stderr => 1,
	    want_time => 1,
	},
	'Bivio::Type::Secret' => {
	    key => 'alphabet',
	},
	'Bivio::UI::Facade' => {
	    local_file_root => '/var/www/facades',
	    http_suffix => 'localhost.localdomain',
	    mail_host => 'localhost.localdomain',
	},
	'Bivio::Util::Release' => {
	    rpm_home_dir => '/usr/src/redhat/RPMS/noarch',
	    projects => [
		[ProjEx => project => 'bivio Software, Inc.'],
	    ],
	    rpm_user => 'nobody',
	},
	'Bivio::ShellUtil' => {
	    vacuum_db_continuously => {
		daemon_max_children => 1,
		daemon_sleep_after_start => 15 * 60,
		daemon_log_file => 'vacuumdb.log',
	    },
	},
	$proto->merge_http_log({
	    # These are defaults, which may be overriden for testing,
	    # which is why they are here
	    email => 'root',
	    pager_email => 'root',
	    error_count_for_page => 3,
	    ignore_unless_count => 3,
	}),
	main => {
	    http => {
		port => '80',
	    },
	},
    };
}

sub _validate_config {
    my($config) = @_;
    # Ensures the configuration is consistent. For example, NoDbAuthSupport
    # should not be present if if Bivio::Ext::DBI is defined.
    # Issues warnings only for dev() configuration.
    warn('WARNING: NoDbAuthSupport used with Bivio::Ext::DBI')
	if ($config->{'Bivio::IO::ClassLoader'}
	    ->{delegates}->{'Bivio::Auth::Support'}
	    eq 'Bivio::Delegate::NoDbAuthSupport')
	    && ($config->{'Bivio::Ext::DBI'}->{database} ne 'none');
    return $config;
}

1;
