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

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="dev"></a>

=head2 dev(int port, hash_ref overrides) : hash_ref

Development environment configuration.

=cut

sub dev {
    my($proto, $port, $overrides) = @_;

    my($pwd) = $^O eq 'MSWin32' ? `cmd /c cd` : `pwd`;
    chomp($pwd);
    my($host) = `hostname`;
    chomp($host);
    return _merge(
	$overrides || {},
	$proto->dev_overrides($pwd, $host),
	{
	    'Bivio::Agent::Request' => {
		can_secure => 0,
	    },
	    'Bivio::UI::FacadeComponent' => {
		die_on_error => 1,
	    },
	    'Bivio::UI::Facade' => {
		local_file_root => "$pwd/files",
		want_local_file_cache => 0,
	    },
	    'Bivio::UI::Text' => {
		http_host => "$host:$port",
		mail_host => $host,
	    },
	    'Bivio::IO::Alert' => {
		want_time => 0,
	    },
	    main => {
		http => {
		    port => $port,
		},
	    },
	},
	$proto->merge_overrides,
	_base(),
    );
}

=for html <a name="dev_overrides"></a>

=head2 static dev_overrides(string pwd, string host) : hash_ref

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
    return _merge($overrides || {}, $proto->merge_overrides, _base());
}

=for html <a name="merge_overrides"></a>

=head2 abstract static merge_overrides(string pwd, string host) : hash_ref

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
		'Bivio::Agent::TaskId' => 'Bivio::Delegate::SimpleTaskId',
		'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::NoCookie',
		'Bivio::Auth::Permission' =>
		    'Bivio::Delegate::SimplePermission',
		'Bivio::UI::FacadeChildType' =>
		    'Bivio::Delegate::SimpleFacadeChildType',
		'Bivio::UI::HTML::FormErrors' =>
		    'Bivio::Delegate::SimpleFormErrors',
		'Bivio::UI::HTML::WidgetFactory' =>
		    'Bivio::Delegate::SimpleWidgetFactory',
		'Bivio::TypeError' => 'Bivio::Delegate::SimpleTypeError',
		'Bivio::Type::RealmName' => 'Bivio::Delegate::SimpleRealmName',
		'Bivio::Auth::Support' => 'Bivio::Delegate::NoDbAuthSupport',
		'Bivio::Type::ECService' => 'Bivio::Delegate::NoECService',
	    },
	    maps => {
		Model => ['Bivio::Biz::Model'],
		Type => ['Bivio::Type'],
		HTMLWidget => ['Bivio::UI::HTML::Widget', 'Bivio::UI::Widget'],
		HTMLFormat => ['Bivio::UI::HTML::Format'],
		MailWidget => ['Bivio::UI::Mail::Widget', 'Bivio::UI::Widget'],
		FacadeComponent => ['Bivio::UI'],
		Action => ['Bivio::Biz::Action'],
		TestHTMLParser => ['Bivio::Test::HTMLParser'],
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
	    key => 'alphabet soup',
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

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
