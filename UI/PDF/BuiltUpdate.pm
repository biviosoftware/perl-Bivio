# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::BuiltUpdate;
use strict;
$Bivio::UI::PDF::BuiltUpdate::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::BuiltUpdate - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::BuiltUpdate;
    Bivio::UI::PDF::BuiltUpdate->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::ClearUpdate>

=cut

use Bivio::UI::PDF::ClearUpdate;
@Bivio::UI::PDF::BuiltUpdate::ISA = ('Bivio::UI::PDF::ClearUpdate');

=head1 DESCRIPTION

C<Bivio::UI::PDF::BuiltUpdate>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::BuiltUpdate



=cut

sub new {
    my($self) = Bivio::UI::PDF::ClearUpdate::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_body_obj"></a>

=head2 add_body_obj() : 



=cut

sub add_body_obj {
    my($self, $obj_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->get_body_ref()->add_obj($obj_ref);
    return;
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->get_body_ref()->emit($emit_ref);
    $self->_get_xref_ref()->emit($emit_ref);

    # We only know the offset of the start of the xref section after we have
    # emitted it.  Get it and put it in the trailer.
    my($offset_ref) = $emit_ref->get_xref_start();
    $self->_get_trailer_ref()->set_xref_offset($offset_ref);

    # Emit the trailer.
    $self->_get_trailer_ref()->emit($emit_ref);
    return;
}

=for html <a name="set_prev_offset"></a>

=head2 set_prev_offset() : 



=cut

sub set_prev_offset {
    my($self, $offset_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->_get_trailer_ref()->set_prev_offset($offset_ref);
    return;
}

=for html <a name="set_root_pointer"></a>

=head2 set_root_pointer() : 



=cut

sub set_root_pointer {
    my($self, $root_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->_get_trailer_ref()->set_root_pointer($root_ref);
    return;
}

=for html <a name="set_size"></a>

=head2 set_size() : 



=cut

sub set_size {
    my($self, $size_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
     $self->_get_trailer_ref()->set_size($size_ref);
   return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
