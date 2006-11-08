# Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::ControlBase;
use strict;
$Bivio::UI::Widget::ControlBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::ControlBase::VERSION;

=head1 NAME

Bivio::UI::Widget::ControlBase - controls widget rendering with a control

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Widget::ControlBase;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Widget::ControlBase::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Widget::ControlBase> calls C<render> only if
the I<control> returns true.  Otherwise, calls C<control_off_render>.

=head1 ATTRIBUTES

=over 4

=item control : string []

=item control : Bivio::Agent::TaskId [] (get_request)

=item control : array_ref []

If string or task, will generate the appropriate control with
L<Bivio::Agent::Request::can_user_execute_task|Bivio::Agent::Request/"can_user_execute_task">.

If there is no control, always calls L<control_on_render|"control_on_render">.

=item control_off_value : any [value]

The value to use when I<control> returns false.  If not defined,
renders nothing.  May be a widget value, widget, etc.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="control_off_render"></a>

=head2 control_off_render(any source, string_ref buffer)

Renders the I<control_off_value>.  May be overridden.

=cut

sub control_off_render {
    my($self, $source, $buffer) = @_;
    $self->unsafe_render_attr(control_off_value => $source, $buffer);
    return;
}

=for html <a name="control_on_render"></a>

=head2 abstract control_on_render(any source, string_ref buffer)

Renders the on value.  Must be defined by subclass.

=cut

$_ = <<'}'; # emacs
sub control_on_render {
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes the control field

=cut

sub initialize {
    my($self) = @_;
    if (my $c = $self->unsafe_get('control')) {
	unless (ref($c)) {
	    if ($c =~ /^[a-z_0-9]{3,}$/
	        and Bivio::Agent::TaskId->is_valid_name(uc($c))
	    ) {
		Bivio::IO::Alert->warn_deprecated(
		    $c, ': change task name to upper case');
		$c = uc($c);
	    }
	    $c = Bivio::Agent::TaskId->from_name($c)
		if Bivio::Agent::TaskId->is_valid_name($c);
	}
	$self->put(
	    control => [['->get_request'], '->can_user_execute_task', $c],
	) if $self->is_blessed($c, 'Bivio::Agent::TaskId');
    }
    $self->map_invoke(
	unsafe_initialize_attr => [qw(control control_off_value)],
    );
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Calls L<control_on_render|"control_on_render"> if I<control> is true
or there is no control.

Else, calls L<control_off_render|"control_off_render">, which by
default renders nothing.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($c) = $self->unsafe_get('control');
    return !defined($c)
	|| ($c = $self->unsafe_resolve_widget_value($c, $source))
	&& (!$self->is_blessed($c, 'Bivio::UI::Widget')
        || $self->render_simple_value($c, $source))
	? $self->control_on_render($source, $buffer)
	: $self->control_off_render($source, $buffer);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
