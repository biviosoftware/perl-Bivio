#
# $Id$
#
use strict;
use ExtUtils::MakeMaker ();
use File::Find ();

my(@_PROGRAMS) = ();
my(%_MODULES) = ();
my(@_TESTS) = ();

# main() : int
#
# main(string build) : int
#
# Creates a makefile for the specified build, 'all' by default.
#
# I<build> may be one of the following:
#
#   * all - all modules, programs, and tests
#   * bOPcore - bOP core modules
#
sub main {
    my($build) = @_;
    $build ||= 'all';

    die("usage: perl -w Makefile.PL [<build>]\n")
	    unless $build eq 'all' || $build eq 'bOPcore';

    my($method) = "_build_$build";
    __PACKAGE__->$method();

    ExtUtils::MakeMaker::WriteMakefile(
	    'NAME' => 'Bivio::ALL',
	    'VERSION' => '0.1',
	    'PL_FILES' => {}, # We don't want any installed
	    'EXE_FILES' => \@_PROGRAMS,
	    'PM' => \%_MODULES,
#	    'TESTS' => join(' ', @_TESTS),
	   );

    return 1;
}

# ? needs a description
sub MY::test {
    package MY;
    return shift->SUPER::test(TESTS => join(' ', @_TESTS));
}

main(@ARGV);

#=PRIVATE METHODS

# _build_all()
#
# Build list for all programs, modules and tests.
#
sub _build_all {

    # If you don't specify the 'PM' files explicitly, MakeMaker doesn't
    # find any files below the current directory.  It has a fixed idea
    # of how you build packages and we want to install everything in one
    # go.

    File::Find::find(\&_find, '.');
    print STDERR "Found the following programs:\n    ",
	    join("\n    ", @_PROGRAMS), "\n";
    return;
}

# _build_bOPcore()
#
# Builds list of bOP core modules.
#
sub _build_bOPcore {

    my($core_modules) = <<'EOF';
Bivio::Collection::Attributes
Bivio::Collection::SingletonMap
Bivio::Die
Bivio::DieCode
Bivio::HTML
Bivio::IO::Alert
Bivio::IO::ClassLoader
Bivio::IO::Config
Bivio::IO::File
Bivio::IO::Format
Bivio::IO::TTY
Bivio::IO::Trace
Bivio::ShellUtil
Bivio::Type
Bivio::TypeValue
Bivio::TypeError
Bivio::Type::Array
Bivio::Type::DateTime
Bivio::Type::Enum
Bivio::Type::Number
Bivio::UNIVERSAL
Bivio::Util::Release
EOF

    foreach my $file (split("\n", $core_modules)) {
	$file =~ s/Bivio\:\://;
	$file =~ s,\:\:,/,;
	$file .= '.pm';
	$_MODULES{$file} = '$(INST_LIBDIR)/'.$file;
    }
    return;
}

# _find()
#
# Searches all subdirectories for programs, modules and tests.
#
sub _find {
    /^b-[-\w]+$/ && (push(@_PROGRAMS, $File::Find::name), return);
    if (/^\w+.pm$/) {
	my($file) = $File::Find::name;
	$file =~ s!^\./!!;
	$_MODULES{$file} = '$(INST_LIBDIR)/' . $file;
	return;
    }
    if (/\.t$/) {
	push(@_TESTS, $File::Find::name);
	return;
    }
    -d $_ && !/^[.A-Z]|^t$|^[fy]\d+\w+$/ && ($File::Find::prune = 1);
}

