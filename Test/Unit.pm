# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Unit;
use strict;
use Bivio::Base 'Bivio.Test';
use Bivio::DieCode;
use Bivio::IO::File;
use File::Basename ();
use File::Spec ();

# C<Bivio::Test::Unit> is a simple wrapper for
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

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD, $_TYPE, $_TYPE_CAN_AUTOLOAD, $_CLASS, $_PM, $_OPTIONS);
our($_PROTO) = __PACKAGE__;
my($_CL) = __PACKAGE__->use('IO.ClassLoader');
my($_CLASS_SEARCH) = [qw(Type Model)];
my($_CLASS_DISPATCH) = {
    Type => 'builtin_from_type',
    Model => 'builtin_model',
};
my($_A) = __PACKAGE__->use('IO.Alert');
my($_R) = __PACKAGE__->use('IO.Ref');
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_F) = b_use('IO.File');

sub AUTOLOAD {
    my($func) = $AUTOLOAD;
    # Tries to find Bivio::DieCode or class or type or type function.
    $func =~ s/.*:://;
    return if $func eq 'DESTROY';
    my($b) = "builtin_$func";
    return $_PROTO->can($b)
	? $_PROTO->$b(@_)
        : $_TYPE && $_TYPE->can('handle_test_unit_autoload_ok')
	    && $_TYPE->handle_test_unit_autoload_ok($func)
        ? $_TYPE->handle_test_unit_autoload($func, \@_)
	: Bivio::DieCode->is_valid_name($func) && Bivio::DieCode->can($func)
	? Bivio::DieCode->$func()
	: $_TYPE
	? $_TYPE->can($func) || $_TYPE_CAN_AUTOLOAD
        ? $_TYPE->$func(@_)
	: _call_class($func, \@_)
	: _load_type_class($func, \@_);
}

sub builtin_assert_contains {
    # Calls Bivio::IO::Ref::nested_contains.  Returns 1.
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
    return Bivio::Die->catch($code, \$die)
	|| Bivio::Die->throw_quietly(
	    DIE => $_A->format_args(
		ref($code) ? ('line ', (caller)[2]) : $code,
		$die ? (': died with: ', $die) : ': returned false',
	    ),
	);
}

sub builtin_assert_not_equals {
    return _assert_expect(1, @_);
}

sub builtin_auth_realm {
    # Return the current auth realm.
    return shift->builtin_req()->get('auth_realm')->get('owner');
}

sub builtin_auth_user {
    # Return the current auth user.
    return shift->builtin_req()->get('auth_user');
}

sub builtin_chomp_and_return {
    my(undef, $value) = @_;
    # Calls chomp and returns its argument
    chomp($value);
    return $value;
}

