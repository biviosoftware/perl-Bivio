# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ClearDot;
use strict;
$Bivio::UI::HTML::Widget::ClearDot::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::ClearDot - renders an in-line ClearDot

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ClearDot;
    Bivio::UI::HTML::Widget::ClearDot->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::ClearDot::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ClearDot> displays the clear dot

=head1 ATTRIBUTES

A widget value of zero (0) will result in nothing being rendered,
i.e. zero means "doesn't exist".

=over 4

=item height : int []

=item height : array_ref []

The (constant) height of the dot.

=item width : int []

=item width : array_ref []

The (constant) width of the dot.

=back

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::UI::Icon;
use Carp ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::ClearDot

Creates a new ClearDot widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="as_html"></a>

=head2 as_html() : string

=head2 static as_html(int width, int height) : string

Renders a clear dot and returns the string.  In the first case renders
this instance (must be initialized).  With arguments, renders a
constant string with the secified params.

=cut

sub as_html {
    my($self, $width, $height) = @_;
    if (@_ > 1) {
#TODO: optimize
	$self = __PACKAGE__->new({width => $width, height => $height});
	$self->initialize;
    }
    return $self->{$_PACKAGE}->{value};
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.  In this case, prefix, alt, and
src, and have_size.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{value});
    $fields->{value} = '<img src="'
	    .Bivio::Util::escape_html(Bivio::UI::Icon->get_clear_dot->{uri})
            .'" border=0';
    $fields->{is_constant} = 1;
    foreach my $f (qw(width height)) {
	my($fv) = $self->get_or_default($f, 0);
	if (ref($fv)) {
	    $fields->{is_constant} = 0;
	    $fields->{$f} = $fv;
	}
	elsif ($fv) {
	    $fields->{value} .= ' '.$f.'='.$fv;
	}
    }
    $fields->{value} .= '>' if $fields->{is_constant};
    return;
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Returns true if is a constant.

=cut

sub is_constant {
    my($fields) = shift->{$_PACKAGE};
    return $fields->{is_constant};
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the clear dot.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($start) = length($$buffer);
    $$buffer .= $fields->{value};
    return if $fields->{is_constant};

    foreach my $f (qw(width height)) {
	next unless ref($fields->{$f});
	my($v) = $source->get_widget_value(@{$fields->{$f}});
	unless ($v) {
	    # Zero width or height means that it shouldn't be drawn.
	    substr($$buffer, $start) = '';
	    return;
	}
	$$buffer .= ' '.$f.'='.$v;
    }
    $$buffer .= '>';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
