# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::FirstParsedUpdate;
use strict;
$Bivio::UI::PDF::FirstParsedUpdate::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::FirstParsedUpdate - encapsulates a PDF parsed update that is
the first one in a PDF file.

=head1 SYNOPSIS

    use Bivio::UI::PDF::FirstParsedUpdate;
    Bivio::UI::PDF::FirstParsedUpdate->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::ParsedUpdate>

=cut

use Bivio::UI::PDF::ParsedUpdate;
@Bivio::UI::PDF::FirstParsedUpdate::ISA = ('Bivio::UI::PDF::ParsedUpdate');

=head1 DESCRIPTION

C<Bivio::UI::PDF::FirstParsedUpdate>

=cut

#=IMPORTS
use Bivio::UI::PDF::Header;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::FirstParsedUpdate



=cut

sub new {
    my($self) = Bivio::UI::PDF::ParsedUpdate::new(@_);
    $self->[$_IDI] = {
	'header_ref' => Bivio::UI::PDF::Header->new()
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{'header_ref'}->emit($emit_ref);
    $self->SUPER::emit($emit_ref);
    return;
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{'header_ref'}->extract($line_iter_ref);
    $self->SUPER::extract($line_iter_ref);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
