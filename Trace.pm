# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Trace;
use strict;
$Bivio::Trace::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Trace - statement level trace management

=head1 SYNOPSIS

    use Bivio::Trace;
    Bivio::Trace->register;
    &T("this is my message");
    $T && &T("This is ", &a_complex, " list of arguments");
    Bivio::Trace->set_filters('/my message/');

=head1 DESCRIPTION

B<Bivio::Trace> is a module-level development and maintenance facility.  Trace
points are free-form text dispersed throughout a module which may be enabled
programmatically or via environment variables.

Tracing is enabled by modifying the L<filter|"filter"> which is a perl
expression that has access to package, line, etc.  If the filter returns true,
the trace point is printed using L<printer|"printer">, which by default prints
to C<STDERR>. The L<filter|"filter"> is initialized by the environment
variable C<BIVIO_TRACE>.

As an optimization, there is a first level L<package_filter|"package_filter">
which enables tracing at the package level.  For large applications, tracing
will be speeded up greatly by using the L<package_filter|"package_filter"> only.
The L<package_filter|"package_filter"> is initialized by the environment
variable C<BIVIO_TRACE_PACKAGES>.  If L<package_filter|"package_filter"> is
defined and L<filter|"filter"> is undefined,
L<filter|"filter">  will be treated as always true.

=cut

use Carp ();

#=VARIABLES

# Maximum length of a string in $msg
my($_MAX_STRING) = 256;

# Packages which are registered
my(@_REGISTERED) = ();

# The package sub must be registered to be false, because of the
# algorithm in &_define_pkg_symbols.
my($_POINT_FILTER, $_PKG_FILTER);
# This must be visible to the outside world.
$Bivio::Trace::_POINT_SUB = undef;
my($_PKG_SUB) = \&_false;

# Sub used for printing.  See &print.
my($_PRINTER) = \&default_printer;

#=INITIALIZATION

# If we are setuid or setgid, then don't initialize from environment
# variables.
if ($< == $> && $( == $)) {
    Bivio::Trace->set_filters($ENV{BIVIO_TRACE}, $ENV{BIVIO_TRACE_PACKAGES});
}

=head1 METHODS

=cut

=for html <a name="default_printer"></a>

=head2 default_printer(string arg1, ...) : boolean

Writes arguments to C<STDERR> and returns result.

=cut

sub default_printer {
    return print STDERR @_;
}

=for html <A name="filter"></A>

=head2 static filter() : string

Returns the current trace filter, or C<undef> if tracing is off.
To set, use L<set_filters|"set_filters">.

=cut

sub filter {
    return $_POINT_FILTER;
}

=for html <a name="package_filter"></a>

=head2 static package_filter() : string

Return the current package filter. 
To set, use L<set_filters|"set_filters">.

=cut

sub package_filter {
    return $_PKG_FILTER;
}

=for html <a name="print"></a>

=head2 print(string pkg, string file, int line, string sub, array msg) : boolean

Formats I<pkg>, I<file>, I<line>, I<sub>, and I<msg> into a pretty printed
string.  Care is taken to truncate too long arguments.  If an element of I<msg>
is an object which supports
<Bivio::UNIVERSAL::to_string|Bivio::UNIVERSAL/"to_string">, C<to_string> will
be called to convert the object to a string.

The formatted output is passed to L<printer|"printer"> and the result is
returned.

=cut

sub print {
    my($proto, $pkg, $file, $line, $sub, $msg) = @_;
    my($text) = defined($sub) ? $sub : defined($pkg) ? $pkg :
	    defined($file) ? $file : 'eval';
    defined($line) && ($text .= "[$line]");
    $text .= ' ';
    my($o);
    foreach $o (@$msg) {
	# Don't let to_string calls crash;
	$text .= substr(defined($o) ?
		&UNIVERSAL::can($o, 'to_string') ?
		(eval {$o->to_string} || $o) : $o
		: 'undef', 0, $_MAX_STRING);
    }
    return &$_PRINTER($text . "\n");
}

=for html <a name="printer"></a>

=head2 printer() : sub

Returns the current printer.  To see, see L<set_printer|"set_printer">.

=cut

sub printer {
    return $_PRINTER;
}

=for html <a name="register"></a>

=head2 static register()

Registers the calling package for tracing.  This will create two entities in
the calling package:

=over 4

=item $_TRACE

is defined if tracing is turned on in the calling package.

=item &_trace

is the routine to define a trace point.

=back

These values will be modified dynamically as tracing is turned on/off
programmatically.

Use C<&_trace> for defining trace_points.  To avoid argument computation, use
the form:

    &_trace(bla, bla, bla, bla)
            if $_TRACE;

You will need to experiment with which trace points are expensive and require
this more elaborate form.  In general, a simple string argument

=cut

sub register {
    my($proto) = @_;
    my($pkg) = caller;
    defined($pkg) && $pkg ne 'main'
	    || &Carp::croak('registrations may only occur packages',
		    ' other than main');
    # already registered?
    grep($pkg eq $_, @_REGISTERED) && return;
    push(@_REGISTERED, $pkg);
    &_define_pkg_symbols($pkg, $Bivio::Trace::_POINT_SUB, $_PKG_SUB);
}

