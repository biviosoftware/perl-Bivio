# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::FindParams;
use strict;
$Bivio::Biz::FindParams::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::FindParams - Model lookup parameters.

=head1 SYNOPSIS

    use Bivio::Biz::FindParams;
    Bivio::Biz::FindParams->new();

=cut

@Bivio::Biz::FindParams::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::FindParams>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash map, int max) : Bivio::Biz::FindParams

Creates a new WhereClause with the specified field mapping and maximum
result size.

=cut

sub new {
    my($self, $map, $max) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	map => $map,
	max => $max
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_fields"></a>

=head2 get_fields() : array

Returns the field names of the mapping.

=cut

sub get_fields {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return keys(%{$fields->{map}});

}

=for html <a name="get_max_rows"></a>

=head2 get_max_rows() : int

Returns the maximum result size.

=cut

sub get_max_rows {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{max};
}

=for html <a name="get_value"></a>

=head2 get_value(string name) : string

Returns the value of the named field.

=cut

sub get_value {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{map}->{$name};
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
