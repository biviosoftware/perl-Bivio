# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
BEGIN {
    use Cwd ();
    $ENV{BCONF} = Cwd::getcwd() . '/Release/t.bconf';
}
use Bivio::IO::File;
use Bivio::Test;
#TODO: Shared with Release.t
my($base) = Bivio::IO::File->rm_rf(Bivio::IO::File->pwd . '/Release/tmp');
my($home) = Bivio::IO::File->mkdir_p("$base/h");
Bivio::IO::File->mkdir_p(my $facades_dir = "$base/f");
Bivio::Test->new('Bivio::Util::Release')->unit([
    # -noexecute leaves tmp directory around, which helps debugging
    [['-noexecute']] => [
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
