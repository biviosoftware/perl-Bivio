# Copyright (c) 2001-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::If;
use strict;
$Bivio::UI::Widget::If::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::If::VERSION;

=head1 NAME

Bivio::UI::Widget::If - simple binary conditional

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Widget::If;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget::ControlBase>

=cut

use Bivio::UI::Widget::ControlBase;
@Bivio::UI::Widget::If::ISA = ('Bivio::UI::Widget::ControlBase');

=head1 DESCRIPTION

C<Bivio::UI::Widget::If> is a simple "if" control.

=head1 ATTRIBUTES

=over 4

=item control : string []

=item control : Bivio::Agent::TaskId [] (get_request)

=item control : array_ref []

If string or task, will generate the appropriate control with
L<Bivio::Agent::Request::can_user_execute_task|Bivio::Agent::Request/"can_user_execute_task">.

=item control_off_value : any []

The value to use when I<control> returns false.  If not defined,
renders nothing.  May be a widget value, widget, etc.

=item control_on_value : any (required)

The value to use when I<control> returns true.  May be a widget value, widget,
etc.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Render I<control_on_value>.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $self->render_attr('control_on_value', $source, $buffer);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes children.

=cut

sub initialize {
    my($self) = shift;
    $self->initialize_attr('control_on_value');
    return $self->SUPER::initialize(@_);
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any args, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $control, $on, $off, $attributes) = @_;
    return '"control" attribute must be defined' unless defined($control);
    return '"on" attribute must be defined' unless defined($on);
    return {
	control => $control,
	control_on_value => $on,
	# Optional
	control_off_value => $off,
	($attributes ? %$attributes : ()),
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
