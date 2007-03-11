# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EnumDelegator;
use strict;
$Bivio::Type::EnumDelegator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::EnumDelegator::VERSION;

=head1 NAME

Bivio::Type::EnumDelegator - delegate Enum and routines

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::EnumDelegator;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::EnumDelegator::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::EnumDelegator> allows you to delegate a
L<Bivio::Type::Enum|Bivio::Type::Enum> and any routines associated with
the enum.  Examples: L<Bivio::Type::ECService|Bivio::Type::ECService>.

=cut

#=IMPORTS

#=VARIABLES
use vars ('$AUTOLOAD');
my($_MAP) = {};

=head1 METHODS

=cut

=for html <a name="AUTOLOAD"></a>

=head2 AUTOLOAD()

Handles method calls by invoking the delegate. This is only called if the
subclass doesn't implement the method.

=cut

sub AUTOLOAD {
    my($proto) = @_;
    my($method) = $AUTOLOAD =~ /([^:]+)$/;
    return if $method eq 'DESTROY';
    my($c) = ref($proto) || $proto;

    # can() returns a reference to the method to invoke
    # use this so delegates can be subclassed
    $_MAP->{$c} ||= Bivio::IO::ClassLoader->delegate_require($c);
    my($dispatch) = $_MAP->{$c}->can($method);
    Bivio::Die->die('method not found: ', $c, '->', $method)
        unless $dispatch;
    return &$dispatch(@_);
}

=for html <a name="compile"></a>

=head2 static compile(array_ref values)

Compiles using delegate information.  May only be called statically.

=cut

sub compile {
    my($proto, $values) = @_;
    return $proto->SUPER::compile(
	$values || Bivio::IO::ClassLoader->delegate_require_info($proto),
    );
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
