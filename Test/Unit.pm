# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
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
our($AUTOLOAD, $_TYPE, $_TYPE_CAN_AUTOLOAD, $_CLASS, $_PM, $_OPTIONS);

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
	? $_TYPE->can($func) || $_TYPE_CAN_AUTOLOAD
        ? $_TYPE->$func(@_)
	: Bivio::Die->die(
	    $func, ': not a valid method of ', ref($_TYPE) || $_TYPE)
	: _load_type_class($func, \@_);
}

=for html <a name="builtin_assert_contains"></a>

=head2 builtin_assert_contains(any expect, any actual) : boolean

Calls Bivio::IO::Ref::nested_contains.  Returns 1.

=cut

sub builtin_assert_contains {
    return _assert_expect(@_);
}

=for html <a name="builtin_assert_eq"></a>

B<DEPRECATED>.

=cut

sub builtin_assert_eq {
    Bivio::IO::Alert->warn_deprecated('use assert_equals');
    return shift->builtin_assert_equals(@_);
}

=for html <a name="builtin_assert_equals"></a>

=head2 builtin_assert_equals(any expect, any actual) : 1

Asserts expected equals actual using Bivio::IO::Ref->nested_equals.
If I<expect> is a regexp_ref and I<actual> is a string or string_ref, will
use I<expect> as a regexp.   Returns 1.

=cut

sub builtin_assert_equals {
    return _assert_expect(@_);
}

=for html <a name="builtin_class"></a>

=head2 static builtin_class() : string

=head2 static builtin_class(string class) : string

Returns builtin_class under test without args.  With args, loads the
classes (mapped classes acceptable), and returns the first one.

=cut

sub builtin_class {
    return shift->use(@_)
	if @_ > 1;
    return $_CLASS
	if $_CLASS;
    $_CLASS = Bivio::IO::ClassLoader->unsafe_simple_require(
	(${Bivio::IO::File->read($_PM)}
	     =~ /^\s*package\s+((?:\w+::)*\w+)\s*;/m)[0]
	    || Bivio::Die->die(
		$_PM, ': unable to extract class to test; must',
		' have "package <class::name>;" statement in class under test',
	    ),
    );
    Bivio::Die->die($_PM, ': unable to load the pm')
        unless $_CLASS;
    return $_CLASS;
}

=for html <a name="builtin_commit"></a>

=head2 builtin_commit()

Calls Bivio::Agent::Task::commit

=cut

