# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::PDF::Widget::String;
use strict;
$Bivio::UI::PDF::Widget::String::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::PDF::Widget::String::VERSION;

=head1 NAME

Bivio::UI::PDF::Widget::String - text/font combination

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::PDF::Widget::String;

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Widget>

=cut

use Bivio::UI::PDF::Widget;
@Bivio::UI::PDF::Widget::String::ISA = ('Bivio::UI::PDF::Widget');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Widget::String>

=head1 ATTRIBUTES

=over 4

=item string_font : string [] (inherited, dynamic)

The font resource name.

=item value : string (required)

The string to render.

=item value : array_ref (required)

The widget value to render.

=item value : Bivio::UI::Widget (required)

The widget to render.

=back

=cut

#=IMPORTS
use Bivio::UI::PDFFont;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::PDF::Widget::String

Creates a new String widget with I<attributes>.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
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
    my($fields) = $self->[$_IDI];
    return if exists($fields->{box});
    $fields->{box} = $self->unsafe_find_box;
    $fields->{font} = $self->ancestral_get('string_font');
    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $value, $font, $attributes) = @_;
    return '"value" attribute must be defined' unless defined($value);
    return {
	value => $value,
	(defined($font) ? (string_font => $font) : ()),
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, Bivio::UI::PDF pdf)

Draws the text within the bounding box.

=cut

sub render {
    my($self, $source, $pdf) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;

    # lookup and set the font
    my($font) = ${$self->render_value('string_font',
        $fields->{font}, $source)};
    Bivio::UI::PDFFont->set_font($font, $req, $pdf);

    my($text) = ${$self->render_attr('value', $source)};
    unless ($self->get_render_mode($req)) {
        $self->save_text_width($req, $pdf, $text);
        return;
    }

    if ($fields->{box}) {
        $fields->{box}->render_in_box($text, $pdf);
        return;
    }

    # break on new lines
    my($first_line) = 1;
    foreach my $line (split("\n", $text)) {
        if ($first_line) {
            $pdf->show($line);
            $first_line = 0;
        }
        else {
            $pdf->continue_text($line);
        }
    }
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
