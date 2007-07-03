# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
use Test::MockObject;
Test::MockObject->fake_module(
    'Bivio::UI::ViewLanguage',
    eval => sub {
	my(undef, $code) = @_;
	Bivio::Die->die($code, ': unexpected eval call')
            unless $$code =~ /^vs_\w+\(.*\);$/s;
	return Bivio::Die->eval_or_die(<<"EOF");
            use strict;
	    use Bivio::UI::HTML::ViewShortcuts;
            Bivio::UI::HTML::ViewShortcuts->$$code
EOF
    },
    AUTOLOAD => sub {
	shift(@_);
	return Bivio::IO::ClassLoader->map_require('HTMLWidget', 'Prose')
	    ->new(@_)
	    if ($Bivio::UI::ViewLanguage::AUTOLOAD || '') eq 'Prose';
	Bivio::Die->die($Bivio::UI::ViewLanguage::AUTOLOAD, \@_,
	    ': unexpected AUTOLOAD call');
    },
);
my($req) = Bivio::Test::Request->setup_facade;
Bivio::Test->new('Bivio::UI::FormError')->unit([
    sub {
	$req->get_nested('Bivio::UI::Facade', 'FormError');
    } => [
	to_html => [
	    [
		$req,
		Bivio::Biz::Model->new($req, 'UserLoginForm'),
		'RealmOwner.password',
		'Password',
		Bivio::TypeError->NULL,
	    ] => qr/Please enter a password/,
	    [
		$req,
		Bivio::Biz::Model->new($req, 'UserLoginForm'),
		'no_such_field',
		'No Such Field',
		Bivio::TypeError->NULL,
	    ] => 'You must supply a value for No Such Field.',
	    [
		$req,
		Bivio::Biz::Model->new($req, 'UserCreateForm'),
		'no_such_field',
		'No Such Field',
		Bivio::TypeError->NULL,
	    ] => Bivio::TypeError->NULL->get_long_desc,
	],
    ],
]);