sub builtin_commit {
    Bivio::Agent::Task->commit(shift->builtin_req);
    return;
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

=for html <a name="builtin_create_user"></a>

=head2 builtin_create_user(string user_name)

Generate a btest, and sets realm and user to this user.  Deletes any user first.

=cut

sub builtin_create_user {
    my($self, $user) = @_;
    my($req) = $self->builtin_req;
    Bivio::Die->eval(sub {
        $req->set_user(
	    Bivio::Biz::Model->new('RealmOwner')->unauth_load({
		name => $user,
		realm_type => Bivio::Auth::RealmType->USER,
	    }) ? $user : return,
	);
        $req->set_realm($user);
	$req->get('auth_user')->cascade_delete;
    });
    $self->use('Bivio::Util::RealmAdmin')
	->create_user($self->builtin_email($user), $user, 'password', $user);
    $req->set_realm_and_user($user, $user);
    return $req->get('auth_user');
}

=for html <a name="builtin_email"></a>

=head2 builtin_email(string suffix) : array

Generate a btest email.
See Bivio::Test::Language::HTTP::generate_local_email.

=cut

sub builtin_email {
    shift;
    return Bivio::IO::ClassLoader->simple_require('Bivio::Test::Language::HTTP')
	->generate_local_email(@_);
}

=for html <a name="builtin_expect_contains"></a>

=head2 builtin_expect_contains(any expect, ... ) : code_ref

Returns a closure that calls assert_contains() on the actual return.

=cut

sub builtin_expect_contains {
    my($proto, @expect) = @_;
    return sub {
	my(undef, $actual) = @_;
	return $proto->builtin_assert_contains(\@expect, $actual);
    };
}

=for html <a name="builtin_inline_case"></a>

=head2 builtin_inline_case(code_ref op) : code_ref

Execute I<op> imperatively.  Note that

=cut

sub builtin_inline_case {
    my($proto, $op) = @_;
    return sub {
	$op->($proto->current_case, $proto->current_self);
	return 1;
    } => 1;
}

=for html <a name="builtin_inline_commit"></a>

=head2 builtin_inline_commit() : code_ref

Commit database changes

=cut

sub builtin_inline_commit {
    my($proto) = @_;
    return sub {
	$proto->commit;
	return 1;
    } => 1;
}

=for html <a name="builtin_inline_rollback"></a>

=head2 builtin_inline_rollback() : code_ref

Rollback database changes

=cut

sub builtin_inline_rollback {
    my($proto) = @_;
    return sub {
	$proto->rollback;
	return 1;
    } => 1;
}

=for html <a name="builtin_model"></a>

=head2 static builtin_model(string name, hash_ref query, array_ref expect) : any

Returns a new model instance if just I<name>.  If I<query>, calls
unauth_load_or_die (PropertyModel), unauth_load_all (ListModel), or process
(FormModel).

If I<expect>, calls map_iterate (PropertyModel in order of primary key) or
unauth_load_all (ListModel), and calls builtin_assert_contains(I<expect>,
I<result>).  Returns the complete data set in this last case.

=cut

sub builtin_model {
    my($proto, $name, $query, $expect) = @_;
    my($m) = Bivio::ShellUtil->model($name);
    return $m
	unless $query;
    my($actual);
    if ($m->isa('Bivio::Biz::PropertyModel')) {
	return Bivio::ShellUtil->model($name, $query)
	    unless $expect;
	$actual = $m->map_iterate(undef, unauth_iterate_start => undef, $query);
    }
    else {
	$m = Bivio::ShellUtil->model($name, $query);
	return $m
	    unless $expect;
	$m->die($expect, ': expected not supported for FormModels')
	    if $m->isa('Bivio::Biz::FormModel');
	$actual = $m->map_rows;
    }
    $proto->builtin_assert_contains($expect, $actual);
    return $actual;
}

=for html <a name="builtin_not_die"></a>

=head2 static builtin_not_die() : undef

Returns C<undef> which is the value L<Bivio::Test::unit|Bivio::Test/"unit">
uses for ignoring result, but not allowing a die.

=cut

sub builtin_not_die {
    return undef;
}

=for html <a name="builtin_options"></a>

=head2 builtin_options(hash_ref options) : hash_ref

Sets global options to be based to Bivio::Test::unit.  Returns current
options.

=cut

sub builtin_options {
    my($proto, $options) = @_;
    $_CLASS = $proto->use($options->{class_name})
	if $options->{class_name};
    return {%$_OPTIONS = (%$_OPTIONS, $options ? %$options : ())};
}

=for html <a name="builtin_random_string"></a>

=head2 builtin_random_string() : string

=head2 builtin_random_string(int length) : string

Return a random string

=cut

sub builtin_random_string {
    return shift->use('Bivio::Biz::Random')->hex_digits(shift || 8);
}

=for html <a name="builtin_string_ref"></a>

=head2 builtin_string_ref(string value) : string_ref

Converts value to string_ref.

=cut

sub builtin_string_ref {
    my(undef, $value) = @_;
    return \$value;
}

=for html <a name="builtin_rm_rf"></a>

=head2 builtin_rm_rf(string io_name)

Calls Bivio::IO::File-E<gt>rm_rf

=cut

sub builtin_rm_rf {
    return shift->use('Bivio::IO::File')->rm_rf(@_);
}

=for html <a name="builtin_read_file"></a>

=head2 static builtin_read_file(string path) : string_ref

Read a file.

=cut

sub builtin_read_file {
    shift;
    return Bivio::IO::File->read(@_);
}

=for html <a name="builtin_req"></a>

=head2 static builtin_req() : Bivio::Agent::Request

=head2 static builtin_req(any wiget_value, ...) : any

Calls Bivio::Test::Request::get_instance.

=cut

sub builtin_req {
    my($self, @args) = @_;
    my($req) = $self->use('Bivio::Test::Request')->get_instance;
    return @args ? $req->get_widget_value(@args) : $req;
}

=for html <a name="builtin_rollback"></a>

=head2 builtin_rollback()

Calls Bivio::Agent::Task::rollback

=cut

sub builtin_rollback {
    Bivio::Agent::Task->rollback(shift->builtin_req);
    return;
}

=for html <a name="builtin_simple_require"></a>

=head2 static builtin_simple_require(string class) : Bivio::UNIVERSAL

Returns class which was loaded.

=cut

sub builtin_simple_require {
    my(undef, $class) = @_;
    return Bivio::IO::ClassLoader->simple_require($class);
}

=for html <a name="builtin_tmp_dir"></a>

=head2 static builtin_tmp_dir() : string

Creates TestName.tmp in the current directory, removing it if it exists
already.

=cut

sub builtin_tmp_dir {
    return Bivio::IO::File->mkdir_p(
	Bivio::IO::File->rm_rf(
	    Bivio::IO::File->absolute_path(
		shift->builtin_class->simple_package_name . '.tmp')));
}

=for html <a name="builtin_write_file"></a>

=head2 static builtin_write_file(string path) : string_ref

Write a file.

=cut

sub builtin_write_file {
    shift;
    return Bivio::IO::File->write(@_);
}

=for html <a name="builtin_var"></a>

=head2 builtin_var(string name) : any

Stores or retrieves global state depending on context.

=cut

sub builtin_var {
    my($proto) = shift;
    Bivio::Die->die(\@_, ': var called with too many arguments')
        if @_ > 2;
    Bivio::Die->die(\@_, ': var called with too few arguments')
        if @_ < 1;
    my($name, $value) = @_;
    return _var_put($proto, $name, $value)
	if @_ == 2;
    return _var_get($proto, $name)
	if (caller(2))[3] eq 'Bivio::Test::Unit::__ANON__';
    return sub {
	my($c) = (caller(1))[3];
	return _var_get_or_put($proto, $name, $_[0])
	    if $c eq 'Bivio::IO::Ref::_diff_eval';
	if ($proto->is_blessed($_[0], 'Bivio::Test::Case')) {
	    foreach my $i (0 .. 10) {
		$c = (caller($i))[3];
		next unless $c =~ /^Bivio::Test::_eval_(\w+)$/;
		$c = $1;
		return _var_get($proto, $name)
		    if $c eq 'method';
		if ($c eq 'params') {
		    my($p) = _var_array(_var_get($proto, $name));
#TODO: Seems a bit dicey, but may be the obvious thingx
		    my($case) = $_[0];
		    return $p
			unless my $cp = $case->unsafe_get('compute_params');
		    return $cp->($case, $p, $case->get(qw(method object)));
		}
		return _var_array(_var_get_or_put($proto, $name, $_[1]->[0]))
		    if $c =~ /^(?:return|result)$/;
	    }
	}
	Bivio::Die->die($name, ': var called in an incorrect context: ', $c);
	# DOES NOT RETURN
    };
}

=for html <a name="run"></a>

=head2 static run(string bunit)

Runs I<file> in bunit environment.

=cut

sub run {
    my($proto, $bunit) = @_;
    local($_PM) = _pm($bunit);
    local($_TYPE, $_CLASS);
    local($_OPTIONS) = {};
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
    return (
	ref($self) ? $self : $self->new({
	    class_name => $self->builtin_class,
	    %$_OPTIONS,
	})
    )->unit(@_);
}

#=PRIVATE SUBROUTINES

sub _assert_expect {
    my($self, $expect, $actual) = @_;
    my($m) = $self->my_caller eq 'builtin_assert_eq'
	? 'nested_differences' : 'nested_contains';
    my($res) = Bivio::IO::Ref->$m($expect, $actual);
    Bivio::Die->throw_quietly(DIE => "expected != actual:\n$$res")
        if $res;
    return 1;
}

sub _load_type_class {
    my($func, $args) = @_;
    $_TYPE = Bivio::IO::ClassLoader->map_require('TestUnit', $func);
    $_TYPE = $_TYPE->new_unit(__PACKAGE__->builtin_class(), @$args)
	if $_TYPE->can('new_unit');
    $_TYPE_CAN_AUTOLOAD = $_TYPE->package_name ne __PACKAGE__
	&& defined(&{\&{$_TYPE->package_name . '::AUTOLOAD'}})
        ? 1 : 0;
    return $_TYPE;
}

sub _pm {
    my($bunit) = @_;
    my($res) = File::Spec->catfile(
	File::Basename::dirname(
	    File::Basename::dirname(File::Spec->rel2abs($bunit))),
	File::Basename::basename($bunit, '.bunit')
	. '.pm');
    return $res
	if -f $res;
    my($res2) = $res;
    $res2 =~ s/\d(?=\.pm$)//;
    return -f $res2 ? $res2 : $res;
}

sub _var_array {
    my($value) = @_;
    return ref($value) eq 'ARRAY' ? $value : [$value];
}

sub _var_exists {
    my($proto, $name) = @_;
    return exists(_var_hash($proto)->{$name});
}

sub _var_get {
    my($proto, $name, $not_die) = @_;
    if (defined($name)) {
	return [map(_var_get($proto, $_, 1), @$name)]
	    if ref($name) eq 'ARRAY';
	return {
	    map((_var_get($proto, $_, 1), _var_get($proto, $name->{$_}, $1)),
		sort(keys(%$name))),
	} if ref($name) eq 'HASH';
	return _var_hash($proto)->{$name}
	    if !ref($name) && _var_exists($proto, $name);
    }
    Bivio::Die->die($name, ': var value is defined')
        unless $not_die;
    return $name;
}

sub _var_get_or_put {
    my($proto, $name, $value) = @_;
    return ref($name) || _var_exists($proto, $name)
	? _var_get($proto, $name)
	: _var_put($proto, $name, $value);
}

sub _var_hash {
    return shift->current_self->get_if_exists_else_put(
	__PACKAGE__ . '.var' => {},
    );
}

sub _var_put {
    my($proto, $name, $value) = @_;
    Bivio::Die->die($name, ': name must be a (perl) identifier')
	unless $name =~ /^\w+$/s;
    Bivio::Die->die($name, ': var may only be set once')
	if _var_exists($proto, $name);
    return _var_hash($proto)->{$name} = $value;
}

=head1 COPYRIGHT

Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
