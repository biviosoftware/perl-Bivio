# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Comment;
use strict;
$Bivio::UI::PDF::Comment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Comment - encapsulates a PDF comment object.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Comment;
    Bivio::UI::PDF::Comment->new();

=cut

use Bivio::UI::PDF::PdfObj;
@Bivio::UI::PDF::Comment::ISA = ('Bivio::UI::PDF::PdfObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Comment>

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Comment



=cut

sub new {
    my($self) = Bivio::UI::PDF::PdfObj::new(@_);
    $self->{$_PACKAGE} = {
	'text_ref' => undef
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
    my($clone) = Bivio::UI::PDF::Comment->new();
    my($clone_fields) = $clone->{$_PACKAGE};
    $clone_fields->{'text_ref'} = $fields->{'text_ref'};
    return($clone);
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $emit_ref->append(${$fields->{'text_ref'}} . "\n");
    return;
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    _trace("Extracting comment \"${$line_iter_ref->current_ref()}\"")
	    if $_TRACE;

    $fields->{'text_ref'} = $line_iter_ref->current_ref();
    # Get rid of any leading white space.
    ${$fields->{'text_ref'}} =~ s/^\s+//;

    # Skip to the next line.
    $line_iter_ref->increment();

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
