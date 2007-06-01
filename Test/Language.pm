# Copyright (c) 2001 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::Test::Language;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';
use Bivio::IO::ClassLoader;
use Bivio::IO::Config;
use Bivio::IO::File;
use Bivio::IO::Trace;
use File::Basename ();
use File::Spec ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
my($_IDI) = __PACKAGE__->instance_data_index;
our($_SELF_IN_EVAL);
Bivio::IO::Config->register(my $_CFG = {
    log_dir => 'log',
});
my($_INLINE) = 'inline00000';

sub AUTOLOAD {
    my(undef, @args) = _args(@_);
    # Calls the test language function.
    my($func) = $AUTOLOAD;
    $func =~ s/.*:://;
    my($self) = _assert_in_eval($func);
    _die($self, " function $func: ", _check_autoload($self, $func))
	if _check_autoload($self, $func);
    _trace($func, ' called with ', \@args) if $_TRACE;
    my($td) = $self->unsafe_get('test_deviance');
    return $self->$func(@args)
	unless $td;
    my($die) = Bivio::Die->catch(sub {
	return $self->$func(@args);
    });
    _die($self, ' deviance call "', $td, '" failed to die: ', $func, \@args)
	unless $die;
    _die($self, ' deviance call to ', $func, \@args, ' failed with "',
	$die, '" but did not match pattern: ', $td)
	unless $die->as_string =~ $td;
    return;
}

sub DESTROY {
    # You probably don't want to define a DESTROY method.  Instead create a
    # L<handle_cleanup|"handle_cleanup">.
    #
    # Subclasses should implement:
    #
    #     sub DESTROY {
    #         my($self) = @_;
    #         my destroy code....
    #         return $self->SUPER::DESTROY;
    #     }
    return;
}

sub handle_cleanup {
    my($self) = @_;
    # Processes cleanup arguments.  See L<test_cleanup|"test_cleanup">.
    # Inverse operation of L<handle_setup|"handle_setup">.
    #
    # Test language classes should implement:
    #
    #     sub handle_cleanup {
    #         my($self, @cleanup_args) = @_;
    #         my cleanup up...;
    #         return $self->SUPER::handle_cleanup;
    #     }
    #
    # All values will be deleted.
    $self->delete_all;
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    # log_dir : string [log]
    #
    # Subdir of test which contains log files.  The log files are prefixed with the
    # test name.
    $_CFG = $cfg;
    return;
}

sub handle_setup {
    # Processes setup arguments.  See L<test_setup|"test_setup">.
    #
    # Test language classes should implement:
    #
    #     sub handle_setup {
    #         my($self, @setup_args) = @_;
    # 	$self->SUPER::handle_setup;
    #         my setup up...;
    #         return;
    #     }
    return;
}

sub new {
    my($proto, $attrs) = @_;
    # Instantiates this class.
    my($self) = $proto->SUPER::new($attrs);
    $self->[$_IDI] = {};
    return $self;
}

sub test_cleanup {
    my($proto) = _args(@_);
    # Clean up state, such as external files, database values, etc.
    # Must not rely on state of instance, but be able to clean up globally.
    #
    # This method is called automatically at the end of every test script.
    #
    # See L<handle_cleanup|"handle_cleanup"> for what subclasses should implement.
    return $proto->handle_cleanup;
}

sub test_conformance {
    # Turn off deviance testing mode.  See also L<test_deviance|"test_deviance">.
    _assert_in_eval('test_setup')->delete('test_deviance');
    return;
}

