# Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.
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
    my($proto) = @_;
    return {
	$proto->default_merge_overrides('Bivio/PetShop' => 'pet' => 'bivio Software, Inc.'),
	'Bivio::Biz::Model::MailReceiveDispatchForm' => {
	    ignore_dashes_in_recipient => 1,
	},
	'Bivio::Ext::DBI' => {
	    database => 'pet',
	    user => 'petuser',
	    password => 'petpass',
	    connection => 'Bivio::SQL::Connection::Postgres',
	},
	$proto->merge_class_loader({
	    delegates => {
		'Bivio::Agent::TaskId' => 'Bivio::PetShop::Delegate::TaskId',
		'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::Cookie',
		'Bivio::Auth::RealmType'
                    => 'Bivio::PetShop::Delegate::RealmType',
		'Bivio::Auth::Support' => 'Bivio::Delegate::SimpleAuthSupport',
		'Bivio::Auth::Permission'
		    => 'Bivio::PetShop::Delegate::Permission',
		'Bivio::Auth::Role' => 'Bivio::PetShop::Delegate::Role',
                'Bivio::Type::ECService'
                    => 'Bivio::PetShop::Delegate::ECService',
                'Bivio::Type::Location'
                    => 'Bivio::PetShop::Delegate::Location',
		'Bivio::TypeError' => 'Bivio::PetShop::Delegate::TypeError',
		'Bivio::UI::HTML::FormErrors'
	    	    => 'Bivio::PetShop::Delegate::FormErrors',
	    },
	    maps => {
		Action => ['Bivio::PetShop::Action'],
		Facade => ['Bivio::PetShop::Facade'],
		HTMLWidget => ['Bivio::PetShop::Widget'],
		Model => [qw(Bivio::PetShop::Model Bivio::OTP::Model)],
		ShellUtil => [qw(Bivio::PetShop Bivio::OTP::Util)],
		TestLanguage => ['Bivio::PetShop::Test'],
		Type => [qw(Bivio::PetShop::Type Bivio::OTP::Type)],
		View => [qw(Bivio::PetShop::View Bivio::OTP::View)],
	    },
	}),
	'Bivio::Test::HTMLParser::Forms' => {
	    error_color => '#993300',
	},
	'Bivio::SQL::PropertySupport' => {
	    unused_classes => [],
	},
	'Bivio::UI::Facade' => {
	    default => 'PetShop',
	    http_suffix => 'bivio.biz',
	    mail_host => 'bivio.biz',
	},
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
