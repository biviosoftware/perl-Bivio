# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::StandardSubmit;
use strict;
$Bivio::UI::HTML::Widget::StandardSubmit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::StandardSubmit - renders a submit button of a form

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::StandardSubmit;
    Bivio::UI::HTML::Widget::StandardSubmit->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget::Grid;
@Bivio::UI::HTML::Widget::StandardSubmit::ISA = ('Bivio::UI::HTML::Widget::Grid');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::StandardSubmit> draws a submit button.  The
font is always I<FORM_SUBMIT>.

If the form's L<SUBMIT_CANCEL|"SUBMIT_CANCEL"> returns an empty
string, the button won't be rendered.

=head1 ATTRIBUTES

=over 4

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item standard_submit_separation : int [10] (inherited);

How far apart should the buttons be.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::Widget::ClearDot;
use Bivio::UI::HTML::Widget::Submit;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::StandardSubmit

Creates a new StandardSubmit widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::Grid::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initialize grid.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{initialized};
    $fields->{initialized} = 1;

    my($row) = [
	Bivio::UI::HTML::Widget::Submit->new({
	    value => 'SUBMIT_OK',
	}),
    ];

    # Only include cancel and spacer if there is a cancel
    my($fc) = $self->ancestral_get('form_class');
    if ($fc->SUBMIT_CANCEL) {
	my($separation) = $self->ancestral_get(
		'standard_submit_separation', 10);
	push(@$row,
	    Bivio::UI::HTML::Widget::ClearDot->as_html($separation),
	    Bivio::UI::HTML::Widget::Submit->new({
		value => 'SUBMIT_CANCEL',
		attributes => 'onclick="reset()"',
	    }),
	);
    }

    # Initialize the grid
    $self->put(values => [$row]);
    $self->SUPER::initialize;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
