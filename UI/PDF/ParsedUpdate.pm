# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::ParsedUpdate;
use strict;
$Bivio::UI::PDF::ParsedUpdate::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::ParsedUpdate - a PDF update whose data comes from parsing some
PDF text.

=head1 SYNOPSIS

    use Bivio::UI::PDF::ParsedUpdate;
    Bivio::UI::PDF::ParsedUpdate->new();

=cut

use Bivio::UI::PDF::ClearUpdate;
@Bivio::UI::PDF::ParsedUpdate::ISA = ('Bivio::UI::PDF::ClearUpdate');

=head1 DESCRIPTION

C<Bivio::UI::PDF::ParsedUpdate>

=cut

#=IMPORTS
use Bivio::UI::PDF::Body;
use Bivio::UI::PDF::Trailer;
use Bivio::UI::PDF::Xref;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::ParsedUpdate



=cut

sub new {
    my($self) = Bivio::UI::PDF::ClearUpdate::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->get_body_ref()->emit($emit_ref);
    $self->_get_xref_ref()->emit($emit_ref);
    $self->_get_trailer_ref()->emit($emit_ref);
    return;
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->get_body_ref()->extract($line_iter_ref);
    $self->_get_xref_ref()->extract($line_iter_ref);
    $self->_get_trailer_ref()->extract($line_iter_ref);
    return;
}

=for html <a name="get_objects_array_ref"></a>

=head2 get_objects_array_ref() : 



=cut

sub get_objects_array_ref {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($self->get_body_ref()->get_objects_array_ref());
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
