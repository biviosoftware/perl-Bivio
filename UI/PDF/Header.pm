# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Header;
use strict;
$Bivio::UI::PDF::Header::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Header - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Header;
    Bivio::UI::PDF::Header->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Section>

=cut

use Bivio::UI::PDF::Section;
@Bivio::UI::PDF::Header::ISA = ('Bivio::UI::PDF::Section');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Header>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Header



=cut

sub new {
    my($self) = Bivio::UI::PDF::Section::new(@_);
    $self->{$_PACKAGE} = {
	'comment_ref' => undef
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
    $fields->{'comment_ref'}->emit($emit_ref);
    return;
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    # The header is supposed to be a comment.  It contains the Pdf
    # version to which the file conforms.
    $fields->{'comment_ref'} = Bivio::UI::PDF::Comment->new();
    $fields->{'comment_ref'}->extract($line_iter_ref);

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
