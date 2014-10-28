# Copyright (c) 2005-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Unit::Unit;
use strict;
use Bivio::Base 'Bivio.Test';
use File::Basename ();
use File::Spec ();

# C<Bivio::Test::Unit::Unit> is a simple wrapper for
# L<Bivio::Test::unit|Bivio::Test/"unit"> that allows you to declare different
# test types.  You create a ".bunit" file which looks like:
#
#     [
# 	4 => [
# 	    compute => [
# 		5 => 5,
# 		5 => 5,
# 		10 => 7,
# 	    ],
# 	    value => 7,
# 	],
# 	class() => [
# 	    new => [
# 		-2 => DIE(),
# 		0 => DIE(),
# 		1 => undef,
# 		2.5 => DIE(),
# 	    ],
# 	],
# 	50 => [
# 	    value => DIE(),
# 	],
#     ];
#
# Or for widgets:
#
#     Widget();
#     [
# 	[['']] => '',
# 	[['a', 'b']] => 'ab',
# 	[['a', 'b'], '-'] => 'a-b',
# 	[['a'], '-'] => 'a',
# 	[['a', 'b'], [sub {return undef}]] => 'ab',
# 	[['a', 'b'], [sub {Bivio::UI::Widget::Join->new(['x'])}]] => 'axb',
# 	[['a', 'b'], [sub {Bivio::UI::Widget::Join->new([''])}]] => 'ab',
# 	[[
# 	   [sub {Bivio::UI::Widget::Join->new([''])}],
# 	    'a',
# 	   'b',
# 	   '',
# 	], '-'] => 'a-b',
#     ];

our($AUTOLOAD, $_TYPE, $_TYPE_CAN_AUTOLOAD, $_CLASS, $_PM, $_OPTIONS, $_SELF, $_BUNIT);
our($_PROTO) = __PACKAGE__;
my($_CL) = b_use('IO.ClassLoader');
my($_A) = b_use('IO.Alert');
my($_R) = b_use('IO.Ref');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
my($_M) = b_use('Biz.Model');
my($_DC) = b_use('Bivio.DieCode');
my($_D) = b_use('Bivio.Die');
my($_BR) = b_use('Biz.Random');

sub AUTOLOAD {
    __PACKAGE__->call_autoload($AUTOLOAD, \@_);
}

sub builtin_assert_contains {
    return _assert_expect(0, @_);
}

sub builtin_assert_eq {
    # B<DEPRECATED>.
    $_A->warn_deprecated('use assert_equals');
    return shift->builtin_assert_equals(@_);
}

sub builtin_assert_equals {
    return _assert_expect(0, @_);
}

sub builtin_assert_eval {
    my(undef, $code) = @_;
    my($die);
    return $_D->catch($code, \$die)
	|| $_D->throw_quietly(
	    DIE => $_A->format_args(
		ref($code) ? ('line ', (caller)[2]) : $code,
		$die ? (': died with: ', $die) : ': returned false',
	    ),
	);
}

sub builtin_assert_file {
    my($self, $contains, $file) = @_;
    return $self->builtin_assert_contains($contains, $self->builtin_read_file($file), $file);
}

sub builtin_assert_not_equals {
    return _assert_expect(1, @_);
}

sub builtin_auth_realm {
    return shift->builtin_req()->get('auth_realm')->get('owner');
}

sub builtin_auth_user {
    return shift->builtin_req()->get('auth_user');
}

sub builtin_bunit_base_name {
    my($self) = @_;
    b_die('bunit_base_name: not a bunit')
	unless $_BUNIT =~ /(\w+)\.bunit$/;
    return $1;
}

sub builtin_case_tag {
    my($proto, $tag) = @_;
    return $proto->builtin_inline_case(sub {
        $proto->builtin_self->put(case_tag => $tag);
        return;
    });
}

sub builtin_class {
    # Returns builtin_class under test without args.  With args, loads the
    # classes (mapped classes acceptable), and returns the first one.
    shift;
    return b_use(@_)
	if @_;
    return $_CLASS
	if $_CLASS;
    $_CLASS = $_CL->unsafe_simple_require(
	(${$_F->read($_PM)}
	     =~ /^\s*package\s+((?:\w+::)*\w+)\s*;/m)[0]
	    || b_die(
		$_PM, ': unable to extract class name from .pm; must',
		' have "package <class::name>;" statement in class under test',
	    ),
    );
    b_die($_PM, ': unable to load the pm')
        unless $_CLASS;
    return $_CLASS;
}

