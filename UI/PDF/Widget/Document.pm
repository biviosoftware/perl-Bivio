# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::PDF::Widget::Document;
use strict;
$Bivio::UI::PDF::Widget::Document::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::PDF::Widget::Document::VERSION;

=head1 NAME

Bivio::UI::PDF::Widget::Document - Top level PDF file widget

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::PDF::Widget::Document;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::PDF::Widget::Document::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Widget::Document>

=head1 ATTRIBUTES

=over 4

=item page_footer : Bivio::UI::PDF::Widget []

The page footer widget to render on each page.

=item page_header : Bivio::UI::PDF::Widget []

The page footer widget to render on each page.

=item page_size : string [A4]

The name of the page size. A0 - A6, B5, letter, legal, ledger, 11x17.

The PDF page size [width, height] in points. Defaults to A4.

=item sections : array_ref (required)

A collection of Bivio::UI::PDF::Widgets for the document contents.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::UI::PDF;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_PAGE_SIZE) = {
    A0 => [2380, 3368],
    A1 => [1684, 2380],
    A2 => [1190, 1684],
    A3 => [842, 1190],
    A4 => [595, 842],
    A5 => [421, 595],
    A6 => [297, 421],
    B5 => [501, 709],
    letter => [612, 792],
    legal => [612, 1008],
    ledger => [1224, 792],
    '11x17' => [792, 1224],
};
my($_MARGIN) = 20;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::PDF::Widget::Document

Creates a new document instance.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.

=cut

sub initialize {
    my($self) = @_;
    $self->put(page_size => 'A4')
        unless $self->unsafe_get('page_size');

    my($width, $height) = @{$_PAGE_SIZE->{$self->get('page_size')}};
    $self->put(location => [$_MARGIN, $_MARGIN]);
    $self->put(size => [$width - 2 * $_MARGIN, $height - 2 * $_MARGIN]);

    foreach my $section (@{$self->get('sections')}) {
        $self->initialize_value('section', $section);
    }
    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $sections, $attributes) = @_;
    return '"sections" attribute must be defined' unless defined($sections);
    return {
        sections => $sections,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="new_page"></a>

=head2 new_page(Bivio::UI::PDF pdf)

Starts a new PDF page.

=cut

sub new_page {
    my($self, $pdf) = @_;
    my($page_size) = $_PAGE_SIZE->{$self->get('page_size')};
    $pdf->begin_page(@$page_size);

#    $pdf->rect(@{$self->get('location')}, @{$self->get('size')});
#    $pdf->stroke;

#TODO: render page header and footer
    # set the text baseline to the top of the page
    my($location) = $self->get('location');
    $pdf->set_text_pos($location->[0], $page_size->[1] - $location->[1]);
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Creates the PDF instance and renders the sections on it. Outputs the
complete PDF file to the buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    $source->get_request->get('reply')->set_output_type('application/pdf');
    my($pdf) = Bivio::UI::PDF->new();
    $pdf->open_file('');

    # need to catch any exceptions because the PDF needs to get closed
    # properly, or pdflib will throw an exception during DESTROY
    my($die) = Bivio::Die->catch(sub {
        foreach my $section (@{$self->get('sections')}) {
            $self->new_page($pdf);
            $section->render($source, $pdf);
            $pdf->end_page;
        }
    });
    $pdf->close;
    $$buffer .= $pdf->get_buffer;
    $die->throw if $die;
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
