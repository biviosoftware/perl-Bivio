# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::LineCell;
use strict;
$Bivio::UI::HTML::Widget::LineCell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::LineCell::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::LineCell - renders a double line cell

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::LineCell;
    Bivio::UI::HTML::Widget::LineCell->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::LineCell::ISA = qw(Bivio::UI::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::LineCell> draws a double line within
a table cell (C<TD> tag not rendered).

The color of the space between the lines is C<page_bg>.

=head1 ATTRIBUTES

=over 4

=item color : string [table_separator]

Color of the line(s).

=item count : int [1]

Number of lines.

=item height : int [1]

The height of a single line of the two lines and the space in between
in pixels.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::LineCell

Creates a new LineCell widget.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
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
    return if exists($fields->{value});
    my($h) = $self->get_or_default('height', 1);
    my($count) = $self->get_or_default('count', 1);
    my($line) = "<td class=\"line_cell\">".$_VS->vs_clear_dot_as_html(1, $h)."</td>";
    $fields->{value} = qq{<table width="100%" cellspacing="0"}
	. qq{ cellpadding="0" border="0">\n}
	. ((qq{<tr!COLOR!>$line</tr>\n<tr!PAGE_BG!>$line</tr>\n}) x --$count)
	. qq{<tr!COLOR!>$line</tr></table>};
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the object.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($value) = $fields->{value};

    my($req) = $source->get_request;
    my($c) = $self->get_or_default('color', 'table_separator');
    $c = $c ? Bivio::UI::Color->format_html($c, 'bgcolor', $req) : '';
    $value =~ s/!COLOR!/$c/g;

    $c = Bivio::UI::Color->format_html('page_bg', 'bgcolor', $req);
    $value =~ s/!PAGE_BG!/$c/g if $c;

    $$buffer .= $value;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
