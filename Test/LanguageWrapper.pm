# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::LanguageWrapper;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
b_use('IO.Trace');

our($AUTOLOAD);
my($_CL) = b_use('IO.ClassLoader');
my($_L) = b_use('Test.Language');
our($_TRACE);

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

sub AUTOLOAD {
    return $_CL->call_autoload($AUTOLOAD, \@_, sub {
        my($func, $args) = @_;
        my($self) = $_L->assert_in_eval($func);
	b_die($self, " function $func: ", _check_autoload($self, $func))
	    if _check_autoload($self, $func);
	_trace($func, ' called with ', $args) if $_TRACE;
	my($td) = $self->unsafe_get('test_deviance');
	return $self->$func(@$args)
	    if !$td || $func =~ /^test_(?:conformance|deviance)$/;
	my($die) = Bivio::Die->catch_quietly(sub {
	    return $self->$func(@$args);
	});
	b_die($self, ' deviance call "', $td, '" failed to die: ', $func, $args)
	    unless $die;
	b_die($self, ' deviance call to ', $func, $args, ' failed with "',
	    $die, '" but did not match pattern: ', $td)
	    unless $die->as_string =~ $td;
	return;
    });
}

sub _check_autoload {
    my($self, $func) = @_;
    return 'test_setup() must be first function called in test script'
	unless $_L->is_blesser_of($self) || $func eq 'test_setup';
    return 'language function cannot begin with handle_ or internal_'
	if $func =~ /^(?:handle|internal)_/;
    return 'test function must be all lower case and begin with letter'
	unless $func =~ /^[a-z][a-z0-9_]+$/;
    return 'test function must contain an underscore (_)'
	unless $func =~ /_/ || Bivio::UNIVERSAL->can($func);
    return ref($self) . ' does not implement this function'
	unless $self->can($func);
    return;
}

1;