sub builtin_clear_local_mail {
    shift;
    return b_use('TestLanguage.HTTP')->clear_local_mail(@_);
}

sub builtin_commit {
    b_use('Agent.Task')->commit(shift->builtin_req);
    return;
}

sub builtin_config {
    shift;
    return b_use('IO.Config')->introduce_values(@_);
}

sub builtin_config_can_secure {
    my($self, $bool) = @_;
    return $self->builtin_config({
	'Bivio::Agent::Request' => {
	    can_secure => $bool ? 1 : 0,
	},
    });
}

sub builtin_create_mail {
    my($self, $from_email, $to_email, $headers, $body) = @_;
    my($r) = $self->builtin_random_string;
    my($req) = $self->builtin_req;
    my($o) = b_use('Mail.Outgoing')->new;
    $o->set_recipients($to_email, $req);
    $o->set_header(To => $to_email);
    $headers = {
	Subject => "subj-$r",
	$headers ? %$headers : (),
    };
    foreach my $k (sort(keys(%$headers))) {
	$o->set_header($k, $headers->{$k});
    }
    $o->set_body($body || "Any unique $r body\n");
    $o->add_missing_headers($req, $from_email);
    my($ea) = $self->builtin_model('EmailAlias');
    my($e) = $self->builtin_model('Email');
    my($te) = b_use('Type.Email');
    my($rid);
    $rid = $self->builtin_realm_id($to_email)
	if $ea->unsafe_load({incoming => $to_email})
	&& !$te->is_valid($to_email = $ea->get('outgoing'));
    $rid = $e->unauth_load({email => $to_email}) ? $e->get('realm_id')
	: $self->builtin_realm_id($te->get_local_part($to_email))
	unless $rid;
    $self->builtin_req->with_realm($rid, sub {
	$self->builtin_model('RealmMail')->create_from_rfc822(\($o->as_string));
	return;
    });
    return $self->builtin_req('Model.RealmMail');
}

sub builtin_create_user {
    my($self, $user) = @_;
    my($req) = $self->builtin_req->initialize_fully;
    my($u) = $_M->new('RealmOwner');
    $u->unauth_delete_realm
	if $u->unauth_load({
	    name => $user,
	    realm_type => b_use('Auth.RealmType')->USER,
	});
    b_use('ShellUtil.RealmAdmin')
	->create_user($self->builtin_email($user), $user, 'password', $user);
    $req->set_realm_and_user($user, $user);
    return $req->get('auth_user');
}

sub builtin_date_time {
    return shift->builtin_from_type(DateTime => shift(@_));
}

sub builtin_email {
    shift;
    return b_use('TestLanguage.HTTP')->generate_local_email(@_);
}

sub builtin_expect_contains {
    my($proto, @expect) = @_;
    return sub {
	my(undef, $actual) = @_;
	return $proto->builtin_assert_contains(\@expect, $actual);
    };
}

sub builtin_file_field {
    shift;
    return b_use('Type.FileField')->from_any(@_);
}

sub builtin_from_type {
    shift;
    my($t) = b_use('Type', shift(@_));
    return @_ ? $t->from_literal_or_die(shift(@_)) : $t;
}

sub builtin_go_dir {
    my(undef, $dir, $op) = @_;
    my($d) = $_F->mkdir_p($_F->absolute_path($dir));
    return $_F->chdir($d)
	unless $op;
    return IO_File()->do_in_dir($d, $op);
}

sub builtin_inline_case {
    my($proto, $op) = @_;
    return sub {
	$op->($proto->current_case, $proto->current_self);
	return $proto->IGNORE_RETURN;
    } => $proto->IGNORE_RETURN;
}

sub builtin_inline_commit {
    my($proto) = @_;
    return sub {
	$proto->commit;
	return $proto->IGNORE_RETURN;
    } => $proto->IGNORE_RETURN;
}

sub builtin_inline_rollback {
    my($proto) = @_;
    return sub {
	$proto->rollback;
	return $proto->IGNORE_RETURN;
    } => $proto->IGNORE_RETURN;
}

sub builtin_inline_trace {
    my($proto, @args) = @_;
    return sub {
	$proto->builtin_trace(@args);
	return $proto->IGNORE_RETURN;
    } => $proto->IGNORE_RETURN;
}

