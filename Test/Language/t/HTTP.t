# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    maps => {
		TestLanguage => ['Bivio::Test::Language'],
	    },
	},
	'Bivio::Test::Language::HTTP' => {
	    home_page_uri => 'http://petshop.bivio.biz',
	},
    });
}
use Bivio::Test;
use Bivio::Test::Language;

Bivio::Test->unit([
    'Bivio::Test::Language' => [
	{
	    method => 'test_run',
	    compute_params => sub {
		my($object, $method, $params) = @_;
		return [\$params->[0]],
	    },
	} => [
	    [<<'EOF'] => [undef],
test_setup('HTTP');
home_page();
goto_link('Sign-in');
goto_link('New User');
my($id) = "test_http_$$";
submit_form(submit => {
    'User ID:' => $id,
    'Password:' => 'password',
    'E-Mail Address:' => "ignore-$id\@bivio.biz",
    'First Name:' => 'HTTP',
    'Last Name:' => 'UnitTest',
    'Street Address:' => '1313 Mockingbird Lane',
    'City:' => 'Gotham',
    'State/Province:' => 'CO',
    'Postal Code:' => '80000',
    'Country:' => 'US',
    'Telephone Number:' => '555-1212',
});
home_page();
goto_link('MyAccount');
EOF
	],
    ],
]);
