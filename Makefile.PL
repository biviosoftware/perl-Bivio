#
# $Id$
#
use strict;
use ExtUtils::MakeMaker;
use File::Find ();

# If you don't specify the 'PM' files explicitly, MakeMaker doesn't
# find any files below the current directory.  It has a fixed idea
# of how you build packages and we want to install everything in one
# go.  There is no sense in breaking it in separate packages as yet.
my(@exe_files) = ();
my(@tests) = ();
my(%pm) = ();
sub find {
    /^b-[-\w]+$/ && (push(@exe_files, $File::Find::name), return);
    if (/^\w+.pm$/) {
	my($file) = $File::Find::name;
	$file =~ s!^\./!!;
	$pm{$file} = '$(INST_LIBDIR)/' . $file;
	return;
    }
    if (/\.t$/) {
	push(@tests, $File::Find::name);
	return;
    }
    -d $_ && !/^[.A-Z]|^t$|^[fy]\d+$/ && ($File::Find::prune = 1);
}

File::Find::find(\&find, '.');
print STDERR "Found the following programs:\n    ",
         join("\n    ", @exe_files), "\n";
sub MY::test {
    package MY;
    return shift->SUPER::test(TESTS => join(' ', @tests));
}
WriteMakefile(
    'NAME' => 'Bivio::ALL',
    'VERSION' => '0.1',
    'PL_FILES' => {},   			  # We don't want any installed
    'EXE_FILES' => \@exe_files,
    'PM' => \%pm,
#    'TESTS' => join(' ', @tests),
);
