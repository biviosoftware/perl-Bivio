# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::ClearUpdate;
use strict;
$Bivio::UI::PDF::ClearUpdate::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::ClearUpdate - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::ClearUpdate;
    Bivio::UI::PDF::ClearUpdate->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Update>

=cut

use Bivio::UI::PDF::Update;
@Bivio::UI::PDF::ClearUpdate::ISA = ('Bivio::UI::PDF::Update');

=head1 DESCRIPTION

C<Bivio::UI::PDF::ClearUpdate>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::ClearUpdate



=cut

sub new {
    my($self) = Bivio::UI::PDF::Update::new(@_);
    $self->{$_PACKAGE} = {
	'body_ref' => undef,
	'xref_ref' => undef,
	'trailer_ref' => undef
    };

    my($fields) = $self->{$_PACKAGE};
    my($xref_ref) = Bivio::UI::PDF::Xref->new();
    my($trailer_ref) = Bivio::UI::PDF::Trailer->new();

    $fields->{'body_ref'} = Bivio::UI::PDF::Body->new($xref_ref, $trailer_ref);
    $fields->{'xref_ref'} = $xref_ref;
    $fields->{'trailer_ref'} = $trailer_ref;

    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_body_ref"></a>

=head2 get_body_ref() : 



=cut

sub get_body_ref {
    my($self, $obj_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'body_ref'});
}

=for html <a name="get_prev_offset"></a>

=head2 get_prev_offset() : 



=cut

sub get_prev_offset {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'trailer_ref'}->get_prev_offset());
}

=for html <a name="get_root_pointer"></a>

=head2 get_root_pointer() : 



=cut

sub get_root_pointer {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'trailer_ref'}->get_root_pointer());
}

=for html <a name="get_size"></a>

=head2 get_size() : 



=cut

sub get_size {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'trailer_ref'}->get_size());
}

=for html <a name="get_xref_offset"></a>

=head2 get_xref_offset() : 



=cut

sub get_xref_offset {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'trailer_ref'}->get_xref_offset());
}

#=PRIVATE METHODS

# _get xref_ref() : 
#
#
#
sub _get_xref_ref {
    my($self, $obj_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'xref_ref'});
}

# _get_trailer_ref() : 
#
#
#
sub _get_trailer_ref {
    my($self, $obj_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'trailer_ref'});
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
