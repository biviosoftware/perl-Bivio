# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::ObjRef;
use strict;
$Bivio::UI::PDF::ObjRef::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::ObjRef - encapsulates a PDF object reference direct object.

=head1 SYNOPSIS

    use Bivio::UI::PDF::ObjRef;
    Bivio::UI::PDF::ObjRef->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::DirectObj>

=cut

use Bivio::UI::PDF::DirectObj;
@Bivio::UI::PDF::ObjRef::ISA = ('Bivio::UI::PDF::DirectObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::ObjRef>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::ObjRef



=cut

sub new {
    my($self) = Bivio::UI::PDF::DirectObj::new(@_);
    $self->{$_PACKAGE} = {
	'obj_number' => undef,
	'obj_generation' => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="clone"></a>

=head2 clone() : 



=cut

sub clone {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($clone) = Bivio::UI::PDF::ObjRef->new();
    my($clone_fields) = $clone->{$_PACKAGE};
    $clone_fields->{'obj_number'} = $fields->{'obj_number'};
    $clone_fields->{'obj_generation'} = $fields->{'obj_generation'};
    return($clone);
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
