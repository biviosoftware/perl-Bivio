# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ClearDot;
use strict;
$Bivio::UI::HTML::Widget::ClearDot::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::ClearDot::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::ClearDot - renders an in-line ClearDot

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ClearDot;
    Bivio::UI::HTML::Widget::ClearDot->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::ClearDot::ISA = qw(Bivio::UI::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ClearDot> displays the clear dot

=head1 ATTRIBUTES

A widget value of zero (0) will result in nothing being rendered,
i.e. zero means "doesn't exist".

=over 4

=item align : string []

How to align the image.  The allowed (case
insensitive) values are defined in
L<Bivio::UI::Align|Bivio::UI::Align>.
The value affects the C<ALIGN> and C<VALIGN> attributes of the C<IMG> tag.

=item height : int [1]

=item height : array_ref []

The (constant) height of the dot.

=item width : int [1]

=item width : array_ref []

The (constant) width of the dot.

=back

=cut

#=IMPORTS
use Bivio::UI::Align;
use Bivio::UI::Icon;

#=VARIABLES

my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(any width, any height, hash_ref attributes) : Bivio::UI::HTML::Widget::ClearDot

Creates a new ClearDot widget with I<width> and I<height> attributes.

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::ClearDot

Creates a new ClearDot widget using I<attributes>.

=cut

sub new {
    my($proto, @args) = _new_args(@_);
    my($self) = $proto->SUPER::new(@args);
    $self->[$_IDI] = {};
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

Don't use in rendering code, because dynamically creates a ClearDot widget.
Instead create a ClearDot widget and have it do the dynamic rendering.

=cut

sub as_html {
    my($self, $width, $height) = @_;
    if (@_ > 1) {
#TODO: optimize
	$self = __PACKAGE__->new({width => $width, height => $height});
	$self->initialize;
    }
    elsif (!ref($self)) {
	die('must pass width and height if called statically');
    }
    return $self->[$_IDI]->{value};
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if exists($fields->{value});
    $fields->{value} = '<img src="'
	    .Bivio::UI::Icon->get_clear_dot->{uri}
            .'" border="0"'
	    .Bivio::UI::Align->as_html($self->unsafe_get('align'));

    $fields->{is_constant} = 1;
    foreach my $f (qw(width height)) {
	my($fv) = $self->get_or_default($f, 1);
	if (ref($fv)) {
	    $fields->{is_constant} = 0;
	    $fields->{$f} = $fv;
	}
	elsif ($fv) {
	    $fields->{value} .= qq{ $f="$fv"};
	}
    }
    $fields->{value} .= ' />' if $fields->{is_constant};
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the clear dot.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
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
	$$buffer .= qq{ $f="$v"};
    }
    $$buffer .= ' />';
    return;
}

#=PRIVATE METHODS

# _new_args(proto, any arg, ...) : array
#
# Returns arguments to be passed to Attributes::new.
#
sub _new_args {
    my($proto, $width, $height, $attributes) = @_;
    return ($proto, $width) if ref($width) eq 'HASH' || int(@_) == 1;
    return ($proto, {
	width => $width,
	height => $height,
	($attributes ? %$attributes : ()),
    }) if defined($width) || defined($height);
    $proto->die(undef, undef, 'invalid arguments to new');
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
