# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Test::Language;
use strict;
$Bivio::Test::Language::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Language::VERSION;

=head1 NAME

Bivio::Test::Language - superclass of all acceptance test languages

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Language;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Test::Language::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Test::Language> is a framework for acceptance testing.  A test script
is a Perl program which is evaluated within the context of this class.  The
first line consists of a call to L<test_setup|"test_setup">, which identifies a
subclass of this class.  The subclass defines methods which are called with an
instance created during L<test_setup|"test_setup">.  The instance contains
state about the test, e.g. cookies and connections to servers.

=head1 ATTRIBUTES

=over 4

=item script : string

file name of the script

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::File;
use Bivio::IO::ClassLoader;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
use vars ('$AUTOLOAD');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_SELF_IN_EVAL);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::Test::Language

Instantiates this class.

=cut

sub new {
    my($proto, $attrs) = @_;
    my($self) = $proto->SUPER::new($attrs);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="AUTOLOAD"></a>

=head2 AUTOLOAD(...) : any

Calls the test language function.

=cut

sub AUTOLOAD {
    my(undef, @args) = _args(@_);
    my($func) = $AUTOLOAD;
    $func =~ s/.*:://;
    my($self) = _assert_in_eval($func);
    _die($self, "function $func: ", _check_autoload($self, $func))
	if _check_autoload($self, $func);
    _trace($func, ' called with ', \@args) if $_TRACE;
    return $self->$func(@args);
}

=for html <a name="DESTROY"></a>

=head2 DESTROY()

You probably don't want to define a DESTROY method.  Instead create a
L<handle_cleanup|"handle_cleanup">.

Subclasses should implement:

    sub DESTROY {
        my($self) = @_;
        my destroy code....
        return $self->SUPER::DESTROY;
    }

=cut

sub DESTROY {
    return;
}

=for html <a name="handle_cleanup"></a>

=head2 handle_cleanup()

Processes cleanup arguments.  See L<test_cleanup|"test_cleanup">.
Inverse operation of L<handle_setup|"handle_setup">.

Test language classes should implement:

    sub handle_cleanup {
        my($self, @cleanup_args) = @_;
        my cleanup up...;
        return $self->SUPER::handle_cleanup;
    }

=cut

sub handle_cleanup {
    return;
}

=for html <a name="handle_setup"></a>

=head2 handle_setup(any setup_arg, ...)

Processes setup arguments.  See L<test_setup|"test_setup">.

Test language classes should implement:

    sub handle_setup {
        my($self, @setup_args) = @_;
	$self->SUPER::handle_setup;
        my setup up...;
        return;
    }

=cut

sub handle_setup {
    return;
}

=for html <a name="test_cleanup"></a>

=head2 static test_cleanup()

Clean up state, such as external files, database values, etc.
Must not rely on state of instance, but be able to clean up globally.

This method is called automatically at the end of every test script.

See L<handle_cleanup|"handle_cleanup"> for what subclasses should implement.

=cut

sub test_cleanup {
    my($proto) = @_;
    return ($_SELF_IN_EVAL || $proto)->handle_cleanup();
}

=for html <a name="test_run"></a>

=head2 static test_run(string script_name) : Bivio::Die

=head2 static test_run(string_ref script) : Bivio::Die

Runs a script.  Cannot be called from within a script.  Returns undef if
everything goes ok.  Otherwise, returns the die instance created by the script.

=cut

sub test_run {
    my($proto, $script) = @_;
    my($die) = Bivio::Die->catch(sub {
	my($script_name) = ref($script) ? '<inline>' : $script;
	_die($_SELF_IN_EVAL, 'called ', $script_name,
	    ' from within test script')
	    if $_SELF_IN_EVAL;
	$_SELF_IN_EVAL = $proto->new({test_script => $script_name});
        $script = Bivio::IO::File->read($script_name) unless ref($script);
	substr($$script, 0, 0) = 'use strict;';
	my($die) = Bivio::Die->catch($script);
	$die->throw if $die;
	return;
    });
    Bivio::Die->eval(sub {$_SELF_IN_EVAL->test_cleanup});
    $_SELF_IN_EVAL = undef;
    _trace($script, ' ', $die) if $die && $_TRACE;
    return $die;
}

=for html <a name="test_setup"></a>

=head2 static test_setup(string map_class, array setup_args) : Bivio::Test::Language

Loads TestLanguage I<map_class>.  Calls L<new|"new"> on the loaded class and
then calls L<handle_setup|"handle_setup"> with I<setup_args> on newly created
test instance.

=cut

sub test_setup {
    my($proto, $map_class, @setup_args) = _args(@_);
    my($self) = _assert_in_eval('test_setup');
    _die('called test_setup() twice') if $self->[$_IDI]->{setup_called};
    my($subclass) = Bivio::IO::ClassLoader->map_require('TestLanguage', $map_class);
    _die("$subclass is not a ", __PACKAGE__, ' class')
	unless $subclass->isa(__PACKAGE__);
    _trace($subclass, ' setup with ', \@setup_args) if $_TRACE;
    my($new_self) = $subclass->new;
    _die("$subclass\->new didn't create an instance of ", __PACKAGE__)
	unless $new_self->isa(__PACKAGE__);
    $new_self->put(test_script => $self->get('test_script'));
    $_SELF_IN_EVAL = $new_self;
    _trace($_SELF_IN_EVAL);
    $_SELF_IN_EVAL->handle_setup(@setup_args);
    return $_SELF_IN_EVAL;
}

#=PRIVATE METHODS

# _args(...) : array
#
# Detects if first argument is $proto or not.  When view_*() methods
# are called from view files or templates, they are not given a $proto.
#
sub _args {
    return defined($_[0]) && $_[0] eq __PACKAGE__ ? @_ : (__PACKAGE__, @_);
}

# _assert_in_eval() : Bivio::Test::Language
#
# Returns the current test or terminates.
#
sub _assert_in_eval {
    my($op) = @_;
    Bivio::Die->die($op, ': attempted operation outside test script')
	unless $_SELF_IN_EVAL;
    return $_SELF_IN_EVAL;
}

# _check_autoload(self, string func) : string
#
# Returns false if ok.
#
sub _check_autoload {
    my($self, $func) = @_;
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

# _die(self, array msg)
#
# Call die with appropriate prefix.
#
sub _die {
    my($self, @msg) = @_;
    Bivio::Die->die(ref($self) ? $self->get('test_script') : __PACKAGE__, @msg);
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
