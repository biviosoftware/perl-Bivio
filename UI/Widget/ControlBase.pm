# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::ControlBase;
use strict;
$Bivio::UI::Widget::ControlBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::ControlBase::VERSION;

=head1 NAME

Bivio::UI::Widget::ControlBase - controls widget rendering with a control

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
renders nothing.

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Widget::ControlBase

Initializes fields.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="control_off_render"></a>

=head2 control_off_render(any source, string_ref buffer)

Renders the I<control_off_value>.  May be overridden.

=cut

sub control_off_render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{off_value}->render($source, $buffer)
	    if $fields->{off_value};
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
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{control};

    die('off_value deprecated, use control_off_value')
	    if $self->has_keys('off_value');

    $fields->{control} = $self->unsafe_get('control');
    $fields->{control} = [['->get_request'], '->can_user_execute_task',
	Bivio::Agent::TaskId->from_any($fields->{control})]
	    if $fields->{control} && ref($fields->{control}) ne 'ARRAY';
    $fields->{off_value} = $self->unsafe_get('control_off_value');
    if (ref($fields->{off_value})) {
	$fields->{off_value}->put(parent => $self);
	$fields->{off_value}->initialize;
    }
    elsif ($fields->{off_value}) {
	# Can't be "true"
	Bivio::Die->die($fields->{off_value}, ': invalid off value');
    }
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
    my($fields) = $self->{$_PACKAGE};
    return !$fields->{control}
	    || $source->get_widget_value(@{$fields->{control}})
		    ? $self->control_on_render($source, $buffer)
		    : $self->control_off_render($source, $buffer);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
