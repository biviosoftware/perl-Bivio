# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Tag;
use strict;
$Bivio::UI::HTML::Widget::Tag::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Tag::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Tag - any html tag with class and/or id

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Tag;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::ControlBase>

=cut

use Bivio::UI::HTML::Widget::ControlBase;
@Bivio::UI::HTML::Widget::Tag::ISA = ('Bivio::UI::HTML::Widget::ControlBase');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Tag>

=cut

#=IMPORTS

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

=head1 METHODS

=cut

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Render the link.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($t) = lc(${$self->render_attr('tag')});
    $self->die('tag', $source, $t, ': is not a valid HTML tag')
	unless $t =~ /^[a-z]+\d*$/;
    $$buffer .= "<$t";
    $self->SUPER::control_on_render($source, $buffer);
    $$buffer .= '>';
    $self->render_attr('value', $source, $buffer);
    $$buffer .= "</$t>";
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initialize children.  Wraps value in String widget if not already a widget.

=cut

sub initialize {
    my($self) = @_;
    my($v) = $self->get('value');
    $self->put(value => $_VS->vs_new('String', $v, 0))
	unless UNIVERSAL::isa($v, 'Bivio::UI::Widget');
    $self->map_invoke(
	'unsafe_initialize_attr',
	[qw(tag value)],
    );
    return shift->SUPER::initialize(@_);
}

=for html <a name="internal_as_string"></a>

=head2 internal_as_string() : array

Returns this widget's config for
L<Bivio::UI::Widget::as_string|Bivio::UI::Widget/"as_string">.

=cut

sub internal_as_string {
    my($self) = @_;
    return $self->unsafe_get('tag', 'value');
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args() :  hash_ref

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    return shift->SUPER::internal_new_args([qw(tag value)], \@_);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
