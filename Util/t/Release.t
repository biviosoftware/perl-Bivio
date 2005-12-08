# Copyright (c) 2002-2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
BEGIN {
    use Cwd ();
    $ENV{BCONF} = Cwd::getcwd() . '/Release/t.bconf';
}

die("this test fails on Redhat 7.2\n");

unless (-x '/bin/rpm') {
    Bivio::IO::Alert->warn("skipping: /bin/rpm not found\n");
    print("1..1\nok 1\n");
    exit(0);
}
use Bivio::IO::File;
use Bivio::Test;
my($base) = Bivio::IO::File->rm_rf(Bivio::IO::File->pwd . '/Release/tmp');
my($home) = Bivio::IO::File->mkdir_p("$base/h");
Bivio::IO::File->mkdir_p(my $facades_dir = "$base/f");
Bivio::Test->new('Bivio::Util::Release')->unit([
    # -noexecute leaves tmp directory around, which helps debugging
    [['-noexecute']] => [
	list_updates => [
	    sub {
		my($case) = @_;
		my($x) = [
		    (split(/\n/, $case->get('object')->create_stream))[0,1,2],
		];
		# Force a difference
		$x->[1] =~ s/\b(\d+)\b/$1 + 1/eg;
		Bivio::IO::File->write("$home/prod-rpms.txt", join("\n", @$x));
		$case->put(expect => [(split(/\s/, $x->[1]))[2] . "\n"]);
		return ['prod'];
	    } => 0,
	],
	build_tar => [
	    R1 => sub {
		my($case) = @_;
		my(@f) = <$home/R1-*.tar.gz>;
		Bivio::Die->die(\@f, ': too many or too few')
		    unless @f == 2;
		$case->actual_return([
		    sort(map($_ =~ m{^R1-HEAD-\d+\.\d+/(.*)}, `tar tzf $f[0]`))]);
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
	{
	    method => 'install_tar',
	    compute_params => sub {
		Bivio::IO::File->mkdir_p(
		    Bivio::IO::File->rm_rf($ENV{PREFIX} = "$base/i"));
		return $_[1];
	    },
	} => [
	    r => sub {
		my($f);
		foreach my $b (qw(ddl/any.sql)) {
		    die("$f: missing")
			unless -f ($f = "$facades_dir/r1/$b");
		}
		return 1;
	    },
	],
    ],
]);
