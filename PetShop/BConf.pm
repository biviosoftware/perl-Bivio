# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::BConf;
use strict;
$Bivio::PetShop::BConf::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::BConf::VERSION;

=head1 NAME

Bivio::PetShop::BConf - default petshop.bivio.net configuration

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::BConf;

=cut

use Bivio::UNIVERSAL;
@Bivio::PetShop::BConf::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::PetShop::BConf> default petshop.bivio.net configuration.

=cut

#=IMPORTS
use Bivio::BConf;

#=VARIABLES
my($_DEFAULT_CONFIG) = Bivio::BConf->merge({
    'Bivio::IO::ClassLoader' => {
	delegates => {
	    'Bivio::Agent::TaskId' => 'Bivio::PetShop::Agent::TaskId',
	    'Bivio::Agent::HTTP::Cookie' => 'Bivio::PetShop::Agent::Cookie',
	    'Bivio::UI::HTML::FormErrors' =>
	    	'Bivio::PetShop::UI::FormErrors',
	    'Bivio::TypeError' => 'Bivio::PetShop::TypeError',
	    'Bivio::Auth::Support' => 'Bivio::Delegate::SimpleAuthSupport',
	},
	maps => {
	    Model => ['Bivio::PetShop::Model', 'Bivio::Biz::Model'],
	    Type => [ 'Bivio::PetShop::Type', 'Bivio::Type'],
	    HTMLWidget => ['Bivio::PetShop::Widget',
		'Bivio::UI::HTML::Widget', 'Bivio::UI::Widget'],
	    Facade => ['Bivio::PetShop::Facade'],
	    Action => ['Bivio::PetShop::Action', 'Bivio::Biz::Action'],
	},
    },
    'Bivio::UI::Facade' => {
        default => 'PetShop',
	local_file_root => '/home/httpd/files',
    },
    'Bivio::UI::Text' => {
	http_host => 'petshop.bivio.net',
	mail_host => 'bivio.net',
    },
    'Bivio::UI::HTML::Widget::SourceCode' => {
	source_dir => '/home/httpd/files/src',
    },
});

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
    # Make sure petshop symlink exists (local_file_prefix is petshop)
    symlink('.', 'files/petshop') unless -l 'files/petshop';
    my($host) = `hostname`;
    chomp($host);
    return Bivio::IO::Config->merge($overrides || {},
	    $proto->merge({
		'Bivio::Agent::Request' => {
		    can_secure => 0,
		},
		'Bivio::PetShop::Cookie' => {
		    domain => $host,
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
