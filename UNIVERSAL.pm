# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UNIVERSAL;
use strict;
$Bivio::UNIVERSAL::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UNIVERSAL - base class for all bivio modules

=head1 SYNOPSIS

    use Bivio::UNIVERSAL;
    @ISA = qw(Bivio::Universal);

    my($PACKAGE) = __PACKAGE__;

    sub new {
	my($self) = &Bivio::UNIVERSAL::new(@_);
	$self->{$PACKAGE} = {'field1' => 'value1'};
	return $self;
    }

=cut

=head1 DESCRIPTION

C<Bivio::UNIVERSAL> is the base class for all bivio modules.  All of the
methods defined here may be overriden.

=cut

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::UNIVERSAL

Creates and blesses the object.

=cut

sub new {
    my($proto) = @_;
    my($self) = {};
    bless($self, ref($proto) || $proto);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="equals"></a>

=head2 equals(UNIVERSAL that) : boolean

Returns true if C<$self> is identical I<that>.

=cut

sub equals {
    my($self, $that) = @_;
    return $self == $that;
}

=for html <a name="to_string"></a>

=head2 to_string() : string

Returns the string form of C<$self>.  By default, this is just C<$self>.

=cut

sub to_string {
    my($self) = @_;
    # Ensure it is a string
    return $self;
}

#=PRIVATE METHODS

=head1 SEE ALSO

L<UNIVERSAL>

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
