# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Math::EMA;
use strict;
$Bivio::Math::EMA::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Math::EMA::VERSION;

=head1 NAME

Bivio::Math::EMA - exponential moving average

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Math::EMA;

=cut

use Bivio::UNIVERSAL;
@Bivio::Math::EMA::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Math::EMA> is an exponential moving average.

=cut

#=IMPORTS
use Bivio::Type::Integer;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_LENGTH_RANGE) = Bivio::Type::Integer->new(
    1, Bivio::Type::Integer->get_max);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(int length) : Bivio::Math::EMA

Creates a moving average with I<length> iterations.

=cut

sub new {
    my($proto, $length) = @_;
    my($self) = Bivio::UNIVERSAL::new($proto);
    $length = $_LENGTH_RANGE->from_literal_or_die($length);
    $self->{$_PACKAGE} = {
	length => $length,
	alpha => 2.0 / ( $length + 1.0 ),
	average => undef,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="compute"></a>

=head2 compute(float value) : float

Adds I<value> to moving average and returns new average.

=cut

sub compute {
    my($self, $value) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{average} = $value unless defined($fields->{average});
    return $fields->{average}
	+= $fields->{alpha} * ($value - $fields->{average});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
