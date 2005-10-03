# Copyright (c) 1999-2003 bivio Inc.  All rights reserved.
# $Id$
package Bivio::IO::Config;
use strict;
$Bivio::IO::Config::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::Config::VERSION;

=head1 NAME

Bivio::IO::Config - simple configuration using perl syntax

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::IO::Config;

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::Config::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::IO::Config> is a simple configuration mechanism.  A configuration file
is a hash_ref of packages and hash_refs.  Each package's hash_ref contains
configuration name/value tuples.

Modules are dynamically configured in the order they are initialized.
Each module defines a C<handle_config> method and
calls L<register|"register"> during initialization.

This module parses I<@ARGV> at initialization time.  It removes any
arguments which are destined for this module.

Without an argument or with just I<@ARGV>, looks for the name of
a configuration file as follows:

=over 4

=item 1.

If running setuid or setgid, skip to step 3.

=item 2.

If the environment variable I<$BCONF> is defined,
identifies the name of the configuration file which
must contain a hash.

=item 3.

The file F</etc/bivio.bconf> must exist and contain a hash.

=back

If none of the files are found or they do not contain a hash, throws an
exception.

If I<argv> is supplied and not running setuid or setgid (but may be
running as root), extracts (i.e. deletes) arguments from the
I<argv> of the form:

    --(Module.)param=value

and sets configuration of the form:

    Module->{param} = value;

I<param> may be of the form I<idx1.idx2.idx3> which translates to:

    Module->{idx1}->{idx2}->{idx3} = value;

An error during evaluation causes program termination.  To set a
value to undef, use the word C<undef>.

Module defaults to C<main> if not supplied on the command line.

This modules observes the lone B<--> convention, i.e.
parsing stops if a B<--> is encountered in the command line arguments.

HACK: Since it is fairly common, the option I<--TRACE> is translated
to I<--Bivio::IO::Trace.package_filter> for brevity.

NOTE: I<Module> and I<param> must contain only word characters (except
for C<::> and C<.> separators) for this syntax to work.

If a valid configuration is found, calls packages which have
called L<register|"register">.

=head2 Bivio::IO::Config configuration

=over 4

=item bconf_file : string (not settable)

This value appears in the config for Bivio::IO::Config.  It is only visible
through tracing.

=item trace : boolean [0]

If true, every time the configuration changes, print all config to STDERR.  Of
note is Bivio::IO::Config.bconf_file, if you are trying to debug where your
configuration is coming from.  Here's how to pass it from the command line:

    my-program --Bivio::IO::Config.trace=1

May also be set in the config file itself.

=back

=head1 ENVIRONMENT

=over 4

=item $BCONF

Name of configuration file if not running setuid or setgid.

=back

=head1 FILES

=over 4

=item /etc/bivio.bconf

Name of configuration used if the program is running setuid or setgid
or the file identified by C<$BCONF> (or its default) is not found.

=back

=cut

=head1 CONSTANTS

=cut

=for html <a name="NAMED"></a>

=head2 NAMED : string

Identifies the named configuration specification, see L<register|"register">.

=cut

sub NAMED {
    return \&NAMED;
}

=for html <a name="REQUIRED"></a>

=head2 REQUIRED : string

Returns a unique value which passed in spec (see L<get|"get">)
will indicate the configuration parameter is required.

=cut

sub REQUIRED {
    return \&REQUIRED;
}

#=IMPORTS
# This is the first module to initialize.  Don't import anything that
# might import other bivio modules.
# use Bivio::BConf;
use File::Basename ();
use File::Spec ();
eval(q{
    use Image::Size ();
    use HTML::Parser ();
}) if $] > 5.008;

#=VARIABLES
my($_PKG) = __PACKAGE__;
my($_BCONF) = undef;
# The configuration read off disk or passed in
my($_ACTUAL) = {};
my($_COMMAND_LINE_ARGS) = [];
# List of packages registered
my(@_REGISTERED) = ();
# Configuration specifications for registered packages
my(%_SPEC) = ();
# Has a package been configured?
my(%_CONFIGURED) = ();
_initialize(defined(@main::ARGV) ? \@main::ARGV : []);

=head1 METHODS

=cut

