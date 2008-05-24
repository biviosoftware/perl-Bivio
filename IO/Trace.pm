# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::IO::Trace;
use strict;
use base 'Bivio::UNIVERSAL';

# B<Bivio::IO::Trace> is a module-level development and maintenance facility.
# Trace points are free-form text dispersed throughout a module which may be
# enabled programmatically or via environment variables.
#
# You can enable tracing from the command line, e.g.
#
#    b-petshop create_db --TRACE=/SQL::Connection/
#
# This turns on trace points in all packages which match the pattern
# C</SQL::Connection/>. This argument is handled specially by
# L<Bivio::IO::Config|Bivio::IO::Config>.  See this class for more info.
#
# Tracing is enabled by modifying the L<get_call_filter|"get_call_filter"> which
# is a perl expression that has access to package, line, etc.  If the call filter
# returns true, the trace point is printed using L<get_printer|"get_printer">,
# which by default prints via
# L<Bivio::IO::Alert::print|Bivio::IO::Alert/"print">.
#
# As an optimization, there is a first level
# L<get_package_filter|"get_package_filter"> which enables tracing at the package
# level.  For large applications, tracing will be speeded up greatly by using the
# L<get_package_filter|"get_package_filter"> only. If
# L<get_package_filter|"get_package_filter"> is defined and
# L<get_call_filter|"get_call_filter"> is undefined,
# L<get_call_filter|"get_call_filter"> will be treated as always true.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my(@_REGISTERED, $_CALL_FILTER, $_PKG_FILTER, $_PKG_SUB, $_PRINTER);
BEGIN {
    # Packages which are registered
    @_REGISTERED = ();
    # The package sub must be registered to be false, because of the
    # algorithm in _define_pkg_symbols().
    # This must be visible to the outside world.
    $Bivio::IO::Trace::_CALL_SUB = undef;
    $_PKG_SUB = \&_false;
    # Sub used for printing.  See &print.
    $_PRINTER = \&default_printer;
}
my($_IS_NAMED) = qr{^[\w:]+$}i;

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::IO::Config;

Bivio::IO::Config->register({
    Bivio::IO::Config->NAMED => {
	call_filter => undef,
	package_filter => undef,
    },
    printer => \&default_printer,
    command_line_arg => undef,
});

sub default_printer {
    # (self, string) : boolean
    # Writes I<msg> to
    # L<Bivio::IO::Alert::print_literally|Bivio::IO::Alert/"print_literally">
    # and returns result.
    my($msg) = @_;
    return Bivio::IO::Alert->print_literally($msg);
}

sub get_call_filter {
    # (proto) : string
    # Returns the current call filter, or C<undef> if tracing is off.
    # To set, use L<set_filters|"set_filters">.
    return $_CALL_FILTER;
}

sub get_package_filter {
    # (proto) : string
    # Return the current package filter.
    # To set, use L<set_filters|"set_filters">.
    return $_PKG_FILTER;
}

sub get_printer {
    # (proto) : sub
    # Returns the current printer.  To see, see L<set_printer|"set_printer">.
    return $_PRINTER;
}

sub handle_config {
    # (proto, hash) : undef
    # call_filter : string [undef]
    #
    # Initial L<get_call_filter|"get_call_filter">
    #
    # package_filter : string [undef]
    #
    # Initial L<get_package_filter|"get_package_filter">
    #
    # printer : code [default_printer]
    #
    # Initial L<get_printer|"get_printer">
    my($proto, $cfg) = @_;
    my($named);
    my($c) = !$cfg->{command_line_arg} ? $cfg
	: $cfg->{command_line_arg} =~ $_IS_NAMED
	? ($named = $cfg->{command_line_arg})
	: {package_filter => $cfg->{command_line_arg}};
    $named ? $proto->set_named_filters($named)
	: $proto->set_filters($c->{call_filter}, $c->{package_filter});
    $proto->set_printer($cfg->{printer});
    return;
}

sub import {
    # (self) : undef
    # Registers the calling package for tracing.  This will create two entities in
    # the calling package:
    #
    #
    # $_TRACE
    #
    # is defined if tracing is turned on in the calling package.
    # It is common place to use it as the qualifier to any trace statement,
    # since it is faster than calling the subroutine if tracing is off
    # in the calling package.
    #
    # _trace()
    #
    # is the routine to define a trace point.
    #
    #
    # These values will be modified dynamically as tracing is turned on/off
    # programmatically.
    #
    # Use C<_trace()> for defining trace_points.  To avoid argument computation, we
    # always use the form:
    #
    #     _trace(bla, bla, bla, bla) if $_TRACE;
    #
    # You will need to experiment with which trace points are expensive, but
    # the C<if $_TRACE> predicate is one of the fastest statements in perl.
    my($pkg) = caller();
    push(@_REGISTERED, $pkg)
	unless grep($pkg eq $_, @_REGISTERED);
    _define_pkg_symbols($pkg, $Bivio::IO::Trace::_CALL_SUB, $_PKG_SUB);
    return;
}

sub print {
    # (proto, string, string, int, string, array) : boolean
    # Formats output with L<Bivio::IO::Alert::format|Bivio::IO::Alert/"format"> and
    # writes the result using L<get_printer|"get_printer">, whose result is returned.
    shift(@_);
    return $_PRINTER->(Bivio::IO::Alert->format(@_));
}

