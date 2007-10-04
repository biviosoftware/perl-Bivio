# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
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
    # Configure L<Bivio::Test::Util|Bivio::Test::Util>.
    # Grab last part: Only needed by PetShop
    my($root_lc) = lc(($args->{root} =~ /(\w+)$/)[0]);
    (my $file_root = "/var/db/$root_lc") =~ s/_/-/g;
    my($res) = {
	'Bivio::Biz::File' => {
	    root => $file_root,
	},
	'Bivio::Ext::DBI' => {
	    database => $args->{prefix},
	    user => "$args->{prefix}user",
	    password => "$args->{prefix}pass",
	    connection => 'Bivio::SQL::Connection::Postgres',
	},
	'Bivio::Test::HTMLParser::Forms' => {
	    error_color => '#993300',
	},
	'Bivio::Test::Language::HTTP' => {
	    home_page_uri => "http://test.$root_lc.bivio.biz",
	},
	'Bivio::Test::Util' => {
	    nightly_output_dir => "/home/btest/$root_lc",
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
	$args->{version} < 1 ? () : (
	    'Bivio::UI::HTML::Widget::AmountCell' => {
		column_align => 0,
		column_nowrap => 0,
		pad_left => 0,
		string_font => 0,
		want_parens => 0,
		zero_as_blank => 0,
	    },
	),
	$args->{version} < 2 ? () : (
	    'Bivio::IO::Log' => {
		directory => '/var/log/bop',
	    },
	),
    };
    return $args->{version} < 2 ? %$res : $res;
}

