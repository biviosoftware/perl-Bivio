# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Test::Util;
use strict;
$Bivio::Test::Util::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Util::VERSION;

=head1 NAME

Bivio::Test::Util - runs and manages acceptance (.btest) and unit (.t) tests

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Util;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Test::Util::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Test::Util> runs acceptance and unit tests.  A unit test is defined
using L<Bivio::Test|Bivio::Test>.  An acceptance test has its own language,
which is a subclass of L<Bivio::Test::Language|Bivio::Test::Language>.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:
  usage: b-test [options] command [args...]
  commands:
      unit test_files... -- runs the tests under Test::Harness

=cut

sub USAGE {
    return <<'EOF';
usage: b-test [options] command [args...]
commands:
    accept tests... - runs the tests (.btest) under Bivio::Test::Language
    cleanup tests... - runs the cleanup function of tests (.btest) 
    unit tests... -- runs the tests (.t) under Test::Harness
EOF
}

#=IMPORTS
use Test::Harness ();
use Bivio::Test::Language;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="accept"></a>

=head2 accept(string tests, ...)

Run acceptance tests.

=cut

sub accept {
    my($self) = @_;
    return;
}

=for html <a name="cleanup"></a>

=head2 cleanup(string btest)

Run cleanup method on btest file after setup.

=cut

sub cleanup {
    my($self) = @_;
    return;
}

=for html <a name="unit"></a>

=head2 unit(string test_file, ...)

Executes I<test_file>(s) by calling C<Test::Harness::runtests>.

=cut

sub unit {
    my($self, @test_file) = @_;
    Test::Harness::runtests(@test_file);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
