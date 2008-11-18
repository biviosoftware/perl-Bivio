# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Case;
use strict;
use Bivio::Base 'Collection.Attributes';

# C<Bivio::Test::Case> provides the execution environment for at test case.
#
# You may use the I<case> instance as a temporary storage location between
# I<compute_params> and I<check_return> or I<check_die>.   To ensure your
# attribute is unique and won't conflict with future attributes on
# cases, begin the attribute with I<my_>, e.g. C<my_buf>.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('IO.Ref');

sub actual_return {
    # (self, array_ref) : undef
    # Sets the actual return value.  Need only be called from
    # I<check_return>.  Asserts that it is valid first.
    my($self, $return) = @_;
    Bivio::Die->die('Error in case ', $self,
	': actual_return must be an array_ref, not ', $return)
	unless ref($return) eq 'ARRAY';
    $self->put(return => $return);
    return;
}

sub as_string {
    # (self) : string
    # Returns the signature of the test.
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
	    $_R->to_short_string($attr->{params}).']' : '')
	.')'
	if $attr->{case_num};
    return $sig;
}

sub expect {
    # (self, any) : undef
    # Sets I<expect> attribute for this case.  Asserts that it is valid first.
    # Probably only need to call from
    # L<Bivio::Test::compute_params|Bivio::Test/"compute_params">.
    #
    # See L<Bivio::Test::check_return|Bivio::Test/"check_return"> and
    # L<Bivio::Test::check_die_code|Bivio::Test/"check_die_code">
    # for simpler ways to change I<expect>.
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

sub is_method {
    my($self, $method) = @_;
    return $self->get('method') eq $method ? 1 : 0;
}

1;