sub builtin_mock {
    my($self, $class, $values) = @_;
    $class = b_use($class);
    b_die($class, ': must be a property model')
        unless $class->isa('Bivio::Biz::PropertyModel');
    my($i) = $class->new($self->builtin_req);
#TODO: Not elegant, but works.  Think about testing structure for mocking objects
    $i->internal_put($values);
    return $i;
}

sub builtin_mock_methods {
    my($self, $map) = @_;
    foreach my $x (keys(%$map)) {
	my($class, $method) = $x =~ /^([\w\.\:]+)->(\w+)$/;
	b_die($x, ': invalid mock_methods configuration')
	    unless $class;
	_verify_mock_method($x, $map->{$x});
	b_use('Bivio.ClassWrapper')->wrap_methods(
	    b_use($class),
	    {mock_data => $map->{$x}},
	    {$method => \&_mock_method},
	);
    }
    return;
}

sub builtin_mock_return {
    my($self, $return) = @_;
    b_die($return, ': must be scalar or array_ref')
	if ref($return) && ref($return) ne 'ARRAY';
    return b_use('Test.MockReturn')->new(@_ > 1 ? {return => $return} : {});
}

sub builtin_model {
    return _model(shift, $_M->new_other_with_query(@_), @_)
}

sub builtin_trim_space {
    my(undef, $value) = @_;
    $value =~ s/^\s+|\s+$//g;
    return $value
}

sub builtin_not_die {
    # Returns C<undef> which is the value L<Bivio::Test::unit|Bivio::Test/"unit">
    # uses for ignoring result, but not allowing a die.
    return undef;
}

sub builtin_now {
    return $_DT->now;
}

sub builtin_options {
    my($proto, $options) = @_;
    $_CLASS = $proto->use($options->{class_name})
	if $options->{class_name};
    return {%{$_OPTIONS = {%$_OPTIONS, $options ? %$options : ()}}};
}

sub builtin_random_alpha_string {
    shift;
    return $_BR->string(shift(@_), ['a' .. 'z']);
}

sub builtin_random_integer {
    shift;
    return $_BR->integer(@_);
}

sub builtin_random_realm_name {
    return shift->builtin_random_alpha_string(@_);
}

sub builtin_random_string {
    shift;
    return $_BR->string(@_);
}

sub builtin_read_file {
    shift;
    return b_use('IO.File')->read(@_);
}

sub builtin_req {
    my($self, @args) = @_;
    my($req) = b_use('Test.Request')->get_instance;
    return @args ? $req->get_widget_value(@args) : $req;
}

sub builtin_rm_rf {
    my(undef, $dir) = @_;
    b_die($dir, ': must be non-zero length and not begin with .')
	unless defined($dir) && length($dir) && $dir !~ /^\./;
    $dir = $_F->absolute_path($dir);
    system("chmod -R u+rwx '$dir' 2>/dev/null");
    return $_F->rm_rf($dir);
}

sub builtin_rollback {
    b_use('Agent.Task')->rollback(shift->builtin_req);
    return;
}

sub builtin_self {
    return $_SELF || b_die('may only be called during test execution');
}

sub builtin_shell_util {
    my($self, $module, $args) = @_;
    return b_use('Bivio.ShellUtil')->new_other($module)->main(@$args);
}

sub builtin_simple_require {
    my(undef, $class) = @_;
    # Returns class which was loaded.
    return $_CL->simple_require($class);
}

sub builtin_string_ref {
    my(undef, $value) = @_;
    # Converts value to string_ref.
    return \$value;
}

sub builtin_tmp_dir {
    my($self) = @_;
    return $_F->mkdir_p(
	$self->builtin_rm_rf($self->builtin_class->simple_package_name . '.tmp'));
}

sub builtin_trace {
    shift;
    b_use('IO.Trace')->set_named_filters(@_);
    return;
}

sub builtin_unauth_model {
    return _model(shift, $_M->new_other_with_query(@_), @_)
}

