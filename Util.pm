# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Util;

use strict;

use HTML::Entities ();
use Carp ();
$^O !~ /win32/i && require 'syscall.ph';

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
	    1;
	' || die($@);
    }
    else {
        eval '
	    use URI::Escape ();
	    sub escape_html { &HTML::Entities::encode }
	    sub escape_uri { &URI::Escape::uri_escape }
	    sub unescape_uri { &URI::Escape::uri_unescape }
	    1;
	' || die($@);
    }
}

#TODO: Fix this HACK.  Probably need once a day time for events like this?
my($_THIS_YEAR) = (localtime)[5] + 1900;

sub unescape_html { &HTML::Entities::decode }

# gettimeofday -> [seconds, micros]
sub gettimeofday () {
    my($i) = '8..bytes';
    syscall(&SYS_gettimeofday, $i, 0);
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
    return eval $eval . '; 1' || croak("accessor compilation failed: $@");
}

=for html <a name="dump_stack"></a>

=head2 static dump_stack

Prints the current stack to STDERR

=cut

sub dump_stack {
    my($i) = 0;
    while (my($package, $file, $line) = caller($i++)) {
	print(STDERR $package.' '.$file.' '.$line."\n");
    }
}

# return an "@bivio.com" email address for the arg
sub email ($) {
    return shift() . '@bivio.com';
}

# href $link ; $label
#   If link is undef, then returns label.
sub href ($;$) {
    my($href, $label) = @_;
    defined($href) || return defined($label) ? &escape_html($label) : undef;
    defined($label) || ($label = $href);
    return &href_with_html_label($href, &escape_html($label));
}

# href_with_html_label $link $label
#   If link is undef, then returns label.  The label is in html and doesn't
#   need to be escaped.
sub href_with_html_label ($$) {
    my($href, $label) = @_;
    defined($href) || return defined($label) ? $label : undef;
    return '<a href="' . $href . '">' . $label . '</a>';
}

# mailto $email ; $label $subject
sub mailto_uri ($;$) {
    my($email, $subject) = @_;
    defined($email) || return undef;
    if (defined($subject)) {
	($subject = &escape_uri($subject)) =~
	    s/([&?])/$1 eq '&' ? '%26' : '%3f'/eg; 	  # easiest, but a hack
	$email .= '?subject=' . $subject;
    }
    return 'mailto:' . $email;
}

# mailto $email ; $label $subject
sub mailto ($;$$) {
    my($email, $label, $subject) = @_;
    defined($label) || ($label = $email);
    return &href(&mailto_uri($email, $subject), $label);
}

# Returns a stringified timestamp
sub timestamp ($) {
    my($time) = shift;
    defined($time) || ($time = time);
    my($sec, $min, $hour, $day, $mon, $year) = gmtime($time);
    return sprintf('%04d%02d%02d%02d%02d%02d', $year + 1900, $mon + 1, $day,
	   $hour, $min, $sec);
}

sub date ($) {
    my($time) = shift;
    defined($time) || return undef;
    unless ($time =~ /\D/) {
	my($day, $mon, $year) = (localtime($time))[3,4,5];
	$time = sprintf('%02d/%02d/%04d', $mon + 1, $day, $year + 1900);
    }
    $time =~ s/\D$_THIS_YEAR//;
    return $time;
}

sub date_range ($$) {
    my($left, $right) = (&date(shift), &date(shift));
    if (defined($left)) {
	defined($right) || ($right = '');
    }
    elsif (defined($right)) {
	$left = '';
    }
    else {
	return undef;
    }
    return $left . ' - ' . $right;
}


sub require {
    map {
	my($c) = $_;
	$c =~ s!::!/!g;
#TODO: Why doesn't perl let me use "use"?
	require $c . '.pm';
    } @_;
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