=for html <a name="set_filters"></a>

=head2 static set_filters(string point_expr, string pkg_expr) : (string, string)

Sets the L<filter|"filter"> to I<point_expr> which may be C<undef>
and L<package_filter|"package_filter"> to I<pkg_expr> which may be C<undef>.
Both expressions have full access to perl.

I<point_expr> has access to the following variables:

=over 4

=item $file

The file name containing the trace point.

=item $line

The line at which the trace point is defined.

=item $msg

An array of arguments to the trace point function.  You might want to check for
something interesting in the message, e.g.

    grep(/something interesting/, @$msg)

=item $pkg

The package defining the trace point.

=item $sub

The subroutine containing the trace point--includes the package
name.

=back

If you want to see all possible trace output, set the point filter to "1" and
the package filter to C<undef>.  This particular filter is optimized specially.

By setting the package filter, you are controlling the values of
C<&_trace> and C<$_TRACE> directly.  If a particular package
matches the filter, then its C<$_TRACE> will be true and C<&_trace>
will be configured to generate output if L<filter|"filter"> returns
true.

The package filter has access to the following variable:

=over 4

=item $_

The package registered for tracing.

=back

To turn off tracing, use:

    Periscope::Trace->set_filters(undef, undef);

Returns the previous filters.

=cut

sub set_filters {
    my(undef, $point_filter, $pkg_filter) = @_;
    my($prev_point, $prev_pkg) = ($_POINT_FILTER, $_PKG_FILTER);
    # If package filter w/o point filter, force to be true.
    my($point_sub, $pkg_sub);
    if (defined($point_filter)) {
	if ($point_filter =~ '^\s*1\s*$') {
	    $point_sub = undef;
	}
	else {
	    $point_sub = eval <<"EOF";
                use strict;
		sub {
		    my(\$pkg, \$file, \$line, \$sub, \$msg) = \@_;
		    ($point_filter) || return 0;
                    return Bivio::Trace->print(\$pkg, \$file,
                            \$line, \$sub, \$msg);
		}
EOF
            defined($point_sub) || &Carp::croak("point filter invalid: $@");
	}
    }
    if (defined($pkg_filter)) {
	$pkg_sub = eval <<"EOF";
	sub {
            local(\$_) = \@_;
            return $pkg_filter;
        }
EOF
	defined($pkg_sub) || &Carp::croak("package filter invalid: $@");
    }
    else {
	$pkg_sub = defined($point_filter) ? \&_true : \&_false;
    }
    my($pkg);
    foreach $pkg (@_REGISTERED) {
	&_define_pkg_symbols($pkg, $point_sub, $pkg_sub);
    }
    ($_POINT_FILTER, $Bivio::Trace::_POINT_SUB, $_PKG_FILTER, $_PKG_SUB)
	    = ($point_filter, $point_sub, $pkg_filter, $pkg_sub);
    return ($prev_point, $prev_pkg);
}

=for html <a name="set_printer"></a>

=head2 set_printer(sub printer) : sub

Sets the routine which does the actual output.  By default, this is
<default_printer|"default_printer">.

To get the current value, call L<printer|"printer">.

Returns the previous printer.

=cut

sub set_printer {
    my($proto, $printer) = @_;
    defined(&{$printer}) || &Carp::croak('printer is not a valid subroutine');
    my($old_printer) = $_PRINTER;
    $_PRINTER = $printer;
    return $old_printer;
}

#=PRIVATE METHODS

sub _define_pkg_symbols {
    my($pkg, $point_sub, $pkg_sub) = @_;
    my($trace, $sub) = '1';
    unless (&$pkg_sub($pkg)) {
	# Tracing is off
	$trace = 'undef';
	$sub = 'return 0';
    }
    else {
	# Tracing is on
	$sub = 'return '
		. (defined($point_sub)
			? '&{$Bivio::Trace::_POINT_SUB}'
			: 'Bivio::Trace->print')
	        # caller(1) can return an empty array, hence '|| undef'
		. '((caller), (caller(1))[$[+3] || undef, \@_)';
    }
    eval <<"EOF" || die("internal inconsistency: $@");
        package $pkg;
        use Bivio::Trace;
        use strict;
        \$${pkg}::_TRACE = $trace;
        BEGIN {
            undef(&_trace);
        }
	sub _trace {
            $sub;
	}
	1;
EOF
}


sub _false {
    return 0;
}

sub _true {
    return 1;
}

=head1 ENVIRONMENT

=over 4

=item $BIVIO_TRACE

initial value of L<filter|"filter"> only if the program is not running
setuid or setgid.

=item $BIVIO_TRACE_PACKAGES

initial value of L<package_filter|"package_filter"> only if the program is not
running setuid or setgid.

=back

=head1 BUGS

The filters are a huge security hole.  A proper implementation would only allow
certain operations within the filter.  This is not possible at this time
without creating a special interpreter.  Therefore, environment variable
initialization can't be used if the program is setgid or setuid.  Moreover,
programmitic control must be limited.  In general, an expression builder should
be provided to allow the developer enough flexibility to debug without allowing
full perl expressions.  Limiting the filters to regular expressions does
nothing to reduce the risk due to perl's string interpolation facilities.

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
