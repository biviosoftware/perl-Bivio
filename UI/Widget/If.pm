# Copyright (c) 2001 bivio Inc.  All rights reserved.
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
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array_ref control, any control_on_value, any control_off_value) : Bivio::UI::Widget::If

Creates with attributes I<control>, I<control_on_value>, and
I<control_off_value>.

=head2 static new(hash_ref attributes) : Bivio::UI::Widget::If

Creates with named attributes.

=cut

sub new {
    my($self) = Bivio::UI::Widget::ControlBase::new(_new_args(@_));
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Render I<control_on_value>.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->render_value('control_on_render', $fields->{on}, $source, $buffer);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes children.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{on});
    $fields->{on} = $self->initialize_attr('control_on_value');
    # ControlBase doesn't require control, but we do.  Result is stored
    # in ControlBase.
    $self->initialize_attr('control');
    return $self->SUPER::initialize();
}

#=PRIVATE METHODS

# _new_args(proto, any arg, ...) : array
#
# Returns arguments to be passed to Attributes::new.
#
sub _new_args {
    my($proto, $control, $on, $off) = @_;
    return ($proto, $control) if ref($control) eq 'HASH' || int(@_) == 1;
    return ($proto, {
	control => $control,
	control_on_value => $on,
	# Optional
	control_off_value => $off,
    }) if ref($control) eq 'ARRAY' && defined($on);
    $proto->die(undef, undef, 'invalid arguments to new');
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
