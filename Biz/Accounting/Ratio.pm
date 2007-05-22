# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Accounting::Ratio;
use strict;
$Bivio::Biz::Accounting::Ratio::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Accounting::Ratio - safe ratio multiplication

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Accounting::Ratio;
    Bivio::Biz::Accounting::Ratio->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Accounting::Ratio::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Accounting::Ratio> safe ratio multiplication

=cut

#=IMPORTS
use Bivio::Type::Amount;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_M) = 'Bivio::Type::Amount';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string numerator, string denominator) : Bivio::Biz::Accounting::Ratio

Creates the ratio with the specified numerator / denominator.

=cut

sub new {
    my($proto, $numerator, $denominator) = @_;
    my($self) = $proto->SUPER::new;

    # need to shift 1 decimal point to correctly round value
    # Bivio::Type::Amount truncates past precision

    $self->[$_IDI] = {
	numerator => $_M->mul($numerator, 10),
	denominator => $denominator,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns the string form "numerator / denominator".

=cut

sub as_string {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $_M->div($fields->{numerator}, 10).' / '.$fields->{denominator};
}

=for html <a name="multiply"></a>

=head2 multiply(string value) : string

Multiplies the specified value by the ratio, returning the result.

=cut

sub multiply {
    my($self, $value) = @_;
    my($fields) = $self->[$_IDI];

    # multiply and unshift
    my($result) = $_M->div(
	    $_M->mul($value, $fields->{numerator}),
	    $fields->{denominator});
    return $_M->div($_M->round($result, $_M->get_decimals - 1), 10);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
