# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::IO::Trace;
use strict;
$Bivio::IO::Trace::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::IO::Trace - statement level trace management

=head1 SYNOPSIS

    use Bivio::IO::Trace;

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::Alert::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

B<Bivio::IO::Trace> is a module-level development and maintenance facility.
Trace points are free-form text dispersed throughout a module which may be
enabled programmatically or via environment variables.

Tracing is enabled by modifying the L<get_filter|"get_filter"> which is a perl
expression that has access to package, line, etc.  If the filter returns true,
the trace point is printed using L<get_printer|"get_printer">, which by default
prints via L<Bivio::IO::Alert::print|Bivio::IO::Alert/"print">.  The
L<get_filter|"get_filter"> is initialized by the environment variable
C<BIVIO_TRACE>.

As an optimization, there is a first level
L<get_package_filter|"get_package_filter"> which enables tracing at the package
level.  For large applications, tracing will be speeded up greatly by using the
L<get_package_filter|"get_package_filter"> only.  The
L<get_package_filter|"get_package_filter"> is initialized by the environment
variable C<BIVIO_TRACE_PACKAGES>.  If
L<get_package_filter|"get_package_filter"> is defined and
L<get_filter|"get_filter"> is undefined, L<get_filter|"get_filter"> will be
treated as always true.

=cut

#=VARIABLES
my(@_REGISTERED, $_POINT_FILTER, $_PKG_FILTER, $_PKG_SUB, $_PRINTER);
BEGIN {
    # Packages which are registered
    @_REGISTERED = ();
    # The package sub must be registered to be false, because of the
    # algorithm in &_define_pkg_symbols.
    # This must be visible to the outside world.
    $Bivio::IO::Trace::_POINT_SUB = undef;
    $_PKG_SUB = \&_false;
    # Sub used for printing.  See &print.
    $_PRINTER = \&default_printer;
}

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Carp ();

Bivio::IO::Config->register({
    'filter' => undef,
    'package_filter' => undef,
    'printer' => \&default_printer,
});

=head1 METHODS

=cut

=for html <a name="default_printer"></a>

=head2 default_printer(string msg) : boolean

Writes I<msg> to
L<Bivio::IO::Alert::print_literally|Bivio::IO::Alert/"print_literally">
and returns result.

=cut

sub default_printer {
    my($msg) = @_;
    return Bivio::IO::Alert->print_literally($msg);
}


=for html <A name="get_filter"></A>

=head2 static get_filter() : string

Returns the current trace filter, or C<undef> if tracing is off.
To set, use L<set_filters|"set_filters">.

=cut

sub get_filter {
    return $_POINT_FILTER;
}

=for html <a name="get_package_filter"></a>

=head2 static get_package_filter() : string

Return the current package filter.
To set, use L<set_filters|"set_filters">.

=cut

sub get_package_filter {
    return $_PKG_FILTER;
}

=for html <a name="get_printer"></a>

=head2 static get_printer() : sub

Returns the current printer.  To see, see L<set_printer|"set_printer">.

=cut

sub get_printer {
    return $_PRINTER;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item filter : string [undef]

Initial L<get_filter|"get_filter">

=item package_filter : string [undef]

Initial L<get_package_filter|"get_package_filter">

=item printer : code [default_printer]

Initial L<get_printer|"get_printer">

=back

=cut

sub handle_config {
    my($class, $cfg) = @_;
    &set_filters(undef, $cfg->{filter}, $cfg->{package_filter});
    &set_printer(undef, $cfg->{printer});
}

=for html <a name="print"></a>

=head2 static print(string pkg, string file, int line, string sub, array msg) : boolean

Formats output with L<Bivio::IO::Alert::format|Bivio::IO::Alert/"format"> and
writes the result using L<get_printer|"get_printer">, whose result is returned.

=cut

sub print {
    shift(@_);
    return &$_PRINTER(Bivio::IO::Alert->format(@_));
}

=for html <a name="register"></a>

=head2 static register()

Registers the calling package for tracing.  This will create two entities in
the calling package:

=over 4

=item $_TRACE

is defined if tracing is turned on in the calling package.
It is common place to use it as the qualifier to any trace statement,
since it is faster than calling the subroutine if tracing is off
in thecalling package.

=item _trace()

is the routine to define a trace point.

=back

These values will be modified dynamically as tracing is turned on/off
programmatically.

Use C<_trace()> for defining trace_points.  To avoid argument computation, use
the form:

    _trace(bla, bla, bla, bla) if $_TRACE;

You will need to experiment with which trace points are expensive.

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
    &_define_pkg_symbols($pkg, $Bivio::IO::Trace::_POINT_SUB, $_PKG_SUB);
}

=for html <a name="set_filters"></a>

=head2 static set_filters(string point_expr, string pkg_expr) : (string, string)

Sets the L<get_filter|"get_filter"> to I<point_expr> which may be C<undef>
and L<get_package_filter|"get_package_filter"> to I<pkg_expr> which may be C<undef>.
Both expressions have full access to perl.

I<point_expr> has access to the following variables:

=over 4

=item $file : string

The file name containing the trace point.

=item $line : int

The line at which the trace point is defined.

=item $msg : array_ref

An array of arguments to the trace point function.  You might want to check for
something interesting in the message, e.g.

    grep(/something interesting/, @$msg)

=item $pkg : string

The package defining the trace point.

=item $sub : string

The subroutine containing the trace point--includes the package
name.

=back

If you want to see all possible trace output, set the point filter to "1" and
the package filter to C<undef>.  This particular filter is optimized specially.

By setting the package filter, you are controlling the values of
C<&_trace> and C<$_TRACE> directly.  If a particular package
matches the filter, then its C<$_TRACE> will be true and C<&_trace>
will be configured to generate output if L<get_filter|"get_filter"> returns
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
	if ($point_filter =~ /^\s*1\s*$/s) {
	    $point_sub = undef;
	}
	else {
	    local($SIG{__DIE__});
	    $point_sub = eval <<"EOF";
                use strict;
		sub {
		    my(\$pkg, \$file, \$line, \$sub, \$msg) = \@_;
		    ($point_filter) || return 0;
                    return Bivio::IO::Trace->print(\$pkg, \$file,
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
    ($_POINT_FILTER, $Bivio::IO::Trace::_POINT_SUB, $_PKG_FILTER, $_PKG_SUB)
	    = ($point_filter, $point_sub, $pkg_filter, $pkg_sub);
    return ($prev_point, $prev_pkg);
}

=for html <a name="set_printer"></a>

=head2 set_printer(sub printer) : sub

Sets the routine which does the actual output.  By default, this is
<default_printer|"default_printer">.

To get the current value, call L<get_printer|"get_printer">.

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
			? '&{$Bivio::IO::Trace::_POINT_SUB}'
			: 'Bivio::IO::Trace->print')
	        # caller(1) can return an empty array, hence '|| undef'
		. '((caller), (caller(1))[$[+3] || undef, \@_)';
    }
    Bivio::IO::Alert->bootstrap_die("internal inconsistency: $@")
	unless eval <<"EOF";
        package $pkg;
        use Bivio::IO::Trace;
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

=head1 BUGS

The filters are a huge security hole.  A proper implementation would only allow
certain operations within the filter.  This is not possible at this time
without creating a special interpreter.  Therefore, environment variable
initialization can't be used if the program is setgid or setuid.  Moreover,
programmatic control must be limited.  In general, an expression builder should
be provided to allow the developer enough flexibility to debug without allowing
full perl expressions.  Limiting the filters to regular expressions does
nothing to reduce the risk due to perl's string interpolation facilities.

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
