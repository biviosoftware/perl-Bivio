# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::OpaqueUpdate;
use strict;
$Bivio::UI::PDF::OpaqueUpdate::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::OpaqueUpdate - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::OpaqueUpdate;
    Bivio::UI::PDF::OpaqueUpdate->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Update>

=cut

use Bivio::UI::PDF::Update;
@Bivio::UI::PDF::OpaqueUpdate::ISA = ('Bivio::UI::PDF::Update');

=head1 DESCRIPTION

C<Bivio::UI::PDF::OpaqueUpdate>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::OpaqueUpdate



=cut

sub new {
    my($self) = Bivio::UI::PDF::Update::new(@_);
    my(undef, $text_ref, $root_ref, $size_ref, $xref_ref) = @_;
    $self->{$_PACKAGE} = {
	'text_ref' => $text_ref,
	'root_ref' => $root_ref,
	'size_ref' => $size_ref,
	'xref_ref' => $xref_ref
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
    my($fields) = $self->{$_PACKAGE};
    $emit_ref->append($fields->{'text_ref'});
    return;
}

=for html <a name="get_root_pointer"></a>

=head2 get_root_pointer() : 



=cut

sub get_root_pointer {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'root_ref'});
}

=for html <a name="get_size"></a>

=head2 get_size() : 



=cut

sub get_size {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'size_ref'});
}

=for html <a name="get_xref_offset"></a>

=head2 get_xref_offset() : 



=cut

sub get_xref_offset {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'xref_ref'});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
