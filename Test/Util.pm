# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Test::Util;
use strict;
$Bivio::Test::Util::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Util::VERSION;

=head1 NAME

Bivio::Test::Util - runs tests using Test::Harness

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

C<Bivio::Test::Util> runs tests using C<Test::Harness>.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:
  usage: b-test [options] command [args...]
  commands:
      run test_files... -- runs the tests under Test::Harness

=cut

sub USAGE {
    return <<'EOF';
usage: b-test [options] command [args...]
commands:
    run tests... -- runs the tests under Test::Harness
EOF
}

#=IMPORTS
use Test::Harness ();

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="run"></a>

=head2 run(string test_file, ...)

Executes I<test_file>(s) by calling C<Test::Harness::runtests>.

=cut

sub run {
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
