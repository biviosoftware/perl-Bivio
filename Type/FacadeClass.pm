# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FacadeClass;
use strict;
$Bivio::Type::FacadeClass::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::FacadeClass::VERSION;

=head1 NAME

Bivio::Type::FacadeClass - identifies valid facades

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::FacadeClass;

=cut

=head1 EXTENDS

L<Bivio::Type::Name>

=cut

use Bivio::Type::Name;
@Bivio::Type::FacadeClass::ISA = ('Bivio::Type::Name');

=head1 DESCRIPTION

C<Bivio::Type::FacadeClass> is used to check if a facade's simple class is a
valid.  See also
L<Bivio::Biz::Model::FacadeClassList|Bivio::Biz::Model::FacadeClassList>.

=cut

#=IMPORTS
use Bivio::UI::Facade;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

=cut

sub from_literal {
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless defined($v);
    return (undef, Bivio::TypeError->FACADE_CLASS)
	unless grep($_ eq $v, @{Bivio::UI::Facade->get_all_classes});
    return $v;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
