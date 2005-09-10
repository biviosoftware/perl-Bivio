# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Unit;
use strict;
$Bivio::Test::Unit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Unit::VERSION;

=head1 NAME

Bivio::Test::Unit - declarative unit tests

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Unit;

=cut

=head1 EXTENDS

L<Bivio::Test>

=cut

use Bivio::Test;
@Bivio::Test::Unit::ISA = ('Bivio::Test');

=head1 DESCRIPTION

C<Bivio::Test::Unit> is a simple wrapper for
L<Bivio::Test::unit|Bivio::Test/"unit"> that allows you to declare different
test types.  You create a ".bunit" file which looks like:

=cut

#=IMPORTS
use Bivio::IO::File;
use Bivio::DieCode;
use File::Spec ();
use File::Basename ();

#=VARIABLES
use vars ('$AUTOLOAD');

=head1 METHODS

=cut

=for html <a name="AUTOLOAD"></a>

=head2 AUTOLOAD(...) : any

Returns L<Bivio::Test::CLASS|Bivio::Test/"CLASS"> or
a L<Bivio::DieCode|Bivio::DieCode> , else dies.

=cut

sub AUTOLOAD {
    my($func) = $AUTOLOAD;
    $func =~ s/.*:://;
    return if $func eq 'DESTROY';
    Bivio::Die->die($func, ': called with too many arguments: ', \@_)
        if @_;
    return $func eq 'CLASS' ? Bivio::Test->CLASS()
	: $func =~ /^[A-Z][A-Z0-9_]*$/ ? Bivio::DieCode->from_name($func)
	: Bivio::Die->die($func, ': method not found');
}

=for html <a name="run"></a>

=head2 static run(string bunit)

Runs I<file> in bunit environment.

=cut

sub run {
    my($proto, $bunit) = @_;
    my($t) = Bivio::Die->eval_or_die(
	'package ' . __PACKAGE__ . ';use strict;'
	. ${Bivio::IO::File->read($bunit)});
    return Bivio::IO::ClassLoader->map_require(
	# Anything but simple word, means we call the unit test
	TestUnit => ref($t->[0]) || $t->[0] !~ /^[A-Z]\w+$/
	    ? ($t = [$t], 'Unit')[1]
	    : shift(@$t),
    )->unit(
	(${Bivio::IO::File->read(
	    File::Spec->catfile(
		File::Basename::dirname(
		    File::Basename::dirname(File::Spec->rel2abs($bunit))),
		File::Basename::basename($bunit, '.bunit'). '.pm',
	    ),
	)} =~ /^\s*package\s+((?:\w+::)*\w+)\s*;/m)[0]
	|| Bivio::Die->die(
	    $bunit, ': unable to extract class to test; must',
	    ' have "package <class::name>;" statement in class under test',
	),
	@$t,
    );
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
