# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Util;

use strict;

use HTML::Entities ();
use Carp ();
$^O !~ /win32/i && CORE::require 'syscall.ph';

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
my(%_PACKAGES);

# are_you_sure()
# are_you_sure(string prompt)
#
# Returns if user answers yes from STDIN.  Otherwise, dies with "Aborted".
sub are_you_sure {
    return unless -t STDIN;
    my($prompt) = @_;
    $prompt ||= 'Are you sure?';
    print STDERR $prompt, " (yes or no) ";
    my $answer = <STDIN>;
    $answer =~ s/\s+//g;
    die("Operation aborted\n") unless $answer eq 'yes';
    return;
}

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
    Carp::croak('invalid start_time') unless $start_time;
    my($end_time) = &gettimeofday;
    return $end_time->[0] - $start_time->[0]
        + ($end_time->[1] - $start_time->[1]) / 1000000.0;
}

# NOT USED
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

NOT USED

Prints the current stack to STDERR

=cut

sub dump_stack {
    my($i) = 0;
    while (my($package, $file, $line) = caller($i++)) {
	print(STDERR $package.' '.$file.' '.$line."\n");
    }
}

# NOT USED
# return an "@bivio.com" email address for the arg
sub email ($) {
    return shift() . '@bivio.com';
}

# NOT USED
# href $link ; $label
#   If link is undef, then returns label.
sub href ($;$) {
    my($href, $label) = @_;
    defined($href) || return defined($label) ? &escape_html($label) : undef;
    defined($label) || ($label = $href);
    return &href_with_html_label($href, &escape_html($label));
}

# NOT USED
# href_with_html_label $link $label
#   If link is undef, then returns label.  The label is in html and doesn't
#   need to be escaped.
sub href_with_html_label ($$) {
    my($href, $label) = @_;
    defined($href) || return defined($label) ? $label : undef;
    return '<a href="' . $href . '">' . $label . '</a>';
}

# NOT USED
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

# NOT USED
# mailto $email ; $label $subject
sub mailto ($;$$) {
    my($email, $label, $subject) = @_;
    defined($label) || ($label = $email);
    return &href(&mailto_uri($email, $subject), $label);
}

# BARELY
# Returns a stringified timestamp
sub timestamp ($) {
    my($time) = shift;
    defined($time) || ($time = time);
    my($sec, $min, $hour, $day, $mon, $year) = gmtime($time);
    return sprintf('%04d%02d%02d%02d%02d%02d', $year + 1900, $mon + 1, $day,
	   $hour, $min, $sec);
}

#NOT USED
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

#NOT USED
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


#other approach?
sub my_require {
    my(@pkg) = @_;
    my($pkg);
    foreach $pkg (@pkg) {
	die('undefined package') unless $pkg;
	no strict 'refs';

	# We use our own symbol table, because there is a weird case
	# with enums which define the package symbol table in advance
	# of loading. In other words, this doesn't work:
	#    next if defined(%{*{"$pkg\::"}});
	next if defined($_PACKAGES{$pkg});

	# Must be a "bareword" for it to do '::' substitution
	eval("require $pkg") || die($@);

	# Only define if loads properly.
	$_PACKAGES{$pkg} = 1;
    }
}

#DONE
sub bsearch_numeric {
    my($key, $array) = @_;
    my($upper) = $#$array;
    my($lower) = 0;
    my($middle);
    my($i);
    while ($lower <= $upper) {
	my($cmp) = $array->[$middle = int(($lower+$upper)/2)]
		<=> $key;
	if ($cmp > 0) {
	    $upper = $middle - 1;
	}
	elsif ($cmp < 0) {
	    $lower = $middle + 1;
	}
	else {
	    # Return success and exact match
	    return (1, $middle);
	}
    }
    # Return failure and "neighbor" match
    return (0, $middle);
}

#done ShellUtil
# shell(string command) : string_ref
# shell(string command, string input) : string_ref
# shell(string command, string_ref input) : string_ref
#
# Runs the command on the local host and returns the result.
# input may be undef.
sub shell {
    my($command, $input) = @_;
    my($in) = ref($input) ? $input : \$input;
    $$in = '' unless defined($$in);
    my($pid) = open(IN, "-|");
    defined($pid) || die("fork: $!");
    unless ($pid) {
	open(OUT, "| exec $command") || die("open $command: $!");
	print OUT $$in;
	close(OUT) || die("write to $command failed: $!");
	CORE::exit(0);
    }
    local($/) = undef;
    my($res) = <IN>;
    $res ||= '';
    close(IN) || die("$res\n$command failed: $!");
    return \$res;
}

# escape_query(string) : string
#
# Calls escape_uri then escapes '=' and '&'.
#
sub escape_query {
    # Calls passing on.
    my($v) = &escape_uri;
    $v =~ s/\=/%3D/g;
    $v =~ s/\&/%26/g;
    return $v;
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
