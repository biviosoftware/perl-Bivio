# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::BConf;
use strict;
$Bivio::PetShop::BConf::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::BConf::VERSION;

=head1 NAME

Bivio::PetShop::BConf - default petshop.bivio.biz configuration

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::BConf;

=cut

=head1 EXTENDS

L<Bivio::BConf>

=cut

use Bivio::BConf;
@Bivio::PetShop::BConf::ISA = ('Bivio::BConf');

=head1 DESCRIPTION

C<Bivio::PetShop::BConf> default petshop.bivio.biz configuration.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="dev_overrides"></a>

=head2 dev_overrides(string pwd, string host, string user, int http_port) : hash_ref

Development environment configuration.

=cut

sub dev_overrides {
    my($proto, $pwd, $host) = @_;
    return {
	'Bivio::UI::HTML::Widget::SourceCode' => {
	    source_dir => "$pwd/src",
	},
    };
}

=for html <a name="merge_overrides"></a>

=head2 merge_overrides(string host) : hash_ref

Base configuration.

=cut

sub merge_overrides {
    return {
	'Bivio::Ext::DBI' => {
	    database => 'petdb',
	    user => 'petuser',
	    password => 'petpass',
	    connection => 'Bivio::SQL::Connection::Postgres',
	},
	'Bivio::IO::ClassLoader' => {
	    delegates => {
		'Bivio::Agent::TaskId' => 'Bivio::PetShop::Agent::TaskId',
		'Bivio::Agent::HTTP::Cookie' =>
		    'Bivio::Delegate::PersistentCookie',
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
		TestLanguage => ['Bivio::PetShop::Test'],
	    },
	},
	'Bivio::Test::Language::HTTP' => {
	    home_page_uri => 'http://petshop.bivio.biz',
	},
	'Bivio::UI::Facade' => {
	    default => 'PetShop',
	},
	'Bivio::UI::Text' => {
	    http_host => 'petshop.bivio.biz',
	    mail_host => 'bivio.biz',
	},
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
