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

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns the signature of the test.

=cut

sub as_string {
    my($self) = @_;
    return $self->SUPER::as_string unless ref($self);
    my($attr) = $self->internal_get;
    my($sig) = '';
    $sig .= (ref($attr->{object}) || $attr->{object} || '<Object>')
	.'#'.$attr->{object_num}
	if $attr->{object};
    $sig .= '->'.($attr->{method} || '<method>').'#'.$attr->{method_num}
	if $attr->{method_num};
    $sig .= '(case#'.$attr->{case_num}
	.($attr->{params} ? '['._summarize($attr->{params}).']' : '')
	.')'
	if $attr->{case_num};
    return $sig;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
