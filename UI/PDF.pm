
# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::PDF;
use strict;
$Bivio::UI::PDF::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::PDF::VERSION;

=head1 NAME

Bivio::UI::PDF - OO Wrapper for pdflib

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::PDF;

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF>

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::IO::Trace;
use pdflib_pl 4.0 ();
use vars ('$AUTOLOAD');

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF

Creates a new PDF maniuplator instance.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {
        pdf => pdflib_pl::PDF_new(),
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="AUTOLOAD"></a>

=head2 AUTOLOAD()

Handles method calls by invoking the related "pdflib_pl::PDF_" function.

=cut

sub AUTOLOAD {
    my($self, @args) = @_;
    # magic variable, created by perl
    my($method_name) = $AUTOLOAD =~ /([^:]+)$/;

    Bivio::Die->die($method_name, ' must be called on an instance')
        unless ref($self);

    _trace($method_name) if $_TRACE;
    my($fields) = $self->[$_IDI];
    my($method) = \&{'pdflib_pl::PDF_'.$method_name};
    return $method->($fields->{pdf}, @args);
}

=for html <a name="DESTROY"></a>

=head2 DESTROY()

Frees memory associated with the instance.

=cut

sub DESTROY {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    _trace("delete") if $_TRACE;
    pdflib_pl::PDF_delete($fields->{pdf});
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
