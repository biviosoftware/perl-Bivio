# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::DirectObj;
use strict;
$Bivio::UI::PDF::DirectObj::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::DirectObj - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::DirectObj;
    Bivio::UI::PDF::DirectObj->new();

=cut

use Bivio::UI::PDF::PdfObj;
@Bivio::UI::PDF::DirectObj::ISA = ('Bivio::UI::PDF::PdfObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::DirectObj>

=cut


=head1 CONSTANTS

=cut

=for html <a name="MAX_EMIT_LINE_LENGTH"></a>

=head2 MAX_EMIT_LINE_LENGTH : string



=cut

sub MAX_EMIT_LINE_LENGTH {
    return '79';
}

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_MAX_EMIT_LINE_LENGTH) = MAX_EMIT_LINE_LENGTH();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::DirectObj



=cut

sub new {
    my($self) = Bivio::UI::PDF::PdfObj::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="extract_obj"></a>

=head2 abstract extract_obj() : 



=cut

sub extract_obj {
    my($self, $line_array_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    die(__FILE__, ", ", __LINE__, ": Abstract object\n");
    return;
}

=for html <a name="get_max_line"></a>

=head2 get_max_line() : 



=cut

sub get_max_line {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($_MAX_EMIT_LINE_LENGTH);
}

=for html <a name="is_dictionary"></a>

=head2 is_dictionary() : 



=cut

sub is_dictionary {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(0);
}

=for html <a name="is_number"></a>

=head2 is_number() : 



=cut

sub is_number {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(0);
}

=for html <a name="is_stream"></a>

=head2 is_stream() : 



=cut

sub is_stream {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(0);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
