#
# $Id$
#
use strict;
use ExtUtils::MakeMaker;
use File::Find ();

my(@exe_files) = ();
sub exe_files {
    /^b-[-\w]+$/ && push(@exe_files, $File::Find::name);
    $_ eq 'blib' && ($File::Find::prune = 1);
}

File::Find::find(\&exe_files, '.');
print STDERR "Found the following programs:\n    ",
         join("\n    ", @exe_files), "\n";
WriteMakefile(
    'NAME' => 'Bivio::ALL',
    'VERSION' => '0.1',
    'PL_FILES' => {},   			  # We don't want any installed
    'EXE_FILES' => \@exe_files,
);