sub dev {
    my($proto, $http_port, $overrides) = @_;
    # Development environment configuration. Will read bconf.d config in bconf.d
    # subdir of where your *.bconf resides.

    my($pwd) = Cwd::getcwd();
    my($host) = Sys::Hostname::hostname();
    my($user) = eval{getpwuid($>)} || $ENV{USER} || 'nobody';
    my($home) = $ENV{HOME} || $pwd;
    (my $root = ref($proto) || $proto) =~ s,::,/,g;
    $root = ($INC{"$root.pm"} =~ m{(.+)/.+?.pm})[0];
    my($file_root) = "$root/files/db";
    mkdir($file_root);
    return _validate_config(Bivio::IO::Config->merge_list(
	$overrides || {},
	Bivio::IO::Config->bconf_dir_hashes,
	$proto->dev_overrides($pwd, $host, $user, $http_port),
	{
	    'Bivio::Agent::Request' => {
		can_secure => 0,
	    },
	    'Bivio::Biz::File' => {
		root => $file_root,
	    },
	    'Bivio::IO::Alert' => {
		want_time => 0,
	    },
	    'Bivio::IO::Log' => {
		directory => $file_root,
	    },
	    'Bivio::Mail::Common' => {
		sendmail => 'b-test -input - mock_sendmail',
	    },
	    'Bivio::Test::Language::HTTP' => {
		home_page_uri => "http://$host:$http_port",
		server_startup_timeout => 60,
	    },
	    'Bivio::UI::FacadeComponent' => {
		die_on_error => 1,
	    },
	    'Bivio::UI::Facade' => {
		local_file_root => "$root/files",
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
    return (
	'Bivio::IO::ClassLoader' => Bivio::IO::Config->merge(
	    $overrides || {}, {
		maps => {
		    Action => ['Bivio::Biz::Action'],
		    Ext => ['Bivio::Ext'],
		    FacadeComponent => ['Bivio::UI'],
		    HTMLFormat => ['Bivio::UI::HTML::Format'],
		    IO => ['Bivio::IO'],
		    Model => ['Bivio::Biz::Model'],
		    map(
			("${_}Widget" => [
			    $_ && $_ ne 'CSS' ? "Bivio::UI::${_}::Widget" : (),
			    $_ eq 'XHTML' ? 'Bivio::UI::HTML::Widget' : (),
			    $_ eq 'Mail' ? 'Bivio::UI::Text::Widget' : (),
			    $_ eq 'CSS' ? 'Bivio::UI::Text::Widget' : (),
			    'Bivio::UI::Widget',
			]),
			'', qw(CSS HTML XHTML Mail Text)),
		    ShellUtil => ['Bivio::Util', 'Bivio::Biz::Util'],
		    TestHTMLParser => ['Bivio::Test::HTMLParser'],
		    TestLanguage => ['Bivio::Test::Language'],
		    TestUnit => ['Bivio::Test'],
		    Type => ['Bivio::Type', 'Bivio::Auth'],
		    View => ['Bivio::UI::View'],
		    WikiText => ['Bivio::UI::XHTML::Widget::WikiText'],
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
		    'Dispatcher::execute_queue:.*JOB_(?:START|END):',
		    # Virii and such
		    '(?:File does not exist:|DieCode::NOT_FOUND:).*(?:robots.txt|system32|\.asp|_vti|default\.ida|/sumthin|/scripts|/cgi|root.exe|/instmsg|/favicon2|site_root/default.bview|\.php$)',
		    '::NOT_FOUND:.*view..site_root/(\w+.html|robots.txt).bview',
		    'DAVList:.*::MODEL_NOT_FOUND',
		    'DieCode::MISSING_COOKIES',
		    'client sent HTTP/1.1 request without hostname',
		    'mod_ssl: SSL handshake timed out',
		    'mod_ssl: SSL handshake failed: HTTP spoken on HTTPS port',
		    'mod_ssl: SSL handshake interrupted by system',
		    'request failed: URI too long',
		    'Invalid method in request',
		    'Facade::setup_request:.*: unknown facade uri',
                    'access to /favicon.ico failed',
		    'Bivio::DieCode::FORBIDDEN',
		    'Invalid URI in request',
		    'Action::RealmFile:.*::MODEL_NOT_FOUND:.*model.*::RealmFile',
		    'MODEL_NOT_FOUND: model.*::RealmOwner.*task=MAIL_RECEIVE_DISPATCH',
		    'Directory index forbidden by rule:',
		],
		error_list => [
		    # Don't add errors that we don't want counts on, e.g.
		    # login_error.  Not ignored, so shows up in email, but
		    # never goes criticial
		    'Bivio::DieCode::DIE',
		    'Bivio::DieCode::CONFIG_ERROR',
		    '\] \[notice\] ',
		],
		critical_list => [
		    'Bivio::DieCode::DB_ERROR',
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
    # Calls $new and basic category map.
    return 'Bivio::Biz::Util::RealmRole' => {
	category_map => sub {
	    return [
	    [
		public_forum_email =>
		    [[qw(ANONYMOUS USER WITHDRAWN GUEST)] => 'MAIL_SEND'],
	    ],
	    [
		system_user_forum_email =>
		    [ANONYMOUS => '-MAIL_SEND'],
		    [USER => 'MAIL_SEND'],
	    ],
	    [
		admin_only_forum_email =>
		    [MEMBER => [qw(-MAIL_POST -MAIL_READ -MAIL_SEND -MAIL_WRITE)]],
	    ],
	    Bivio::Agent::TaskId->is_component_included('tuple') ? ([
		tuple =>
		    [ADMINISTRATOR => [qw(TUPLE_ADMIN TUPLE_WRITE TUPLE_READ)]],
		    [MEMBER => [qw(TUPLE_WRITE TUPLE_READ)]],
	    ]) : (),
	    Bivio::Agent::TaskId->is_component_included('motion') ? ([
		closed_results_motion =>
		    [MEMBER => [qw(MOTION_WRITE -MOTION_READ)]],
		    [ADMINISTRATOR => [qw(MOTION_ADMIN MOTION_WRITE MOTION_READ)]],
	    ], [
		open_results_motion =>
		    [MEMBER => [qw(MOTION_WRITE MOTION_READ)]],
		    [ADMINISTRATOR => [qw(MOTION_ADMIN MOTION_WRITE MOTION_READ)]],
	    ]) : (),
	    $new ? @{$new->()} : (),
        ];
    }};
}

sub _base {
    my($proto) = @_;
    # Returns _base configuration.
    return {
	$proto->merge_class_loader({
	    delegates => {
		'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::NoCookie',
		'Bivio::Agent::TaskId' => 'Bivio::Delegate::SimpleTaskId',
		'Bivio::Auth::Permission' =>
		    'Bivio::Delegate::SimplePermission',
		'Bivio::Auth::RealmType' => 'Bivio::Delegate::RealmType',
		'Bivio::Auth::Role' => 'Bivio::Delegate::Role',
		'Bivio::Auth::Support' => 'Bivio::Delegate::NoDbAuthSupport',
		'Bivio::Type::ECService' => 'Bivio::Delegate::NoECService',
		'Bivio::Type::Location' => 'Bivio::Delegate::SimpleLocation',
		'Bivio::Type::RealmName' => 'Bivio::Delegate::SimpleRealmName',
		'Bivio::TypeError' => 'Bivio::Delegate::SimpleTypeError',
		'Bivio::UI::FacadeChildType' =>
		    'Bivio::Delegate::SimpleFacadeChildType',
		'Bivio::UI::HTML::FormErrors' =>
		    'Bivio::Delegate::SimpleFormErrors',
		'Bivio::UI::HTML::WidgetFactory' =>
		    'Bivio::Delegate::SimpleWidgetFactory',
		'Bivio::Type::MotionVote' =>
		    'Bivio::Delegate::SimpleMotionVote',
		'Bivio::Type::MotionStatus' =>
		    'Bivio::Delegate::SimpleMotionStatus',
		'Bivio::Type::MotionType' =>
		    'Bivio::Delegate::NoMotionType',
	    },
	}),
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
	'Bivio::IO::Log' => {
	    directory => '/var/log',
	},
	'Bivio::Type::Secret' => {
	    key => 'alphabet',
	},
	'Bivio::UI::Facade' => {
	    local_file_root => '/var/www/facades',
	    http_suffix => 'localhost',
	    mail_host => 'localhost',
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
