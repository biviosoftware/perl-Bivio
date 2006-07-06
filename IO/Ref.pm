# Copyright (c) 2001-2006 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::IO::Ref;
use strict;
$Bivio::IO::Ref::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::Ref::VERSION;

=head1 NAME

Bivio::IO::Ref - manipulate references

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::IO::Ref;

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::Ref::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::IO::Ref> manipulates references.

=cut

#=IMPORTS
use Data::Dumper ();
use Bivio::IO::Alert;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="nested_contains"></a>

=head2 nested_contains(any subset, any set) : string_ref

If all elements of I<subset> are contained in I<set>, returns undef.  If not,
returns the nested differences of the values.  Special cases are code references.
If I<subset> value is a code reference, will execute the code reference on the
value in I<set>, e.g.

    {                                {
        key1 => 1,		         key1 => 1,
        key2 => sub {		         key2 => val2
            my($val2) = @_;   },
            assert on $val2;
            return $val2;
        },
    },

For array refs, this works out to:

    [                                [
        1,                               1,
        sub {                            2,
            my($val, $index) = @_;   ],
            return 2;
        },
    ];

If I<subset> contains a scalar, and I<set> is a ref that matches the
scalar either by dereferencing or by calling to_string() or in the case of
enums get_name(), then the match is ok.

The purpose of contains is to find a general matching of values for unit
testing.  See Bivio::Test::Unit::assert_contains for details.

=cut

sub nested_contains {
    return _diff(@_);
}

=for html <a name="nested_differences"></a>

=head2 nested_differences(any left, any right) : string_ref

Returns differences between left and right.  If no differences, returns
undef.  Special cases for CODE on left and regexp on left. 

=cut

sub nested_differences {
    return _diff(@_);
}

=for html <a name="nested_equals"></a>

=head2 nested_equals(any left, any right) : boolean

Returns true if I<left> is structurally equal to I<right>, i.e. the contents of
all the data.

B<Does not handle cyclic data structures.>

=cut

sub nested_equals {
    my($proto, $left, $right) = @_;
    return 0 unless defined($left) eq defined($right);
    return 1 unless defined($left);

    # References must match exactly or we've got a problem
    return 0 unless ref($left) eq ref($right);

    # Scalar
    return $left eq $right ? 1 : 0 unless ref($left);

    if (ref($left) eq 'ARRAY') {
	return 0 unless int(@$left) == int(@$right);
	for (my($i) = 0; $i <= $#$left; $i++) {
	    return 0
		unless $proto->nested_equals($left->[$i], $right->[$i]);
	}
	return 1;
    }
    if (ref($left) eq 'HASH') {
	my(@l_keys) = sort(keys(%$left));
	my(@r_keys) = sort(keys(%$right));
	return 0
	    unless $proto->nested_equals(\@l_keys, \@r_keys);
	foreach my $k (@l_keys) {
	    return 0
		unless $proto->nested_equals($left->{$k}, $right->{$k});
	}
	return 1;
    }
    return $proto->nested_equals($$left, $$right)
	if ref($left) eq 'SCALAR';

    # blessed ref: Check if can equals and compare that way
    return $left->equals($right) ? 1 : 0
	if UNIVERSAL::can($left, 'equals');

    # CODE, GLOB, Regex, and blessed references should always be equal exactly
    return $left eq $right ? 1 : 0;
}

=for html <a name="to_scalar_ref"></a>

=head2 to_scalar_ref(string scalar) : scalar_ref

DEPRECATED: Use \('bla').

Returns its argument as a scalar_ref.

=cut

sub to_scalar_ref {
    my(undef, $scalar) = @_;
    return \$scalar;
}

=for html <a name="to_short_string"></a>

=head2 to_short_string(any value) : string

Returns a string summary of the ref.  Uses
L<Bivio::IO::Alert::format_args|Bivio::IO::Alert/"format_args">,
but doesn't include ending newline.

=cut

sub to_short_string {
    my(undef, $value) = @_;
    my($res) = Bivio::IO::Alert->format_args($value);
    chomp($res);
    return $res;
}

=for html <a name="to_string"></a>

=head2 static to_string(any ref, integer max_depth, integer indent) : string_ref

Converts I<ref> into a string_ref.  The string is formatted "tersely"
using C<Data::Dumper>.  I<max_depth> is passed to Data::Dumper::Maxdepth.
I<indent> is passed to Data::Dumper::Indent (defaults 1);

=cut

sub to_string {
    my(undef, $ref, $max_depth, $indent) = @_;
    my($dd) = Data::Dumper->new([$ref]);
    $dd->Deepcopy(1);
    $dd->Indent(defined($indent) ? $indent : 1);
    $dd->Maxdepth($max_depth || 0);
    $dd->Sortkeys(1)
	if $dd->can('Sortkeys');
    $dd->Terse(1);
    my($res) = $dd->Dumpxs();
    return \$res;
}