sub builtin_class {
    # Returns builtin_class under test without args.  With args, loads the
    # classes (mapped classes acceptable), and returns the first one.
    return shift->use(@_)
	if @_ > 1;
    return $_CLASS
	if $_CLASS;
    $_CLASS = $_CL->unsafe_simple_require(
	(${$_F->read($_PM)}
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

sub builtin_commit {
    # Calls Bivio::Agent::Task::commit
    Bivio::Agent::Task->commit(shift->builtin_req);
    return;
}

sub builtin_config {
    my(undef, $config) = @_;
    # Calls Bivio::IO::Config::introduce_values.
    Bivio::IO::Config->introduce_values($config);
    return;
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
    # Generate a btest, and sets realm and user to this user.  Deletes any user first.
    my($req) = $self->builtin_req->initialize_fully;
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

sub builtin_date_time {
    return shift->builtin_from_type(DateTime => shift(@_));
}

sub builtin_email {
    return shift->use('TestLanguage.HTTP')->generate_local_email(@_);
}

sub builtin_expect_contains {
    my($proto, @expect) = @_;
    # Returns a closure that calls assert_contains() on the actual return.
    return sub {
	my(undef, $actual) = @_;
	return $proto->builtin_assert_contains(\@expect, $actual);
    };
}

sub builtin_file_field {
    return shift->use('Type.FileField')->from_disk(@_);
}

sub builtin_from_type {
    my($t) = shift->use('Type', shift(@_));
    return @_ ? $t->from_literal_or_die(shift(@_)) : $t;
}

sub builtin_go_dir {
    my(undef, $dir) = @_;
    return $_F->chdir($_F->mkdir_p($_F->absolute_path($dir)));
}

sub builtin_inline_case {
    my($proto, $op) = @_;
    # Execute I<op> imperatively.  Note that
    return sub {
	$op->($proto->current_case, $proto->current_self);
	return $proto->IGNORE_RETURN;
    } => $proto->IGNORE_RETURN;
}

sub builtin_inline_commit {
    my($proto) = @_;
    # Commit database changes
    return sub {
	$proto->commit;
	return 1;
    } => 1;
}

sub builtin_inline_rollback {
    my($proto) = @_;
    # Rollback database changes
    return sub {
	$proto->rollback;
	return 1;
    } => 1;
}

sub builtin_trace {
    shift->use('IO.Trace')->set_named_filters(@_);
    return;
}

sub builtin_inline_trace {
    my($proto, @args) = @_;
    return sub {
	$proto->builtin_trace(@args);
	return 1;
    } => 1;
}

sub builtin_mock {
    my($self, $class, $values) = @_;
    $class = $self->use($class);
    Bivio::Die->die($class, ': must be a property model')
        unless $class->isa('Bivio::Biz::PropertyModel');
    my($i) = $class->new($self->builtin_req);
#TODO: Not elegant, but works.  Think about testing structure for mocking objects
    $i->internal_put($values);
    return $i;
}

sub builtin_model {
    return _model(@_);
}

sub builtin_model_exists {
    my($self, $name, $query) = @_;
    my($actual) = _model($self, $name, $query, undef);
    return @$actual > 0 ? 1 : 0;
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
    # Sets global options to be based to Bivio::Test::unit.  Returns current
    # options.
    $_CLASS = $proto->use($options->{class_name})
	if $options->{class_name};
    return {%{$_OPTIONS = {%$_OPTIONS, $options ? %$options : ()}}};
}

sub builtin_random_string {
    # Return a random string
    return shift->use('Biz.Random')->string(@_);
}

sub builtin_random_alpha_string {
    # Return a random string
    return shift->use('Biz.Random')->string(shift(@_), ['a' .. 'z']);
}

sub builtin_read_file {
    return shift->use('IO.File')->read(@_);
}

sub builtin_req {
    my($self, @args) = @_;
    # Calls Bivio::Test::Request::get_instance.
    my($req) = $self->use('Test.Request')->get_instance;
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
    # Calls Bivio::Agent::Task::rollback
    Bivio::Agent::Task->rollback(shift->builtin_req);
    return;
}

sub builtin_self {
    return ref($_TYPE) ? $_TYPE
	: Bivio::Die->die($_TYPE, ': is not an instance');
}

sub builtin_shell_util {
    my($self, $module, $args) = @_;
    return Bivio::ShellUtil->new_other($module)->main(@$args);
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
	$self->rm_rf($self->builtin_class->simple_package_name . '.tmp'));
}

sub builtin_unauth_model {
    return _model(@_);
}

sub builtin_var {
    my($proto) = shift;
    # Stores or retrieves global state depending on context.
    Bivio::Die->die(\@_, ': var called with too many arguments')
        if @_ > 2;
    Bivio::Die->die(\@_, ': var called with too few arguments')
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
	if ($proto->is_blessed($_[0], 'Bivio::Test::Case')) {
	    foreach my $i (0 .. 10) {
		$c = (caller($i))[3];
		return _var_get($proto, $name)
		    if $c =~ /^Bivio::Test::FormModel::__ANON__/;
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
	Bivio::Die->die($name, ': var called in an incorrect context: ', $c);
	# DOES NOT RETURN
    };
}

sub builtin_write_file {
    shift;
    return $_F->write(@_);
}

sub builtin_realm_id {
    return shift->use('ShellUtil.RealmAdmin')->to_id(@_);
}

sub builtin_remote_email {
    return shift->use('TestLanguage.HTTP')->generate_remote_email(@_);
}

sub builtin_template {
    return shift->use('IO.Template')->replace_in_string(@_);
}

sub builtin_to_string {
    return ${shift->use('IO.Ref')->to_string(@_)};
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
    # Runs I<file> in bunit environment.
    local($_PM) = _pm($bunit);
    local($_TYPE, $_CLASS);
    local($_OPTIONS) = {};
    local($_PROTO) = $proto->package_name;
    my($t) = Bivio::Die->eval_or_die(
	"package $_PROTO;use strict;" . ${$_F->read($bunit)});
    $_TYPE ||= $_PROTO;
    return $_TYPE->run_unit($t);
}

sub run_unit {
    my($self) = shift;
    return (
	$self->new({
	    class_name => $self->builtin_class,
	    ref($self) ? %{$self->get_shallow_copy} : (),
	    %$_OPTIONS,
	})
    )->unit(@_);
}

sub _assert_expect {
    my($invert, $self, $expect, $actual) = @_;
    my($m) = $self->my_caller eq 'builtin_assert_equals'
	? 'nested_differences' : 'nested_contains';
    my($res) = $_R->$m($expect, $actual);
    Bivio::Die->throw_quietly(
	DIE => $invert
	    ? "unexpected match: ${$_R->to_string($expect)} == ${$_R->to_string($actual)}"
	    : "expected != actual:\n$$res",
    ) if $invert xor $res;
    return 1;
}

sub _call_class {
    my($func, $args) = @_;
    my($map, $class);
    foreach my $m (@$_CLASS_SEARCH) {
	next unless $class = $_CL->unsafe_map_require($m, $func);
	$map = $m;
	last;
    }
#TODO: Need to merge with ClassLoader->call_autoload
    unless ($class) {
	($map, $class) = $func =~ /^([A-Z][a-zA-Z]+)_([A-Z][A-Za-z0-9]+)$/;
	Bivio::Die->die(
	    $func, ': not a valid method of ', ref($_TYPE) || $_TYPE,
	    ' and not not found in these maps: ', $_CLASS_SEARCH,
	) unless $map && $_CL->is_map_configured($map)
	    and $class = $_CL->unsafe_map_require($map, $class);
    }
    if (my $method = $_CLASS_DISPATCH->{$map}) {
	return $_PROTO->$method($class->simple_package_name, @$args);
    }
    my($method) = $class->can('from_literal_or_die') ? 'from_literal_or_die'
	: 'new';
    return @$args ? $class->$method(@$args) : $class;
}

sub _called_in_closure {
    my($proto) = @_;
    return 0
	unless $proto->unsafe_current_self;
    foreach my $i (3..5) {
	my($sub) = (caller($i))[3];
	return 1
	    if $sub =~ qr{^\w+::Test::Unit::__ANON__$};
	last unless $sub =~ /AUTOLOAD|__ANON__/;
    }
    return 0;
}

sub _load_type_class {
    my($func, $args) = @_;
    $_TYPE = $_CL->map_require('TestUnit', $func);
    $_TYPE = $_TYPE->new_unit($_PROTO->builtin_class(), @$args)
	if $_TYPE->can('new_unit');
    $_TYPE_CAN_AUTOLOAD = $_TYPE->package_name ne $_PROTO
	&& defined(&{\&{$_TYPE->package_name . '::AUTOLOAD'}})
        ? 1 : 0;
    return $_TYPE;
}

sub _model {
    my($proto, $name, $query, $expect) = @_;
    my($have_expect) = @_ >= 4;
    # Returns a new model instance if just I<name>.  If I<query>, calls
    # unauth_load_or_die (PropertyModel), unauth_load_all (ListModel), or process
    # (FormModel).
    #
    # If I<expect>, calls map_iterate (PropertyModel in order of primary key) or
    # unauth_load_all (ListModel), and calls builtin_assert_contains(I<expect>,
    # I<result>).  Returns the complete data set in this last case.
    my($m) = $proto->use('Bivio::ShellUtil')->model($name);
    return $m
	unless $query;
    my($actual);
    my($is_unauth) = $proto->my_caller =~ /unauth/;
    my($method) = $is_unauth ? 'unauth_model' : 'model';
    if ($m->isa('Bivio::Biz::PropertyModel')) {
	return Bivio::ShellUtil->$method($name, $query)
	    unless $have_expect;
	$actual = $m->map_iterate(
	    undef,
	    $is_unauth ? 'unauth_iterate_start' : 'iterate_start',
	    undef,
	    $query,
	);
    }
    else {
	$m = Bivio::ShellUtil->$method($name, $query);
	return $m
	    unless $have_expect;
	$m->die($expect, ': expected not supported for FormModels')
	    if $m->isa('Bivio::Biz::FormModel');
	$actual = $m->map_rows;
    }
    $proto->builtin_assert_contains($expect, $actual)
	if defined($expect);
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
	$_PROTO . '.var' => {},
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

1;
