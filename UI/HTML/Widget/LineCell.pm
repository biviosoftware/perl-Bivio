# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::LineCell;
use strict;
$Bivio::UI::HTML::Widget::LineCell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::LineCell - renders a double line cell

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::LineCell;
    Bivio::UI::HTML::Widget::LineCell->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::LineCell::ISA = qw(Bivio::UI::HTML::Widget);

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

=item height :  [1] 

The height of a single line of the two lines and the space in between
in pixels.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::LineCell

Creates a new LineCell widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
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
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{value});
    my($h) = $self->get_or_default('height', 1);
    my($count) = $self->get_or_default('count', 1);
    my($dot) = Bivio::UI::Icon->get_clear_dot->{uri};
    my($line) = "<td><img src=\"$dot\" height=$h width=1 border=0></td>";
    my($pc) = Bivio::UI::Color->as_html_bg('page_bg');
    $fields->{value} = "<table width=\"100%\" cellspacing=0"
	    . " cellpadding=0 border=0>\n"
	    . (("<tr!COLOR!>$line</tr>\n<tr$pc>$line</tr>\n") x --$count)
	    . "<tr!COLOR!>$line</tr></table>";
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the object.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($value) = $fields->{value};

    my($c) = $self->get_or_default('color', 'table_separator');
    if ($c) {
	$c = Bivio::UI::Color->as_html_bg($c);
	$value =~ s/!COLOR!/$c/g;
    }
    $$buffer .= $value;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
