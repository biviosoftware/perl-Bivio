# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::IO::File;
use Bivio::Test;
my($tmp) = Bivio::IO::File->pwd . '/Release';
my($home) = Bivio::IO::File->mkdir_p(Bivio::IO::File->rm_rf("$tmp/home"));
Bivio::IO::Config->introduce_values({
    'Bivio::UI::Facade' => {
	# This name shouldn't be "facades" to test that "facades" is renamed
	local_file_root => my $facades_dir = "$tmp/f",
    },
    'Bivio::Util::Release' => {
	rpm_home_dir => $home,
	rpm_http_root => $home,
	tmp_dir => "$tmp/tmp",
	# We start at this level
	cvs_perl_dir => (`cat Release/CVS/Repository`)[0] =~ /^(.*)/,
	projects => [
	    ['R1', 'r', 'Roger, Inc.'],
	],
    },
});
$ENV{PREFIX} = "$tmp/i";
Bivio::Test->new('Bivio::Util::Release')->unit([
    # -noexecute leaves tmp directory around, which helps debugging
    [['-noexecute']] => [
	build_tar => [
	    R1 => sub {
		my($case) = @_;
		my(@f) = <$home/R1-*.tar.gz>;
		Bivio::Die->die(\@f, ': too many or too few')
		    unless @f == 1;
		$case->actual_return([
		    sort(map($_ =~ m{^R1-\d+\.\d+/(.*)}, `tar tzf $f[0]`))]);
		return [sort(split(/\n/, <<'EOF'))];

lib/
lib/R1/
lib/R1/BConf.pm
lib/R1/Util/
lib/R1/Util/Util.pm
facades/
facades/other/
facades/other/view/
facades/other/view/base.bview
facades/r1/
facades/r1/ddl/
facades/r1/ddl/any.sql
tests/
tests/R1/
tests/R1/t/
tests/R1/t/some.t
bin/
bin/r-util
Makefile.PL
EOF
	    },
	],
    ],
    [] => [
	install_tar => [
	    r => sub {
		my($f);
		foreach my $b (qw(plain/i/bivio_power view/login.bview)) {
		    die("$f: missing")
			unless -f ($f = "$facades_dir/petshop/$b");
		}
		return 1;
	    },
	],
    ],
]);
