# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Text;
use strict;
$Bivio::UI::HTML::Widget::Text::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Text - draws a string with font decoration

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Text;
    Bivio::UI::HTML::Widget::Text->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Text::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Text>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Text

Creates a new Text widget.

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

Initializes static information.  In this case, prefix and suffix
field values.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{prefix};
    my($font_name, $font_size, $font_color, $font_style)
	    = $self->unsafe_get(
	    qw(font_name font_size font_color font_style));
    my($p, $s) = ('', '');
    if (defined($font_size) && $font_size !~ /^[-+]?\d+$/) {
	$p .= "<$font_size>";
	$s = "</$font_size>"; 
	# Already took care of font_size
	$font_size = undef;
    }
    if ($font_color || $font_name || defined($font_size)) {
	$p .= '<font';
	$p .= ' name="'.$font_name.'"' if $font_name;
	$p .= ' color="'.$font_color.'"' if $font_color;
	$p .= ' size="'.$font_size.'"' if defined($font_size);
	$p .= '>';
	$s = '</font>' . $s;
    }
    $p .= "<$font_style>", $s = "</$font_style>" if $font_style;
    $fields->{prefix} = $p;
    $fields->{suffix} = $s;
    $fields->{value} = $self->get('value');
    return;
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= $fields->{prefix}.$fields->{value}->as_string
	    .$fields->{suffix};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
