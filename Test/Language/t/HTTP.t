# Copyright (c) 2002-2004 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
my($mail_dir);
BEGIN {
    use Bivio::IO::Config;
    use Cwd ();
    Bivio::IO::Config->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    maps => {
		TestLanguage => ['Bivio::Test::Language'],
	    },
	},
	'Bivio::Test::Language::HTTP' => {
 	    home_page_uri => 'http://petshop.bivio.biz',
	    email_user => 'hello',
	    mail_dir => ($mail_dir = Cwd::getcwd() . '/tmp'),
	    mail_tries => 1,
	},
    });
}
use Bivio::IO::File;
use Bivio::Test;
use Bivio::Test::Language;
Bivio::IO::File->mkdir_p(
    Bivio::IO::File->rm_rf($mail_dir));
my($mail_file) = Bivio::IO::File->write("$mail_dir/1", 'should be deleted');
Bivio::Test->unit([
    'Bivio::Test::Language' => [
	{
	    method => 'test_run',
	    compute_params => sub {
		my(undef, $params) = @_;
		return [\$params->[0]],
	    },
	} => [
	    [<<"EOF"] => [undef],
test_setup('HTTP');
home_page();
follow_link('Sign-in');
test_deviance('You must supply a value');
submit_form('submit');
submit_form('submit' => {
    'Email:' => 'foobar',
});
EOF
	    [<<"EOF"] => [undef],
test_setup('HTTP');
use Bivio::IO::File;
Bivio::Die->die(q{$mail_file: should not exist})
    if -e q{$mail_file};
my(\$e1) = generate_local_email();
test_deviance(qr/No mail for /);
verify_local_mail(\$e1, '');
test_conformance();
my(\$i) = 1;
my(\$m) = sub {
   my(\$x) = \$_[0] || \$e1;
Bivio::IO::File->write(q{$mail_file} . \$i++, <<"END");
From: someone\\\@example.com
To: \$x

You have mail
END
};
\$m->();
my(\$mail) = verify_local_mail(\$e1, 'You have mail');
\$mail =~ /^From: someone\\\@example.com[\\s\\S]*You have mail\n\$/
    or die('bad return value from verify_local_mail()');
test_deviance(qr/No mail for /);
verify_local_mail(\$e1, 'You have mail');
test_conformance();
my(\$e2) = generate_local_email('.*');
\$m->();
test_deviance(qr/No mail for /);
verify_local_mail(\$e2, '');
test_deviance(qr/Found mail for .* but does not match /);
verify_local_mail(\$e1, 'this should not match');
test_conformance();
\$m->(\$e2);
verify_local_mail(\$e2, 'You have mail');
test_deviance(qr/No mail for /);
verify_local_mail(\$e2, 'You have mail');
test_conformance();
verify_local_mail(\$e1, 'You have mail');
\$m->();
\$m->();
test_deviance(qr/wrong number of messages matched/);
verify_local_mail(\$e1, 'You have mail');
test_conformance();
foreach my \$m (verify_local_mail(\$e1, 'You have mail', 2)) {
    \$m =~ /^From: someone\\\@example.com[\\s\\S]*You have mail\n\$/
        or Bivio::Die->die(\$m, ': bad return value from verify_local_mail()');
}

EOF
	    [<<'EOF'] => [undef],
test_setup('HTTP');
home_page();
follow_link('Sign-in');
go_back();
verify_text(qr/View\.main/);
test_deviance(qr/no page to go back to/);
go_back();
test_conformance();
home_page();
follow_link('Sign-in');
follow_link('New User');
my($id) = "test_http_$$";
submit_form(submit => {
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
follow_link('MyAccount');
submit_form(search => {
});
submit_form(qr/\bsearch\b/ => {
    _anon => 'dogs',
});
verify_text('Adult Female German Shepherd');
submit_form(search => {
    qr/_ano/ => 'dogs',
});
verify_text('Adult Female German Shepherd');
follow_link_in_table('Item ID', 'Item Name', 'Male Adult Corgi');
verify_text('Friendly dog from Wales');
debug_print('Forms');
EOF
	],
    ],
]);
