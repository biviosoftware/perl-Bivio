# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::CompoundField;
use strict;
$Bivio::Biz::CompoundField::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::CompoundField - A complex field.

=head1 SYNOPSIS

    use Bivio::Biz::CompoundField;
    Bivio::Biz::CompoundField->new();

=cut

@Bivio::Biz::CompoundField::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::CompoundField>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array values, int size) : Bivio::Biz::CompoundField

Creates a new CompoundField with the specified values.

=cut

sub new {
    my($proto, $values, $size) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	values => $values,
	size => $size
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_size"></a>

=head2 get_size() : int

Returns the number of elements.

=cut

sub get_size {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{size};
}

=for html <a name="get_value"></a>

=head2 get_value(int index) : scalar or CompoundField

Returns the scalar or CompoundField at the specified index.

=cut

sub get_value {
    my($self, $index) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{values}->[$index];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
