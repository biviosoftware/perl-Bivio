#!perl
#
# $Id$
#
use Cwd ();
require 'ctime.pl';
@ARGV || die('usage: perl run_mhonarc.pl [-d] <club> <motion>');

my($_DEBUG) = $ARGV[0] eq '-d' ? shift(@ARGV) : '';
$_DEBUG && print STDERR <<'EOF';
Interesting breakpoints:
     b postpone Bivio::Club::mhonarc_hook
     b postpone Bivio::Club::Page::Motions::process_mhonarc_hook
EOF
my($_CLUB, $_MOTION) = @ARGV;
my($_USER, $_FULL_NAME) = (getpwuid($>))[0,6];
defined($_USER) || die("couldn't find user");
my($_OUTDIR) = '../../data/clubs/$_CLUB/messages';
# Remove the lock if it exists
-d "$_OUTDIR/.mhonarc.lck" && rmdir("$_OUTDIR/.mhonarc.lck");
$ENV{PERLLIB} = '.';
&simulate_add("Dropped Motion");


sub simulate_add ($$) {
    my($subject_prefix) = @_;
    my($time) = time;
    my($sec, $min, $hour, $mday, $mon, $year) = localtime($time);
    $year += 1900;
    $mon++;
    my($id) = sprintf('%04d%02d%02d%02d%02d.LAA%s@bivio.com',
		     $year, $mon, $mday, $hour, $min, $$);
    my($ctime) = &ctime($time);
    chop($ctime); # stupid \n
    open(OUT, "|perl $_DEBUG ../../external/MHonArc2.3.3/mhonarc"
	 . " -add -quiet -outdir $_OUTDIR"
	 . ' -rc ../../etc/majordomo/club.mrc'
	 . ' -addhook Bivio::Club::mhonarc_addhook');
    print OUT <<"EOF";
From owner-$_CLUB\@bivio.com  $ctime
Message-Id: <$id>
From: $_FULL_NAME <$_USER\@bivio.com>
To: My Favorite Club Name <$_CLUB\@bivio.com>
Subject: $subject_prefix: $_MOTION
Date: $ctime -0700
Sender: owner-$_CLUB\@bivio.com
Precedence: bulk
Reply-To: My Favorite Club Name <$_CLUB\@bivio.com>
EOF
    close(OUT);
}