#=PRIVATE METHODS

sub _diff {
    my($proto, $left, $right) = @_;
    $_[3] ||= '';
    $_[4] ||= $proto->my_caller;
    return ref($left) eq ref($right) ? _diff_similar(@_) : _diff_eval(@_);
}

sub _diff_array {
    my($proto, $left, $right, $name, $method) = @_;
    my($res) = @$left == @$right ? undef : ${_diff_res(
	$proto, scalar(@$left), scalar(@$right), $name . '->scalar()')};
    for (my($i) = 0; $i <= ($#$left > $#$right ? $#$left : $#$right); $i++) {
	my($r) = $proto->$method($left->[$i], $right->[$i], $name . "->[$i]");
	$res .= ($res ? "\n" : '') . $$r
	    if $r;
    }
    return $res ? \$res : undef;
}

sub _diff_eval {
    my($proto, $left, $right, $name) = @_;
    return ref($left) eq 'CODE' && ($left = $left->($right)) eq $right
	|| ref($left) eq 'Regexp' && _diff_to_string($proto, $right) =~ $left
	|| defined($left) && !ref($left)
	    && $left eq _diff_to_string($proto, $right)
	? undef
	: _diff_res($proto, $left, $right, $name);
}

sub _diff_hash {
    my($proto, $left, $right, $name, $method) = @_;
    my($res);
    if ($method eq 'nested_differences') {
	my(@l_keys) = sort(keys(%$left));
	my(@r_keys) = sort(keys(%$right));
	my($res) = $proto->$method(\@l_keys, \@r_keys, $name . '->keys()');
	return $res
	    if $res;
    }
    foreach my $k (sort(keys(%$left))) {
	my($n) = $name . "->{'$k'}";
	my($r) = exists($right->{$k})
	    ? $proto->nested_contains($left->{$k}, $right->{$k}, $n)
	    : _diff_res($proto, $left->{$k}, "<key '$k' not found>", $n);
	$res .= ($res ? "\n" : '') . $$r
	    if $r;
    }
    return $res ? \$res : undef;
}

sub _diff_res {
    my($proto, $left, $right, $name) = @_;
    my($res) = $name && $name =~ /\S/ ? " at $name" : '';
    if ($left && $right && !ref($left) && !ref($right)
	&& $left =~ /\n/ && $right =~ /\n/
	&& $proto->use('Algorithm::Diff'),
    ) {
	my($diff) = Algorithm::Diff->new(
	    map([split(/(?<=\n)/, $_)], $left , $right),
	);
	$res = "*** EXPECTED$res\n--- ACTUAL\n";
	$diff->Base(1);
	while ($diff->Next) {
	    next if $diff->Same;
	    my($sep) = '';
	    $res .= sprintf(
		"*** %s ***\n",
		$diff->Items(2)
		? sprintf('%d,%dd%d', $diff->Get(qw(Min1 Max1 Max2)))
	        : $diff->Items(1) ? (
		    sprintf('%d,%dc%d,%d', $diff->Get(qw(Min1 Max1 Min2 Max2))),
		    $sep = "--\n",
		)[0] : sprintf('%da%d,%d', $diff->Get(qw(Max1 Min2 Max2))),
	    );
	    my($top, $bot) = map({
		my($s) = $_ ? '+' : '-';
		join('', map("$s $_", $diff->Items($_ + 1)));
	    } 0, 1);
	    $res .= $top . ($top && $bot ? $sep : '') . $bot;
	}
    }
    else {
        substr($res, 0, 0) = join(
	    ' != ',
	    map({
		my($v) = $proto->to_short_string($_);
		chomp($v);
		$v;
	    } $left, $right),
	);
    }
    return \$res;
}

sub _diff_similar {
    my($proto, $left, $right, $name, $method) = @_;
    return defined($left) ne defined($right)
	? _diff_res($proto, $left, $right, $name)
	: !defined($left)
	? undef
	: ref($left) eq 'ARRAY'
	? _diff_array($proto, $left, $right, $name, $method)
	: ref($left) eq 'HASH'
	? _diff_hash($proto, $left, $right, $name, $method)
        : ref($left) eq 'SCALAR'
	? $proto->$method($$left, $$right, $name . '->', $method)
	: UNIVERSAL::can($left, 'equals') && $left->equals($right)
	    || $left eq $right
	? undef
	: _diff_res($proto, $left, $right, $name);
}

sub _diff_to_string {
    my($proto, $s) = @_;
    return !ref($s) ? defined($s) ? $s : '<undef>'
	: ref($s) eq 'SCALAR' ? $$s
	: UNIVERSAL::can($s, 'as_xml') ? $s->as_xml
	: UNIVERSAL::can($s, 'as_string') ? $s->as_string
	: $proto->to_string($s, 0, 1);
}

=head1 COPYRIGHT

Copyright (c) 2001-2006 bivio Software, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
