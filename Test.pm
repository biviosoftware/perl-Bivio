# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Test;
use strict;
$Bivio::Test::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::VERSION;

=head1 NAME

Bivio::Test - support for declarative testing

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test;

=cut

use Bivio::UNIVERSAL;
@Bivio::Test::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Test> supports declarative testing.  A declarative test allows you to
define what you want to test very succinctly.  Here's an example:

    #!perl -w
    use strict;
    use Bivio::TypeError;
    use Bivio::Type::Integer;
    Bivio::Test->run([
        Bivio::Type::Integer => [
            from_literal => [
	        ['1' => 1],
	        ['x', => [undef, Bivio::TypeError->INTEGER]],
            ],
        ],
    ]);

You declare the class or instance you are testing followed by a list of tests.
Each test is a method name followed by a list of cases.  Each case is a tuple
of parameter(s) and return value(s).  If a parameter is a single value, you
don't need to wrap it in an array_ref unless it is an array_ref itself.  The
same is of the return values.  If there is no return value, specify C<undef>.
That's what the method should return if it doesn't return anything.  (All perl
subs return C<undef> implicitly.  To ignore the return result, don't specify
it, i.e. the test case tuple should only include the parameter(s).

If the expected (declared) return value is an unblessed code_ref (subroutine)
specified as a simple value, it will be executed to evaluate the return result.
See L<handle_result|"handle_result"> for a description of this interface.

If the expected (declared) return value is a L<Bivio::DieCode|Bivio::DieCode>,
an exception will be expected.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="handle_result"></a>

=head2 abstract sub handle_result(any proto, string method, array_ref params, array_ref result) : boolean

=head2 abstract sub handle_result(any proto, string method, array_ref params, Bivio::Die die) : boolean

I<proto> is the instance or class which was executed.  I<method> was called
with I<params>.  The result is either a I<die> or I<result>.

The handler returns true on success, i.e. I<die> or I<result> as expected.

The handler is called as a subroutine.

=cut

$_ = <<'}'; # emacs
sub handle_result {
}

=for html <a name="run"></a>

=head2 run(array_ref tests)

Evaluates I<tests> which are defined as tuples of tuples of tuples.
see L<DESCRIPTION|"DESCRIPTION"> for the syntax.

The tests are suitable for processing by C<Test::Harness>, a standard CPAN
module.  See also L<Bivio::Util::Test|Bivio::Util::Test> which is a
front-end to C<Test::Harness>.

=cut

sub run {
    my($proto, $tests) = @_;
    _assert_even($tests, 'tests');
    return;
}

#=PRIVATE METHODS

# _assert_even(array_ref value, string name)
#
# Asserts value is an even length array_ref.
#
sub _assert_even {
    my($value, $name) = @_;
    _assert_array($value, $name);
    _die($name, '
    Bivio::Die->die($name,
     int(@$value) % 2 == 0;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
