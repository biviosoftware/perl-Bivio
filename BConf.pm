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
my($_DEFAULT_CONFIG) = {
    'Bivio::IO::ClassLoader' => {
	delegates => {
	    'Bivio::Agent::TaskId' => 'Bivio::Delegate::SimpleTaskId',
	    'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::NoCookie',
	    'Bivio::Auth::Permission' => 'Bivio::Delegate::SimplePermission',
	    'Bivio::UI::FacadeChildType' =>
	            'Bivio::Delegate::SimpleFacadeChildType',
	    'Bivio::UI::HTML::FormErrors' =>
	            'Bivio::Delegate::SimpleFormErrors',
	    'Bivio::UI::HTML::WidgetFactory' =>
	    	    'Bivio::Delegate::SimpleWidgetFactory',
	    'Bivio::TypeError' => 'Bivio::Delegate::SimpleTypeError',
	    'Bivio::Type::RealmName' => 'Bivio::Delegate::SimpleRealmName',
	    'Bivio::Auth::Support' => 'Bivio::Delegate::NoDbAuthSupport',
	},
	maps => {
	    Model => ['Bivio::Biz::Model'],
	    Type => ['Bivio::Type'],
	    HTMLWidget => ['Bivio::UI::HTML::Widget', 'Bivio::UI::Widget'],
	    HTMLFormat => ['Bivio::UI::HTML::Format'],
	    MailWidget => ['Bivio::UI::Mail::Widget', 'Bivio::UI::Widget'],
	    FacadeComponent => ['Bivio::UI'],
	    Action => ['Bivio::Biz::Action'],
	},
    },
    'Bivio::Die' => {
	stack_trace_error => 1,
    },
    'Bivio::Ext::DBI' => {
	oracle_home => '/usr/local/oracle/product/8.1.6',
	database => 'none',
	user => 'none',
	password => 'none',
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

=head1 METHODS

=cut

=for html <a name="dev"></a>

=head2 dev(int port, hash_ref overrides) : hash_ref

Development environment configuration.

=cut

sub dev {
    my($proto, $port, $overrides) = @_;

    my($pwd) = `pwd`;
    chomp($pwd);
    my($host) = `hostname`;
    chomp($host);
    return Bivio::IO::Config->merge($overrides || {},
	    $proto->merge({
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
	    }));
}

=for html <a name="merge"></a>

=head2 merge(hash_ref custom) : hash_ref

Uses I<custom> config to override default config defined in this
module.

=cut

sub merge {
    my($proto, $config) = @_;

    # make a copy of the default, then add the supplied config recursively
    return Bivio::IO::Config->merge($config, $_DEFAULT_CONFIG);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
