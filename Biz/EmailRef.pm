# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::EmailRef;
use strict;
$Bivio::Biz::EmailRef::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::EmailRef - An (email, name, subject) type

=head1 SYNOPSIS

    use Bivio::Biz::EmailRef;
    Bivio::Biz::EmailRef->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::CompoundField>

=cut

@Bivio::Biz::EmailRef::ISA = qw(Bivio::Biz::CompoundField);

=head1 DESCRIPTION

C<Bivio::Biz::EmailRef>

=cut

=head1 CONSTANTS

=cut

=for html <a name="ADDRESS"></a>

=head2 ADDRESS : int

The address index.

=cut

sub ADDRESS {
    return 0;
}

=for html <a name="TEXT"></a>

=head2 TEXT : int

The text index.

=cut

sub TEXT {
    return 1;
}

=for html <a name="SUBJECT"></a>

=head2 SUBJECT : int

The subject index.

=cut

sub SUBJECT {
    return 2;
}

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string address, string name, string subject) : Bivio::Biz::EmailRef

Creates an EmailRef for the specified address, name, and subject.

=cut

sub new {
    my($proto, $address, $name, $subject) = @_;
    my($self) = &Bivio::Biz::CompoundField::new(
	   [$address, $name, $subject], 3);
    return $self;
}

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
