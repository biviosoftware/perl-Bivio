# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Util;

use strict;

use HTML::Entities ();
use Carp ();
require 'syscall.ph';

BEGIN {
    # Create routines dynamically
    if (exists $ENV{MOD_PERL}) {
	eval '
	    # Use Apache::Util because it is faster
	    use Apache ();
	    use Apache::Util ();
	    sub escape_html { &Apache::Util::escape_html }
	    sub escape_uri { &Apache::Util::escape_uri }
	    sub unescape_uri { &Apache::unescape_url }
	';
    }
    else {
        eval '
	    use URI::Escape ();
	    sub escape_html { &HTML::Entities::encode }
	    sub escape_uri { &URI::Escape::uri_escape }
	    sub unescape_uri { &URI::Escape::uri_unescape }
	';
    }
}

sub unescape_html { &HTML::Entities::decode }

# gettimeofday -> [seconds, micros]
sub gettimeofday () {
    my($i) = '8..bytes';
    syscall(&SYS_gettimeofday, $i);
    return [unpack('ll', $i)];
}

# time_delta_in_seconds $start_time -> $seconds
#
#   Time $start_time was initiated (in seconds)
sub time_delta_in_seconds ($) {
    my($start_time) = shift;
    my($end_time) = &gettimeofday;
    return $end_time->[0] - $start_time->[0]
        + ($end_time->[1] - $start_time->[1]) / 1000000.0;
}

#
# compile_attribute_accessors \@attrs [@options] -> \@attr_names
#
sub compile_attribute_accessors ($@) {
    my($attrs) = shift;
    my($no_set, $no_undef) = (0, 0);
    my($option);
    foreach $option (@_) {
	$option =~ /^no_undef$/i && ($no_undef = 1, next);
	$option =~ /^no_set$/i && ($no_set = 1, next);
	&Carp::croak("$option: unknown characteristic for attribute");
    }
    $no_set && $no_undef
	&& Carp::croak('only one of no_undef & no_set may be used');
    my($pkg) = caller;
    my($name);
    my($eval) = "package $pkg; use Carp ();\n";
    foreach $name (@$attrs) {
	$name =~ /^\w+$/ || Carp::croak("$name: invalid attribute name");
	$eval .=  "sub $name {shift->{$name}}\n"; 			  # get
	unless ($no_set) {
	    $eval .= "sub set_$name {my(\$self, \$value) = \@_;\n"; 	  # set
	    $no_undef && ($eval .= 'defined($value) || &Carp::croak("set_'
			  . $name . ": value must be defined\");\n");
	    $eval .= "\$self->{$name} = \$value }";
	}
    }
    eval $eval . '; 1' || croak("accessor compilation failed: $@");
}

1;
__END__

=head1 NAME

Bivio::Util - Contains various utility routines

=head1 SYNOPSIS

    use Bivio::Util;

    &Bivio::Util::escape_uri("uri to escape");
    &Bivio::Util::unescape_uri("uri%20to%20escape");
    &Bivio::Util::escape_html("-> escape this & that");

=head1 DESCRIPTION

C<escape> routines hide interfaces to mod_perl(1).

C<compile_attribute_accessors> adds attribute subroutines to the calling
package.  The get accessor is the name of the attribute.  The set accessor is
the name of the attribute prefixed with C<set_> as follows:

    sub <attr_name> {
        shift->{<attr_name>}
    }
    sub set_<attr_name> {
        my($self) = shift;
	$self->{<attr_name>} = shift;
    }

The first argument to C<compile_attribute_accessors> is a list of attribute
names.  The second argument is an option: C<'no_undef'> or C<'no_set'> which
element specify the attribute may not be set to C<undef> or not set at all,
respectively.

=head1 EXAMPLES

The following example creates the following accessors: C<&name>,
C<&set_name>, C<&date>, and C<&set_date>:

    BEGIN {
        use Bivio::Util;
        &Bivio::Util::compile_attribute_accessors([qw(name date)]);
    }
   
The equivalent code would be:

    sub name ($) { shift->{name} }
    sub set_name ($) { my($self) = shift; $self->{shift} }
    sub date ($) { shift->{date} }
    sub set_date ($) { my($self) = shift; $self->{date} }

To make C<name> read-only, use:

    BEGIN {
        use Bivio::Util;
        &Bivio::Util::compile_attribute_accessors(['name'], 'no_set');
    }

This will create a get accessor, but not a C<&set_name>.

If attributes are not allowed to be undefined, use the following:

    BEGIN {
        use Bivio::Util;
        &Bivio::Util::compile_attribute_accessors(
	    [qw(name date)], 'no_undef');
    }

In this case, the set accessors will be defined, but if the caller passes in
C<undef>, croak will be called with an appropriate error message.

=head1 AUTHOR

Rob Nagler <nagler@bivio.com>

=head1 SEE ALSO

HTML::Entities(3), URI::Escape(3), Apache(3), Apache::Util(3),
mod_perl(1), Class::Struct(3)

=cut
