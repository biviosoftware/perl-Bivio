# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::BConf;
use strict;
$Bivio::BConf::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::BConf::VERSION;

=head1 NAME

Bivio::BConf - simple default configuration

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::BConf;

=cut

use Bivio::UNIVERSAL;
@Bivio::BConf::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::BConf> provides a basic configuration.  You bivio.bconf file
would look like:

   use Bivio::BConf;
   Bivio::BConf->merge({});

Set your $BCONF variable to point to this file, e.g. for bash:

   export BCONF=$PWD/bivio.bconf

=cut

#=IMPORTS
use Bivio::IO::Config;
use Cwd ();
use Sys::Hostname ();

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="dev"></a>

=head2 dev(int http_port, hash_ref overrides) : hash_ref

Development environment configuration.

=cut

sub dev {
    my($proto, $http_port, $overrides) = @_;

    my($pwd) = Cwd::getcwd();
#TODO: local_file_root is wrong.  Base on $INC{ref($proto)}
    my($host) = Sys::Hostname::hostname();
    my($user) = eval{getpwuid($>)} || $ENV{USER} || 'nobody';
    return _validate_config(_merge(
	$overrides || {},
	$proto->dev_overrides($pwd, $host, $user, $http_port),
	{
	    'Bivio::Agent::Request' => {
		can_secure => 0,
	    },
	    'Bivio::IO::Alert' => {
		want_time => 0,
	    },
	    'Bivio::Test::Language::HTTP' => {
		home_page_uri => "http://$host:$http_port",
	    },
	    'Bivio::UI::FacadeComponent' => {
		die_on_error => 1,
	    },
	    'Bivio::UI::Facade' => {
		local_file_root => "$pwd/files",
		want_local_file_cache => 0,
	    },
	    'Bivio::UI::Text' => {
		http_host => "$host:$http_port",
		mail_host => $host,
	    },
	    main => {
		http => {
		    port => $http_port,
		},
	    },
	},
	$proto->merge_overrides($host),
	_base(),
    ));
}

=for html <a name="dev_overrides"></a>

=head2 static dev_overrides(string pwd, string host, string user, int http_port) : hash_ref

Returns any overrides to the development configuration, called by
L<dev|"dev">.  Returns an empty hash by default.

=cut

sub dev_overrides {
    return {};
}

=for html <a name="merge"></a>

=head2 merge(hash_ref overrides) : hash_ref

Uses I<overrides> config to override default config defined in this
module.

=cut

sub merge {
    my($proto, $overrides) = @_;
    return _merge($overrides || {},
	$proto->merge_overrides(Sys::Hostname::hostname()), _base());
}

=for html <a name="merge_dir"></a>

=head2 static merge_dir(hash_ref overrides) : hash_ref

Reads the /etc/bconf.d directory for *.bconf files.  Merges in reverse
alphabetical order.  I<overrides> take precedence over dir, and dir
takes precedence over the rest.

=cut

sub merge_dir {
    my($proto, $overrides) = @_;
    return _merge(
	$overrides || {},
	(
	    map {
		my($file) = $_;
		my($data) = do($file) || die($@);
		die($file, ': did not return a hash_ref')
		    unless ref($data) eq 'HASH';
		$data;
	    } sort(</etc/bconf.d/*.bconf>),
	),
	$proto->merge_overrides(Sys::Hostname::hostname()),
	_base());
}

=for html <a name="merge_overrides"></a>

=head2 abstract static merge_overrides(string host) : hash_ref

Returns any overrides to the base configuration, called by
L<merge|"merge">.  Returns an empty hash by default.

=cut

sub merge_overrides {
    return {};
}

#=PRIVATE METHODS

# _base() : hash_ref
#
# Returns _base configuration.
#
sub _base {
    return {
	'Bivio::IO::ClassLoader' => {
	    delegates => {
		'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::NoCookie',
		'Bivio::Agent::TaskId' => 'Bivio::Delegate::SimpleTaskId',
		'Bivio::Auth::Permission' => 'Bivio::Delegate::SimplePermission',
		'Bivio::Auth::Support' => 'Bivio::Delegate::NoDbAuthSupport',
		'Bivio::Type::ECService' => 'Bivio::Delegate::NoECService',
		'Bivio::Type::Location' => 'Bivio::Delegate::SimpleLocation',
		'Bivio::Type::RealmName' => 'Bivio::Delegate::SimpleRealmName',
		'Bivio::TypeError' => 'Bivio::Delegate::SimpleTypeError',
		'Bivio::UI::FacadeChildType' => 'Bivio::Delegate::SimpleFacadeChildType',
		'Bivio::UI::HTML::FormErrors' => 'Bivio::Delegate::SimpleFormErrors',
		'Bivio::UI::HTML::WidgetFactory' => 'Bivio::Delegate::SimpleWidgetFactory',
	    },
	    maps => {
		Action => ['Bivio::Biz::Action'],
		FacadeComponent => ['Bivio::UI'],
		HTMLFormat => ['Bivio::UI::HTML::Format'],
		HTMLWidget => ['Bivio::UI::HTML::Widget', 'Bivio::UI::Widget'],
		MailWidget => ['Bivio::UI::Mail::Widget', 'Bivio::UI::Widget'],
		Model => ['Bivio::Biz::Model'],
		TestHTMLParser => ['Bivio::Test::HTMLParser'],
		Type => ['Bivio::Type'],
	    },
	},
	'Bivio::Die' => {
	    stack_trace_error => 1,
	},
	'Bivio::Ext::DBI' => {
	    database => 'none',
	    user => 'none',
	    password => 'none',
	    connection => 'Bivio::SQL::Connection::Postgres',
	},
	'Bivio::IO::Alert' => {
	    intercept_warn => 1,
	    stack_trace_warn => 1,
	    want_pid => 0,
	    want_stderr => 1,
	    want_time => 1,
	},
	'Bivio::IO::Trace' => {
	},
	'Bivio::Type::Secret' => {
	    key => 'alphabet',
	},
	'Bivio::UI::Text' => {
	    http_host => 'localhost',
	    mail_host => 'localhost',
	},
	main => {
	    http => {
		port => '80',
	    },
	},
    };
}

# _merge(hash_ref cfgN, ...) : hash_ref
#
# Merges configuration hashes with $cfgN being last override.
#
sub _merge {
    my(@cfg) = @_;
    my($res) = {};
    foreach my $c (reverse(@cfg)) {
	$res = Bivio::IO::Config->merge($c, $res);
    }
    return $res;
}

# _validate_config(hash_ref config) : hash_ref
#
# Ensures the configuration is consistent. For example, NoDbAuthSupport
# should not be present if if Bivio::Ext::DBI is defined.
# Issues warnings only for dev() configuration.
#
sub _validate_config {
    my($config) = @_;
    warn('WARNING: NoDbAuthSupport used with Bivio::Ext::DBI')
	if ($config->{'Bivio::IO::ClassLoader'}
	    ->{delegates}->{'Bivio::Auth::Support'}
	    eq 'Bivio::Delegate::NoDbAuthSupport')
	    && ($config->{'Bivio::Ext::DBI'}->{database} ne 'none');
    return $config;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
