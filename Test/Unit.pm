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

    [
	4 => [
	    compute => [
		5 => 5,
		5 => 5,
		10 => 7,
	    ],
	    value => 7,
	],
	class() => [
	    new => [
		-2 => DIE(),
		0 => DIE(),
		1 => undef,
		2.5 => DIE(),
	    ],
	],
	50 => [
	    value => DIE(),
	],
    ];

Or for widgets:

    Widget();
    [
	[['']] => '',
	[['a', 'b']] => 'ab',
	[['a', 'b'], '-'] => 'a-b',
	[['a'], '-'] => 'a',
	[['a', 'b'], [sub {return undef}]] => 'ab',
	[['a', 'b'], [sub {Bivio::UI::Widget::Join->new(['x'])}]] => 'axb',
	[['a', 'b'], [sub {Bivio::UI::Widget::Join->new([''])}]] => 'ab',
	[[
	   [sub {Bivio::UI::Widget::Join->new([''])}],
	    'a',
	   'b',
	   '',
	], '-'] => 'a-b',
    ];

=cut

#=IMPORTS
use Bivio::IO::File;
use Bivio::DieCode;
use File::Spec ();
use File::Basename ();

#=VARIABLES
use vars (qw($AUTOLOAD $_TYPE $_CLASS));

=head1 METHODS

=cut

=for html <a name="AUTOLOAD"></a>

=head2 AUTOLOAD(...) : any

Tries to find Bivio::DieCode or class or type or type function.

=cut

sub AUTOLOAD {
    my($func) = $AUTOLOAD;
    $func =~ s/.*:://;
    return if $func eq 'DESTROY';
    my($b) = "builtin_$func";
    return __PACKAGE__->can($b)
	? __PACKAGE__->$b(@_)
	: Bivio::DieCode->is_valid_name($func) && Bivio::DieCode->can($func)
	? Bivio::DieCode->$func()
	: $_TYPE
	? $_TYPE->$func(@_)
	: ($_TYPE = Bivio::IO::ClassLoader->map_require('TestUnit', $func)
	   and $_TYPE->can('new_unit')
	       ? ($_TYPE = $_TYPE->new_unit($_CLASS, @_))
	       : $_TYPE);
}

=for html <a name="builtin_class"></a>

=head2 static builtin_class() : string

Returns builtin_class under test.

=cut

sub builtin_class {
    return $_CLASS;
}

=for html <a name="builtin_config"></a>

=head2 builtin_config(hash_ref config)

Calls Bivio::IO::Config::introduce_values.

=cut

sub builtin_config {
    my(undef, $config) = @_;
    Bivio::IO::Config->introduce_values($config);
    return;
}

=for html <a name="builtin_email"></a>

=head2 builtin_email(string suffix) : array

Generate a btest email.
See Bivio::Test::Language::HTTP::generate_local_email.

=cut

sub builtin_email {
    shift;
    return [
	Bivio::IO::ClassLoader->simple_require('Bivio::Test::Language::HTTP')
            ->generate_local_email(@_),
    ]->[0];
}

=for html <a name="builtin_not_die"></a>

=head2 static builtin_not_die() : undef

Returns C<undef> which is the value L<Bivio::Test::unit|Bivio::Test/"unit">
uses for ignoring result, but not allowing a die.

=cut

sub builtin_not_die {
    return undef;
}

=for html <a name="builtin_simple_require"></a>

=head2 static builtin_simple_require(string class) : Bivio::UNIVERSAL

Returns class which was loaded.

=cut

sub builtin_simple_require {
    my(undef, $class) = @_;
    return Bivio::IO::ClassLoader->simple_require($class);
}

=for html <a name="run"></a>

=head2 static run(string bunit)

Runs I<file> in bunit environment.

=cut

sub run {
    my($proto, $bunit) = @_;
    local($_CLASS) = Bivio::IO::ClassLoader->simple_require(
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
    );
    local($_TYPE);
    my($t) = Bivio::Die->eval_or_die(
	'package ' . __PACKAGE__ . ';use strict;'
	. ${Bivio::IO::File->read($bunit)});
    $_TYPE ||= __PACKAGE__;
    return $_TYPE->run_unit($t);
}

=for html <a name="run_unit"></a>

=head2 static run_unit(array_ref cases)

Calls L<Bivio::Test::unit|Bivio::Test/"unit">.

=cut

sub run_unit {
    my($self) = shift;
    return $self->new($_CLASS)->unit(@_);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