sub register {
    # (proto) : undef
    # B<DEPRECATED> automatically registered with L<import|"import">.
}

sub set_filters {
    # (proto, string, string) : (string, string)
    # Sets the L<get_call_filter|"get_call_filter"> to I<point_expr> which may be C<undef>
    # and L<get_package_filter|"get_package_filter"> to I<pkg_expr> which may be C<undef>.
    # Both expressions have full access to perl.
    #
    # I<point_expr> has access to the following variables:
    #
    #
    # $file : string
    #
    # The file name containing the trace point.
    #
    # $line : int
    #
    # The line at which the trace point is defined.
    #
    # $msg : array_ref
    #
    # An array of arguments to the trace point function.  You might want to check for
    # something interesting in the message, e.g.
    #
    #     grep(/something interesting/, @$msg)
    #
    # $pkg : string
    #
    # The package defining the trace point.
    #
    # $sub : string
    #
    # The subroutine containing the trace point--includes the package
    # name.
    #
    #
    # If you want to see all possible trace output, set the call filter to "1" and
    # the package filter to C<undef>.  This particular filter is optimized specially.
    #
    # By setting the package filter, you are controlling the values of
    # C<_trace> and C<$_TRACE> directly.  If a particular package
    # matches the filter, then its C<$_TRACE> will be true and C<_trace>
    # will be configured to generate output if L<get_call_filter|"get_call_filter">
    # returns true.
    #
    # The package filter has access to the following variable:
    #
    #
    # $_
    #
    # The package registered for tracing.
    #
    #
    # To turn off tracing, use:
    #
    #     Bivio::IO::Trace->set_filters(undef, undef);
    #
    # Returns the previous filters.
    my(undef, $call_filter, $pkg_filter) = @_;
    my($prev_point, $prev_pkg) = ($_CALL_FILTER, $_PKG_FILTER);
    # If package filter w/o point filter, force to be true.
    my($call_sub, $pkg_sub);
    if (defined($call_filter)) {
	if ($call_filter =~ /^\s*1\s*$/s) {
	    $call_sub = undef;
	}
	else {
	    local($SIG{__DIE__});
	    $call_sub = eval <<"EOF";
                use strict;
		sub {
		    my(\$pkg, \$file, \$line, \$sub, \$msg) = \@_;
		    ($call_filter) || return 0;
                    return Bivio::IO::Trace->print(\$pkg, \$file,
                            \$line, \$sub, \$msg);
		}
EOF
            defined($call_sub) || die("call filter invalid: $@");
	}
    }
    if (defined($pkg_filter)) {
	$pkg_sub = eval <<"EOF";
	sub {
            local(\$_) = \@_;
            return $pkg_filter;
        }
EOF
	defined($pkg_sub) || die("package filter invalid: $@");
    }
    else {
	$pkg_sub = defined($call_filter) ? \&_true : \&_false;
    }
    my($pkg);
    foreach $pkg (@_REGISTERED) {
	_define_pkg_symbols($pkg, $call_sub, $pkg_sub);
    }
    ($_CALL_FILTER, $Bivio::IO::Trace::_CALL_SUB, $_PKG_FILTER, $_PKG_SUB)
	    = ($call_filter, $call_sub, $pkg_filter, $pkg_sub);
    return ($prev_point, $prev_pkg);
}

sub set_named_filters {
    my($proto, $name) = @_;
    my($c) = defined($name) ?
	$name =~ /^\w+$/ && Bivio::IO::Config->unsafe_get($name) || {
	    call_filter => undef,
	    package_filter => $name =~ $_IS_NAMED ? "m{$name}i"
		: die($name, ': invalid named filter'),
	}
        : {};
    $proto->set_filters($c->{call_filter}, $c->{package_filter});
    return;
}

sub set_printer {
    # (self, sub) : sub
    # Sets the routine which does the actual output.  By default, this is
    # <default_printer|"default_printer">.
    #
    # To get the current value, call L<get_printer|"get_printer">.
    #
    # Returns the previous printer.
    my($proto, $printer) = @_;
    defined(&{$printer}) || die('printer is not a valid subroutine');
    my($old_printer) = $_PRINTER;
    $_PRINTER = $printer;
    return $old_printer;
}

sub _define_pkg_symbols {
    my($pkg, $call_sub, $pkg_sub) = @_;
    my($trace, $sub);
    unless ($pkg_sub->($pkg)) {
	# Tracing is off
	$trace = undef;
	$sub = sub {return};
    }
    else {
	# Tracing is on
	$trace = 1;
	$sub = eval 'sub {return '
		. (defined($call_sub)
			? '$Bivio::IO::Trace::_CALL_SUB->'
			: 'Bivio::IO::Trace->print')
	        # caller(1) can return an empty array, hence '|| undef'
		. '((caller), (caller(1))[$[+3] || undef, \@_)}';
    }
    # Look Ma! No evals!!
    no strict qw(refs);
    *{$pkg.'::_TRACE'} = \$trace;
    # Suppress 'Subroutine %s redefined' warning
    local($^W) = 0;
    *{$pkg.'::_trace'} = $sub;
    return;
}

sub _false {
    return 0;
}

sub _true {
    return 1;
}

1;
