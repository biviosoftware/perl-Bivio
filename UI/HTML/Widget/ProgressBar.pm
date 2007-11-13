# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ProgressBar;
use strict;
$Bivio::UI::HTML::Widget::ProgressBar::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::ProgressBar::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::ProgressBar - task progress indicator

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ProgressBar;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::ProgressBar::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ProgressBar>

=head1 ATTRIBUTES

=over 4

=item maximum_text : code_ref

The maximum value as text (ex. "50.0MB")

=item percent : code_ref

The current percent value.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_VS) = __PACKAGE__->use('UI.ViewShortcuts');
my($_RENDER_KEY) = __PACKAGE__ . 'rendered';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::ProgressBar

Creates a new ProgressBar widget.

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

Widget setup.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{grid};
    $fields->{grid} = $self->initialize_value('grid, ', $_VS->vs_new('Grid', [
        [$_VS->vs_new('Grid', [[
            $_VS->vs_new('Grid', [[
                $_VS->vs_new('ClearDot', {
                    height => '10',
                    cell_bgcolor => 'page_heading',
                    cell_width_as_html => [\&_get_cell_width, $self],
                }),
                $_VS->vs_new('ClearDot'),
            ]], {
                width => '200',
            }),
        ]], {
            border => 1,
        })],
        [$_VS->vs_new('String', $_VS->vs_new('Join', [
            [$self->get('percent')],
            '% of ',
            [$self->get('maximum_text')],
        ]))->put(cell_align => 'center')]
    ], {
        pad => 1,
    }));
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Renders the progress bar.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    return if $req->unsafe_get($_RENDER_KEY);
    $fields->{grid}->render($source, $buffer);
    $req->put($_RENDER_KEY => 1);
    return;
}

#=PRIVATE SUBROUTINES

# _get_cell_width(any source, self) : string
#
# Returns the HTML for the table cell width.
#
sub _get_cell_width {
    my($source, $self) = @_;
    # want min width to be 1, 0% isn't rendered correctly by mozilla
    return ' width="' . ($self->get('percent')->($source) || 1) . '%"';
}

=head1 COPYRIGHT

Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
