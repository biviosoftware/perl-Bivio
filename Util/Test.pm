# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Util::Test;
use strict;
$Bivio::Util::Test::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::Test::VERSION;

=head1 NAME

Bivio::Util::Test - runs tests using Test::Harness

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::Test;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::Test::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::Test> runs tests using C<Test::Harness>.

=cut

#=IMPORTS
use Test::Harness ();

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="run"></a>

=head2 run(string test_file)

Executes I<test_file> by calling C<Test::Harness::runtests>.

=cut

sub run {
    my($self, $test_file) = @_;
    Test::Harness::runtests($test_file);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