sub builtin_var {
    my($proto) = shift;
    b_die(\@_, ': var called with too many arguments')
        if @_ > 2;
    b_die(\@_, ': var called with too few arguments')
        if @_ < 1;
    my($name, $value) = @_;
    return _var_put($proto, $name, $value)
	if @_ == 2;
    return _var_get($proto, $name)
	if _called_in_closure($proto);
    return sub {
	my($c) = (caller(1))[3];
	return _var_get_or_put($proto, $name, $_[0])
	    if $c eq 'Bivio::IO::Ref::_diff_eval';
	if ($proto->is_blesser_of($_[0], 'Bivio::Test::Case')) {
	    foreach my $i (0 .. 10) {
		$c = (caller($i))[3];
		return _var_get($proto, $name)
		    if $c =~ /^Bivio::Test::Unit::FormModel::__ANON__/;
		next unless $c =~ /^Bivio::Test::_eval_(\w+)$/;
		$c = $1;
		return _var_get($proto, $name)
		    if $c eq 'method';
		if ($c eq 'params') {
		    my($p) = _var_array(_var_get($proto, $name));
#TODO: Seems a bit dicey, but may be the obvious thing
		    my($case) = $_[0];
		    return $p
			unless my $cp = $case->unsafe_get('compute_params');
		    return $cp->($case, $p, $case->get(qw(method object)));
		}
		return _var_array(_var_get_or_put($proto, $name, $_[1]->[0]))
		    if $c =~ /^(?:return|result)$/;
	    }
	}
	b_die($name, ': var called in an incorrect context: ', $c);
	# DOES NOT RETURN
    };
}

sub builtin_write_file {
    shift;
    return $_F->write(@_);
}

sub builtin_realm_id {
    shift;
    return b_use('ShellUtil.RealmAdmin')->to_id(@_);
}

sub builtin_realm_id_exists {
    shift;
    return b_use('ShellUtil.RealmAdmin')->unsafe_to_id(@_) ? 1 : 0;
}

sub builtin_remote_email {
    shift;
    return b_use('TestLanguage.HTTP')->generate_remote_email(@_);
}

sub builtin_template {
    shift;
    return b_use('IO.Template')->replace_in_string(@_);
}

sub builtin_to_string {
    shift;
    return ${b_use('IO.Ref')->to_string(@_)};
}

sub builtin_verify_local_mail {
    shift;
    return b_use('TestLanguage.HTTP')->verify_local_mail(@_);
}

sub call_autoload {
    my(undef, $autoload, $args) = @_;
    my($func) = $autoload;
    $func =~ s/.*:://;
    return
	if $func eq 'DESTROY';
    my($builtin) = "builtin_$func";
    return $_PROTO->can($builtin)
	? $_PROTO->$builtin(@$args)
        : $_TYPE
	&& $_TYPE->can('handle_test_unit_autoload_ok')
	&& $_TYPE->handle_test_unit_autoload_ok($func)
        ? $_TYPE->handle_test_unit_autoload($func, $args)
	: $_DC->is_valid_name($func) && $_DC->can($func)
	? $_DC->$func()
	: $_TYPE
	? $_TYPE->can($func) || $_TYPE_CAN_AUTOLOAD
        ? $_TYPE->$func(@$args)
	: $_CL->call_autoload($func, $args, [qw(Type Model)])
	: _load_type_class($func, $args);
}

sub new_unit {
    my($proto, $class, $attrs) = @_;
    return $proto->SUPER::new({
	class_name => $class,
	$attrs ? %$attrs : (),
    });
}

sub run {
    my($proto, $bunit) = @_;
    local($_PM) = _pm($bunit);
    local($_TYPE, $_CLASS);
    local($_OPTIONS) = {};
    local($_PROTO) = $proto->package_name;
    local($_BUNIT) = $bunit;
    my($t) = $_D->eval_or_die(
	"package $_PROTO;use strict;" . ${$_F->read($bunit)});
    $_TYPE ||= $_PROTO;
    my($res) = $_TYPE->run_unit($t);
    b_use('Test.Request')->get_instance->call_process_cleanup;
    return $res;
}

sub run_unit {
    my($proto) = shift;
    local($_SELF);
    return (
	$_SELF = $proto->new({
	    class_name => $proto->builtin_class,
	    ref($proto) ? %{$proto->get_shallow_copy} : (),
	    %$_OPTIONS,
	})
    )->unit(@_);
}

sub unit_from_method_group {
    return shift->SUPER::unit(@_)
	if @_ > 2;
    my($self, $group) = @_;
    my($c) = $self->builtin_class;
    return $self->SUPER::unit(ref($group->[0]) eq 'ARRAY' ? $group : [
	map({
	    my($next) = [splice(@$group, 0, 2)];
	    $c eq $next->[0] ? @$next : ($c => $next);
	} 1 .. @$group/2),
    ]);
}

