# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::TypeValue;
use strict;
$Bivio::TypeValue::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::TypeValue - binds a type and a value

=head1 SYNOPSIS

    use Bivio::TypeValue;
    my($tv) = Bivio::TypeValue->new($type, $ref);
    $tv->get('type');
    $tv->get('value');

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::TypeValue::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::TypeValue> binds a type and a value.  Convenient for parameter
passing.

=cut

#=IMPORTS
use Bivio::Type;
use Carp ();

#=VARIABLES


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Type type, any_ref value) : Bivio::TypeValue

Sets the I<type> and I<value> attributes.

=cut

sub new {
    my($proto, $type, $value) = @_;
    Carp::croak("$type: not a type")
		unless UNIVERSAL::isa($type, 'Bivio::Type');
    my($self) = &Bivio::Collection::Attributes::new($proto, {
	type => $type,
	value => $value,
    });
    return $self;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
