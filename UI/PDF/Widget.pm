# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::PDF::Widget;
use strict;
$Bivio::UI::PDF::Widget::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::PDF::Widget::VERSION;

=head1 NAME

Bivio::UI::PDF::Widget - PDF widget base class

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::PDF::Widget;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::PDF::Widget::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Widget>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 abstract render(any source, Bivio::UI::PDF pdf)

Draws value onto the PDF instance.

=cut

$_ = <<'}'; # for emacs
sub render {
}

=for html <a name="unsafe_find_box"></a>

=head2 unsafe_find_box() : Bivio::UI::PDF::Widget::Box

Looks through the widget's parent hierarchy for the first box widget.
Returns undef if not found.

=cut

sub unsafe_find_box {
    my($self) = @_;
    my($widget) = $self;

    while ($widget) {
        return $widget
            if UNIVERSAL::isa($widget, 'Bivio::UI::PDF::Widget::Box');
        $widget = $widget->unsafe_get('parent');
    }
    return undef;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
