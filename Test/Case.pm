# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Case;
use strict;
$Bivio::Test::Case::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Case::VERSION;

=head1 NAME

Bivio::Test::Case - the execution context for a test case

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Case;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Test::Case::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Test::Case> provides the execution environment for at test case.

You may use the I<case> instance as a temporary storage location between
I<compute_params> and I<check_return> or I<check_die>.   To ensure your
attribute is unique and won't conflict with future attributes on
cases, begin the attribute with I<my_>, e.g. C<my_buf>.

=cut

#=IMPORTS
use Bivio::IO::Ref;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="actual_return"></a>

=head2 actual_return(array_ref return)

Sets the actual return value.  Need only be called from
I<check_return>.  Asserts that it is valid first.

=cut

sub actual_return {
    my($self, $return) = @_;
    Bivio::Die->die('Error in case ', $self,
	': actual_return must be an array_ref, not ', $return)
	unless ref($return) eq 'ARRAY';
    $self->put(return => $return);
    return;
}

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns the signature of the test.

=cut

sub as_string {
    my($self) = @_;
    return $self->SUPER::as_string
	unless ref($self);
    my($attr) = $self->internal_get;
    my($sig) = '';
    if ($attr->{object}) {
	my($s) = UNIVERSAL::can($attr->{object}, 'as_string')
	    && Bivio::Die->eval(sub {$attr->{object}->as_string})
	    || ref($attr->{object})
	    || $attr->{object} || '<Object>';
	$s =~ s/=\w+\(0x[a-z0-9]\)$//;
	$sig .= substr($s, 0, 100) . '#' . $attr->{object_num};
    }
    $sig .= '->'.($attr->{method} || '<method>').'#'.$attr->{method_num}
	if $attr->{method_num};
    $sig .= '(case#'.$attr->{case_num}
	.($attr->{params} ? '['.
	    Bivio::IO::Ref->to_short_string($attr->{params}).']' : '')
	.')'
	if $attr->{case_num};
    return $sig;
}

=for html <a name="expect"></a>

=head2 expect(any expect)

Sets I<expect> attribute for this case.  Asserts that it is valid first.
Probably only need to call from
L<Bivio::Test::compute_params|Bivio::Test/"compute_params">.

See L<Bivio::Test::check_return|Bivio::Test/"check_return"> and
L<Bivio::Test::check_die_code|Bivio::Test/"check_die_code">
for simpler ways to change I<expect>.

=cut

sub expect {
    my($self, $expect) = @_;
    $expect = [$expect] if defined($expect) && !ref($expect);
    Bivio::Die->die('Error in case ', $self,
	': expect must be undef, scalar, array_ref, CODE, Regexp or Bivio::DieCode, not ',
        $expect)
	unless !defined($expect) ||
	    (ref($expect) =~ /^(ARRAY|CODE|Regexp)$/
		|| UNIVERSAL::isa($expect, 'Bivio::DieCode'));
    $self->put(expect => $expect);
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