=for html <a name="bconf_dir_hashes"></a>

=head2 bconf_dir_hashes() : array

Returns list of hashes from bconf dir in sorted order.

=cut

sub bconf_dir_hashes {
    my($proto) = @_;
    return map({
	my($file) = $_;
	my($data) = do($file) || die($@);
	die($file, ': did not return a hash_ref')
	    unless ref($data) eq 'HASH';
	$data;
    } sort(<@{[_bconf_dir($proto)]}/*.bconf>));
}

=for html <a name="bconf_file"></a>

=head2 static bconf_file() : string

Returns the bconf_file used by this module during initialization.
It is available during initialization, i.e., in the I<bconf_file> itself.

=cut

sub bconf_file {
    return $_BCONF;
}

=for html <a name="command_line_args"></a>

=head2 static command_line_args() : array_ref

Returns command line arguments, which were stripped from @ARGV

=cut

sub command_line_args {
    return [@$_COMMAND_LINE_ARGS];
}

=for html <a name="get"></a>

=head2 static get(string name) : hash

Looks up configuration for the caller's package.  If name is provided, returns
the configuration hash bound to I<name> within the package's configuration
space, e.g. given the config:

    'Bivio::IPC::Server' => {
        'listen' => 35,
        'my_server' => {
            'port' => 1234,
            'timeout' => 60_000,
        },
        'my_other_server' => {
            'port' => 9999,
        },
    }

C<get('my_server')> will return the following hash:

    {
        'listen' => 35,
        'port' => 1234,
        'timeout' => 60_000,
    }

Required configuration is checked during this call.

If I<name> is passed but is undefined, then only the named configuration
parameters will be returned.

If I<name> is not passed, then the entire configuration will be returned,
including specific named sections.

=cut

sub get {
    my($proto, $name) = @_;
    my($pkg);
    my($i) = 0;
    0 while ($pkg = caller($i++)) eq __PACKAGE__;
    my($pkg_cfg) = &_get_pkg($pkg);
    int(@_) < 2 && return $pkg_cfg;
    my($spec) = $_SPEC{$pkg};
    defined($spec) && defined($spec->{&NAMED})
	    || die("$pkg: NAMED config not specified");
    if (defined($name)) {
	defined($pkg_cfg->{$name})
		|| die("$pkg.$name: named config not found");
	return $pkg_cfg->{$name};
    }
    # Retrieve the "undef" config, see _get_pkg
    my($cfg) = $pkg_cfg->{&NAMED};
    my(@bad) = grep(defined($cfg->{$_}) && $cfg->{$_} eq &REQUIRED,
	    keys(%$cfg));
    @bad || return $cfg;
    @bad = sort @bad;
    die("$pkg.(@bad): named config required");
}

=for html <a name="handle_config"></a>

=head2 abstract callback handle_config(hash cfg)

This method is upcalled during the call to L<register|"register">.
It will be passed I<cfg> for the registrant.  The values parallel
the registered configuration.

=cut

$_ = <<'}'; # for emacs
sub handle_config {
}

=for html <a name="introduce_values"></a>

=head2 static introduce_values(hash_ref new_values)

Adds I<new_values> to the running programs configuration.  This routine should
be called sparingly.  There's no guarantee running programs can handle dynamic
reconfiguration.  L<handle_config|"handle_config"> will be called.

Typical usage:

    BEGIN {
        use Bivio::IO::Config;
        Bivio::IO::Config->introduce_values({
            value1 => ...,
        });
    }

The earlier in the program's initialization process this is executed, the less
likely it is to cause problems.

=cut

sub introduce_values {
    my($proto, $new_values) = @_;
#TODO: Named config defaults don't get filled in
    die('new_values must be a hash_ref') unless ref($new_values) eq 'HASH';
    $_ACTUAL = $proto->merge($new_values, $_ACTUAL);
    _actual_changed();
    return;
}

=for html <a name="merge"></a>

=head2 static merge(hash_ref custom, hash_ref defaults, boolean merge_arrays) : hash_ref

Creates a new hash_ref by copying I<custom> values int a I<default>
configuration.  Most applications have a common set of configuration which they
should define in a perl module.  Development, test, and production
configurations can then be customized more easily without having to edit lots
of files.

For example, your I<bconf> file might be defined as follows:

    #
    # My development configuration
    #
    use strict;
    use OurSite::BConf;
    OurSite::BConf->merge({
	'Bivio::UI::Facade' => {
	    http_suffix => 'myhost.oursite.com:8888',
	    mail_host => 'myhost.oursite.com',
	},
	'Bivio::UI::FacadeComponent' => {
	    die_on_error => 1,
	},
    });

The class I<OurSite::BConf> might contain the standard production
configuration, which will be overridden by the custom configuration above:

    sub merge {
        my($proto, $custom) = @_;
	return Bivio::IO::Config->merge($custom, {
	    'Bivio::UI::FacadeComponent' => {
		# Production systems don't die if can't find component values,
		# just return "undef" configuration.
		die_on_error => 0,
	    },
	    'Bivio::UI::Facade' => {
		http_suffix => 'www.oursite.com',
		mail_host => 'oursite.com',
	    },
	    'Bivio::Die' => {
		stack_trace_error => 1,
	    },
	    'Bivio::IO::ClassLoader' => {
		delegates => {
		    'Bivio::Agent::TaskId' => 'OurSite::Agent::TaskId',
		    'Bivio::Agent::HTTP::Cookie' => 'OurSite::Agent::Cookie',
		    'Bivio::UI::FacadeChildType' => 'OurSite::UI::FacadeChildType',
		    'Bivio::UI::HTML::FormErrors' => 'OurSite::UI::FormErrors',
		    'Bivio::TypeError' => 'OurSite::TypeError',
		},
		maps => {
		    Model => ['OurSite::Model', 'Bivio::Biz::Model'],
		    Type => ['OurSite::Type', 'Bivio::Type'],
		    HTMLWidget => ['Bivio::UI::HTML::Widget', 'Bivio::UI::Widget'],
		    HTMLFormat => ['Bivio::UI::HTML::Format'],
		    MailWidget => ['Bivio::UI::Mail::Widget', 'Bivio::UI::Widget'],
		    FacadeComponent => ['OurSite::UI', 'Bivio::UI'],
		    Facade => ['OurSite::UI::Facade'],
		    Action => ['OurSite::Action', 'Bivio::Biz::Action'],
		},
	    },
	});
    }

If I<merge_arrays> is true, then arrays in I<defaults> will be with
arrays in I<custom>.  Most commonly used for maps, e.g.,

    merge({
	maps => {
	    Model => ['OurSite:Model'],
	    },
	},
    }, {
	maps => {
	    Model => ['Bivio::Biz::Model'],
	    },
	},
    },
        1,
    );

yields:

    {
	maps => {
	    Model => ['OurSite:Model', 'Bivio::Biz::Model'],
        },
    };

=cut

sub merge {
    my($proto, $custom, $defaults, $merge_arrays) = @_;
    # Make a copy, so we don't modify original values in defaults
    my($result) = {%$defaults};
    while (my($key, $value) = each(%$custom)) {
	$result->{$key} = ref($result->{$key}) eq ref($value)
	    ? ref($value) eq 'HASH'
		? $proto->merge($value, $result->{$key}, $merge_arrays)
		: ref($value) eq 'ARRAY' && $merge_arrays
		    ? [@$value, @{$result->{$key}}]
		    : $value
	    : $value;
    }
    return $result;
}

=for html <a name="merge_list"></a>

=head2 merge_list(hash_ref custom, ..., hash_ref defaults) : hash_ref

Returns a merge by applying any number of I<custom> values to I<defaults>.
Calls L<merge|"merge"> from right to left.

=cut

sub merge_list {
    my($proto, @cfg) = @_;
    my($res) = {};
    foreach my $c (reverse(@cfg)) {
	$res = $proto->merge($c, $res);
    }
    return $res;
}


=for html <a name="register"></a>

=head2 register(hash spec)

Calling package will be put in the list of packages to be configured.  A
callback to L<handle_config|"handle_config"> will happen
during the call to this method.

The calling package must define a L<handle_config|"handle_config"> method which
takes two arguments, the class and the configuration as a hash.

If I<spec> is supplied, the values will be filled in when L<get|"get"> is
called or the values are upcalled to L<handle_config|"handle_config">.

A configuration I<spec> looks like:

    {
	'my_optional_param' => 35,
        'my_required_param' => Bivio::IO::Config->REQUIRED,
        Bivio::IO::Config->NAMED => {
            'my_named_optional_param' => 'hello',
            'my_named_required_param' => Bivio::IO::Config->REQUIRED,
        }
    }

Named configuration allows the package's configuration to be separately
named.  For example, you might have several named databases you want
to configure.  Named configuration is initialized from three locations:

=over 4

=item *

A specifically named configuration section, e.g. C<my_server>.

=item *

The parameters found in the (unnamed) common part of the configuration
using the names found in the L<NAMED|"NAMED"> part of the specification.

=item *

Lastly, the default values specified in the L<NAMED|"NAMED"> specification.

=back

All configuration names must be fully specified.

=cut

sub register {
    my($proto, $spec) = @_;
    my($pkg) = caller;
    defined(&{$pkg . '::handle_config'}) || die(
	    "&$pkg\::handle_config not defined");
    push(@_REGISTERED, $pkg);
    $_SPEC{$pkg} = $spec;
    &{\&{$pkg . '::handle_config'}}($pkg, _get_pkg($pkg));
    return;
}

#=PRIVATE METHODS

# _actual_changed()
#
# Call handlers and dump config, if debug option set.
#
sub _actual_changed {
    eval(q{
	use Data::Dumper;
	my($dd) = Data::Dumper->new([$_ACTUAL]);
	$dd->Indent(1);
	$dd->Terse(1);
	$dd->Deepcopy(1);
	print(STDERR "Configuration is: ", $dd->Dumpxs(), "\n");
    }) if $_ACTUAL->{$_PKG}->{trace};
    foreach my $pkg (@_REGISTERED) {
	&{\&{$pkg . '::handle_config'}}($pkg, _get_pkg($pkg));
    }
    return;
}

# _bconf_dir(proto) : string_ref
#
# Returns the bconf.d directory relative to the file that was loaded.
#
sub _bconf_dir {
    return File::Spec->catfile(
	File::Basename::dirname(shift->bconf_file), 'bconf.d');
}

# _get_pkg(string pkg) : hash_ref
#
# Returns the config for pkg
#
sub _get_pkg {
    my($pkg) = @_;
    $_CONFIGURED{$pkg} && return $_ACTUAL->{$pkg};
    my($actual) = ref($_ACTUAL->{$pkg}) ? $_ACTUAL->{$pkg} : {};
    if ($_SPEC{$pkg}) {
	# Set the defaults for the common configuration
	my($spec) = $_SPEC{$pkg};
	while (my($k, $v) = each(%$spec)) {
	    # If it is required, then it is an error
	    if (defined($v) && $v eq &REQUIRED) {
		defined($actual->{$k}) && next;
		die("$pkg.$k: config parameter not defined.");
	    }
	    # Have an actual value for specified config?
	    exists($actual->{$k}) && next;
	    # Is the named spec?
	    $k eq &NAMED && next;
	    # Assign the default value
	    $actual->{$k} = $v;
	}
	# Set the defaults for all named configuration
	if (defined($spec->{&NAMED})) {
	    my($named_spec) = $spec->{&NAMED};
	    # Fill in the actual for the "undef" case of &get
	    my($undef_cfg) = {%$named_spec};
	    while (my($k, $v) = each(%$actual)) {
		# Does a spec exist for this param?
		exists($spec->{$k}) && next;
		# Does a named spec exist for this param?
		if (exists($named_spec->{$k})) {
		    # Override named default with actual config
		    $undef_cfg->{$k} = $v;
		    next;
		}
		# Must be a named configuration section
		my($named_actual) = $v;
		ref($named_actual) || die("$pkg.$k: invalid config parameter");
		while (my($nk, $nv) = each(%$named_spec)) {
		    # If it is required, then must be defined (not just exists)
		    if (defined($nv) && $nv eq &REQUIRED) {
			# Defined in named section?
			defined($named_actual->{$nk}) && next;
			# Defined in common section?
			if (defined($actual->{$nk})) {
			    $named_actual->{$nk} = $actual->{$nk};
			    next;
			}
			die("$pkg.$nk: named config parameter not defined");
		    }
		    else {
			# Have an actual value for specified named config?
			exists($named_actual->{$nk}) && next;
		    }
		    # Have an actual value in the common area?
		    if (exists($actual->{$nk})) {
			$named_actual->{$nk} = $actual->{$nk};
			next;
		    }
		    # Assign the default value (not found in either section)
		    $named_actual->{$nk} = $nv;
		}
	    }
	    # Overload the use of "NAMED" to mean undef named cfg
	    # in actual configuration.
	    $actual->{&NAMED} = $undef_cfg;
	}
    }
    $_CONFIGURED{$pkg} = 1;
    return $_ACTUAL->{$pkg} = $actual;
}

# _initialize(array_ref argv)
#
# Initializes the configuration from I<config> hash.
#
sub _initialize {
    my($argv) = @_;
    %_CONFIGURED = ();
    # On failure, we have no configuration.
    $_ACTUAL = undef;
    my($is_setuid) = !($< == $> && $( == $));
    # If we are setuid or setgid, then don't _initialize from
    # environment variables or files in the current directory.
    # /etc/bivio.bconf is last resort if the file doesn't exist.
    $_BCONF = $ENV{BCONF};
    if ($is_setuid && defined($_BCONF)) {
	warn('Ignoring $BCONF while running setuid');
	$_BCONF = undef;
    }
    unless (defined($_BCONF) && -f $_BCONF && -r $_BCONF) {
	$_BCONF = '/etc/bivio.bconf'
	    if -r '/etc/bivio.bconf';
    }
    if (defined($_BCONF)) {
	$_BCONF = File::Spec->rel2abs($_BCONF);
	$_ACTUAL = do($_BCONF);
    }
    else {
	# If there's no configuration, this will be {} as init'd above
	# We don't do a eval with {}, because we want the use to happen
	# dynamically.
	eval('
	    use Bivio::BConf;
	    $_ACTUAL = Bivio::BConf->merge({});
	');
	$_BCONF = File::Spec->rel2abs($INC{'Bivio/BConf.pm'});
    }
    die("$_BCONF error: ", $@ || 'Must return hash ref')
	unless ref($_ACTUAL) eq 'HASH';
    ($_ACTUAL->{$_PKG} ||= {})->{bconf_file} = $_BCONF;
    # Only process arguments in not_setuid case
    _process_argv($_ACTUAL, $argv)
	unless $is_setuid;
    _actual_changed();
    return;
}

# _process_argv(hash_ref actual, array_ref argv)
#
# Inserts applicable command line arguments in $argv to $actual.
#
sub _process_argv {
    my($actual, $argv) = @_;
    for (my($i) = 0; $i < int(@$argv); $i++) {
	my($a) = $argv->[$i];
	# Lone '--' means we're done
	$a =~ /^--$/s && last;
	# HACK: Probably want to generalize(?)
	$a =~ s/^--TRACE=/--Bivio::IO::Trace.package_filter=/s;
	# Matches our form?
	(my($m, $p, $v) = $a =~ /^--([\w:]+)([\.\w]+)*=(.*)$/s) || next;
	# Need to default to package main?
	# (Convention: packages begin with upper-case letter)
	if ($m =~ /^[a-z0-9_]+$/ && $m ne 'main') {
	    $p = defined($p) ? ($m . $p) : $m;
	    $m = 'main';
	}
	else {
	    # Kill leading '.'
	    substr($p, 0, 1) = '';
	}
	$v eq 'undef' && ($v = undef);
	# Ensure the hashes exist down the chain, starting at the module ($m)
	# perl in Lispish
	my($ref, $car, $cdr) = ($actual, $m, $p);
	while (defined($cdr) && length($cdr)) {
	    exists($ref->{$car}) || ($ref->{$car} = {});
            $ref = $ref->{$car};
	    ($car, $cdr) = split(/\./, $cdr, 2);
	}
	$ref->{$car} = $v;
	# Get rid of processed parameter
	push(@$_COMMAND_LINE_ARGS, splice(@$argv, $i--, 1));
    }
}

=head1 COPYRIGHT

Copyright (c) 1999-2003 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