sub test_deviance {
    # Sets up test for deviance testing.  Expect all functions to fail.  If I<regex>
    # supplied, expect the exception (L<Bivio::Die|Bivio::Die>)
    # to contain I<regex>.  If I<regex> is a
    # string, will be compiled with qr/$regex/is.  See also
    # L<test_conformance|"test_conformance">
    if (ref($_[1]) eq 'CODE') {
	_do_deviance(@_);
    }
    else {
        my(undef, $regex) = _args(@_);
        _assert_in_eval('test_setup')->put(test_deviance =>
	    ref($regex) ? $regex : defined($regex) ? qr/$regex/is : qr//);
    }
    return;
}

sub test_equals {
    my($self, $expect, $actual);
    # Asserts I<expect> and I<actual> are identical.
    return unless my $d = Bivio::IO::Ref->nested_differences($expect, $actual);
    _die($self, $$d);
    # DOES NOT RETURN
}

sub test_log_output {
    my(undef, $file_name, $content) = _args(@_);
    # Writes output to a separate log file in I<test_log_prefix> directory.  Returns
    # the file name that was written or undef if no file was written (no
    # I<test_log_prefix>).
    return unless $_SELF_IN_EVAL;
    my($self) = _assert_in_eval('test_log_output');
    return unless ref($self) && $self->unsafe_get('test_log_prefix');
    return Bivio::IO::File->write(
	$self->get('test_log_prefix') . "/$file_name",
	ref($content) ? $content : \$content,
    );
}

sub test_name {
    # Returns the basename of the test_script.
    return File::Basename::basename(
	_assert_in_eval('test_name')->get('test_script'), '.btest');
}

sub test_ok {
    my($self) = shift;
    # Returns I<value> if true, else dies with I<msg>.
    return shift || _die($self, @_);
}

sub test_run {
    my($proto, $script) = @_;
    # Runs a script.  Cannot be called from within a script.  Returns undef if
    # everything goes ok.  Otherwise, returns the die instance created by the script.
    local($_SELF_IN_EVAL);
    my($script_name) = ref($script) ? $_INLINE++ : $script;
    my($die) = Bivio::Die->catch(sub {
	_die($_SELF_IN_EVAL, 'called ', $script_name,
	    ' from within test script')
	    if $_SELF_IN_EVAL;
	$_SELF_IN_EVAL = $proto->new({test_script => $script_name});
        $script = Bivio::IO::File->read($script_name)
	    unless ref($script);
	substr($$script, 0, 0) = 'use strict;';
	my($die) = Bivio::Die->catch($script);
	_trace($die) if $_TRACE;
	return unless $die;
	$_SELF_IN_EVAL->test_log_output('test_run.err',
	    $die->as_string . "\n" . $die->get('stack'))
	    if $_SELF_IN_EVAL;
	$die->throw;
	# DOES NOT RETURN
    });
    _trace($die) if $_TRACE;
    Bivio::Die->eval(sub {$_SELF_IN_EVAL->test_cleanup});
    _find_line_number($die, $script_name) if $die;
    _trace($script, ' ', $die) if $die && $_TRACE;
    return $die;
}

sub test_script {
    # Returns name of test script.
   return _assert_in_eval('test_script')->get('test_script');
}

sub test_setup {
    my($proto, $map_class, @setup_args) = _args(@_);
    # Loads TestLanguage I<map_class>.  Calls L<new|"new"> on the loaded class and
    # then calls L<handle_setup|"handle_setup"> with I<setup_args> on newly created
    # test instance.
    my($self) = _assert_in_eval('test_setup');
    _die($proto, 'called test_setup() twice') if $self->[$_IDI]->{setup_called}++;
    my($subclass) = Bivio::IO::ClassLoader->map_require(
	'TestLanguage', $map_class);
    _die($proto, "$subclass is not a ", __PACKAGE__, ' class')
	unless $subclass->isa(__PACKAGE__);
    _trace($subclass, ' setup with ', \@setup_args) if $_TRACE;
    my($new_self) = $subclass->new;
    _die($proto, "$subclass\->new didn't create an instance of ", __PACKAGE__)
	unless $new_self->isa(__PACKAGE__);
    $new_self->put(
	test_script => $self->get('test_script'),
	test_log_prefix => _log_prefix($self->get('test_script')),
    );
    $_SELF_IN_EVAL = $new_self;
    _trace($_SELF_IN_EVAL);
    $_SELF_IN_EVAL->handle_setup(@setup_args);
    return $_SELF_IN_EVAL;
}

sub _args {
    # Detects if first argument is $proto or not.  When view_*() methods
    # are called from view files or templates, they are not given a $proto.
    return defined($_[0]) && UNIVERSAL::isa(ref($_[0]) || $_[0], __PACKAGE__)
	? @_ : (__PACKAGE__, @_);
}

sub _assert_in_eval {
    my($op) = @_;
    # Returns the current test or terminates.
    Bivio::Die->die($op, ': attempted operation outside test script')
	unless $_SELF_IN_EVAL;
    return $_SELF_IN_EVAL;
}

sub _check_autoload {
    my($self, $func) = @_;
    # Returns false if ok.
    return 'test_setup() must be first function called in test script'
	if ref($self) eq __PACKAGE__;
    return 'language function cannot begin with test_ or handle_'
	if $func =~ /^(?:test|handle)_/;
    return 'test function must be all lower case and begin with letter'
	unless $func =~ /^[a-z][a-z0-9_]+$/;
    return 'test function must contain an underscore (_)'
	unless $func =~ /_/;
    return ref($self) . ' does not implement this function'
	unless $self->can($func);
    return;
}

sub _die {
    my(undef, @msg) = @_;
    # Call die with appropriate prefix.
    Bivio::Die->die(@msg);
    # DOES NOT RETURN
}

sub _do_deviance {
    my($self, $dev_block, $regex) = @_;
    $regex = defined($regex) ? qr/$regex/is : qr//
        unless ref($regex);
    my($die) = Bivio::Die->catch($dev_block);
    _die($self, ' deviance call "', $regex, '" failed to die.')
	unless $die;
    _die($self, ' deviance call failed with "',
	$die, '" but did not match pattern: ', $regex)
	unless $die->as_string =~ $regex;

    return;
}

sub _find_line_number {
    my($die, $script_name) = @_;
    # Find the line number of error in the test script.
    return unless my($stack) = $die->get('stack');
    my($line) = $stack =~ /.* at \(eval \d+\) line (\d+)\s+eval '/s;
    substr($die->get('attrs')->{message}, 0, 0) = "$script_name, line $line: "
	if $line;
    return;
}

sub _log_prefix {
    my($script_name) = @_;
    # Parses test_script and writes log prefix.
    my($v, $d, $f) = File::Spec->splitpath(File::Spec->rel2abs($script_name));
    $f =~ s/(?<=.)\.[^\.]+$//g;
    return Bivio::IO::File->mkdir_p(
	Bivio::IO::File->rm_rf(
	    File::Spec->catpath(
		'',
		File::Spec->catpath(
		    $v, $d, $_CFG->{log_dir}),
		$f)));
}

1;