sub _assert_expect {
    my($invert, $self, $expect, $actual, $comment) = @_;
    my($m) = $self->my_caller eq 'builtin_assert_equals'
	? 'nested_differences' : 'nested_contains';
    my($res) = $_R->$m($expect, $actual);
    $comment = defined($comment) ? "/* $comment */ " : '';
    $_D->throw_quietly(
	DIE => $invert
	    ? "${comment}unexpected match: ${$_R->to_string($expect)} == ${$_R->to_string($actual)}"
	    : "${comment}expected != actual:\n$$res",
    ) if $invert xor $res;
    return 1;
}

sub _called_in_closure {
    my($proto) = @_;
    return 0
	unless $proto->unsafe_current_self;
    foreach my $i (3..5) {
	my($sub) = (caller($i))[3];
	return 1
	    if $sub =~ qr{^\w+::(?:Test::Unit|Test|TestUnit)::Unit::__ANON__$};
	last unless $sub =~ /AUTOLOAD|__ANON__/;
    }
    return 0;
}

sub _load_type_class {
    my($func, $args) = @_;
    b_use('Test.Request')->require_no_cookie;
    $_TYPE = $_CL->map_require('TestUnit', $func);
    $_TYPE = $_TYPE->new_unit($_PROTO->builtin_class(), @$args)
	if $_TYPE->can('new_unit');
    $_TYPE_CAN_AUTOLOAD = $_TYPE->package_name ne $_PROTO
	&& defined(&{\&{$_TYPE->package_name . '::AUTOLOAD'}})
        ? 1 : 0;
    return $_TYPE;
}

sub _mock_method {
    my($class_wrapper, $args) = @_;
    my($md) = $class_wrapper->get(qw(mock_data));
    my($return);
    my($grep) = sub {
	my($arg) = shift;
	foreach my $x (@$md) {
	    my($expect, $value) = @$x;
	    next
		unless ref($expect) ? $arg =~ $expect : $arg eq $expect;
	    my($v) = @$value > 1 ? shift(@$value)
		: $value->[0];
	    return $v
		unless b_use('Test.MockReturn')->is_blesser_of($v);
	    b_die($expect, ': too many matches for mock_return')
		if $return;
	    $return = $v;
	    return undef;
	}
	return $arg;
    };
    my($args2) = [map(
	ref($_) || !defined($_) ? $_ : $grep->($_),
	@$args,
    )];
    if ($return) {
	return
	    unless $return->has_keys('return');
	my($res) = $return->get('return');
	return ref($res) ? @$res : $res;
    }
    return $class_wrapper->call_method($args2);
}

sub _model {
    my($proto, $model, $name, $query, $expect) = @_;
    return $model
	unless @_ >= 5;
    my($is_unauth) = $proto->my_caller =~ /unauth/;
    b_die($expect, ': expected not supported for FormModels')
	if $model->isa('Bivio::Biz::FormModel');
    my($actual) = $model->isa('Bivio::Biz::PropertyModel')
	? $model->map_iterate(
	    undef,
	    $is_unauth ? 'unauth_iterate_start' : 'iterate_start',
	    undef,
	    $query,
	) : $model->map_rows;
    $proto->builtin_assert_contains($expect, $actual)
	if $expect;
    return $actual;
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
    $res2 =~ s/\d+(?=\.pm$)//;
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
    b_die($name, ': var value is defined')
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
	$_PROTO . '.var' => {},
    );
}

sub _var_put {
    my($proto, $name, $value) = @_;
    b_die($name, ': name must be a (perl) identifier')
	unless $name =~ /^\w+$/s;
    b_die($name, ': var may only be set once')
	if _var_exists($proto, $name);
    return _var_hash($proto)->{$name} = $value;
}

sub _verify_mock_method {
    my($method, $args) = @_;
    foreach my $x (@$args) {
	my($expect, $value) = @$x;
	b_die($expect, ': invalid expected argument for ', $method)
	    unless ref($expect) ? ref($expect) eq 'Regexp' : defined($expect);
	b_die($value, ': value must be array_ref for ', $method)
	    unless (ref($value) || '') eq 'ARRAY';
    }
    return;
}

1;
